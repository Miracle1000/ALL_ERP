//binary.2014.03.10.解决已打开窗口再打开时不激活的问题;
if(!window.onwinfunExec) {
	window.onwinfunExec = window.open;
	window.open = function(var1, var2, var3, var4) {
		var hwnd = null;
		if(var2==undefined && var3==undefined && var4==undefined) { hwnd = window.onwinfunExec(var1);}
		else {
			if(var4==undefined) {hwnd = window.onwinfunExec(var1, var2, var3, var4);}
			else{hwnd = window.onwinfunExec(var1, var2, var3);}
		}
		if(var1!="") { try{hwnd.focus();}catch(e){} }
		return hwnd;
	}
}
window.onpageinit = function(){
	if ((top == window || (top.app && top.app.IeVer >= 100)) && uizoom != 1) {
		document.write("<style>body{position:relative;zoom:" + window.uizoom + "}</style>");
	}
	if(window.onCommPageInit){ window.onCommPageInit(); }
}
Array.prototype.indexOf = function(e){ 
	for(var i=0; i<this.length ; i++){ 
		if(this[i]==e){return i;} 
	} 
	return -1; 
}
function $ID(id){return document.getElementById(id);}
var $TOC=top.document;
var $PDC=parent.document;
var $DOE=document.documentElement;
var $DC=document;
function __firefox(){
	HTMLElement.prototype.__defineGetter__("runtimeStyle",__element_style);
	window.constructor.prototype.__defineGetter__("event",__window_event);
	Event.prototype.__defineGetter__("srcElement",__event_srcElement);
	Event.prototype.__defineGetter__("propertyName",function(){return "value"});
	Event.prototype.__defineGetter__("x",__event_x);
	Event.prototype.__defineGetter__("y",__event_y);
}
function __event_x(){return this.srcElement.getBoundingClientRect().left+document.documentElement.scrollLeft;}
function __event_y(){return this.srcElement.getBoundingClientRect().top+document.documentElement.scrollTop+10;}
function __element_style(){return this.style;}
function __window_event(){return __window_event_constructor();}
function __event_srcElement(){return this.target;}
function __window_event_constructor(){
	if(window.ActiveXObject){ return window.event; }
	var _caller=__window_event_constructor.caller;
	var xc = 1;
	while(_caller!=null && xc<200){
		var _argument=_caller.arguments[0];
		if(_argument){
			var _temp=_argument.constructor;
			if(_temp.toString().indexOf("Event")!=-1){
				return _argument;
			}
			if(xc>30) {
				//获取JQuery框架event对象
				if(_argument.target && _argument.target.tagName && _argument.timeStamp && _argument.type && _argument.type.length>0) {
					return {
						srcElement: _argument.target,
						type: _argument.type,
						isQueryEvent: 1
					};
				}
			}
		}
		_caller=_caller.caller;
		xc ++;
	}
	return null;
}
if(window.addEventListener&&HTMLElement.prototype.__defineGetter__){__firefox();}
String.prototype.trim=function(){return this.replace(/(^\s*)|(\s*$)/g,"");}
String.prototype.ltrim=function(){return this.replace(/(^\s*)/g,"");}
String.prototype.rtrim=function(){return this.replace(/(\s*$)/g,"");}
try
{if(!HTMLElement.prototype.swapNode)
{
	HTMLElement.prototype.swapNode = function (node2)
	{
		var node1 = this;
		var parent=node1.parentNode;
		var t1=node1.nextSibling;
		var t2 = node2.nextSibling;
		try {
			if (t1) parent.insertBefore(node2, t1);
			else parent.appendChild(node2);
			if (t2) parent.insertBefore(node1, t2);
			else parent.appendChild(node1);
		} catch (ex) { }
	}
}
}
catch (e){}
Date.prototype.DateAdd=function(strInterval,Number)
{var dtTmp=this;
switch(strInterval.toLowerCase())
{case 's':return new Date(Date.parse(dtTmp)+(1000 * Number));
case 'n':return new Date(Date.parse(dtTmp)+(60000 * Number));
case 'h':return new Date(Date.parse(dtTmp)+(3600000 * Number));
case 'd':return new Date(Date.parse(dtTmp)+(86400000 * Number));
case 'w':return new Date(Date.parse(dtTmp)+((86400000 * 7) * Number));
case 'q':return new Date(dtTmp.getFullYear(),(dtTmp.getMonth())+Number*3,dtTmp.getDate(),dtTmp.getHours(),dtTmp.getMinutes(),dtTmp.getSeconds());
case 'm':return new Date(dtTmp.getFullYear(),(dtTmp.getMonth())+Number,dtTmp.getDate(),dtTmp.getHours(),dtTmp.getMinutes(),dtTmp.getSeconds());
case 'y':return new Date((dtTmp.getFullYear()+Number),dtTmp.getMonth(),dtTmp.getDate(),dtTmp.getHours(),dtTmp.getMinutes(),dtTmp.getSeconds());}}
Date.prototype.DateDiff=function(strInterval,dtEnd)
{var dtStart=this;
if(typeof dtEnd=='string')
{dtEnd=StringToDate(dtEnd);}
switch(strInterval)
{case 's':return parseInt((dtEnd-dtStart) / 1000);
case 'n':return parseInt((dtEnd-dtStart) / 60000);
case 'h':return parseInt((dtEnd-dtStart) / 3600000);
case 'd':return parseInt((dtEnd-dtStart) / 86400000);
case 'w':return parseInt((dtEnd-dtStart) / (86400000 * 7));
case 'm':return (dtEnd.getMonth()+1)+((dtEnd.getFullYear()-dtStart.getFullYear())*12)-(dtStart.getMonth()+1);
case 'y':return dtEnd.getFullYear()-dtStart.getFullYear();}}
Date.prototype.toString=function(showWeek)
{var myDate=this;
var str=myDate.toLocaleDateString();
if(showWeek)
{var Week=['日','一','二','三','四','五','六'];
str +=' 星期'+Week[myDate.getDay()];}
return str;}
var app=new Object();
app.currWindow=window;
app.getIEVer=function(){var browser=navigator.appName
app.isArray = function(arr){ return Object.prototype.toString.call(arr) == "[object Array]";}
app.isObject = function(arr){ return Object.prototype.toString.call(arr) == "[object Object]";}
app.isString = function(arr){ return Object.prototype.toString.call(arr) == "[object String]";}
var b_version=navigator.appVersion
var version=b_version.split(";");
if(browser=="Microsoft Internet Explorer")
{var v=version[1].replace(/[ ]/g,"");
if(v=="MSIE9.0"){return 9;}
if(v=="MSIE8.0"){return 8;}
if(v=="MSIE7.0"){return 7;}
if(v=="MSIE6.0"){return 6;}
if(v=="MSIE5.0"){return 5;}
else{return 10}}
else
{return 100;}}
app.IeVer=app.getIEVer();
app.currdlgPos=10000;
app.bindEvent=function(obj,ename,func) { 
	if(obj.attachEvent){
		obj.attachEvent("on"+ename,func);
	}else{
		obj.addEventListener(ename,func);
	}
}
app.bindServerEvent=function(obj,ename,serverFun,asymode) {
	app.bindEvent(obj, ename, function(){
		ajax.regEvent("__sys_ajax_clientE_Fun");
		ajax.addParam("serverFun",serverFun);
		ajax.exec(asymode);
	})
}
app.createWindow=function(id,title,ico,left,top,width,height,style,shadow,bgcolor,position,keepPos)
{var win=app.currWindow;
var wCE=win.document.documentElement;
var wD=win.document;
var sw=wCE.offsetWidth;
if(!width||isNaN(width)){width=600;}
if(!height||isNaN(height)){height=350;}
if(height>700){height=700;}
if(!top||isNaN(top)){
	var tv = $DOE.scrollTop;
	top=(parseInt((706-height)/2)+(tv>0?tv:document.body.scrollTop));
}
if(!left||isNaN(left)){left=(parseInt((sw-width)/2)+$DOE.scrollLeft);}
if(!bgcolor){bgcolor="white";}
if(!keepPos){keepPos=0;}
var div=wD.getElementById("sys_comm_dlg_"+id);
if(!style||isNaN(style)){style=97;}
if(!div)
{if(ico.indexOf("/")<0){ico=window.sysskin+"/images/dlgIco/"+ico;}
div=wD.createElement("div");
div.id="sys_comm_dlg_"+id;
div.className="sysdlg";
div.innerHTML="<div style='position:absolute;top:10px;left:10px;height:"+(height-20)+"px;width:"+(width-20)+"px;'>"+(app.IeVer<7?"<iframe class='sys_dlgframe'></iframe><iframe class='sys_dlgframe2'></iframe>":"")+"<table class='sys_dtab1' cellspacing=0 cellpadding=0><tr><td class='sys_dtl' onclick='alert(this.offsetWidth)'></td><td class='sys_dtc'></td><td class='sys_dtr'></td></tr></table>"
+"<table class='sys_dtab2' cellspacing=0 cellpadding=0 bgcolor='"+bgcolor+"'><tr><td class='sys_dtooll'></td><td class='sys_dtoolc'>"
+"<table class='sys_dtit' onmousedown='app.beginMoveWindow(event,this,\""+id+"\");' cellspacing=0 cellpadding=0><tr><td  class='sys_dtit_ico'><img id='sys_comm_dlg_ico_"+id+"' onerror='app.showcommico(this)' src='"+ico+"'></td><td class='sys_dtit_txt'><span id='sys_comm_dlg_title_"+id+"'>"+title+"</span></td>"
+"<td class='sys_dtit_bar'><img "+(style%3==0?"style='display:none'":"")+" title='关闭' onclick='app.closeWindow(\""+id+"\")' src='"+win.sysskin+"/images/dlgIco/close_1.gif' onmouseout='app.imagechange(this,\"close_2.gif\",\"close_1.gif\")' onmouseover='app.imagechange(this,\"close_1.gif\",\"close_2.gif\")'></td></tr></table>"
+"</td><td class='sys_dtoolr'></td></tr></table>"
+"<table class='sys_dtab1' cellspacing=0 cellpadding=0 bgcolor='"+bgcolor+"' style='height:"+(height-8-29-10-20)+"px'>"
+"<tr><td class='sys_dcl'></td><td class='sys_dcc'><div id='sys_comm_dlg_body_"+id+"' style='height:"+(height-8-29-10-20-2)+"px;width:100%;overflow:auto;"+(position?"position:"+position+";":"") +"'></div></td><td class='sys_dcr'></td></tr></table>"
+"<table class='sys_dtab3' cellspacing=0 cellpadding=0 bgcolor='"+bgcolor+"'><tr><td class='sys_dbl1'></td><td class='sys_dbc1'></td><td class='sys_dbr1'></td></tr></table>"
+"<table class='sys_dtab3' cellspacing=0 cellpadding=0><tr><td class='sys_dbl2'></td><td class='sys_dbc2'></td><td class='sys_dbr2'></td></tr></table></div>"
+"<table class='sys_dbgtab"+((app.IeVer <7)?"6":"8")+"' cellspacing=0 cellpadding=0><tr><td class='sys_dbtl' style='height:20px'></td><td class='sys_dbtc'></td><td class='sys_dbtr'></td></tr>"
+"<tr><td class='sys_dbcl' style='height:"+(height-40)+"px'></td><td></td><td class='sys_dbcr'></td></tr><tr><td class='sys_dbbl'></td><td class='sys_dbbc'></td><td class='sys_dbbr'></td></tr></table>"
if(app.IeVer<=8){wD.body.appendChild(div);}
else{wCE.appendChild(div);}
keepPos=0;}
else{wD.getElementById('sys_comm_dlg_title_'+id).innerHTML=title;}
app.currdlgPos=app.currdlgPos+3;
div.style.zIndex=app.currdlgPos;
if(div.style.display !="block"){div.style.display="block";
keepPos=0;}
if(keepPos!=1)
{div.style.width=width+"px";
div.style.top=top+"px";
div.style.left=left+"px";
div.style.height=height+"px";}
if(shadow!=false){var bgdiv=wD.getElementById("sys_comm_dlg_body_shadow_"+id);
if(!bgdiv){bgdiv=wD.createElement("div");
bgdiv.className="ShaDiv";
bgdiv.id="sys_comm_dlg_body_shadow_"+id;
bgdiv.style.zIndex=app.currdlgPos-1;
if(app.IeVer<=8){wD.body.appendChild(bgdiv);}
else{wCE.appendChild(bgdiv);}
if(shadow>3)
{try{bgdiv.filters.item("alpha").Opacity=shadow;}catch(e){}}}
bgdiv.style.display="block";}
return wD.getElementById("sys_comm_dlg_body_"+id);}
app.playMedia=function(wUrl){if(app.IeVer<9)
{var sound=$TOC.getElementsByTagName("bgsound")[0];
if(!sound)
{sound=$TOC.createElement("bgsound");
$TOC.body.appendChild(sound);}
sound.src=wUrl;}
else{var sound=$TOC.getElementsByTagName("audio")[0];
if(!sound)
{sound=$TOC.createElement("audio");
sound.autoplay="autoplay";
$TOC.body.appendChild(sound);}
sound.src=wUrl;}}
app.msgbox=function(title,body,intro,atype,retFun,disshadow,buttons){if(!title||title==""){title="系统消息";}
try{
	var od = top.document.getElementById("sys_comm_dlg_appmsg");
	od.parentNode.removeChild(od);
	od =  top.document.getElementById("sys_comm_dlg_body_shadow_appmsg");
	od.parentNode.removeChild(od);
}catch(e){}
if(isNaN(atype)){atype=0;}
if(!buttons){buttons="确定";}
var c="";
switch(atype){case 0:c="msg";break;
case 1:c="alert";break;
case 2:c="error";break;
default:;}
var h = 200;
var w = 400;
if (body.length<15 && body.indexOf("<br>") == -1)
{
	h = 175;
	w = 360;
}
app.currWindow=window.top;
var div=app.createWindow("appmsg","<span style='font-size:12px;position:relative;left:-5px'>"+title+"</span>","s.gif","","",w,h,0,(disshadow==1)?false:true,"#f5f9fc");
div.innerHTML="<table style='table-layout:fixed;width:100%'><tr><td style='width:23%;text-align:center;padding-top:15px;' valign='top'><img src='"+app.currWindow.sysskin+"/images/dlg/"+(c.length>0?c:"")+".gif'></td>"
+"<td style='width:77%;text-align:left;padding-top:10px' valign='top'><div style='color:#000;text-align:left;'>"+body
+ ((intro&&intro.length>0)?"&nbsp;&nbsp;(<a href='javascript:void(0)' style='color:red' onclick='return app.swpVisible(\"msglistbody\")'>点击查看详情</a>)":"")+ "</div>"
+"<div><div id='msglistbody' style='border:1px dashed #c6c9ef;padding:5px;color:blue;background-color:white;width:240px;height:70px;overflow:auto;display:none'>"+intro+"</div></div></td></tr><tr>"
+ "<td></td></tr>"
+"</table><div align='center' style='_top:" + (h-112) + "px;position:absolute;bottom:0px;left:0px;right:0px;padding-bottom:20px;width:100%'><button class='button' style='width:50px' onclick='app.closeWindow(\"appmsg\")'>确定</button></div>";
app.currWindow=window;
var wUrl=c.length>0?app.currWindow.sysskin+"/images/media/"+c+".mp3":"";
if(wUrl.length>0){app.playMedia(wUrl);}}
app.showMsg=function(msg)
{msg=msg+"";if(msg.indexOf("<font")==-1){msg=msg.replace(/\n/g,"<br>");
msg=msg.replace(/\s/g,"&nbsp;");
msg=msg.replace(/\</g,"&#60;");
msg=msg.replace(/\</g,"&#62;");}
app.msgbox("消息",msg,"",0)}
app.showmsg=app.showMsg;
if(!app.Alert){
	app.Alert = function(msg, onlycreate){
		try{
			if(!top.app) { top.alert(msg); return; }
			if(top.location.href.toLowerCase().indexOf("init/home.ashx")>0) {
				var fms = top.document.getElementsByTagName("iframe")[0].contentWindow.document.getElementsByTagName("iframe");
				for (var ii = 0;  ii<fms.length ; ii++)
				{
					if(!fms[ii].contentWindow.app) {
						fms[ii].contentWindow.alert(msg);  return;
					}
				}
			}
		} catch(exx){}
		var ifm = document.getElementById("asasasasxx_alert");
		if(!ifm){
			ifm = document.createElement("iframe");
			ifm.src = "about:blank";
			ifm.id = "asasasasxx_alert";
			ifm.style.cssText = "position:absolute;top:-1px;left:-100px;width:1px;height:1px;";
			document.body.appendChild(ifm);
		}
		if(onlycreate==true) { return; }
		ifm.contentWindow.alert(msg);
	}
	if(navigator.userAgent.indexOf("Firefox")>0 && !window.ActiveXObject) {
		//setTimeout(function(){ app.Alert("",true); },1000);
	}
}
app.showerr=function(msg ,body)
{msg=msg+"";
if(msg.indexOf("<font")==-1){msg=msg.replace(/\n/g,"<br>");
msg=msg.replace(/\s/g,"&nbsp;");
msg=msg.replace(/\</g,"&#60;");
msg=msg.replace(/\</g,"&#62;");}
app.msgbox("请注意",msg,body ,2)}
app.showerror=app.showerr;
app.beginMoveWindow=function(ev ,scobj,id)
{var div=app.currWindow.document.getElementById("sys_comm_dlg_"+id);
if(div)
{if(scobj){scobj.style.cursor="move";}
if(app.IeVer<100)
{scobj.setCapture();
div.mv_x=div.offsetLeft;
div.mv_y=div.offsetTop;
div.preX=null;
div.dtTop=null;
scobj.onmousemove=function(){if(!div.preX){div.preX=window.event.screenX
div.preY=window.event.screenY
div.dtTop=window.event.clientY-div.offsetTop;}
else{x0=div.preX-window.event.screenX
y0=div.preY-window.event.screenY
div.style.left=(div.offsetLeft-x0)+"px";
if(div.offsetTop-y0<0)
{div.style.top="0px";}
else{div.style.top=(div.offsetTop-y0)+"px";}
div.preX=window.event.screenX
div.preY=window.event.screenY}}
scobj.onmouseup=function(){div.preX=null;
scobj.onmousemove=function(){}
scobj.releaseCapture();
scobj.style.cursor="default";}}
else{app.currWindow.document.captureEvents(Event.MOUSEMOVE);
div.mv_x=div.offsetLeft;
div.mv_y=div.offsetTop;
div.preX=null;
div.dtTop=null;
var doc=app.currWindow.document;
doc.oldmouseove=doc.onmousemove;
doc.oldmouseup=doc.onmouseup;
doc.oldselectstart=doc.onselectstart;
doc.onmousemove=function(){if(!div.preX)
{div.preX=window.event.screenX
div.preY=window.event.screenY
div.dtTop=window.event.clientY-div.offsetTop;}
else{x0=div.preX-window.event.screenX
y0=div.preY-window.event.screenY
div.style.left=(div.offsetLeft-x0)+"px";
if(div.offsetTop-y0<0)
{div.style.top="0px";}
else{div.style.top=(div.offsetTop-y0)+"px";}
div.preX=window.event.screenX
div.preY=window.event.screenY}}
doc.onmouseup=function(){div.preX=null;
scobj.style.cursor="default";
doc.onmousemove=doc.oldmouseove;
doc.onmouseup=doc.oldmouseup;
if(doc.releaseCapture){doc.releaseCapture();}}
doc.onmouseout=function(){if(window.event.clientY<=0)
{doc.onmouseup();}}}}}
app.beginMoveElement = function(eventObj, moveEvent, endEvent) {
	if (app.IeVer < 100) {
		window.__mv_oldscmv = eventObj.onmousemove;
		window.__mv_oldscmu = eventObj.onmouseup;
		eventObj.setCapture();
		eventObj.onmousemove = moveEvent;
		eventObj.onmouseup = function() { 
			eventObj.releaseCapture(); 
			endEvent();
			eventObj.onmousemove = window.__mv_oldscmv;
			eventObj.onmouseup = window.__mv_oldscmu;
		}
	} else {
		app.currWindow.captureEvents(Event.MOUSEMOVE);
		var doc = app.currWindow.document;
		doc.oldmouseove = doc.onmousemove;
		doc.oldmouseup = doc.onmouseup;
		doc.oldselectstart = doc.onselectstart;
		doc.onmousemove = moveEvent;
		doc.onmouseup = function() { 
			window.releaseEvents();endEvent();
			if(doc.oldmouseove) { doc.onmousemove = doc.oldmouseove; }
			if(doc.oldmouseup) { doc.onmouseup = doc.oldmouseup; }
			if(doc.oldselectstart) { doc.onselectstart = doc.oldselectstart; }
		}
		doc.onmouseout = function() { if (window.event.clientY <= 0) { doc.onmouseup();} }
	}
}
app.closeWindow=function(id)
{var div=app.currWindow.document.getElementById("sys_comm_dlg_"+id);
var bgdiv=app.currWindow.document.getElementById("sys_comm_dlg_body_shadow_"+id);
if(div){div.style.display="none";
if(bgdiv){bgdiv.style.display="none";}}}
app.PageOpen=function(url,mWidth,mHeight,wName){var w=860 ,h=640;
if(mWidth){w=mWidth;}
if(mHeight){h=mHeight;}
var l=(screen.availWidth-w) / 2
var t=(screen.availHeight-h) / 2
var opener1,opener2;
if(wName&&wName.length>0)
{opener2=window.open(url ,wName,"height="+h+",width="+w+",left="+l+",top="+t+",z-look=yes,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes");}
else
{opener1=window.open(url,"_blank","height="+h+",width="+w+",left="+l+",top="+t+",z-look=yes,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes");}
return wName?opener2:opener1;}
app.getParent=function(obj,parentIndex){for(var i=0;i< parentIndex;i++)
{if(obj){obj=obj.parentNode;}else{return obj;}}
return obj;}
app.showcommico=function(img){if(!img.errored){img.errored=true
img.src=window.sysskin+"/images/dlgIco/commico.gif"}}
app.imagechange=function(img ,imgold ,imgnew)
{img.src=img.src.replace(imgold,imgnew);	}
app.fireChange=function(obj) {
	if(obj.fireEvent) { obj.fireEvent("onchange");  }
	else { 
		var evt = document.createEvent('HTMLEvents');  
		evt.initEvent('change',true,true);  
		obj.dispatchEvent(evt);  
	}
}
app.fireEvent=function(obj ,eventName)
{if($DC.all){obj.fireEvent(eventName);}
else{var evt=window.document.createEvent("MouseEvents");
evt.initEvent(eventName.replace("on",""),true,true);
obj.dispatchEvent(evt);}}
app.dlg=new Object();
app.dlg.showgates=function(title,selgate ,allgate)
{if(typeof(__dlg_showGate)=="undefined"){alert("缺少文件支持，请引用文件【commdlg.js】");
return;}
__dlg_showGate(title,selgate ,allgate);}
window.__sys_ajax_form_result_handle = function(fram, backfun) {
	var win = fram.contentWindow;
	return function() {
		var html = win.document.body.innerHTML;
		html = html.replace("<!--__formproxy.init\r\n","")
		html = html.replace("<!--__formproxy.init\r","")
		html = html.replace("<!--__formproxy.init\n","")
		html = html.replace("\r\n__formproxy.end-->","")
		html = html.replace("\n__formproxy.end-->","")
		html = html.replace("\r__formproxy.end-->","")
		backfun(html);
		var div = fram.parentNode;
		document.body.removeChild(div);
	}
}
String.prototype.replaceAll = function(s1,s2){return this.replace(new RegExp(s1,"gm"),s2);}
function xmlHttp(){var base=new Object()
base.sendText="";
base.tempurl="";
base.ascCodev="& ﹙ ﹚ ﹛ ﹜ ＋ － × ÷ ﹢ ﹣ ≠ ≤ ≥ ≈ ≡ ≒ ∥ ／ ± ＜ ＞ ﹤ ﹥ ≦ ＝ ≧ ≌ ∽ ≮ ≯ ∶ ∴ ∵ ∷ ⊙ ∑ ∏ ∪ ∩ ∈ ⌒ ⊥ ∠ ㏑ ￠ ㏒ ∟ √ ∨ ∧ ∞ ∝ ∮ ∫ ％ ‰ ℅ ° ℃ ℉ ′ ″ 〒 ¤ ○ ￡ ￥ ㏕ ♂ ♀ △ ▽ ● ○ ◇ □ ·".split(" ");
base.ascCodec="%26+%A9v+%A9w+%A9x+%A9y+%A3%AB+%A3%AD+%A1%C1+%A1%C2+%A9%80+%A9%81+%A1%D9+%A1%DC+%A1%DD+%A1%D6+%A1%D4+%A8P+%A1%CE+%A3%AF+%A1%C0+%A3%BC+%A3%BE+%A9%82+%A9%83+%A8Q+%A3%BD+%A8R+%A1%D5+%A1%D7+%A1%DA+%A1%DB+%A1%C3+%A1%E0+%A1%DF+%A1%CB+%A1%D1+%A1%C6+%A1%C7+%A1%C8+%A1%C9+%A1%CA+%A1%D0+%A1%CD+%A1%CF+%A9R+%A1%E9+%A9S+%A8N+%A1%CC+%A1%C5+%A1%C4+%A1%DE+%A1%D8+%A1%D3+%A1%D2+%A3%A5+%A1%EB+%A8G+%A1%E3+%A1%E6+%A8H+%A1%E4+%A1%E5+%A8%93+%A1%E8+%A1%F0+%A1%EA+%A3%A4+%A9T+%A1%E1+%A1%E2+%A1%F7+%A8%8C+%A1%F1+%A1%F0+%A1%F3+%A1%F5+%A1%A4".split("+");
base.UrlEncode=function (data){
data=data.toString().replace(/\r/g,"xglllrtfgherwerrg").replace(/\n/g,"xerttfghertdfssy").replace(/\s/g,"kglllskjdfsfdsdwerr");
if(!isNaN(data)||!data){return data;}
for(var i=0;i<base.ascCodev.length;i++){var re=new RegExp(base.ascCodev[i],"g")
data=data.replace(re,"ajaxsrpchari"+i);
re=null;}
data=escape(data);
for(var i=base.ascCodev.length-1;i>-1;i--){var re=new RegExp("ajaxsrpchari"+i,"g")
data=data.replace(re,base.ascCodec[i]);}
data=data.replace(/\+/g,"%2B")
data=data.replace(/kglllskjdfsfdsdwerr/g,"%20").replace(/xglllrtfgherwerrg/g,"%0D").replace(/xerttfghertdfssy/g,"%0A");
return data;}
base.defUrl=function(){return ("/"+window.location.pathname).replaceAll("//","/")}
base.url=base.defUrl();
base.getHttp=function(){var MSXML=['Msxml2.XMLHTTP',
'Microsoft.XMLHTTP',
'Msxml2.XMLHTTP.5.0',
'Msxml2.XMLHTTP.4.0',
'Msxml2.XMLHTTP.3.0'];
if(window.XMLHttpRequest){try{return new XMLHttpRequest();} catch (e){}}
for(var i=0;i<MSXML.length;i++){try{return new ActiveXObject(MSXML[i]);}
catch (e){}}}
base.Http=base.getHttp();
base.formmodel = false;
base.regEvent=function(eventName,sendurl){
try{base.Http.onreadystatechange=null;}
catch(e){}
base.formmodel = (eventName.indexOf("form:") == 0);
eventName = eventName.replace("form:","");
base.curreventname = eventName;
if(base.formmodel) {
	var formdiv = $ID("__sys_ajx_form_proxy_" + base.curreventname );
	if(!formdiv) {
		formdiv = document.createElement("div");
		formdiv.id = "__sys_ajx_form_proxy_d_iv_" + base.curreventname;
		formdiv.style.cssText = "position:absolute;top:100px,left:100px,width:10px;height:10px;overflow:hidden"
		formdiv.innerHTML = "<form method='post' action='" + (sendurl ? sendurl : "") + "' id='__sys_ajx_form_proxy_" + base.curreventname + "' target='__sys_ajx_form_target_" + base.curreventname + "'>" 
							+ "<input type='hidden' name='__msgid' value='" + escape(eventName) + "'><input type='hidden' name='__formproxymodel' value='1'></form>"
							+ "<iframe id='__sys_ajx_form_target_" + base.curreventname + "_id' style='height:1px;width:1px' frameborder=0 name='__sys_ajx_form_target_" + base.curreventname + "' ></iframe>"
		document.body.appendChild(formdiv);
	}
}
base.sendText="__msgId="+escape(eventName);
base.tempurl=sendurl;}
base.regCtlEvent=function(controlID,eventName){base.regEvent("ctl_event_callback");
base.addParam("controlID",controlID);
base.addParam("eventName",controlID);}
base.addParam=function(name,value){
	if(base.formmodel) {
		var formdiv = $ID("__sys_ajx_form_proxy_" + base.curreventname );
		if(formdiv==false) {
			app.Alert("表单模式下调用异常，未获取到由regEvent事件创建的表单组件。");
			return;
		}
		var item = $DC.createElement("span");
		item.innerHTML = "<input type='hidden' name='" + name + "'>"
		item.children[0].value = value;
		formdiv.appendChild(item);
		return;
	}
	if(value==undefined){window.confirm("提示：\n\n    在Ajax事件“" + base.curreventname + "”中，参数“" + name + "”的数据类型为Undefined。\n\n    该类型的数据可能引发当前处理过程异常。")};
	base.sendText = base.sendText + "&" + escape(name) + "=" + encodeURIComponent(value).replace(/\+/g, "%2B");
}
base.addParam2=function(name,value){
	if(base.formmodel) { base.addParam(name, value) ; return ; }
	base.sendText=base.sendText+"&"+name+"="+value;
}
base.ajaxstatuschange=function(callback,showproc){
	return  function()
	{
		var http=base.Http;
		if(http.readyState==4)
		{
			if(showproc) { base.hideprocc(); }
			try{
				if(http.responseText.indexOf("content=\"zbintel.error.message\"")>0) {
					document.write(http.responseText);
					return;
				}
			}
			catch(e){}
			callback(base.PreScript(http.responseText));
		}
	}
}
base.showprocc=function(msg){
	var procDiv=$ID("__ajax_proc_div");
	if(!procDiv){
		procDiv=$DC.createElement("div");
		procDiv.id="__ajax_proc_div";
		procDiv.innerHTML="<table align=center style='margin-top:15px'><tr><td align=right style='width:50px'>"
						+ "<img src='" + window.virpath + "images/smico/proc.gif' style='height:20px'>&nbsp;</td><td style='color:red' align='left'>&nbsp;" + (msg?msg:"正在加载,请稍候...") + "</td></tr></table>"
		$DC.body.appendChild(procDiv);
	}
	procDiv.style.cssText="display:block;left:" + parseInt(document.body.offsetWidth*0.4 + document.documentElement.scrollLeft + document.body.scrollLeft) + "px;top:" + parseInt(120 + document.documentElement.scrollTop + document.body.scrollTop) + "px"
}
base.hideprocc=function(){
	var procDiv=$ID("__ajax_proc_div");
	if(procDiv){procDiv.style.display="none"}
}
base.PreScript=function (txt){
	var a=txt.replace(/\<\/ajaxscript\>/g,"<ajaxscript>").split("<ajaxscript>");
	for(var i=1;i<a.length;i=i+2){eval(a[i]);a[i]="";}
	return a.join("");
}
base.send=function (callback,pmsg)
{
	var url="";
	base.addParam("__ajaxsendTime",(new Date).getTime())
	url=base.tempurl ? base.tempurl : base.url;
	url = url.replaceAll("//","/");
	if(base.formmodel==true) {
		//__onajax_proc_load
		if( !callback) {
			app.Alert("Ajax执行【" + base.curreventname + "】过程失败：\n\n采用表单方式提交数据不支持同步模式。")
		}
		else {
			var fram = $ID("__sys_ajx_form_target_" + base.curreventname + "_id");
			if(fram.attachEvent)
			{
				fram.attachEvent("onload",window.__sys_ajax_form_result_handle(fram, callback));
			}
			else
			{
				fram.addEventListener("load",window.__sys_ajax_form_result_handle(fram, callback));
			}
			fram.action = url;
			$ID("__sys_ajx_form_proxy_" + base.curreventname).submit();
			base.formmodel = false;
		}
		return;
	}
	if(callback)
	{
		var http=base.Http;
		http.open("post",url,true);
		http.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
		if(window.ActiveXObject) { http.setRequestHeader("Content-Length",base.sendText.length+""); }
		http.onreadystatechange=base.ajaxstatuschange(callback, pmsg?true:false);
		if(pmsg){base.showprocc();}
		http.send(base.sendText);
	}
	else{
		var http=base.Http;
		http.open("post",url,false);
		http.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
		if(window.ActiveXObject) { http.setRequestHeader("Content-Length",base.sendText.length+"");}
		http.send(base.sendText);
		try{
			if(http.responseText.indexOf("content=\"zbintel.error.message\"")>0) {
				document.write(http.responseText);
				return;
			}
		}
		catch(e){}
		return base.PreScript(http.responseText);
	}
}
base.addParamsById=function(controlid){var div=$ID(controlid)
if(!div){return false}
var Inputs=div.getElementsByTagName("INPUT")
for(var i=0;i<Inputs.length;i++)
{if(Inputs[i].id.length>0){$ap(Inputs[i].id,Inputs[i].value)}}}
base.execCallBack=function(requestText){try{var sc=requestText.split("<ajaxvar>")
if(sc.length==0){eval(requestText)
return;}
for(var i=1;i<sc.length;i=i+2)
{sc[i]="var _sys_ajaxvar=\""+sc[i].replace(/\"/g,"\\\"").replace(/\r\n/g,"\\n").replace(/\n/g,"\\n")+"\""}
requestText=sc.join(";")
eval(requestText);}
catch(e){var div=$DC.createElement("Span")
div.innerHTML=requestText
app.Alert("系统请求消息:\n\n"+div.innerText+"\n\n" + e.message)
div=null}}
base.exec=function(isAsynchronous){base.addParam("__execMode","true");
if(isAsynchronous){base.send(base.execCallBack);}
else{base.execCallBack(base.send(null));}}
return base;}
window.ajax=new xmlHttp();
function $ap(n,v){ajax.addParam(n,v);}
window.XmlHttp=xmlHttp;
app.swimg=function(img,kv){ if(kv==undefined){kv="_"};img.src=img.src.indexOf(kv + "s.gif")>0?img.src.replace(kv + "s.gif",".gif"):img.src.replace(".gif", kv + "s.gif");}
app.swpCss=function(obj){obj.className=obj.className.indexOf("_over")>0?obj.className.replace("_over",""):obj.className+"_over";}
app.swpVisible=function(objid,display){var obj=$ID(objid);
if(!display){display="block";}
obj.style.display=(obj.style.display=="none")>0?display:"none";
return false;}
app.unline=function(obj,v)
{obj.style.textDecoration=(v==1)?"underline":"none";}
var tvw=new Object();
tvw.onitemclick=null;
tvw.canrepeatClick=false;
tvw.getcheckBoxAttrs=function(id,attrname,ckboxname,checked)
{var rs=new Array();
var div=$ID("tvw_"+id);
var boxs=div.getElementsByTagName("input")
checked=(checked==undefined)?true:checked;
for(var i=0;i<boxs.length;i++)
{var box=boxs[i];
if(box.type=="checkbox"&&box.checked==checked&&(!ckboxname||box.name==ckboxname)&&box.id.indexOf("tvw_"+id)==0)
{var itemobj=$ID((box.id+"~").replace("_cb~",""));
var a=itemobj.children[0];
switch(attrname)
{case "value":
var v=a.getAttribute("value");
if(v&&v.length>0)
{rs[rs.length]=v;}
break;
case "text":
rs[rs.length]=a.innerHTML;
break;
default:
rs[rs.length]={text:a.innerHTML ,value:a.getAttribute("value")};
break;}}}
var boxs=div.getElementsByTagName("div")
for(var i=0;i<boxs.length;i++)
{var json=boxs[i].getAttribute("datajosn")
if(json&&json.length>0){var obj=eval(json);
__tvw_sys_loadCheckboxAttr_Json(obj,rs,attrname,ckboxname,checked);
obj=null;}}
return rs;}
function __tvw_sys_loadCheckboxAttr_Json(obj,rs,attrname,ckboxname,checked)
{for(var i=0;i<obj.length;i++)
{var o=obj[i];
if(!o.pagecount)
{if((!ckboxname||o.ckname==ckboxname)&&(o.checked==checked?1:0))
{switch(attrname)
{case "value":
var v=o.value;
if(v&&v.length>0)
{rs[rs.length]=v;}
break;
case "text":
rs[rs.length]=a.text;
break;
default:
rs[rs.length]={text:a.text,value:a.value};
break;}}
if(o.nodeobjs&&o.nodeobjs.length>0)
{__tvw_sys_loadCheckboxAttr_Json(o.nodeobjs,rs,attrname,ckboxname,checked)}}}}
function __tvw_mtc(obj,t){obj.style.color=(t==1)?obj.getAttribute("c2"):obj.getAttribute("c1");}
app.Serialize=function (obj){switch(obj.constructor){case Object:
var str=new Array();
for(var o in obj){str[str.length]=o+":"+app.Serialize(obj[o]);}
return "{"+str.join(",")+"}";
case Array:
var str=new Array();
for(var i=0;i<obj.length;i++)
{str[i]=app.Serialize(obj[i]);}
return "["+str.join(",")+"]";
case Boolean:return "\""+obj.toString()+"\"";break;
case Date:return "\""+obj.toString()+"\"";break;
case Function:break;
case Number:return "\""+obj.toString()+"\"";break;
case String:return "\""+obj.toString().replace(/\"/g,"\\\"")+"\"";break;}}	//2014-3-10.ljh.修改弹出缓存损坏的报错
app.GetJson=app.Serialize;
function __tvw_getCheckBoxValues(id,ckname,checkState){var nd=$ID("tvw_"+id);
var boxs=nd.getElementsByTagName("input");
var d=new Array();
for(var i=0;i<boxs.length;i++)
{var b=boxs[i];
if(b.type=="checkbox"&&b.getAttribute("tvwck")){var nd=$ID((b.id+"$").replace("_cb$","_n"));
if(b.name==ckname&&b.checked==checkState)
{var a=nd.getElementsByTagName("a")[0];
d[d.length]=a.getAttribute("value");}
nd=$ID((b.id+"$").replace("_cb$","_bg"));
if(nd){var v=nd.getAttribute("datajosn");
if(v&&v.length>0)
{try{var obj=eval(v);}
catch (e)
{alert("树的子级缓存数据损坏，请确认页面加载是否完整");return;}
for(var ii=0;ii<obj.length;ii++)
{var item=obj[ii];
if(item.ckname==ckname&&(item.checked==1)==checkState)
{d[d.length]=item.value;}
__tvw_getCheckBoxValuesForJsonChild(item,ckname,checkState ,d);}}}}}
return d;}
function __tvw_getCheckBoxValuesForJsonChild(pItem,ckname,checkState ,d){if(!pItem.nodeobjs){return;}
for(var i=0;i<pItem.nodeobjs.length;i++)
{var item=pItem.nodeobjs[i];
if(item.ckname==ckname&&(item.checked==1)==checkState)
{d[d.length]=item.value;}
__tvw_getCheckBoxValuesForJsonChild(item,ckname,checkState ,d)}
return;}
function __tvw_item_checked(box)
{window.event.cancelBubble=true;
if(box.checked==false)
{var ids=box.id.split("_");
for(var i=ids.length-2;i>1;i --)
{var t=ids.slice(0,i).join("_")+"_cb";
var b=$ID(t);
if(b){b.checked=false;}}}
__tvw_checkedChilds(box);
if(window.__on_tvw_checkBoxClick){window.__on_tvw_checkBoxClick(box);}
return true;}
function __tvw_checkedChilds(box,objType)
{if(objType=="json")
{if(!box.nodeobjs){return;}
for(var i=0;i<box.nodeobjs.length;i++)
{box.nodeobjs[i].checked=box.checked;
__tvw_checkedChilds(box.nodeobjs[i],"json");}
return;}
var nd=$ID((box.id+"$").replace("_cb$","_bg"))
if(!nd){return;}
var v=nd.getAttribute("datajosn");
if(v&&v.length>0)
{try{var obj=eval(v);}
catch (e)
{alert("树的子级缓存数据损坏，请确认页面加载是否完整");return;}
for(var i=0;i<obj.length;i++)
{obj[i].checked=box.checked?1:0;
__tvw_checkedChilds(obj[i],"json");}
nd.setAttribute("datajosn",app.Serialize(obj));
return;}
else
{var boxs=nd.getElementsByTagName("input");
for(var i=0;i<boxs.length;i++)
{var b=boxs[i];
if(b.type=="checkbox"&&b.getAttribute("tvwck")){b.checked=box.checked;
var nd=$ID((b.id+"$").replace("_cb$","_bg"))
if(nd){var v=nd.getAttribute("datajosn");
if(v&&v.length>0){__tvw_checkedChilds(b);}}}}}}
function __tvw_page_itemClick(obj,newPageIndex)
{var root=null;
newPageIndex=newPageIndex+"";
if(isNaN(newPageIndex)||newPageIndex.length==0){app.Alert("请输入正确的数字");
window.event.keyCode=0;
window.event.cancelBubble=true;
return false;}
var nobj=obj.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
var nitem=nobj.previousSibling;
if (!nitem || !nitem.getAttribute("autosql")) {
	nitem = nobj.parentNode;
root=nitem;}
else{root=nobj.parentNode;
var findRoot=false;
while(findRoot==false&&root){findRoot=(root.tagName=="DIV"&&root.className=="treeview")
if(findRoot==false)
{root=root.parentNode;}}}
var id=root.id.replace("tvw_","");
ajax.regEvent("sys_treeviewCallBack");
$ap("cmd","doPageSize");
$ap("autosql",nitem.getAttribute("autosql"));
$ap("id", root.id.replace("tvw_", ""));
$ap("B", document.getElementById("htB") ?document.getElementById("htB")["value"]:"");
$ap("C", document.getElementById("htKeywords") && document.getElementById("htB")["value"] != '按回车搜索' ? document.getElementById("htKeywords")["value"] : "");
$ap("pagesize",root.getAttribute("pagesize"));
$ap("pageindex",newPageIndex);
if(root.id!=nitem.id){
	$ap("pnodevalue",nitem.getElementsByTagName("a")[0].getAttribute("value"));
} else {
	$ap("pnodevalue","0");
}
$ap("itemid",nitem.id.replace("tvw_",""));
$ap("deepData",nobj.children[0].getAttribute("deepData"));
$ap("explan",$ID("vartvw_"+id+"_defExplan").value);
$ap("pdm",$ID("tvw_"+id).getAttribute("pdm"))
$ap("checkbox",root.getAttribute("checkbox"));
if(window.__on_sys_tvw_beforePageStatus)
{__on_sys_tvw_beforePageStatus(root.id.replace("tvw_",""));}
var r = ajax.send();
nobj.innerHTML=r;
if(window.__on_afterPageStatus)
{
	__on_afterPageStatus();
}
}
function __tvw_checkboxSet(tvwid,checked){var nd=$ID("tvw_"+tvwid);
var boxs=nd.getElementsByTagName("input");
for(var i=0;i<boxs.length;i++)
{var b=boxs[i];
if(b.type=="checkbox"&&b.getAttribute("tvwck")){b.checked=checked;
var nd=$ID((b.id+"$").replace("_cb$","_bg"))
if(nd){var v=nd.getAttribute("datajosn");
if(v&&v.length>0){__tvw_checkedChilds(b);}}}}}

function __tvw_execDataJosn(bgElement) {
	var isjson = typeof(bgElement) == "string";
	var v =  isjson==true?bgElement:bgElement.getAttribute("datajosn");
	if (!v || v.length == 0) {
		return;
	}
	try {
		var obj = eval(v);
		if (isjson == false) { bgElement.setAttribute("datajosn", "") }
	} catch(e) {
		alert("树的子级缓存数据损坏，请确认页面加载是否完整");
		return;
	}
	var html = new Array();
	for (var i = 0; i < obj.length; i++) {
		var item = obj[i];
		if (!item) {
			continue;
		}
		if (item.recordcount && !isNaN(item.recordcount)) {
			html[html.length] = "<div id='tvw_psize_n' class='tvw_n_item' style='height:50px;width:" + item.width + "px;'>"
			for (var ii = 0; ii < item.deep.length; ii++) {
				var d = item.deep.substr(ii, 1);
				if (d == "1") {
					html[html.length] = "<div class='tvw_n_ln d" + (ii == 0 ? "1": "0") + "' style='width:" + item.idw + "px'></div>";
				} else {
					html[html.length] = "<div class='tvw_n_spc' style='width:" + item.idw + "px'></div>";
				}
			}
			html[html.length] = "<div class='tvw_n_st' style='width:2px'>&nbsp;</div>";
			html[html.length] = "<table cellspacing=0 cellpadding=0 style='border:1px solid #f0f0f0;height:30px;border-collapse:collapse;line-height:16px;margin:0px;padding:0px;table-layout:auto' cellpadding=0><tr>";
			html[html.length] = "<td valign=top colspan=5>&nbsp;共" + item.recordcount + "行&nbsp;&nbsp;" + item.pagesize + "行/页</td>";
			html[html.length] = "</tr><tr>";
			html[html.length] = "<td valign=top><input onclick='__tvw_page_itemClick(this,1)' type=image " + (item.canpre == 2 ? "style='cursor:pointer'": "disabled") + " src='" + window.sysskin + "/images/ico_page_first_0" + item.canpre + ".gif'></td>";
			html[html.length] = "<td valign=top><input onclick='__tvw_page_itemClick(this," + (item.pageindex - 1) + ")' type=image " + (item.canpre == 2 ? "style='cursor:pointer'": "disabled") + "  src='" + window.sysskin + "/images/ico_page_pre_0" + item.canpre + ".gif'></td>";
			html[html.length] = "<td valign=top><input onkeydown='if(window.event.keyCode==13){if(!isNaN(this.value) && this.value > " + item.pagecount + ")(this.value = " + item.pagecount + ");if(!isNaN(this.value) && this.value < 1)(this.value = 1);return __tvw_page_itemClick(this,this.value);return __tvw_page_itemClick(this,this.value);}' type='text' value='" + item.pageindex + "' maxlength=5 style='position:relative;top:-1px;text-align:center;width:22px;font-size:12px;height:14px;border:1px solid #aaa;padding:0px;'>/" + item.pagecount + "</td>";
			html[html.length] = "<td valign=top><input onclick='__tvw_page_itemClick(this," + (item.pageindex * 1 + 1) + ")' type=image " + (item.cannext == 2 ? "style='cursor:pointer'": "disabled") + "  src='" + window.sysskin + "/images/ico_page_next_0" + item.cannext + ".gif'></td>";
			html[html.length] = "<td valign=top><input onclick='__tvw_page_itemClick(this," + (item.pagecount) + ")' type=image " + (item.cannext == 2 ? "style='cursor:pointer'": "disabled") + "  src='" + window.sysskin + "/images/ico_page_end_0" + item.cannext + ".gif'></td>";
			html[html.length] = "</tr></table>";
			html[html.length] = "</div>";
		} else {
			item.autosql = !item.autosql ? "": item.autosql;
			html[html.length] = "<div id='" + item.id + "_n' autosql='" + item.autosql + "' deepData='" + item.deep + "' class='tvw_n_item' ";
			html[html.length] = "style='" + (item.height ? "height:" + item.height + "px;line-height:" + item.height + "px;": "") + (item.width ? "width:" + item.width + "px": "") + "'>";
			var css = ""
			for (var ii = 0; ii < item.deep.length; ii++) {
				var d = item.deep.substr(ii, 1);
				if (d == "1") {
					html[html.length] = "<div class='tvw_n_ln d" + (ii == 0 ? "1": "0") + "' style='width:" + item.idw + "px'></div>";
				} else {
					html[html.length] = "<div class='tvw_n_spc' style='width:" + item.idw + "px'></div>";
				}
			}
			item.expand = !item.expand ? 0 : item.expand;
			if (item.hasnext == 0) {
				css = (item.nodes == 0 || item.casd == 1) ? "ty_1_e2": "ty_1_e" + item.expand;
			} else {
				css = (item.nodes == 0 || item.casd == 1) ? "ty_2_e2": "ty_2_e" + item.expand;
			}
			if (item.firstnode == 1) {
				css = css + " fnode";
			}
			html[html.length] = "<div class='tvw_n_st " + css + "' style='width:" + item.idw + "px' onclick='tvw_expnode(this,\"" + item.id + "\")'>&nbsp;</div>";
			if (item.ckbox == 1) {
				html[html.length] = "<div class='tvw_n_ckbox'><input name='" + item.ckname + "' id='" + item.id + "_cb' tvwck=1 type='checkbox'" + (item.checked == 1 ? " checked": "") + " onclick='return __tvw_item_checked(this)'></div>"
			}
			item.ico2 = !item.ico2 ? "": item.ico2;
			item.ico = !item.ico ? "": item.ico;
			if (item.ico.length > 0) {
				if (item.ico2.length == 0) {
					item.ico2 = item.ico;
				}
				item.ico2 = item.ico2.replace("@img", window.sysskin + "/images");
				item.ico = item.ico.replace("@img", window.sysskin + "/images");
				html[html.length] = "<div class='tvw_n_ico'><img id='" + item.id + "_ico' src='" + (item.expand == 1 ? item.ico: item.ico2) + "' ico1='" + item.ico + "' ico2='" + item.ico2 + "'></div>";
			}
			item.color = !item.color ? "": item.color;
			var scss = item.selected == 1 ? "tvw_txt_sel": "tvw_txt";
			var sty = item.color.length > 0 ? "color:" + item.color + ";": "";
			sty = sty + (item.cursor ? "cursor:" + item.cursor + ";": "");
			sty = sty.length > 0 ? "style=\"" + sty + "\"": "";
			var hcEvent = (item.hvcolor && item.hvcolor.length > 0) ? " onmouseover='__tvw_mtc(this,1)' onmouseout='__tvw_mtc(this,0)' ": "";
			if (item.text.lengt == 0) {
				item.text = "&nbsp;";
			}
			html[html.length] = "<div class='tvw_n_txt' id='" + item.id + "'>";
			html[html.length] = "<a canselect='" + item.cansel + "' onclick='__tvwnodeClick(this,\"" + item.id + "\")' onmousedown='tvwnodedown(this,\"" + item.id + "\")' href='javascript:void(0)' onfocus='this.blur()' class='" + scss + "' ";
			html[html.length] = "value='" + item.value + "' c2='" + item.hvrcolor + "' c1='" + item.color + "' " + sty + hcEvent + ">" + item.text + "</a></div>";
			html[html.length] = "</div>";
			if (item.nodes > 0) {
				if (item.expand == 0) {
					html[html.length] = "<div id='" + item.id + "_bg' style='display:none' datajosn=\"" + app.Serialize(item.nodeobjs).replace(/\"/g, "&#34;").replace(/\</g, "&#60;").replace(/\>/g, "&#62;") + "\"></div>";
				} else {
					html[html.length] = "<div id='" + item.id + "_bg'>"
					html[html.length] = __tvw_execDataJosn(app.Serialize(item.nodeobjs));
					html[html.length] = "</div>";
				}
			}
		}
	}
	if (isjson == true) { return html.join(""); }
	bgElement.innerHTML = html.join("");
	html = null;
}


function tvw_rplpnclss(nd) {
	if(nd.className.indexOf(" dp")>0){
		var s = nd.className;
		var s1 = s.substring(0,s.length-1);
		var s2 = s.substring(s.length-1,s.length);
		nd.className = s1 + (s2=="1"?"0":"1");
	}
}
function tvw_expnode(eico ,id){var icobox=$ID(id+"_ico");
var divObj=$ID(id+"");
var adiv=divObj.childNodes[0].getAttribute("value");
if(eico.className.indexOf(" ty_1_e1")>0){
tvw_rplpnclss(eico.parentNode);
eico.className=eico.className.replace(" ty_1_e1"," ty_1_e0");
$ID(id+"_bg").style.display="none";
if(icobox){icobox.src=icobox.getAttribute("ico2");}
if(tvw.onitemexpnode){tvw.onitemexpnode(id,0,adiv);}
return;}
if(eico.className.indexOf(" ty_1_e0")>0){
tvw_rplpnclss(eico.parentNode);
eico.className=eico.className.replace(" ty_1_e0"," ty_1_e1");
__tvw_execDataJosn($ID(id+"_bg"));
$ID(id+"_bg").style.display="block";
if(icobox){icobox.src=icobox.getAttribute("ico1");}
if(tvw.onitemexpnode){tvw.onitemexpnode(id,1,adiv);}
return;}
if(eico.className.indexOf(" ty_2_e1")>0){
tvw_rplpnclss(eico.parentNode);
eico.className=eico.className.replace(" ty_2_e1"," ty_2_e0");
$ID(id+"_bg").style.display="none";
if(icobox){icobox.src=icobox.getAttribute("ico2");}
if(tvw.onitemexpnode){tvw.onitemexpnode(id,0,adiv);}
return;}
if(eico.className.indexOf(" ty_2_e0")>0){
tvw_rplpnclss(eico.parentNode);
eico.className=eico.className.replace(" ty_2_e0"," ty_2_e1");
__tvw_execDataJosn($ID(id+"_bg"));
$ID(id+"_bg").style.display="block";
if(icobox){icobox.src=icobox.getAttribute("ico1");}
if(tvw.onitemexpnode){tvw.onitemexpnode(id,1,adiv);}
return;}}
function tvwnodedown(txttag,id)
{
	var cldiv=txttag.parentNode.parentNode;
	var id0=(cldiv.id+"@#").replace("_n@#","");
	var cdiv=$ID(id0+"_bg");
	if(cdiv){
		var divs=cldiv.children;
		for(var i=0;i<divs.length;i++)
		{
			if(divs[i].className.indexOf("tvw_n_st")==0)
			{
				tvw_expnode(divs[i],id0)
				break;
			}
		}
	}
}
function __tvwnodeClick(txttag, id) {
	try{//左侧导航IE9不兼容执行
		document.getElementById("treebody_bg").style.overflowY="hidden";
		document.getElementById("treebody_bg").style.overflowY="auto";
	}catch(e){}
	if(txttag.getAttribute("canselect")==0){return;}
	if(txttag.className!="tvw_txt_sel"||tvw.canrepeatClick==true)
	{
		var ids=id.split("_");
		var tid=ids[0]+"_"+ids[1];
		var div=$ID(tid);
		var tlinks=div.getElementsByTagName("a");
		for(var i=0;i<tlinks.length;i++)
		{var n = tlinks[i];
		if(n.className=="tvw_txt_sel")
		{
			n.className="tvw_txt";
			n.parentNode.parentNode.className = n.parentNode.parentNode.className.replace("tnsel ","");
			break;
		}}
		txttag.className="tvw_txt_sel";
		var obj = txttag.parentNode.parentNode;
		obj.className = "tnsel " + obj.className;
		//alert(obj.className)
		if(tvw.onitemclick)
		{
			var o=new Object();
			o.id=ids[1];
			o.nodeid=id;
			o.text=txttag.innerHTML;
			o.value=txttag.getAttribute("value");
			o.srcElement=txttag;
			o.deep=ids.length-2;
			tvw.onitemclick(o);
			o=null;
		}
	}
}
tvw.getselNode=function(id)
{var div=$ID("tvw_"+id);
var tlinks=div.getElementsByTagName("a");
for(var i=0;i<tlinks.length;i++)
{if(tlinks[i].className=="tvw_txt_sel")
{var nd=tlinks[i].parentNode;
nd.setAttribute("active",
function()
{if(tvw.onitemclick)
{var o=new Object();
o.id=id;
o.nodeid=nd.id;
o.text=tlinks[i].innerHTML;
o.value=tlinks[i].getAttribute("value");
o.srcElement=tlinks[i];
o.deep=nd.id.split("_").length-2;
tvw.onitemclick(o)
o=null;}}
);
return nd;}}
return null}
tvw.setNodeText=function(nd ,txt){try{nd.getElementsByTagName("a")[0].innerHTML=txt;}catch(e){alert("设置树节点文本标题失败:"+e.message);}}
tvw.callback=function(id,funAddParams,funOnCallend)
{ajax.regEvent("sys_treeviewCallBack");
$ap("id",id);
if(funAddParams){funAddParams();}
ajax.send(tvw.oncallbackend(id,funOnCallend));}
tvw.oncallbackend=function(id,funOnCallend)
{return function (data)
{if (data.indexOf("'tvw_") > 0)
{var resultDataArray = data.split("<!--");
$ID("tvw_" + id).innerHTML = resultDataArray[0];
$ID("tvw_" + id).setAttribute("autosql", resultDataArray[1].replace("-->", ""));
if(funOnCallend){funOnCallend();}}}}

function __OnMenuItemClick(id ,srcTag){
var v=srcTag.getAttribute("value")
if(v.indexOf("&%__sysMore")>=0)
{ajax.regEvent("sys_menuviewcallback");
$ap("id",id);
$ap("cmd","moreclick");
$ap("value",v.replace("&%__sysMore",""));
var r=ajax.send();
$ID("mvw_"+id).innerHTML=r;
return;}
if(window.onMenuItemClick){window.onMenuItemClick(id,srcTag);}
if(srcTag.parentNode){
var ids = srcTag.id.split("_");
var idp = ids[0]+"_"+ids[1]+"_" + ids[2] + "_p";
var box = document.getElementById(idp);
if(box && box.parentNode && box.parentNode.className == "menu_topitem_hover"){
	box = box.parentNode;
	box.className = "menu_topitem";
}
else{
	srcTag.parentNode.style.display="none";
	window.setTimeout(function(){srcTag.parentNode.style.display="";},100)}}
}
var xxx=0
function __MenuEvents(srcTag,eType){switch(eType){case 1:
srcTag.className="menu_topitem_hover";
return;
case 2:
srcTag.className="menu_topitem";
return;
case 3:
srcTag.className="menu_t_line_hover";return;
case 4:
srcTag.className="menu_t_line";return;
case 5:
srcTag.className="menu_morebar morehover";
if(app.IeVer==6){var ul=srcTag.getElementsByTagName("Ul")[0];
if(ul){srcTag.IE6Child=ul;
$DC.body.insertBefore(ul);
var o=fGetXY(srcTag);
ul.style.cssText="position:absolute;top:"+(o.y+srcTag.offsetHeight)+"px;left:"+o.x+"px;z-index:1000;display:block;width:"+ul.style.width;
ul.onmouseup=function(){ul.style.display="none";}
window.curroutmoreMenuItem=ul;}
else{if(srcTag.IE6Child){srcTag.IE6Child.style.display="block";
window.curroutmoreMenuItem=srcTag.IE6Child;}}}
return;
case 6:
srcTag.className="menu_morebar";
return;
default:}}
window.currPopMenu=null;
window.currPopMenuItemClick=null;
function isParantNode(childEm,parentEm){if(childEm==parentEm){return true;}
var oTmp=childEm.parentNode;
while (oTmp){if(oTmp==parentEm){return true;}
oTmp=oTmp.parentNode;}
return false;}
function GetObjectPos(element){if(arguments.length !=1||element==null){return null;}
var elmt=element;
var offsetTop=elmt.offsetTop;
var offsetLeft=elmt.offsetLeft;
var offsetWidth=elmt.offsetWidth;
var offsetHeight=elmt.offsetHeight;
while (elmt=elmt.offsetParent){if(elmt.style.position=='absolute'||elmt.style.position=='relative'
|| (elmt.style.overflow!='visible'&&elmt.style.overflow !='')){break;}
offsetTop+=elmt.offsetTop;
offsetLeft +=elmt.offsetLeft;}
return{top:offsetTop,left:offsetLeft,width:offsetWidth,height:offsetHeight};}
if(typeof(fGetXY) === "undefined") {
	function fGetXY(aTag){var pt={x:0,y:0};
	var w=0,h=0
	var oTmp=aTag;
	while (oTmp){pt.x=pt.x+oTmp.offsetLeft-oTmp.scrollLeft;
	pt.y=pt.y+oTmp.offsetTop-oTmp.scrollTop;
	oTmp=oTmp.offsetParent;}
	if(pt.x+w>$DC.body.offsetWidth){pt.x=$DC.body.offsetWidth-w;}
	if(pt.y+h>$DC.body.offsetHeight){pt.y=pt.y-h-aTag.offsetHeight;
	if(pt.y<0){pt.y=$DC.body.offsetHeight-h;}}
	pt.x=pt.x+$DC.body.scrollLeft;
	pt.y=pt.y+$DC.body.scrollTop;
	return pt;}
};
function  ContextMenuClass(Parent){var obj=new Object();
obj.menus=new Array();
obj.parent=parent;
obj.ItemMaxSize=36;
obj.id="m_def";
obj.width=0;
obj.onitemclick=null;
obj.currdiv=null;
obj.menus.add=function(text,value ,ico){obj.menus[obj.menus.length]={"text":text ,
"value":value,
"ico":ico ,
"menus":null};
var index=obj.menus.length-1;
if(!obj.menus[obj.menus.length-1].value){obj.menus[index].value="";}
return obj.menus[obj.menus.length-1];}
obj.LenC=function(str){return str.replace(/[^\x00-\xff]/g,'xx').length}
obj.itemhtml=function(item){var fll ,html;
html="";
fll=obj.LenC(item.text)>obj.ItemMaxSize?true:false;
html=html+"<li class='menu_t_line' text=\""+item.text.replace("\"","#&34;")+"\" value=\""+item.value.replace("\"","#&34;")+"\" onmousedown='if(window.currPopMenuItemClick){window.currPopMenuItemClick(this);}else{alert(\"创建了菜单对象,但是没有定义该菜单的鼠标事件\")}' onmouseout='__MenuEvents(this,4)' onmouseover='__MenuEvents(this,3)'><table class='menu_u_c_ws_s0'><tr><td class='menu_u_c_ws_s1'></td>"
html=html+(fll?"<td class='menu_u_c_ws_s2' title=\""+item.text.replace("\"","&#34;")+"\">":"<td class='menu_u_c_ws_s2'>");
html=html+"<div class='menu_t_ico'>"+(item.ico?"<img src='"+item.ico+"'>":"")+ "</div>";
html=html+(item.menus?"<div class='menu_t_more_ico'>":"<div class='menu_t_more'>");
html=html+(fll?"</div>"+item.text.substring(0,obj.ItemMaxSize-12)+"...":"</div>"+item.text);
html=html+"</td><td class='menu_u_c_ws_s3'></td></tr></table>"
if(item.menus)
{html=html+ item.menus.show(obj);}
html=html+"</li>"
return html;}
obj.show=function(parent)
{var html="";
var div=$ID("context_menu_"+obj.id);
if(!div){div=$DC.createElement("div");
div.id="context_menu_"+obj.id;
div.className="contextmenu";
$DC.body.appendChild(div);}
var iw ,iwidth,cl
iw=0;
for(var i=0;i<obj.menus.length;i++){cl=obj.LenC(obj.menus[i].text)
if(cl>obj.ItemMaxSize){cl=obj.ItemMaxSize;}
if(iw<parseInt(cl*9)){iw=parseInt(cl*9);}}
if(iw<90){iw=90;}
iwidth=iw+44;
obj.width=iwidth;
html=html+"<ul class='menu_ul_cnitem' style='width:"+iwidth+"px;"+(parent?"left:"+(parent.width-10)+"px;top:-20px;":"")+"'>";
html=html+"<li class='menu_ul_cnitem_lts'><table><tr><td class='menu_u_c_ts_s1'></td><td class='menu_u_c_ts_s2'></td><td class='menu_u_c_ts_s3'></td></tr></table></li>"
for(i=0;i <obj.menus.length;i++)
{html=html+obj.itemhtml(obj.menus[i])}
html=html+"<li class='menu_ul_cnitem_lbs'><table><tr><td class='menu_u_c_ls_s1'></td><td class='menu_u_c_ls_s2'></td><td class='menu_u_c_ls_s3'></td></tr></table></li>"
html=html+"</ul>";
if(parent){return html;}
if(window.currPopMenu&&window.currPopMenu!=div){window.currPopMenu.style.display="none";}
window.currPopMenu=div;
div.style.width=iwidth+"px";
div.style.left=window.event.clientX+"px";
div.style.top=window.event.clientY+"px";
div.innerHTML=html;
div.style.display="block";
window.returnValue=false;
window.event.cancelBubble=true;
window.currPopMenuItemClick=obj.onitemclick;
obj.currdiv=div;
return div;}
obj.BindElement=function(srcElemnt,offsetX,offsetY){var pos=GetObjectPos(srcElemnt);
obj.currdiv.style.left=parseInt(pos.left+offsetX)+ "px";
obj.currdiv.style.top=parseInt(pos.top+offsetY)+"px";}
return obj;}
window.onmousedownHandle=function(){
	if (parent != window) {
		try {
			if ($DC.all) { $PDC.fireEvent("onmousedown"); }
			else {
				var evt = parent.document.createEvent("MouseEvents");
				evt.initEvent("mousedown", true, true);
				parent.document.dispatchEvent(evt);
			}
		} catch (e) { }
}
if(window.currPopMenu)
{$DC.body.removeChild(window.currPopMenu);window.currPopMenu=null;}}
if($DC.attachEvent){$DC.attachEvent("onmousedown",window.onmousedownHandle);}
else{$DC.addEventListener("mousedown",window.onmousedownHandle,false);}
function _toolbarmv(srcTag,t){
	var uimodel = srcTag.getAttribute("uimodel");
	uimodel = ( uimodel == "" ? "" : "_" + uimodel );
	srcTag.className= t ? "btnlist_hover" + uimodel : "btnlist";
	var ico2 = srcTag.getAttribute("ico2");
	if(ico2!="") {
		var ico1 = srcTag.getAttribute("ico1");
		var sty = srcTag.children[0].children[0].style;
		var im = sty.backgroundImage;
		sty.backgroundImage = t ? im.replace(ico1,ico2) : im.replace(ico2, ico1);
	}
}

function getBtnclickEvntHandle(btn) {
	return function(key, value) {
		switch(key) {
			case "ico":
				var v = btn.getAttribute("value");
				var vl = v.split("#-#");
				vl[2] = value;
				btn.setAttribute("value", vl.join("#-#"));
				btn.setAttribute("ico1", value);
				break;
			case "ico2":  
				btn.setAttribute("ico2", value);
				btn.children[0].children[0].style.backgroundImage = "url(" + window.sysskin +"/images/toolbar/" + value + ")";
				break;
			case "value":  
				var v = btn.getAttribute("value");
				var vl = v.split("#-#");
				vl[1] = value;
				btn.setAttribute("value", vl.join("#-#"));
				break;
			case "text":
				var divs = btn.getElementsByTagName("div");
				btn.title = value;
				for (var i = 0; i<divs.length ; i++ )
				{
					if(divs[i].getAttribute("istext")==1) { divs[i].innerText = value;  break;	}
				}
				break;
		}
	}
}
function __toolbarshowmore(bn)
{var vs=bn.children[0].value.split("$%#4");
var m=new ContextMenuClass();
m.onitemclick=function(li){var newv=li.getAttribute("value");
var dvs=bn.parentNode.getElementsByTagName("DIV")
var lbn=null;
for(var i=0;i< dvs.length;i++)
{if(dvs[i].className=="btnlist")
{lbn=dvs[i];}}
var cells=newv.split("#-#");
if(window.ontoolbarclick){
	var data={"id":cells[5],"sort":cells[4],"text":cells[0],"value":cells[1],"setattr":getBtnclickEvntHandle(bn)};
window.ontoolbarclick(data)}
return;
var oldv=lbn.getAttribute("value");
lbn.setAttribute("value",newv);
lbn.title=cells[0];
lbn.children[0].style.backgroundImage="url("+window.sysskin+"/images/toolbar/"+cells[2]+")";
bn.children[0].value=bn.children[0].value.replace(newv,oldv);}
for(var i=1;i< vs.length;i++)
{var item=vs[i].split("#-#");
m.menus.add(item[0],vs[i],window.sysskin+"/images/toolbar/"+item[2]);}
m.show();
m.BindElement(bn,5,(bn.offsetHeight)/2+8);}
function __toolbarclick(tag)
{var v=tag.getAttribute("value").split("#-#");
if(window.ontoolbarclick){var data={"id":v[5],"sort":v[4],"text":v[0],"value":v[1],"setattr":getBtnclickEvntHandle(tag)};
window.ontoolbarclick(data)}}
function __stabRefresh(id){var tb=$ID("ctl_stab_"+id);
var dds=tb.getElementsByTagName("dd");
for(var i=0;i<dds.length;i++){if(dds[i].className=="tabstrip_item_sel"){var srcTag=dds[i];
var t=dds[i].id.split("_");
var index=t[t.length-1];
ajax.regEvent("sys_TabSriptloadItem");
$ap("id",id);
$ap("index",index);
$ap("text",srcTag.innerText);
$ap("key",srcTag.getAttribute("key"))
srcTag.setAttribute("cachehtml","");
ajax.send(__sys_stabClickLoadItem($ID("stab_"+id+"_item_"+index),srcTag));
return;}}}
function __stabClick(id,srcTag,index){
	var pobj=srcTag.parentNode.parentNode;
	var c=pobj.getAttribute("count");
	var iheight=pobj.getAttribute("itemheight");
	var cache=pobj.getAttribute("cache");
	var domHideModel = pobj.getAttribute("domHideModel")
	if(srcTag.className.indexOf("sel")<0)
	{
		srcTag.className="tabstrip_item_sel_over";
		$ID("stab_"+id+"_item_"+index).style.display="block";
		srcTag.style.height=(iheight*1+1)+"px";
	}
	for(var i=0;i<c;i++)
	{
		var item=$ID("TBSr_"+id+"_"+(i+1));
		if(item.id!=srcTag.id&&item.className.indexOf("sel")>0)
		{
			item.className="tabstrip_item";
			$ID("stab_"+id+"_item_"+(i+1)).style.display="none";
			item.style.height=iheight+"px";
		}
	}
	var bodydiv=$ID("stab_"+id+"_item_"+index);
	var html=bodydiv.getAttribute("cachehtml");
	if(domHideModel=="0")
	{ 
		if(cache!=1||!html||html.length==0){
			ajax.regEvent("sys_TabSriptloadItem");
			$ap("id",id);
			$ap("index",index);
			$ap("text", srcTag.innerText.replace(/[\r\n\t]/g, "") || srcTag.textContent);
			$ap("key",srcTag.getAttribute("key"))
			ajax.send(__sys_stabClickLoadItem(bodydiv,srcTag));}
		else{
			bodydiv.innerHTML=html;
			try{
				var objs=bodydiv.getElementsByTagName("object");
				for(var i=0;i<objs.length;i++)
				{
					if(objs[i].classid.replace("clsid:","").toLowerCase()=="D27CDB6E-AE6D-11cf-96B8-444553540000".toLowerCase()){objs[i].Play();
				}
			}
			} catch(e){}
		}
	}
	if(window.onsTabClick){window.onsTabClick(id,srcTag,index);}
}
function __sys_stabClickLoadItem(srcParent,srcTag){return function (html){srcParent.innerHTML=html;
srcParent.setAttribute("cachehtml",html);
var scripts=srcParent.getElementsByTagName("script");
for(var i=0;i<scripts.length;i++)
{if(window.execScript){window.execScript(scripts[i].innerHTML,"javascript")}
else{eval(scripts[i].innerHTML);}}}}
function __sys_tabsritp_setselcache(id,index){var obj=$ID("TBSr_"+id+"_"+index);
obj.setAttribute("cachehtml",$ID("stab_"+id+"_item_"+index).innerHTML);}
function __oncardStartDrag(obj,id){if(window.event.srcElement.tagName=="BUTTON"){return}
var bodydiv=obj.nextSibling;
window.beginDragCardObject=obj.parentNode;
window.defonselectstart=$DC.onselectstart;
window.defonmouseup=$DC.onmouseup;
window.defonmousemove=$DC.onmousemove;
$DC.onselectstart=function(){return false;}
$DC.onmouseup=function(){$DC.onselectstart=null;
$DC.body.style.cursor="";
$DC.onmousemove=window.defonmousemove;
$DC.onmouseup=window.defonmouseup;
window.currcardmovediv.style.display="none";
window.currcardmovediv.innerHTML="";
if(window.hotCardObject){if(window.beginDragCardObject==window.hotCardObject){window.hotCardObject.style.border="0px";}
else{if(window.onCardviewItemDragEnd){window.onCardviewItemDragEnd(window.beginDragCardObject,window.hotCardObject)}}}}
window.currcardmovediv=$ID("currcardmovediv");
if(!window.currcardmovediv){window.currcardmovediv=$DC.createElement("div");
window.currcardmovediv.id="currcardmovediv";
window.currcardmovediv.style.cssText="position:absolute;color:#000000;overflow:hidden;height:50px;display:none;border:1px solid #abc1e6;filter:Alpha(style=0,opacity=60);background-color:#ffffff;z-index:10000";
$DC.body.appendChild(window.currcardmovediv);}
$DC.body.style.cursor="move";
var div=window.currcardmovediv;
div.innerHTML="<div style='height:30px;background-color:#f0f0ff;line-height:30px'><b>&nbsp;"+obj.innerText+"</b></div><div style='border-top:1px solid #abc1e6;padding:0px;'>"+bodydiv.outerHTML+ "</div>";
div.style.width=obj.offsetWidth+"px";
div.style.height=(obj.offsetHeight+bodydiv.offsetHeight)+"px";
var divs=$DC.body.getElementsByTagName("div");
window.cardsPosArray=new Array();
var ii=0;
for(var i=0;i<divs.length;i++){if(divs[i].className=="ctlcarditem"){var xy=GetObjectPos(divs[i]);
var ndiv=divs[i].nextSibling;
window.cardsPosArray[ii]={obj:divs[i],x1:xy.left ,y1:xy.top,x2:(xy.left*1+divs[i].offsetWidth),y2:(xy.top*1+divs[i].offsetHeight+ndiv.offsetHeight)}
ii++;}}
$DC.onmousemove=function(){var div=window.currcardmovediv;
if(div.style.display !="block"){div.style.display="block"}
var x=window.event.clientX;
var y=window.event.clientY+$DOE.scrollTop * 1;
div.style.left=parseInt(x-div.offsetWidth / 2)+"px";
div.style.top=parseInt(y-5)+"px";
for(var i=0;i<window.cardsPosArray.length;i++){var o=window.cardsPosArray[i];
if(x>o.x1&&x<o.x2&&y>o.y1&&y<o.y2){if(window.hotCardObject !=o.obj){var candrag=true
if(window.canCardviewItemDragEnd){candrag=window.canCardviewItemDragEnd(beginDragCardObject,o.obj)}
if(window.hotCardObject){window.hotCardObject.style.border="0px solid white";}
if(candrag==true){o.obj.style.border="2px solid blue";
window.hotCardObject=o.obj;}
else{window.hotCardObject=null;
return;}}
return;}}}}
function __carditemclose(itemid){if(window.confirm("是否确定不显示本栏目？")){var loaditem=$ID(itemid);
ajax.regEvent("sys_ctl_cardcloseitem");
$ap("key",loaditem.getAttribute("key"));
var r=ajax.send();
if(r !="ok"){alert("取消栏目失败",r)}
else{window.location.reload();
return;
var disObj=new Array();
var pobj=loaditem.parentNode;
disObj[0]=loaditem;
disObj[1]=loaditem.nextSibling;
disObj[2]=loaditem.previousSibling;
try{disObj[3]=loaditem.nextSibling.nextSibling;} catch (e){disObj[3]=null;}
for(var i=0;i<disObj.length;i++){try{disObj[i].parentNode.removeChild(disObj[i]);} catch (e){}}
while (pobj&&pobj !=$DC.body){if(pobj.getAttribute("cachehtml")){pobj.setAttribute("cachehtml",pobj.innerHTML);
return false;}
pobj=pobj.parentNode}}}}
function __carditemrefresh(itemid ,advAttr,orderattr){var loaditem=$ID(itemid);
var ax=new xmlHttp();
ax.regEvent("sys_ctl_cardloaditem");
if($ID("crd_"+itemid+"_s_t1")){ax.addParam("s_t1",$ID("crd_"+itemid+"_s_t1").value);}
if($ID("crd_"+itemid+ "_s_t2")){ax.addParam("s_t2",$ID("crd_"+itemid+"_s_t2").value);}
if($ID("crd_"+itemid+"_s_tag")){ax.addParam("s_tag",$ID("crd_"+itemid+"_s_tag").value);}
var sbox=loaditem.getElementsByTagName("select");
if(sbox.length>0)
{if(sbox[0].className=="lvw_pgsize")
{ax.addParam("lvwpagesize",sbox[0].value);}}
ax.addParam("id",loaditem.getAttribute("parentId"));
ax.addParam("index",loaditem.id.split("item")[1]);
ax.addParam("key",loaditem.getAttribute("key"));
ax.addParam("tag",loaditem.getAttribute("tag"));
if(advAttr&&advAttr.length>0)
{var d=new Array();
for(var i=0;i< advAttr.length;i++)
{d[d.length]=advAttr[i].join("\1");}
ax.addParam("advattr",d.join("\2"));
d=null;}
ax.send(
function (r){var div=$ID("body"+itemid);
div.innerHTML=r;
var p=div.parentNode;
while (p){if(p.getAttribute&&p.getAttribute("cachehtml") !=null){p.setAttribute("cachehtml",p.innerHTML);
break;}
p=p.parentNode;}
if(window.oncarditemrefresh){window.oncarditemrefresh(div);}}
);
ax=null;}
function __cardmsrchange(t,id)
{var t1=$ID("crd_"+id+"_s_t1");
var t2=$ID("crd_"+id+"_s_t2");
ajax.regEvent("sys_getsystime");
$ap("type",t);
$ap("currtime",t1.value);
var r=ajax.send();
r=r.split(";")
t1.value=r[0];
t2.value=r[1];
app.fireEvent(t1,"onchange");}
function __sys_loadcardbody(id,disloadnext)
{var div=$ID("cardview_"+id);
var count=div.getAttribute("count");
var curr=div.getAttribute("currloadIndex");
if(!curr){curr=0;}
var itemid="c_"+id+"_item"+curr;
var loaditem=$ID(itemid);
if(!loaditem){return;}
var ax=new xmlHttp();
ax.regEvent("sys_ctl_cardloaditem");
if($ID("crd_"+itemid+"_s_t1")){ax.addParam("s_t1",$ID("crd_"+itemid+"_s_t1").value);}
if($ID("crd_"+itemid+ "_s_t2")){ax.addParam("s_t2",$ID("crd_"+itemid+"_s_t2").value);}
if($ID("crd_"+itemid+"_s_tag")){ax.addParam("s_tag",$ID("crd_"+itemid+"_s_tag").value);}
ax.addParam("id",id);
ax.addParam("index",curr);
ax.addParam("key",loaditem.getAttribute("key"));
ax.addParam("tag",loaditem.getAttribute("tag"));
ax.send(__sys_loadcardbodyresult(id,curr,count,false));
ax=null;}
function __sys_loadcardbodyresult(id,curr,count,disloadnext){return function (r){var div=$ID("bodyc_"+id+"_item"+curr);
div.innerHTML=r;
var obj=$ID("cardview_"+id);
curr++;
obj.setAttribute("currloadIndex",curr);
if(curr<count&&!disloadnext){setTimeout("__sys_loadcardbody('"+id+"')",10);}
else{var p=div.parentNode;
while (p){if(p.getAttribute&&p.getAttribute("cachehtml") !=null){p.setAttribute("cachehtml",p.innerHTML);
break;}
p=p.parentNode;}
obj.setAttribute("currloadIndex",0);
if(window.oncardloadComplete){window.oncardloadComplete(id);}}}}
function showCardSearchList(obj)
{var v=obj.getAttribute("datavalue").split("|");
var cm=new ContextMenuClass(obj);
for(var i=0;i< v.length;i++)
{if(v[i]&&v[i].length>0){cm.menus.add(v[i] ,v[i]  ,"");}}
cm.onitemclick=function(o){var id=obj.parentNode.children[0].id;
var t=o.getAttribute("text");
if(t=="最近一周"||t=="最近三天"||t=="最近一月"){var t1=(id+"@t").replace("_s_tag@t","_s_t1");
var t2=(id+"@t").replace("_s_tag@t","_s_t2");
ajax.regEvent("sys_getsystime");
$ap("type",o.getAttribute("text"));
var r=ajax.send();
r=r.split(";")
$ID(t1).value=r[0];
$ID(t2).value=r[1];
app.fireEvent($ID(t2),"onchange");}
else{obj.parentNode.children[0].value=t;
var pobj=obj.parentNode.parentNode.parentNode.parentNode;
__carditemrefresh(pobj.getAttribute("parentId"));}}
cm.show();
cm.BindElement(obj,0,obj.offsetHeight+(app.IeVer<8?6:3));}
function ExtformatData(input,oldevent,type)
{return function()
{if(oldevent){oldevent();}
input.setAttribute("fnumTimer",setTimeout(function(){formatData(input,type,1);},1));}}
function formatData(obj, type, notf, maxl)
{
	if(typeof(notf) == "undefined"){ notf = 1; } //默认不可以为负数
	if(typeof(maxl) == "undefined"){ maxl = 500;}
	var ov = obj.getAttribute("oldvalue");
	var v = obj.value;
	var nup = 0;
	var fnum = "a";
	if(app.getIEVer() < 100 && window.event.propertyName!="value") {return;}	// 只在IE下执行
	if (obj.getAttribute("fving") == 1) { return; }
	if (!type) { type = obj.getAttribute("dataformat"); }
	if(!type) {type = obj.getAttribute("datatype");}
	if(!ov) {ov = obj.defaultValue;}
	if(v.length>maxl*1) {v=v.substr(0,maxl);nup=1;}
	switch(type)
	{
		case "float":
			v = v.replace(" ","z");  //使空格不为数字
			if(isNaN(v)){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}else{
				if(nup==1) { obj.setAttribute("fving",1); obj.value = v; obj.setAttribute("fving",0) }	
			}
			break;
		case "zk":
			fnum = window.sysConfig.zkmumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "hl":
			fnum = window.sysConfig.hlnumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "money":
			fnum = window.sysConfig.moneynumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "CommPrice":
			fnum = window.sysConfig.CommPriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "SalesPrice":
			fnum = window.sysConfig.SalesPriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "StorePrice":
			fnum = window.sysConfig.StorePriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "FinancePrice":
			fnum = window.sysConfig.FinancePriceDotNum;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "number":
			fnum = window.sysConfig.floatnumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "number2":
			fnum = 2;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "int":
			if(isNaN(v) || v.indexOf(".") >= 0){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}else{
				if(nup==1) { obj.setAttribute("fving",1); obj.value = v; obj.setAttribute("fving",0) }	
			}
			break;
		default:
	}
	if (notf == 1 && v < 0 ){
		v = v.replace("\-","");
		obj.value = v;
	}
	if(!isNaN(fnum))
	{
		var cv = v;
		var f = isNaN(v) || v.length==0;
		if (f == false) {
		    var s = v.toString().split(".");
		    if (s.length == 2) {
		        if (s[1].length > fnum) {
		            s[1] = s[1].substr(0, fnum);
		        }
		        v = s[0] + "." + s[1]
		    }
		}
		else {
		    if (v.replace(/\s/g, "").length == 0) {
		        //在属性更改事件中判断是否为空有问题，改为在按键弹起事件中判断
		        //v = "0";
		        //window.setTimeout(function (){obj.select();},100);
		        if (!obj.onkeyup) {
		            obj.onkeyup = function () {
		                 if (obj.value.length == 0 && obj.getAttribute("cannull")!="1" && obj.defaultValue!="") {
		                    obj.setAttribute("fving", 1);
		                    obj.value = 0
		                    obj.select();
		                    obj.setAttribute("fving", 0)
		                }
		            }
		        }
		    }
		    else {
		        v = ov;
		    }
		}
		if(cv!=v) {
			obj.setAttribute("fving",1);
			obj.value = v;
			obj.setAttribute("fving",0)
		}
	}
	obj.setAttribute("oldvalue", obj.value);
}
function clearinput(obj,divid)
{if(!obj.checked)
{var divobj=$ID(divid);if(!divobj) {return}
var chkobj=divobj.getElementsByTagName("input");
for(var i=0;i<chkobj.length;i++)
{if(chkobj[i].type=="checkbox"&&chkobj[i].checked&&(chkobj[i].name=="W3"||chkobj[i].name=="W2"))
{if(chkobj[i].name=="W2"&&chkobj[i].checked)
{chkobj[i].click();}
else{chkobj[i].checked=false;}}}}}
function menumoreItemOut(){if(window.curroutmoreMenuItem){var o=window.curroutmoreMenuItem.xyObj;
if(!o){o=fGetXY(window.curroutmoreMenuItem);
window.curroutmoreMenuItem.xyObj=o;}
var w=window.curroutmoreMenuItem.offsetWidth;
var h=window.curroutmoreMenuItem.offsetHeight;
var cx=window.event.clientX;
var cy=window.event.clientY;
if(cx<o.x||cx>o.x+w||cy<(o.y-20)||cy>o.y+h){window.curroutmoreMenuItem.style.display="none";}}}
$DC.onmousemove=function(){if(app.IeVer==6){menumoreItemOut();}}
app.cookie=new Object();
app.cookie.add=function(n,v,d)
{var cookie=$DC.cookie;
var str=n+"="+escape(objValue);
if(!d){d=0;}
if(d>0){var date=new Date();
var ms=d*24*3600*1000;
date.setTime(date.getTime()+ms);
str +=";expires="+date.toGMTString();}
$DC.cookie=str;}
function __onicoitemEditBlurHandle(id,em,td,html)
{return function()
{var v=em.value;
if(v==""){v=" "}
td.innerHTML=html;
td.children[0].innerText=v;
$ID(td.id.replace("ivw_et","ivw_t")).children[0].innerText=v;
eval("if(window."+id+"_onicoitemsetText){"+id+"_onicoitemsetText(td,v);}");}}
function __onicoitemEdit(id,obj){var html=obj.parentNode.innerHTML;
var td=obj.parentNode;
var v=obj.innerText;
td.innerHTML="<textarea maxlength='20' cols=10 rows=10 onkeydown='if(event.keyCode==13){this.blur();return false;};' class='ivw_edit_box' style='width:"+(td.offsetWidth-10)+"px;height:"+obj.offsetHeight+"px'></textarea>";
var elm=td.children[0];
elm.value=v;
elm.focus();
elm.select();
if(elm.attachEvent)
{elm.attachEvent("onblur",__onicoitemEditBlurHandle(id,elm,td,html));}
else
{elm.addEventListener("blur",__onicoitemEditBlurHandle(id,elm,td,html));}}
function __ivw_onattritem(id,obj){return eval("if(window."+id+"_onicoitemsetAttr){"+id+"_onicoitemsetAttr(obj);}");}
function __ivw_ondelitem(id,obj){return eval("if(window."+id+"_onicoitemDel){"+id+"_onicoitemDel(obj);}");}
function __ivw_dragBegin(obj,id)
{var control=obj.parentNode.parentNode;
window.oldIvwItemParent=obj.parentNode;
var tgn=window.event.srcElement.tagName;
if(tgn=="A"||tgn=="TEXTAREA"||tgn=="INPUT"){return true;}
window.defonselectstart=$DC.onselectstart;
window.defonmouseup=$DC.onmouseup;
window.defonmousemove=$DC.onmousemove;
$DC.onselectstart=function(){return false;}
$DC.onmouseup=function(){$DC.onselectstart=null;
$DC.body.style.cursor="";
$DC.onmousemove=window.defonmousemove;
$DC.onmouseup=window.defonmouseup;
if(window.currcardmovediv){window.currcardmovediv.innerHTML="";
window.currcardmovediv.style.display="none";}
if(window.hotCardObject){window.hotCardObject.className=window.hotCardObject.className.replace(" ivw_itemhover","");
var div=$DC.createElement("div");
var pdiv=window.hotCardObject.parentNode;
pdiv.insertBefore(div,window.hotCardObject);
div.swapNode(obj);
try{pdiv.removeChild(div);}catch(e){div.outerHTML="";}
return eval("var r=null;if(window."+id+"_onicoitemDragEnd){r="+id+"_onicoitemDragEnd(window.hotCardObject,obj);};window.hotCardObject=null;div=null;r");}}
if(!window.currcardmovediv){window.currcardmovediv=$DC.createElement("div");
window.currcardmovediv.id="currcardmovediv";
window.currcardmovediv.style.cssText="position:absolute;color:#000000;overflow:hidden;display:none;border:1px solid #667788;filter:Alpha(style=0,opacity=60);background-color:#ffffff;z-index:10000";
$DC.body.appendChild(window.currcardmovediv);}
$DC.body.style.cursor="move";
var div=window.currcardmovediv;
var tb=obj.getElementsByTagName("table")[0]
div.innerHTML="<table style='width:100%;height:100%;border-collapse:collapse;'><tr><td style='background:transparent "+obj.children[1].style.backgroundImage+" no-repeat center center;height:"+(obj.offsetHeight-27)+"px'></td></tr><tr><td align=center style='color:#000'>"+tb.innerText+"</td></tr></table>";
div.style.width=obj.offsetWidth+"px";
div.style.height=obj.offsetHeight+"px";
div.style.backgroundColor="#f6f6fa";
div.style.border="1px solid #e6e6e6";
var divs=control.getElementsByTagName("div");
window.cardsPosArray=new Array();
var ii=0;
for(var i=0;i<divs.length;i++){if(divs[i].className&&divs[i].className.indexOf("ivw_item")>=0){var xy=GetObjectPos(divs[i]);
window.cardsPosArray[ii]={obj:divs[i],x1:xy.left ,y1:xy.top,x2:(xy.left*1+divs[i].offsetWidth),y2:(xy.top*1+divs[i].offsetHeight)}
ii++;}}
$DC.onmousemove=function(){var div=window.currcardmovediv;
if(div.style.display !="block"){div.style.display="block";}
var x=window.event.clientX;
var y=window.event.clientY+$DOE.scrollTop * 1;
div.style.left=parseInt(x-div.offsetWidth / 2)+"px";
div.style.top=parseInt(y-div.offsetHeight / 2)+"px";
for(var i=0;i<window.cardsPosArray.length;i++){var o=window.cardsPosArray[i];
if(x>o.x1&&x<o.x2&&y>o.y1&&y<o.y2){if(window.hotCardObject !=o.obj){var candrag=true
if(window.canCardviewItemDragEnd){candrag=window.canCardviewItemDragEnd(beginDragCardObject,o.obj)}
if(window.hotCardObject){window.hotCardObject.className=window.hotCardObject.className.replace(" ivw_itemhover","");}
if(candrag==true){o.obj.className=o.obj.className+" ivw_itemhover";
window.hotCardObject=o.obj;}
else{window.hotCardObject=null;
return;}}
return;}}}}
function __ivw_G_dragBegin(obj, id) {
	var oldX = fGetXY(obj).x;
    var control = obj.parentNode;
    window.oldIvwItemParent = obj.parentNode;
    var tgn = window.event.srcElement.tagName;
    if (tgn == "A" || tgn == "TEXTAREA" || tgn == "INPUT") { return true; }
    window.defonselectstart = $DC.onselectstart;
    window.defonmouseup = $DC.onmouseup;
    window.defonmousemove = $DC.onmousemove;
    $DC.onselectstart = function () { return false; }
    $DC.onmouseup = function () {
        $DC.onselectstart = null;
        $DC.body.style.cursor = "";
        $DC.onmousemove = window.defonmousemove;
        $DC.onmouseup = window.defonmouseup;
        if (window.currcardmovediv) {
            window.currcardmovediv.innerHTML = "";
            window.currcardmovediv.style.display = "none";
        }
        if (window.hotCardObject) {
            window.hotCardObject.className = window.hotCardObject.className.replace(" ivw_GrouphoverB", "");
			window.hotCardObject.previousSibling.className = window.hotCardObject.previousSibling.className.replace(" ivw_GrouphoverT", "");
            return eval("var r=null;if(window." + id + "_onicoitemGDragEnd){r=" + id + "_onicoitemGDragEnd(window.hotCardObject,obj);};window.hotCardObject=null;div=null;r");
        } 
    }
    if (!window.currcardmovediv) {
        window.currcardmovediv = $DC.createElement("div");
        window.currcardmovediv.id = "currcardmovediv";
        window.currcardmovediv.style.cssText = "position:absolute;color:#000000;overflow:hidden;display:none;border:1px solid #667788;filter:Alpha(style=0,opacity=60);background-color:#ffffff;z-index:10000";
        $DC.body.appendChild(window.currcardmovediv);
    }
    $DC.body.style.cursor = "move";
    var div = window.currcardmovediv;
    var tb = obj.getElementsByTagName("table")[0]
    div.innerHTML = obj.outerHTML ;
	div.children[0].style.marginTop = "0px";
    div.style.width = obj.offsetWidth + "px";
	var vH =  (obj.offsetHeight + obj.nextSibling.offsetHeight);
	vH = vH > 120 ? 120 : vH;
    div.style.height = vH + "px";
    div.style.backgroundColor = "#f6f6fa";
    div.style.border = "1px solid #e6e6e6";
    var divs = control.getElementsByTagName("div");
    window.cardsPosArray = new Array();
    var ii = 0;
    for (var i = 0; i < divs.length; i++) {
        if (divs[i].className && divs[i].className.indexOf("ivw_groupchild") >= 0) {
            var xy = GetObjectPos(divs[i]);
            window.cardsPosArray[ii] = { obj: divs[i], x1: xy.left, y1: xy.top, x2: (xy.left * 1 + divs[i].offsetWidth), y2: (xy.top * 1 + divs[i].offsetHeight) }
            ii++;
        } 
    }
    $DC.onmousemove = function () {
        var div = window.currcardmovediv;
        if (div.style.display != "block") { div.style.display = "block"; }
        var x = window.event.clientX;
        var y = window.event.clientY + $DOE.scrollTop * 1;
        div.style.left = oldX + "px";
        div.style.top = parseInt(y - 15) + "px";
        for (var i = 0; i < window.cardsPosArray.length; i++) {
            var o = window.cardsPosArray[i];
            if (x > o.x1 && x < o.x2 && y > o.y1 && y < o.y2) {
                if (window.hotCardObject != o.obj) {
                    var candrag = true
                    if (window.canCardviewItemDragEnd) { candrag = window.canCardviewItemDragEnd(beginDragCardObject, o.obj) }
                    if (window.hotCardObject) { 
						window.hotCardObject.className = window.hotCardObject.className.replace(" ivw_GrouphoverB", ""); 
						window.hotCardObject.previousSibling.className = window.hotCardObject.previousSibling.className.replace(" ivw_GrouphoverT", "");
					}
                    if (candrag == true) {
                        o.obj.className = o.obj.className + " ivw_GrouphoverB";
						o.obj.previousSibling.className = o.obj.previousSibling.className + " ivw_GrouphoverT";
                        window.hotCardObject = o.obj;
                    }
                    else {
                        window.hotCardObject = null;
                        return;
                    } 
                }
                return;
            } 
        } 
    } 
}
function checkAll2(str){
	var a=document.getElementById("u"+str).getElementsByTagName("input");
	var b=document.getElementById("e"+str);
	for(var i=0;i<a.length;i++){
		a[i].checked=b.checked;
	}
}

Validator =
{
	Require : /.+/,
	Email : /^$|^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/,
	EmailList : /^([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?((\;([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?)*[\;]?)+$/,
	EmailNull :/^(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*)?$/,
	Phone : /^(((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7})$/,
	PhoneNull : /^((((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7}))?$/,
	Mobile : /^(13[0-9]|14[0-9]|15[^4]|17[0-9]|18[0-9])\d{8}$/,
	MobileNull : /^((13[0-9]|14[0-9]|15[^4]|17[0-9]|18[0-9])\d{8})?$/,
	DateTime : /^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)(\ ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9])?$/,
	Url : /^(http|https):\/\/[A-Za-z0-9\-_]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/,
	Money : /^\-?[0-9]+[\.][0-9]{0,4}$/,
	IdCard : /^\d{15}(\d{2}[A-Za-z0-9])?$/,
	Currency : /^\d+(\.\d+)?$/, Number : /^\d+$/,
	Zip : /^$|^[0-9]\d{5}$/,
	QQ : /^$|^[1-9]\d{4,9}$/,
	Integer : /^[-\+]?\d+$/,
	Double : /^[-\+]?\d+(\.\d+)?$/,
	English : /^[A-Za-z]+$/,
	Chinese :  /^[\u0391-\uFFE5]+$/,
	FloatNum :  /^([0-1](\.[\d]+)?)?$/,
	UnSafe : /^(([A-Z]*|[a-z]*|\d*|[-_\~!@#\$%\^&\*\.\(\)\[\]\{\}<>\?\\\/\'\"]*)|.{0,5})$|\s/,
	IsSafe : function(str){return !this.UnSafe.test(str);},
	SafeString : "this.IsSafe(value)",
	Limit : "this.limit(value.replace(/^\\s*/,'').replace(/\\s*$/,'').length,getAttribute('min'),  getAttribute('max'))",
	LimitB : "this.limit(this.LenB(value.replace(/^\\s*/,'').replace(/\\s*$/,'')), getAttribute('min'), getAttribute('max'))",
	Date : "this.IsDate(value, getAttribute('min'), getAttribute('format'))",
	Repeat : "value == document.getElementsByName(getAttribute('to'))[0].value",
	Range : "(!getAttribute('min') || getAttribute('min') <= Number(value.replace(/\,/g,''))) && (!getAttribute('max') || Number(value.replace(/\,/g,'')) <= getAttribute('max').replace(/\,/g,'')*1)",
	Compare : "this.compare(value,getAttribute('operator'),getAttribute('to'))",
	Custom : "this.Exec(value, getAttribute('regexp'))",
	Group : "this.MustChecked(getAttribute('name'), getAttribute('min'), getAttribute('max'))",
	number:  /.+/,
	ErrorItem : [document.forms[0]],
	ErrorMessage : ["以下原因导致提交失败：\t\t\t\t"],
	Validate : function(date, mode)
	{
		
		var obj = date || event.srcElement;
		var count = obj.elements.length;
		this.ErrorMessage.length = 1;
		this.ErrorItem.length = 1;
		this.ErrorItem[0] = obj;
		for(var i=0;i<count;i++)
		{
			with(obj.elements[i])
			{
				var _dataType = getAttribute("dataType");
				if(typeof(_dataType) == "object" || typeof(this[_dataType]) == "undefined")  continue;
				this.ClearState(obj.elements[i]);
				if(getAttribute("require") == "false" && value == "") continue;
				switch(_dataType)
				{
					case "Date" :
					case "Repeat" :
					case "Range" :
					case "Compare" :
					case "Custom" :
					case "Group" :
					case "Limit" :
					case "LimitB" :
					case "SafeString" :
						if(!eval(this[_dataType])){this.AddError(i, getAttribute("msg"));}
						break;
					default :
						if(_dataType!='number'&&!this[_dataType].test(value)){this.AddError(i, getAttribute("msg"));}//
						break;
				}
				if(_dataType=="number"){
					if (isNaN(value)==true || value.toString().length==0){
						setAttribute("msg","请输入正确数字");
						this.AddError(i, getAttribute("msg"));
					}
					else{
						var max = getAttribute("max");
						if(max!=null && !isNaN(max) && (value-max>0)){setAttribute("msg","不能大于" + max); this.AddError(i, getAttribute("msg")); break;}
						var min = getAttribute("min");
						if(min!=null && !isNaN(min) && (value-min<0)){setAttribute("msg","不能小于" + min); this.AddError(i, getAttribute("msg")); break;}
						var limit = getAttribute("limit");
						if(limit!=null && !isNaN(limit) && (value-limit<=0)){setAttribute("msg","必须大于" + limit); this.AddError(i, getAttribute("msg")); break;}
					}
					//break;
				}
			}
		}
		if(this.ErrorMessage.length > 1)
		{
			mode = mode || 1;
			var errCount = this.ErrorItem.length;
			switch(mode)
			{
				case 2 :
					for(var i=1;i<errCount;i++)	this.ErrorItem[i].style.color = "red";
				case 1 :
					for(var i=1;i<errCount;i++)
					{
						try
						{
							var span = document.createElement("SPAN");
							span.id = "__ErrorMessagePanel";
							span.style.color = "red";
							this.ErrorItem[i].parentNode.appendChild(span);
							span.innerHTML = this.ErrorMessage[i].replace(/\d+:/,"");
						}
						catch(e)
						{
							alert(e.description);
						}
					}
					try
					{
						this.ErrorItem[1].focus();
					}
					catch(e){}
					break;
				case 3 :
					for(var i=1;i<errCount;i++)
					{
						try
						{
							var span = document.createElement("SPAN");
							span.id = "__ErrorMessagePanel";
							span.style.color = "red";
							this.ErrorItem[i].parentNode.appendChild(span);
							span.innerHTML = this.ErrorMessage[i].replace(/\d+:/,"");
						}
						catch(e)
						{
							alert(e.description);
						}
					}
					try
					{
						this.ErrorItem[1].focus();
					}
					catch(e){}
					break;
				default :
					alert(this.ErrorMessage.join("\n"));
					break;
			}
			return false;
		}
		return true;
	},
	limit : function(len,min, max)
	{
		min = min || 0;
		max = max || Number.MAX_VALUE;
		return min <= len && len <= max;
	},
	LenB : function(str)
	{
		return str.replace(/[^\x00-\xff]/g,"**").length;
	},
	ClearState : function(elem)
	{
		with(elem)
		{
			if(style.color == "red") style.color = "";
			var lastNode = parentNode.childNodes[parentNode.childNodes.length-1];
			if(lastNode.id == "__ErrorMessagePanel") parentNode.removeChild(lastNode);
		}
	},
	AddError : function(index, str)
	{
		this.ErrorItem[this.ErrorItem.length] = this.ErrorItem[0].elements[index];
		this.ErrorMessage[this.ErrorMessage.length] = this.ErrorMessage.length + ":" + str;
	},
	Exec : function(op, reg)
	{
		return new RegExp(reg,"g").test(op);
	},
	compare : function(op1,operator,op2)
	{
		switch (operator)
		{
			case "NotEqual":
				return (op1 != op2);
			case "GreaterThan":
				return (op1 > op2);
			case "GreaterThanEqual":
				return (op1 >= op2);
			case "LessThan":
				return (op1 < op2);
			case "LessThanEqual":
				return (op1 <= op2);
			default:
				return (op1 == op2);
		}
	},
	MustChecked : function(name, min, max)
	{
		var groups = document.getElementsByName(name);
		var hasChecked = 0;
		min = min || 1;
		max = max || groups.length;
		for(var i=groups.length-1;i>=0;i--)	if(groups[i].checked) hasChecked++;
		return min <= hasChecked && hasChecked <= max;
	},
	IsDate : function(op, min,formatString)
	{
		if ( ( (op == null ) || (op =="") ) && ( (min == null ) || (min =="") ) ) return true;
		formatString = formatString || "ymd";
		var m, year, month, day;
		switch(formatString)
		{
			case "ymd" :
				m = op.match(new RegExp("^((\\d{4})|(\\d{2}))([-./])(\\d{1,2})\\4(\\d{1,2})$"));
				if (m == null ) return false;
				day = m[6];
				month = m[5]--;
				year =  (m[2].length == 4) ? m[2] : GetFullYear(parseInt(m[3], 10));
				break;
			case "dmy" :
				m = op.match(new RegExp("^(\\d{1,2})([-./])(\\d{1,2})\\2((\\d{4})|(\\d{2}))$"));
				if(m == null ) return false;
				day = m[1];
				month = m[3]--;
				year = (m[5].length == 4) ? m[5] : GetFullYear(parseInt(m[6], 10));
				break;
			default :
				break;
		}
		if(!parseInt(month)) return false;
		month --;
		var date = new Date(year, month, day);
		return (typeof(date) == "object" && year == date.getFullYear() && month == date.getMonth() && day == date.getDate());
		function GetFullYear(y)
		{
			return ((y<30 ? "20" : "19") + y)|0;
		}
	}
}

app.getUrlItem = function(itemname) {
	var itemname = itemname.toLowerCase();
	var urls = window.location.href.split("?");
	if(urls.length>1) {
		var items = urls[1].split("&");
		for (var i = 0; i < items.length ; i++)
		{
			var att = items[i].split("=");
			if(att[0].toLowerCase()==itemname) {
				return att[1];
			}
		}
		return "";
	}
	else{
		return "";
	}
}
window.OpenNoUrl = function(url, name, attr) {
	//通过代理的方式，屏蔽url
	var currhref = window.location.href;
	if(currhref.indexOf("?")>-1){
		currhref = currhref.split("?")[0];
	}
	var urls = currhref.split("/");
	urls[urls.length-1] = url;
	window.currOpenNoUrl= urls.join("/");
	window.open(  window.virpath + "inc/datawin.asp", name, attr);
}



function __as_tck_nck(nd) {
	var ck = nd.checked;
	if($ID(nd.id + "_b")) {
		$ID(nd.id + "_b").style.display = ck ? "" : "none";
		nd.parentNode.style.clear = ck  ? "both" : "none";
	}
}

//数字位数校验
function checkNumDot(sid,num_dot){
	var obj = typeof(sid)=="string" ? document.getElementById(sid) :  sid;
	var txtvalue = obj.value ;//正则获取的是数字
	if (txtvalue != "")	{
		if (txtvalue.length>15)		{
			txtvalue = txtvalue.substr(0,15);
			obj.value = txtvalue;
		}
	}
	if (txtvalue.indexOf('.')>=0)	{
		var txt1,txt2,txt3;
		txt1=txtvalue.split('.');		
		txt2=txt1[0];
		if(txt2.indexOf('-')>=0){txt2="-"+txt2.replace(/\-/g,'');}
		txt3=txt1[1].replace(/\-/g,'');		
		if (txt2.length==0){
			txt2="0";
		}else{
			if (txt2.length>15){//整数部分不能大于15位
				txt2=txt2.substr(0,15);
			}			
		}		
		if (txt1.length==2){
			if (txt3.length>num_dot)
			{//小数部分不能大于8位
				txt3=txt3.substr(0,num_dot);
			}
		}	
		obj.value=txt2+"."+txt3;
	}else{//整数不能超过15位
		if (txtvalue.length>15){
			obj.value=txtvalue.substr(0,15);
		}else{
			if (txtvalue.indexOf('-')>=0){
				obj.value="-"+txtvalue.replace(/\-/g,'');
			}
		}
	}
}
function checkDot(sid,num_dot) {
	return checkNumDot(sid,num_dot);
}

//判断录入必须是数字,参数idot为1/0,用于判断是否可以录入小数点
function checkOnlyNum(idot){
	if (idot==null){idot=0;}
	var char_code = window.event.charCode ? window.event.charCode : window.event.keyCode;
	if((char_code<48 || char_code >57) && (idot==0 || (idot=1 && char_code!=46))) {return false;}
}

//按指定的位数格式化小数，不足时补0
function formatNumDot(Num,dot_num){
	var fNum2 = 1;
	var Num2 = "";
	var str0 = "";
	var m = 0;
	for(m=0;m<dot_num;m++){
		fNum2 = fNum2 * 10
	}
	Num2 = Math.round(Num * fNum2)/fNum2;
	if(dot_num>0){
		Num2 = Num2.toString();
		if(Num2.indexOf(".")==-1){
			for(m=1; m<=dot_num; m++){
				str0 += "0";
			}
			Num2 = Num2 + "." + str0;
		}else{
			var arr_num2 = Num2.split(".");
			var dot2 = arr_num2[1];
			for(m=dot2.length; m<dot_num; m++){
				str0 += "0";
			}
			Num2 = Num2 + str0;
		}
	}
	return Num2;
}

function FormatNumber(srcStr,nAfterDot)        //nAfterDot表示小数位数
{
	if(nAfterDot==0) {return parseInt(srcStr);}
	srcStr=(srcStr+'').replace(",","");
	if (isNaN(srcStr)) return  "0";
	srcStr=(Math.round(srcStr*Math.pow(10,nAfterDot))/Math.pow(10,nAfterDot)).toString();
	var v=srcStr.split(".");
	var num=v.length==1?(srcStr+ "."+"000000000000".substr(0,nAfterDot)):(srcStr + "000000000000").substr(0,srcStr.indexOf(".")+1+nAfterDot*1);
	return num;
}

//通用导出方法，obj参数是一个json对象，属性如下：
/*
	from : 'url' | 'form' 参数来源类型,url代表自动从url中提取参数，form则需要使用另一个属性“formid”，使用该form中的参数提交,默认是url
	formid : 如果前面使用的是form 则此属性指定form元素的id
	params : 此属性用于指定附加的参数，以“key=value&key2=value2”格式，参数需要转码，目前底层采用get方式提交，需考虑参数长度问题
	page : 导出页面的路径
*/
window.exportExcel = function(obj){
	obj = obj || {from : 'url'} ;
	obj.from = obj.from || 'url';
	obj.postParams = obj.postParams || [];
	var debug = obj.debug || false;

	var $frm=jQuery("#listview_dIframe");
	if($frm.size()==0){
		var $div = jQuery("<div style='width:460px;position:fixed;_position:absolute;left:28%;top:150px;z-index:10000;'/>")
			.attr('id','lvw_xls_proc_bar')
			.appendTo(document.body);
		$frm = jQuery("<form style='background-color:lightblue;text-align:center;line-height:30px;position:absolute;left:"+(debug?0:-100)+"px;top:"+(debug?0:-100)+"px;width:"+(debug?300:1)+"px;height:"+(debug?400:1)+"px;display:inline' target='lvwexcelfrm'>"+
						"<span style='cursor:hand' onclick='jQuery(this).parent().css({left:-1000,top:-1000})'>关闭调试窗口</span>" +
						"<iframe style='height:"+(debug?370:1)+"px;width:"+(debug?300:1)+"px' frameborder=1 id='lvwexcel_frm' name='lvwexcelfrm'></iframe></form>")
			.attr('id','listview_dIframe')
			.attr('name','listview_dr')
			.attr('method','post')
			.appendTo(document.body);
		for(var i=0; i<obj.postParams.length; i++) {
			jQuery("<input type='hidden' name='" + obj.postParams[i].n + "' value=\"" + obj.postParams[i].v + "\">").appendTo($frm);
		}
	}else{
		$frm.children(':hidden').remove();
		for(var i=0; i<obj.postParams.length; i++) {
			jQuery("<input type='hidden' name='" + obj.postParams[i].n + "' value=\"" + obj.postParams[i].v + "\">").appendTo($frm);
		}
		var $div = jQuery("#lvw_xls_proc_bar")
		if($div.css("display")=="block"){return;}
		if(obj.debug){
			$frm.css({left:0,top:0});
		}
		$div.show();
	}

	$div.empty().html(""
		+"<TABLE class=sys_dbgtab8 cellSpacing=0 cellPadding=0  style='width:460px;' align='center'>"
		+"<TBODY>"
			+"<TR><TD style='HEIGHT: 20px' class=sys_dbtl></TD><TD class=sys_dbtc></TD><TD class=sys_dbtr></TD></TR>"
			+"<TR>"
				+"<TD class=sys_dbcl style='padding-top:22px;padding-bottom:22px;'></TD>"
				+"<TD style='border:0px solid #c0ccdd;background-color:white;padding:12px;background-color:#fff;' valign='top' id='lxls_by'>"
					+"<div id='lxls_by_progress'>"
					+"	<span id='lxls_status'>正在生成Excel文档,<span id='lvw_xls_p_bar_st'>请稍候<span id='lxls_t'></span>...</span></span>"
					+"	<div style='margin-top:10px;margin-bottom:10px;border:1px solid #c0ccdd;height:8px;font-size:8px;background-color:white;'>"
					+"		<div id='lxls_pv' style='height:8px;font-size:8px;background-color:#3333dd;width:0%;margin-top:0px'></div>"
					+"	</div>"
					+"</div>"
				+"</TD>"
				+"<TD class=sys_dbcr></TD>"
			+"</TR>"
			+"<TR><TD class=sys_dbbl></TD><TD class=sys_dbbc></TD><TD class=sys_dbbr></TD></TR>"
		+"</TBODY>"
		+"</TABLE>"
	);

	var oriPage;
	switch (obj.from.toLowerCase()){
		case 'form' :
			if (!obj.formid){alert('请指定表单id');return;}
			$frm = jQuery('#'+obj.formid);
			oriPage = $frm.attr('action');
			$frm.attr('target','lvwexcelfrm').attr('action',obj.page);
			break;
		case 'form_with_page_action' :
			$frm.attr('action',obj.page);
			break;
		case 'url' :
		default :
			var allurl=document.URL.split("?");
			var baseparam="";
			if (allurl.length > 1) {
				baseparam = allurl[1].replace(/\#/g, ""); 
				obj.page += (obj.page.indexOf('?')>0?'&':'?') + baseparam
			}
			$frm.attr('action',obj.page)
	}
	$frm.submit();
	if (obj.from.toLowerCase()=='form'){
		$frm.attr('target','').attr('action',oriPage);
	}
}


function sendCancelRequest(rids,cfgId,subCfgId,oids,lvwid , callback){
	if (!confirm('确定要取消该提醒吗？')) return ;
	lvwid = lvwid || 'mlistvw';
	jQuery.ajax({
		url:'../inc/ReminderCall.asp?act=cancel',
		data:{rid:rids,cfgId:cfgId,subId:0,oid:oids},
		cache:false,
		success:function(h){
			if (callback)
			{
				callback.call(this,arguments);
			}else{
				lvw_refresh(lvwid);
			}
		},
		error:function(rep){
			var $div = jQuery('<div style="position:absolute;left:0px;top:0px;width:50%;height:50%;z-index:9999"></div>');
			$div.html(rep.responseText).appendTo(document.body);
		}
	});
}

function loadPagePrintHack() {
	window.onafterprint = function() {
		if($ID("comm_itembarText")) {
			ajax.regEvent("sys_saveprintLog");
			ajax.addParam("title", $ID("comm_itembarText").innerText || $ID("comm_itembarText").textContent);
			ajax.send(function(r){});
		}
	}
}

//--- 编辑器图片显示控制 begin ---
window.__ImgBigToSmall = function(w,h,delay){
	delay = delay || 500;
	setTimeout(function () {
		try{
			var defWidth = w || 200;	
			var defHeight = h || 150;
			$(".ewebeditorImg img,.ewebeditorImg_plan img").each(function (index, element) {
				var parentsVal = $(this).closest(".ewebeditorImg_plan").html();		//判断是否为日程列表 不是则返回 null
				var w  = $(this).width();	//实际宽度
				var h  = $(this).height(); //实际高度
				//缩放后的高度 =（默认宽度*实际高度）/ 实际宽度
				if(w > defWidth){
					var thumbH = (defWidth * h) / w;
					$(this).attr({ width: defWidth, height: thumbH });				
				}
				//缩放后的宽度 =（默认高度*实际宽度）/ 实际高度
				else if(h > defHeight){
					var thumbW = (defHeight * w) / h;	
					$(this).attr({ width: thumbW, height: defHeight });	
				}
				
				//判断日程列表不显示弹出框
				if (parentsVal == null && window.currUserId!==0) {
					//缩放后的图片可点击，弹出窗口显示原图
					if(w > defWidth || h > defHeight){
						$(this).css({ margin: '5px', cursor: 'pointer' });	
						$(this).attr("title","点击放大查看原图"); 
						var url = $(this).attr("src");						
						$(this).click(function () {
						    window.open(window.virpath + 'inc/img.asp?url=' + escape(url))
						});
					}
				}
				
			});
		
		}catch(e){
			
		}
	},delay);

}
//--- 编辑器图片显示控制 end ---
app.easyui = new Object();
app.easyui.createWindow = function(id, title, optionsobj) {
	var w = $ID(id);
	if(!w) {
		w = document.createElement("div");
		w.id = id;
		w.className = "easyui-window";
		w.title = title
		w.setAttribute("closed", "true");
		w.innerHTML = "&nbsp;";
		w.style.backgroundColor = optionsobj && optionsobj.backgroundColor ? optionsobj.backgroundColor : "#f0f0f5";
		document.body.appendChild(w);
	}
	var options = optionsobj ? optionsobj : {"width" : 600, "height" : 400 };
	if(!optionsobj.top && document.body.offsetHeight>1500) { optionsobj.top = (120 + document.body.scrollTop + document.documentElement.scrollTop ) + "px"; }
	if(!$('#' + id).window) {
		app.Alert("函数【bill.easyui.createWindow】执行失败，调用BillPage框架时，需要显式加载EasyUI相关js。")
		return;
	}
	if(!window.XMLHttpRequest) {
		$('#' + id).window(options).data().window.shadow.append('<iframe width="100%" height="100%" frameborder="0" scrolling="no"></iframe>');
	}else{
		$('#' + id).window(options);
	}
	$('#' + id).window('open');
	return w;
}
//编辑器预览弹层控制start---
function FilePreviewAndDownload() {
    var FILETYPE = ['txt', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf']
    $(document).find(".ewebeditorImg a").bind("mouseover", function (e) {
        var type = e.target.innerText.split(".");
        if (type[type.length - 1] && (FILETYPE.join(",").indexOf(type[type.length - 1]) >= 0 || type[type.length - 1].indexOf("预览下载") >= 0) && e.target.getAttribute("href")) {
            window.paramLinkAdress = e.target.href.substr(e.target.href.indexOf("pf="));
            window.EDITORLOADLINK = e.target;
            if (!e.target.children.length) {
                var div = document.createElement("span");
                div.onclick = function () { return false; }
                div.innerHTML = '<span class="darrow"></span><span class="blank"></span><span title="" onclick="window.open(\'../\'+window.virpath +\'sysn/view/comm/UpLoaderFilePreview.ashx?\' + paramLinkAdress,\'newwin80\',\'width=1000,height=820,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100\')" class="preview">预览</span><span title="" onclick="FireEvent1(window.EDITORLOADLINK,\'click\')" class="downloadL">下载</span>'
                $(this).append($(div).addClass("viewAndLoad"))
            }
        }
    })
}

function FireEvent1(obj, eventName) {
    try {
        obj.attachEvent('on' + eventName.toLowerCase().replace("on", ""), function (event) {
            window.open(obj.href, '_self')
        });
    }
    catch (e) {
        var event = document.createEvent('MouseEvents');
        event.initEvent(eventName.toLowerCase().replace("on", ""), true, true);
        obj.dispatchEvent(event);
    }
}

//编辑器预览弹层控制end---
app.easyui.CAjaxWindow = function(id, fun) {
	window.__tmp_bill_ajaxpagetruct = null;
	ajax.regEvent("bll_ajax_page");
	ajax.addParam("key", id);
	if(fun) {fun();}
	var html = ajax.send();
	var o = window.__tmp_bill_ajaxpagetruct;
	o.height=o.height+30;//高度不够
	app.easyui.createWindow(id, o?o.title:"无标题", o).innerHTML = html;
}

app.easyui.closeWindow = function(id) {
	$('#' + id).window('hide');
}

app.showHelp = function(ord) {
	window.open( window.virpath + 'china2/help.asp?V=' + (new Date()).getTime().toString().replace(".","") + (ord? "&urlid=" + ord : "") , 'helpwindow', fwAttr());
	return false
}

// 解决onpropertychange兼容性问题
document.oninput = function(e){
	var code = e.target.getAttribute("onpropertychange");
	eval("(function(){" + code + "})").call(e.target);
}

app.drawVMLCone = function(id, data) {
	function DrawVMLConeRect(context, x1, y1, x2, y2, color){
		var dtx = y1*0.13;
		var dtx2 = y2*0.13;
		
		context.shadowOffsetX = 5; 
		context.shadowOffsetY = -5;
		context.shadowBlur = 8; // 模糊尺寸
		context.shadowColor = 'rgba(0,0,0,0.3)'; // 颜色
		context.beginPath();
		context.moveTo(x1+dtx,y1+13);
		context.lineTo(x2-dtx,y1+13);
		context.lineTo(x2-dtx2,y2+13);
		context.lineTo(x1+dtx2,y2+13);
		context.lineTo(x1+dtx,y1+13);
		context.closePath();
		
		context.fillStyle = color;
		context.fill();

	}
	
	var canvas = $ID("vml_con_" + id);
	context = canvas.getContext("2d");
	var Colors = ("#ff8c19;#ff1919;#ffff00;#1919ff;#00ee19;#fc0000;#3cc000;#ff19ff;#993300;#f60000").split(";");
	var items = data.split("|");
	var dth = 0;
	for (var i = 0; i < items.length ; i++ )
	{
		if(items[i]*1==0) { dth=dth+14;}
	}
	canvas.style.border = "1px solid #aaaaaa";
	canvas.style.height = (canvas.offsetHeight + dth) + "px"
	var y0 = 0;
	var clen = Colors.length-1;
	var sumv = 0;
	var width = items[0]*1;
	var c =  items.length -  2;
	for (var i = 2; i < items.length ; i++)
	{
		sumv = sumv + items[i]*1;
	}
	var itemh = (items[1] - c*5)/sumv;
	for (var i = 2; i < items.length ; i++)
	{
		var h = items[i]*itemh;
		if(h==0) {h=1;}
		DrawVMLConeRect(context, 1, y0, width, y0+h, Colors[(i-2)%clen]);
		y0 = (y0*1 + h + 3)
	}
}

app.ReplaceUrl = function (url, paramName, newcode) {
    newcode = newcode || "";
    paramName = (paramName || "").toLowerCase();
    if (url.indexOf("?") == -1) return url + (newcode.length == 0 ? "" : ("?" + newcode));
    var ups = url.split("?");
    if (ups.length >= 1) {
        ps = ups[1].split("&");
        if (paramName.length > 0) {
            for (var i = 0; i < ps.length; i++) {
                if (ps[i].toLowerCase().indexOf(paramName) == 0) {
                    ps.splice(i, 1);
                    break;
                }
            }
        };
        if (newcode.length > 0) { ps.push(newcode); }
        ups[1] = ps.join("&");
    }
    return ups[1] ? ups.join("?") : ups[0];
}

app.GetLongAttrUrl = function (url, longattrs) {
    var pobj = [];
    if (typeof (longattrs) == "function") {
        var obj = longattrs();
        for (var n in obj)
        { pobj.push({ "n": n, "v": obj[n] }); }
        longattrs = null;
    }
    if (longattrs) {  //长参数处理
        var urls = url.split("?");
        var params = (urls[1] || "").split("&");
        var longattrs = longattrs.replace(";", ",").split(",");
        if (params.length > 0) {
            for (var i = 0; i < params.length; i++) {
                for (var ii = 0; ii < longattrs.length; ii++) {
                    if (params[i].toLowerCase().indexOf(longattrs[ii].toLowerCase() + "=") == 0) {
                        var v = params[i].substr(longattrs[ii].length + 1);
                        var n = params[i].substr(0, longattrs[ii].length);
                        if (v.length > 0) {
                            pobj.push({ n: longattrs[ii], v: decodeURIComponent(v.replace(/\+/g, " ")) });
                            url = app.ReplaceUrl(url, n, "");
                        }
                    }
                }
            }
        }
    }
    if (pobj.length > 0) {
        var mn = window.location.href.split("?")[0] + name;
        var murl = ajax.url;
        ajax.url = window.virpath + '../SYSN/view/comm/CacheManager.ashx?__sys_msgid=sdk_sys_RegLongUrlParams';
        ajax.regEvent("");
        $ap("Sign", mn.substr(mn.length - 50, 50));
        $ap("Data", app.GetJson(pobj));
        var r = ajax.send();
        url = app.ReplaceUrl(url, "", "__sys_LongUrlParamsID=" + r);
        ajax.url = murl;
    }
    return url;
}
/**
 * @description 根据URL打开新界面
 * @method app.OpenUrl
 * @constructor
 * @param url {string} URL地址
 * @param name {string} 新页面name标识
 * @param attrs {string} 新页面的UI信息
 * @param longattrs {string} 长参数的处理
 * @example app.OpenUrl("http://www.zbintel.com","AAA","width=1100",null)
 * @return null
 */
app.OpenUrl = function (url, name, attrs, longattrs) {
    if (name == undefined) {
        name = ("W" + (new Date()).getTime()).replace(".", "");
    }
    if (url.indexOf("SYSN/") == 0) { url = "/" + url; }
    if (url && url.toLowerCase().indexOf("/sysn/") == 0) {
        url = (window.virpath + url).replace("//", "/"); //防止绝对路径问题
    }
    if (url && url.indexOf("/SYSN/") > 0) {
        url = (window.virpath + "../SYSN/" + url.split("/SYSN/")[1]).replace("//", "/"); //防止绝对路径问题
    }

    if (url.indexOf("SYSA/") == 0) { url = "/" + url; }
    if (url && url.toLowerCase().indexOf("/sysa/") == 0) {
        url = (window.virpath + url).replace("//", "/"); //防止绝对路径问题
    }
    if (url && url.indexOf("/SYSA/") > 0) {
        url = (window.virpath + "SYSA/" + url.split("/SYSA/")[1]).replace("//", "/"); //防止绝对路径问题
    }
    url = app.GetLongAttrUrl(url, longattrs);
    if (app.isObject(attrs)) {
        if (!attrs.fullscreen) { attrs.fullscreen = "no"; }
        if (!attrs.toolbar) { attrs.toolbar = "0"; }
        if (!attrs.resizable) { attrs.resizable = "1"; }
        if (!attrs.width) { attrs.width = 1200; }
        if (!attrs.height) { attrs.height = 700; }
        if (attrs.align == "center") {
            var sc = window.screen;
            var w = (sc.availWidth || sc.width);
            var h = (sc.availHeight || sc.height);
            attrs.left = parseInt((w - (attrs.width + "").replace("px", "") * 1) / 2);
            attrs.top = parseInt((h - (attrs.height + "").replace("px", "") * 1) / 2);
        } else {
            if (!attrs.left) { attrs.left = (90 + Math.random() * 20) };
            if (!attrs.top) { attrs.top = (90 + Math.random() * 20) };
        }
        attrsv = "";
        for (var n in attrs) {
            n = n.toLowerCase();
            var iv = attrs[n] + "";
            if ("width,height,top,left,".indexOf(n) != -1) { if (iv.indexOf("px") == -1 && iv.indexOf("%") == -1 && iv.indexOf("em") == -1) { iv = iv + "px"; } }
            attrsv += n + "=" + iv + ",";
        }
        attrs = attrsv;
    } else {
        if (attrs) {
            if (attrs && attrs.indexOf("resizable") == -1) { attrs = (attrs + ",resizable=1").replace(",,", ","); }
        } else {
            attrs = "width=1200px,height=700px,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=" + (90 + Math.random() * 20) + "px,top=" + (60 + Math.random() * 20) + "px";
        }
    }
    var win = window.open(url, name, attrs);
    setTimeout(function () { if (win) win.focus() }, 150);
    return win;
}