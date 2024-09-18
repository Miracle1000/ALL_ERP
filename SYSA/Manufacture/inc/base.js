//binary.2014.03.10.解决已打开窗口再打开时不激活的问题;
//非IE模式下模拟相关IE属性和方法
function __firefox(){
	window.IEObjArrayAttrExt = [];
	HTMLElement.prototype.__defineGetter__("runtimeStyle",__element_style);
	HTMLTableElement.prototype.__defineGetter__("cells",__element_getcells);
	/*模拟生产栏目IE模式下直接书写的属性*/
	var ExtAttrs = ["sBoxArray","listview","hdataArray","PageSize","PageEndIndex","autoindex","checkbox","autosum","delalert","resizeing","resize","mouseDownX","pareneTdW","pareneTableW",
		"dbname","dtype","oid","bid","edit","currFocusCell","formula","selid","isKey","ztlrbtn","candel","state","ywname","oywname","tag","currFocusInput","syshide","deep","JoinList"];
	function ExtAttrFun(t, name){
		return (t==0?(function(){
			for(var i = 0; i<window.IEObjArrayAttrExt.length;i++) {
				if(window.IEObjArrayAttrExt[i].id==this &&  window.IEObjArrayAttrExt[i].nm == name) {
					return window.IEObjArrayAttrExt[i].obj;
				}
			}
			var v = this.getAttribute(name);
			if(v=="true") {return true;}
			if(v=="false") {return false;}
			return v;
		}):(function(v){
			var s = (v && v.constructor) ? v.constructor.toString() : "" ;
			if(s.indexOf("Array")>=0 || s.indexOf("Element")>=0 ) {
				for(var i = 0; i<window.IEObjArrayAttrExt.length;i++) {
					if(window.IEObjArrayAttrExt[i].id==this && window.IEObjArrayAttrExt[i].nm == name) {
						window.IEObjArrayAttrExt[i].obj = v;
						return;
					}
				}
				window.IEObjArrayAttrExt[i] = { "id": this, "obj": v, "nm": name};
				return;
			}
			this.setAttribute(name,v);
		}));
	}
	for (var i = 0 ; i < ExtAttrs.length ; i++ )
	{
		HTMLElement.prototype.__defineGetter__(ExtAttrs[i],ExtAttrFun(0,ExtAttrs[i]));
		HTMLElement.prototype.__defineSetter__(ExtAttrs[i],ExtAttrFun(1,ExtAttrs[i]));
	}

	/*结束属性模拟*/
	HTMLElement.prototype.removeNode = function(){
		var p = this.parentNode?this.parentNode:this.parentElement;
		try{
			p.removeChild(this);
		}catch(e){
			try{
				this.ownerDocument.removeChild(this);
			}catch(e){
			}
		}
	}
	HTMLElement.prototype.fireEvent = function(eventName){
		var evt  = document.createEvent('HTMLEvents');  
        evt.initEvent(eventName.replace("on",""),true,true);  
        this.dispatchEvent(evt);
	}
	HTMLElement.prototype.setCapture = function(){
	
	}
	HTMLElement.prototype.releaseCapture = function(){
		
	}
	
	HTMLElement.prototype.attachEvent = function(Ename, funBack){
		this.addEventListener(Ename.replace("on",""),funBack,false);
	}
	
	document.attachEvent = function(Ename, funBack){
		document.addEventListener(Ename.replace("on",""),funBack,false);
	}
	window.constructor.prototype.__defineGetter__("event",__window_event);
	Event.prototype.__defineGetter__("srcElement",__event_srcElement);
	Event.prototype.__defineGetter__("propertyName",function(){return "value"});
	Event.prototype.__defineGetter__("x",__event_x);
	Event.prototype.__defineGetter__("y",__event_y);


	try {
		if(!HTMLElement.prototype.swapNode) {
			HTMLElement.prototype.swapNode = function(node2) {
					var node1=this;
					var parent=node1.parentNode;
					var parent2=node2.parentNode;
					var t1=node1.nextSibling;
					var t2=node2.nextSibling;

					if(t1) {
						parent.insertBefore(node2,t1);
					} else {
						parent.appendChild(node2);
					};

					if(t2) {
						parent2.insertBefore(node1,t2);
					} else {
						parent2.appendChild(node1);
					};
				}
			}
		}
	catch (e){}
}
function __event_x(){return this.srcElement.getBoundingClientRect().left+document.documentElement.scrollLeft;}
function __event_y(){return this.srcElement.getBoundingClientRect().top+document.documentElement.scrollTop+10;}
function __element_style(){return this.style;}
function __window_event(){return __window_event_constructor();}
function __element_getcells(){
	var  arr = new Array();
	for (var i = 0; i<this.rows.length ;i++ )
	{
		for (var ii = 0; ii<this.rows[i].cells.length ; ii++ )
		{
			arr[arr.length] = this.rows[i].cells[ii];
		}
	}
	return arr;
}
function __event_srcElement(){return this.target;}
function __window_event_constructor(){
	try{
	if(document.all){return window.event;}
	var _caller=__window_event_constructor.caller;
	var tempI = 0
	while(_caller!=null && (tempI++) < 20){var _argument=_caller.arguments[0];
	if(_argument){var _temp=_argument.constructor;
	if(_temp.toString().indexOf("Event")!=-1){return _argument;}}
	_caller=_caller.caller;}}catch(e){}
	return null;
}
if(window.addEventListener&&HTMLElement.prototype.__defineGetter__){__firefox();}

//非IE模式下模拟Window.createPopup
if(!window.createPopup) {
	window.createPopup = function() {
		if(!window.createPopupObj){ window.createPopupObj = new Object(); }
		window.createPopupObj.fm = top.document.getElementById("js_popo_frame");
		if(!window.createPopupObj.fm){
			window.createPopupObj.fm = top.document.createElement("iframe");
			window.createPopupObj.fm.id = "js_popo_frame";
			window.createPopupObj.fm.src = ((top.virpath?top.virpath:(top.sysCurrPath?top.sysCurrPath:"../../")) + "edit/pop.htm");
			window.createPopupObj.fm.frameBorder = "0";
			window.createPopupObj.fm.scrolling = "no";
			window.createPopupObj.fm.style.cssText = "position:absolute;border:1px solid #aaa;z-index:100000;background-color:white;display:none";
			top.document.documentElement.appendChild(window.createPopupObj.fm)
		}
		window.createPopupObj.fmbg = top.document.getElementById("js_popo_framebg");
		if(!window.createPopupObj.fmbg){
			window.createPopupObj.fmbg = top.document.createElement("div");
			window.createPopupObj.fmbg.id = "js_popo_framebg";
			window.createPopupObj.fmbg.style.cssText = "position:fixed;border:1px solid #aaa;z-index:99999;background-color:white;display:none;left:0px;top:0px;width:100%;height:100%;background-color:rgba(0,0,0,0.01)";
			window.createPopupObj.fmbg.innerHTML = "<div style='width:100%;height:100%' onmousedown='document.getElementById(\"js_popo_frame\").style.display=\"none\";document.getElementById(\"js_popo_framebg\").style.display=\"none\";'></div>"
			top.document.documentElement.appendChild(window.createPopupObj.fmbg);
		}
		window.createPopupObj.document = window.createPopupObj.fm.contentWindow.document;
		window.createPopupObj.document.open = function(){
			window.createPopupObj.sys_curr_popMMHtml="";
		}
		window.createPopupObj.document.close = function(){
			window.createPopupObj.sys_curr_popMMHtml="";
		}
		window.createPopupObj.document.write = function(html){
			window.createPopupObj.sys_curr_popMMHtml = window.createPopupObj.sys_curr_popMMHtml + html;
		}
		window.createPopupObj.document.body = window.createPopupObj.fm.contentWindow.document.body;
		window.createPopupObj.show = function(x, y, width, height) {
			var w = window;
			while (w.parent!=w)
			{	
				var  hs = false;
				var ifrms = w.parent.document.getElementsByTagName("iframe");
				for (var i = 0; i< ifrms.length; i++ )
				{
					if(ifrms[i].contentWindow==w) {
						var pos = ifrms[i].getBoundingClientRect();
						x = x*1 + pos.left;
						y = y*1 + pos.top;
						hs = true;
						break;
					}
				}
				if(hs==false) {
					var ifrms = w.parent.document.getElementsByTagName("frame");
					for (var i = 0; i< ifrms.length; i++ )
					{
						if(ifrms[i].contentWindow==w) {
							var pos = ifrms[i].getBoundingClientRect();
							x = x*1 + pos.left;
							y = y*1 + pos.top;
							hs = true;
							break;
						}
					}
				}
				w = w.parent;
			}
			window.createPopupObj.fm.style.left = x + "px";
			window.createPopupObj.fm.style.top = y + "px";
			window.createPopupObj.fm.style.width = width + "px";
			window.createPopupObj.fm.style.height = height + "px";
			window.createPopupObj.fm.style.display = "block";
			window.createPopupObj.fmbg.style.display = "block";
			var html = 	window.createPopupObj.sys_curr_popMMHtml;
			top.sys_curr_popMMWindow = window;
			//window.createPopupObj.fm.contentWindow.showMenu(html.replace(/parent\./g,"window.parentProxy."), window);
		}
		window.createPopupObj.hide =  function(){
			window.createPopupObj.fm.style.display = "none";
			window.createPopupObj.fmbg.style.display = "none";
		}
		return window.createPopupObj;
	}
}


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
var debug = new Object();
debug.copy = function(){
	var dat ="URL: " +  document.getElementById("debug_url").value + "\r\n\r\n\r\nHTML Code:\r\n\r\n" + document.getElementById("debug_body").value
	window.clipboardData.setData("Text",dat);
}
debug.GetTextFile = function(){
	var dat ="……可以在此处输入您的描述，然后将该文件发给客服……\r\n\r\n\r\n\r\n当前页面数据(请不要删除下面数据)\r\n\r\nURL: " +  document.getElementById("debug_url").value + "\r\n\r\n\r\n" + document.getElementById("debug_body").value
	var t = new Date()
	var form = document.getElementById("debug_txt_fileform") 
	if (!form)
	{
		form =  document.createElement("form");
		form.method = "post"
		form.target = "tmp_debug_113_frame"
		form.action = ajax.defUrl();
		form.id = "debug_txt_fileform"
		form.style.cssText = "display:inline"
		form.innerHTML = "<input type='hidden' name='__msgId' value='sys_debug_getTextFile'>"
						 + "<input type='hidden' name='sys_debug_body' id='sys_debug_body'>"
						 + "<iframe name='tmp_debug_113_frame' borderframe=0 width=800 height=300></iframe>";
		document.body.appendChild(form);
	}
	document.getElementById("sys_debug_body").value = dat
	form.submit();
} 


function xmlHttp(){  // ajax简单封装
	var base = new Object()
	base.sendText = ""; //要提交的数据
	base.ascCodev = "﹙ ﹚ ﹛ ﹜ ＋ － × ÷ ﹢ ﹣ ≠ ≤ ≥ ≈ ≡ ≒ ∥ ／ ± ＜ ＞ ﹤ ﹥ ≦ ＝ ≧ ≌ ∽ ≮ ≯ ∶ ∴ ∵ ∷ ⊙ ∑ ∏ ∪ ∩ ∈ ⌒ ⊥ ∠ ㏑ ￠ ㏒ ∟ √ ∨ ∧ ∞ ∝ ∮ ∫ ％ ‰ ℅ ° ℃ ℉ ′ ″ 〒 ¤ ○ ￡ ￥ ㏕ ♂ ♀ △ ▽ ● ○ ◇ □ ·".split(" ");
	base.ascCodec = "%A9v+%A9w+%A9x+%A9y+%A3%AB+%A3%AD+%A1%C1+%A1%C2+%A9%80+%A9%81+%A1%D9+%A1%DC+%A1%DD+%A1%D6+%A1%D4+%A8P+%A1%CE+%A3%AF+%A1%C0+%A3%BC+%A3%BE+%A9%82+%A9%83+%A8Q+%A3%BD+%A8R+%A1%D5+%A1%D7+%A1%DA+%A1%DB+%A1%C3+%A1%E0+%A1%DF+%A1%CB+%A1%D1+%A1%C6+%A1%C7+%A1%C8+%A1%C9+%A1%CA+%A1%D0+%A1%CD+%A1%CF+%A9R+%A1%E9+%A9S+%A8N+%A1%CC+%A1%C5+%A1%C4+%A1%DE+%A1%D8+%A1%D3+%A1%D2+%A3%A5+%A1%EB+%A8G+%A1%E3+%A1%E6+%A8H+%A1%E4+%A1%E5+%A8%93+%A1%E8+%A1%F0+%A1%EA+%A3%A4+%A9T+%A1%E1+%A1%E2+%A1%F7+%A8%8C+%A1%F1+%A1%F0+%A1%F3+%A1%F5+%A1%A4".split("+");

	base.defUrl = function(){
		if (window.location.pathname.indexOf("/")==0)
		{
			return window.location.pathname.replace("//","/")
		}
		else {
			return ("/" + window.location.pathname).replace("//","/")
		}
	}
	base.url = base.defUrl();
	base.getHttp = function(){ //创建http对象
		 var MSXML	=	['Msxml2.XMLHTTP',
						 'Microsoft.XMLHTTP',
						 'Msxml2.XMLHTTP.5.0',
						 'Msxml2.XMLHTTP.4.0',
						 'Msxml2.XMLHTTP.3.0'
						];
		 if (window.XMLHttpRequest) {
		     try { return new XMLHttpRequest(); }
		     catch (e) { } 
		 }
		 for (var i = 0; i < MSXML.length; i++) 
		 {
				try {return new ActiveXObject(MSXML[i]);} 
				catch (e){}
		 }
		
		
	}
	base.Http = base.getHttp(); // 获取http对象
	base.regEvent = function(eventName){ //注册事件
		 try{base.Http.onreadystatechange  = null;}
		 catch(e){}
		 base.sendText = "__msgId=" + escape(eventName);
	}
	
	base.regCtlEvent = function(controlID,eventName){ //注册事件
		 base.regEvent("ctl_event_callback");
		 base.addParam("controlID",controlID);
		 base.addParam("eventName",controlID);
	}

	base.UrlEncode = function (data) {
	    return encodeURIComponent(data);

	    if (!isNaN(data) || !data) { return data; }
	    for (var i = 0; i < base.ascCodev.length; i++) {
	        var re = new RegExp(base.ascCodev[i], "g")
	        data = data.replace(re,"ajaxsrpchari" + i + "endbyjohnny");
	        re = null;
	    }
	    data = escape(data);
	    for (var i = base.ascCodev.length - 1; i > -1; i--) {
	        var re = new RegExp("ajaxsrpchari" + i + "endbyjohnny", "g")
	        data = data.replace(re, base.ascCodec[i]);
	    }
	    data = data.replace(/\+/g, "%2B")
	    return data;
	}

	base.addParam = function(name,value){ //添加参数
	    base.sendText = base.sendText + "&" + base.UrlEncode(name) + "=" + base.UrlEncode(value);
	}
	
	base.ajaxstatuschange = function(callback) { //回调函数
		return  function(){ 
			var http = base.Http;
			if (http.readyState==4)
			{
				base.hideprocc(); 
				var data = "";
				try { data = http.responseText; }
				catch (e) { return ; }
				callback(data);
			}
		}
	}
	base.showprocc = function(){
		var procDiv = document.getElementById("__ajax_proc_div");
		if(!procDiv){
			procDiv = document.createElement("div"); //ById("__ajax_proc_div");
			procDiv.style.cssText = "position:absolute;background-color:#fff;left:40%;top:120px;width:20%;height:50px;border:8px solid #6666cc;display:none;;"
			procDiv.id = "__ajax_proc_div"
			procDiv.innerHTML = "<table align=center style='margin:15px auto 0;'><tr><td><img src='../../images/smico/proc.gif' style='height:20px'></td><td style='color:red'>&nbsp;正在加载,请稍候...</td></tr></table>"
			document.body.appendChild(procDiv);
		}
		procDiv.style.display = "block"
	}
	base.hideprocc = function(){
		var procDiv = document.getElementById("__ajax_proc_div");
		if(procDiv){
			procDiv.style.display = "none"
		}
	}
	base.send = function(callback){ //提交事件
		base.addParam("__ajaxsendTime",(new Date).getTime())
		if (callback) //异步通讯
		{
			 var http = base.Http;
			 http.open("post", base.url , true);
			 http.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			 if(window.ActiveXObject){ http.setRequestHeader("Content-Length", base.sendText.length + ""); }
			 http.onreadystatechange  = base.ajaxstatuschange(callback);
			 http.send(base.sendText);
		}
		else{	//同步通讯
			 var http = base.Http;
			 http.open("post", base.url , false);
			 http.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			 if(window.ActiveXObject){  http.setRequestHeader("Content-Length", base.sendText.length + "");}
			 http.send(base.sendText);
			 return http.responseText;
		}
	}
	base.addParamsById = function(controlid){
		var div = document.getElementById(controlid)
		if(!div) {return false}
		var Inputs = div.getElementsByTagName("INPUT")
		for (var i=0;i<Inputs.length ;i++ )
		{
			if(Inputs[i].id.length>0){
				ajax.addParam(Inputs[i].id,Inputs[i].value)
			}
		}
	}
	base.execCallBack = function(requestText){ //执行脚本回调函数
		try{
			var sc = requestText.split("<ajaxvar>")
			if(sc.length==0){
				eval(requestText)
				return;
			}
			for (var i=1;i<sc.length ;i=i+2 )
			{
				sc[i]="var _sys_ajaxvar=\"" + sc[i].replace(/\"/g,"\\\"").replace(/\r\n/g,"\\n").replace(/\n/g,"\\n") + "\""
			}
			requestText = sc.join(";")
			eval(requestText);
		}
		catch(e){
			var  div = document.createElement("Span")
			div.innerHTML = requestText
			alert("智邦国际生产管理系统		\n\n消息:\n\n" + div.innerText + "\n\n" + e.message)
			div = null
		}
	}

	base.exec = function(isAsynchronous){ //执行返回脚本 , isAsynchronous = true 表示异步通讯
		base.addParam("__execMode","true"); 
		if(isAsynchronous){
			base.send(base.execCallBack);
		}
		else{
			base.execCallBack(base.send(null));
		}
	}
	return base;
} 
window.ajax = new xmlHttp()  //实例化xmlhttp对象

//----------------------------------------------以下是一些通用函数------------------------------------------------------------------
window.PageOpen = function(url,mWidth,mHeight,wName){ //弹出页面
	var w = 860 , h = 640 ;
	if(mWidth){w = mWidth;}
	if(mHeight){h = mHeight;}
	var l = (screen.availWidth - w) / 2
	var t = (screen.availHeight - h) / 2
	var opener1,opener2;
	if(wName)
	{
	 	opener2 = window.open(url,wName,"scrollbars=yes,height=" + h + ",width=" + w + ",left=" + l + ",top=" + t + ",status=no,toolbar=no,menubar=no,location=no,resizable=yes");
		opener2.focus();
	}
	else
	{
		opener1 = window.open(url,null,"scrollbars=yes,height=" + h + ",width=" + w + ",left=" + l + ",top=" + t + ",status=no,toolbar=no,menubar=no,location=no,resizable=yes");
		opener1.focus();
	}
	return wName?opener2:opener1;
}


window.showdlg = function(path,title,width,height,left,top,Params){
	var ax = new xmlHttp();
	var t = new Date();
	if(!Params){
		Params = "";
	}
	if(!width || width==null){width=300}
	if(!height || height == null){height=200}
	ax.url = "../dlg/" + path + ".asp?t=" + t.getTime();
	ax.regEvent("showdlg");
	ax.addParam("params",Params)
	r = ax.send();
	var div = window.DivOpen(path,title,width,height,left,top,true,20);
	div.innerHTML = r;
	var script = div.getElementsByTagName("script")
    for (var i = 0; i < script.length; i++) {
		try{
			window.eval("(function(){" + script[i].innerHTML + "})()")
		}
		catch(e){
			alert("脚本错误:" + e.message)
		}
	}
	ax = null;
}

window.GetDivIndex = function(){
	var zt = new Date();
	return parseInt(zt.getTime()-parseInt(zt.getTime()/1000000)*1000000 )*1
}

window.getDivFormByChild = function(child){ //根据弹出层对话框中的元素获取层对话框
	while(child ) {
		if(child.className == "DIV" && child.className == "divForm") {
			return child;
		}
	}
	return null;
}

window.DivUpdate =  function(id ,title, mWidth,mHeight,mTop,mLeft){
	var div = document.getElementById("divdlg_" + id)
   
	if(isNaN(mWidth)) {mWidth  = undefined;}
	if(isNaN(mHeight)){mHeight = undefined;}
	if(isNaN(mTop))   {mTop    = undefined;}
	if(isNaN(mLeft))  {mLeft   = undefined;}
	if(div){
		var hf = document.getElementById(id + "_hideFrame")
		if(title.length>0){div.children[0].rows[0].cells[0].children[0].innerText = title}
		if(mWidth) {
			div.style.width = mWidth + "px";
			div.children[0].style.width = (mWidth-4) + "px";
			div.children[0].rows[0].cells[0].style.width = (mWidth-40) + "px";
			div.children[0].rows[1].cells[0].children[0].style.width = (mWidth-30) + "px"
			if(hf){hf.style.width =(mWidth-40) + "px"}
		}
		if(mHeight) {
			div.style.height = mHeight + "px";
			div.children[0].style.height = (mHeight-7) + "px";
			try{//这两行代码在低版本ie下报错
				div.children[0].rows[1].cells[0].style.height = (mHeight-44) + "px"
			    div.children[0].rows[1].cells[0].children[0].style.height = (mHeight-58) + "px"
			}catch(e){}

		
			if(hf){hf.style.height =(mHeight - 44) + "px"}
		}
		if(mTop) {
			div.style.top = mTop + "px";
		}
		if(mLeft) {
			div.style.left = mLeft + "px";
		}
	}

}

window.disScrollParent = function(obj){
	var elm = window.event.srcElement;
	if((elm.tagName=="TEXTAREA" || elm.tagName=="SELECT") && document.activeElement==elm){
		return true;
	}
	window.event.cancelBubble=true;
	window.event.returnValue=false;
	obj.children[0].scrollTop = obj.children[0].scrollTop - window.event.wheelDelta/3;
}
window.bindEvent=function(obj,ename,func) { 
	if(obj.attachEvent){
		obj.attachEvent("on"+ename,func);
	}else{
		obj.addEventListener(ename,func);
	}
}
window.DlgClass = function(){
	var obj = new Object();
	obj.width = 600;
	obj.height = 400;
	obj.title = "对话框"
	obj.value = null;
	obj.model = true;
	obj.resize = false;
	obj.window = null;
	obj.document = null;
	obj.body = null;
	obj.onload = null;
	obj.show = function(){
		var url = "../../Manufacture/inc/dlg.asp" 
		if(window.sys_verPath){
			url = window.sys_verPath + "dlg.asp"
		}
		else{
			if(window.rootPath){
				url = window.rootPath + "Manufacture/inc/dlg.asp"
			}
		}
		var ui = "dialogWidth:" + obj.width + "px;dialogHeight:" + obj.height + "px;center:yes;resizable:" + (obj.resize ? "yes" : "no" +";status:no;scroll:no")
		if(obj.model==true){
			obj.value = showModalDialog(url,obj,ui)
		}
		else{
			obj.value = showModelessDialog(url,obj,ui)
		}
		return obj.value;
	}
	return obj;
}

window.DivOpen = function (id, title, mWidth, mHeight, mTop, mLeft, disbg, bgAph, disShade, buttonStyle) {  // 弹出层对话框
    
	var div = document.getElementById("divdlg_" + id)
	var w = 700 , h = 420 ,  l, t , rdiv
	
	if(!isNaN(mWidth)){w = mWidth;}
	if(!isNaN(mHeight)){h = mHeight+30;}
	if (!isNaN(mTop)) { t = mTop; } else { t = 140 + document.documentElement.scrollTop + document.body.scrollTop; }
	if(!isNaN(mLeft)){l = mLeft;} else { l = document.documentElement.scrollLeft + (document.documentElement.offsetWidth - w) / 2;}
	if(isNaN(buttonStyle)) {buttonStyle = 0}
	var divbg = document.getElementById("divdlg_" + id + "_bg");
	if(!div){
		var addatdoc = document.getElementsByTagName("frameset").length>0 && !window.ActiveXObject;
		div = document.createElement("DIV");
		div.style.cssText = "display:none;padding:0px;cursor:defualt" ;
		div.id = ("divdlg_" + id);
		(addatdoc?document.documentElement:document.body).appendChild(div)
		//document.body.insertBefore(div,document.body.children[0]);
		html = "<table onselectstart='return false' style='width:" + (w-4) + "px;height:" + (h-7) + "px;' class='divForm' onclick='this.parentElement.style.zIndex=window.GetDivIndex()'>"
		if(!title){title = ""}
		html = html +  "<tr style='cursor:move' onmousedown='window.moveDiv(this.parentElement.parentElement.parentElement)'><td class='resetTextColor333 tableTitleLinks' style='width:" + (w-40) + "px;text-align:left;height:22px;padding:2px;padding-left:5px;'><b>" + title + "</b></td>" 
					+  "<td style='text-align:right;;width:30px;cursor:default;'><span style='cursor:default;' onclick='window.DivClose(this);document.body.style.overflow=\"auto\";if(this.afterclick){this.afterclick()}'><b style='font-family:Webdings;font-size:1px;color:#ccccff'></b></span>&nbsp;&nbsp;</td></tr>"
		html = html +  "<tr><td colspan=2 style='padding:7px;height:" + (h-44) + "px' valign=top><div class='divdlgBody' style='width:" + (w-30) + "px;height:" + (h-58) + "px;overflow:auto;position:relative;padding:4px;' onmousewheel='return window.disScrollParent(this)'></div></td></tr></table>"
		if(!window.XMLHttpRequest){ html = html + "<iframe id='" + id + "_hideFrame' style='position:absolute;z-index:-1;top:0px;left:0px;width:" + (w-4) + "px;height:" + (h-7) + "px' frameborder=0></iframe>" }
		switch(buttonStyle){
			case 0:
				html = html + "<div style='position:absolute;top:8px;right:15px;width:20px'>"
							+ "<div class='dvt_closebar_out' title='关闭'  onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,0)'></div></div>"
				break;
			case 1:
				html = html + "<div style='position:absolute;top:8px;right:19px;width:auto;width:40px'>"
							+ "<div title='关闭' class='dvt_closebar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,0)'></div>"
							+ "<div title='最大化' class='dvt_maxbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,1)'></div></div>"
				break
			case 2:
				html = html + "<div style='position:absolute;top:8px;right:19px;width:auto;width:60px'>"
							+ "<div title='关闭' class='dvt_closebar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,0)'></div>"
							+ "<div title='最大化' class='dvt_maxbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,1)'></div>"
							+ "<div title='最小化' class='dvt_minbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,2)'></div>"
							+ "</div>"
			case 3:
				html = html + "<div style='position:absolute;top:8px;right:19px;width:auto;width:60px'>"
							+ "<div title='关闭' class='dvt_closebar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,0)'></div>"
							+ "<div title='最小化' class='dvt_minbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,2)'></div>"
							+ "</div>"
			default:
		}

		div.innerHTML = html
		if(disbg && !divbg){
			divbg = document.createElement("DIV");
			divbg.className = "DisDivBgCss";
			divbg.style.backgroundImage = "url(about:blank)";
			divbg.id = "divdlg_" + id + "_bg";
			var h1 = document.documentElement.offsetHeight;
			var h2 = document.body.offsetHeight;
			divbg.style.height = ( (h1>h2 ? h1 : h2) - 5) + "px";
			(addatdoc?document.documentElement:document.body).appendChild(divbg); //insertBefore(divbg,document.body.children[0]);
		}
	}
	else{
		if(div.style.display != "none" ){
			rdiv = div.children[0].rows[1].cells[0].children[0]
			rdiv.isOpen = true;
			window.DivUpdate(id ,title, w,h);
			return rdiv;
		}
	}
	div.isDivObject = true;
	div.onselectstart = function(){return false;}
	//document.body.style.overflow = "";

	div.style.cssText = "display:bloack;z-index:" + window.GetDivIndex() + ";position:absolute;width:" + w + "px;height:" + h + "px;top:" + t + "px;left:" + l + "px;" 
						+ (disShade==1 ? "" : "filter: Shadow(color=#cccccf,direction=135,strength=3);")
	if(divbg){
		if(disbg){
			if(isNaN(bgAph)) {
				bgAph = 0.1
			}
			if(window.ActiveXObject){
				try{
					divbg.filters.alpha.opacity=bgAph;
				}catch(e){}
			}else{
				if(bgAph>1) {bgAph=bgAph/100 }
				divbg.style.background =  "rgba(0,0,0," + bgAph + ")";
			}
			divbg.style.display = "block"
		}
	}
	rdiv = div.children[0].rows[1].cells[0].children[0];
	rdiv.isOpen = false;
	window.DivUpdate(id ,title, w,h);
	rdiv.onselectstart = function(){
		window.event.cancelBubble = true;
		return true;
	}
	
	rdiv.setCloseEvent = function(eventobj){
		try{
			rdiv.parentElement.parentElement.parentElement.rows[0].cells[1].children[0].afterclick = eventobj
			//alert(rdiv.parentElement.parentElement.parentElement.rows[0].cells[1].outerHTML)
			//alert(eventobj)
		}catch(e){}
	}

	return rdiv;
}

window.moveDiv = function (div) {
	jQuery(div).css("cursor","move");
	var offset = jQuery(div).offset();
	var x = (window.event.pageX || window.event.clientX) - offset.left;
	var y = (window.event.pageY || window.event.clientY) - offset.top;
	var mousemovefun = function(ev)
	{ 
		jQuery(div).stop();
		var _x = ev.pageX - x;
		var _y = ev.pageY - y;
		var rightBoundary = $(window).width() - $(div).children("table").width()
		if (_y <= 0) { _y = 0 };
		if (_x <= 0) { _x = 0 }      
		if (_x > rightBoundary) {
		    _x = rightBoundary
		}
		jQuery(div).css({left:_x+"px",top:_y+"px"}); 
	};
	var mouseupfun = function(ev){
		jQuery(div).css("cursor","default"); 
		jQuery(document).unbind("mousemove", mousemovefun); 
	};
	jQuery(document).bind("mousemove",mousemovefun);
	jQuery(document).bind("mouseup",mouseupfun);
}

window.getParent = function(obj,parentIndex){ //获取父节点
	for (var i=0;i< parentIndex ; i++)
	{if(obj){obj = obj.parentElement;}else{return obj;}}
	return obj;
}

window.DivClose = function(divChild){
	while (divChild && !divChild.isDivObject)
	{
		divChild = divChild.parentElement;
		if(divChild.isDivObject){
			if(window.onmovediv){
				window.onmovediv.preX = null;
				window.onmovediv.preY = null;
			}
			window.onmovediv = null;
			divChild.style.display = "none";
			var bgDiv = document.getElementById(divChild.id+"_bg")
			if(bgDiv){
				bgDiv.style.display = "none"
			}
			if(divChild.onclose){
				divChild.onclose();
			}
			return;
		}
	}
}

window.DivReOpen = function(divChild)
{
	while (divChild && !divChild.isDivObject)
	{
		divChild = divChild.parentElement;
		if(divChild.isDivObject)
		{
			divChild.style.display = "block";
			if(divChild.bgDiv)
			{
				divChild.bgDiv.style.display = "block"
			}
			return;
		}
	}
};

document.onmousemove = function (event) {  //移动层
	var div = window.onmovediv;
	if(div){
		if(!div.preX) {
			div.preX = event.x
			div.preY = event.y
			
		}
		else{
			 x0 = div.preX - event.x
			 y0 = div.preY - event.y
			 div.style.left = (div.offsetLeft - x0) + "px";
			 div.style.top = (div.offsetTop - y0) + "px";
			 div.preX = event.x
			 div.preY = event.y 
		}
	}
	mousemoveevents.exec();
}

document.onmouseup = function () { //移动终止
	if(window.onmovediv){
		window.onmovediv.preX = null;
		window.onmovediv.preY = null;
		window.onmovediv = null;
	}
	mouseupevents.exec();
}


function EventClass(){
	var base = new Object()
	base.events = new Array()
	base.add = function(nevent) {
		var rindex = base.events.length;
		base.events[rindex] = nevent;
		return rindex;
	}
	base.del = function(index){
		base.events[index] = null;
		base.events.splice(index,1)
	}
	base.exec = function(){
		
		for (var i=0;i<base.events.length ; i ++ )
		{
			if(base.events[i]){
				base.events[i]();
			}
		}
	}
	return base;
}

var initevents = new EventClass();  //加载启动过程
var mousemoveevents = new EventClass();  //加载启动过程
var mouseupevents = new EventClass();  //加载启动过程



document.onkeydown = function()	
{
	var code;   
    var e = window.event;   
    if (e.keyCode) code = e.keyCode;   
    else if (e.which) code = e.which;   
    if (((event.keyCode == 8) &&                                                    //禁止回车键退回上一页面  
         ((event.srcElement.type != "text" &&    
         event.srcElement.type != "textarea" &&    
         event.srcElement.type != "password") ||    
         event.srcElement.readOnly == true)) ||    
        ((event.ctrlKey) && ((event.keyCode == 78) || (event.keyCode == 82)) ) ||    //CtrlN,CtrlR    
        (event.keyCode == 116) ) {                                                   //F5    
        event.keyCode = 0;    
        event.returnValue = false;    
    }
	if(e.altKey==true && e.ctrlKey==true && e.keyCode==68){ //ctrl + alt + d 组合键 启动调试界面
		showdebugdlg();
		e.returnValue = false;
		return false
	}
    return true;   
}   

function showdebugdlg(){
	var html = document.documentElement.outerHTML;
	var div = window.DivOpen("sys_debugdiv" ,"实时调试数据捕捉", 480,280,'a','b',true,20)
	div.innerHTML = "<table style='margin-top:10px;margin-left:20px;'>" +
					"<tr><td style='height:30px'>当前网址：</td><td><a id=debug_url href='" + window.location.href + "'  style='color:blue;' target=_blank>" + window.location.href +"</a></td></tr>" + 
					"<tr><td valign=top>实时源码：</td><td><textarea id=debug_body style='color:#6666aa;border:1px solid #eeeef0;width:340px;height:120px;font-size:12px'></textArea></td></tr>" +  
					"<tr><td colspan=2 style='height:30px;padding-top:10px' align=center><button class=button onclick='debug.copy()' style='width:70px;height:24px;cursor:default'><table><tr><td><img src='../../images/smico/dot.gif'></td><td>复制</td></tr></table></button>&nbsp;&nbsp;" +
					"<button onclick='debug.GetTextFile()' class=button  style='width:70px;height:24px;cursor:default'><table><tr><td><img src='../../images/smico/txt.gif'></td><td>导出</td></tr></table></button></td></tr>"
					"</table>"
	document.getElementById("debug_body").value = html;
	htm = "";
}


Math.cint = function (value) { //取整数
    if (value.length == 0 || isNaN(value))
    { return 0; }
    return value;
}

Math.division = function(v1,v2,s){

	if (isNaN(v2) || v2.length==0){return 0}
	if (isNaN(v1) || v1.length==0){return 0}
	if(v2*1==0) {return 0;}
	if(!s){
		return Math.cfloat(v1/v2,2);
	}
	else{
		return Math.cfloat(v1/v2,s);
	}
}

Math.cfloat = function(v,s){ //转换成浮点数
	if (isNaN(v) || v.length==0){return 0}
	if(!s){s=2}
	else{
		if (isNaN(s) || s.length==0){s=2}
	}
	switch(Math.cint(s)){
		case 0: return Math.cint(v);
		case 1: return Math.cint(v*10)/10;
		case 3: return Math.cint(v*1000)/1000;
		case 4: return Math.cint(v*10000)/10000;
		case 5: return Math.cint(v*100000)/100000;
		default:
			return Math.cint(v*100)/100;
	}
}

Math.fnum = function(n){
	var v = n.toFixed(6) + "";
	if(v.indexOf(".")>=0){
		v = v.replace(/00000\d$/,"").replace(/0+$/,"").replace(/^\./,"0.").replace(/\.$/,"");
		return isNaN(v) ? "" : v
	}else{
		return n;
	}
}

window.MaxLength = function (contrl,c){
	var s = contrl.value + "";
	if (s.length > c)
	{contrl.value = s.substr(0,c);}
}

window.verPath = ""  ; //其他目录调用


window.RegObjectScript = function(obj)
{ //执行一个对象中包含的javascript脚本
	 var script = obj.getElementsByTagName("script")
     for (var i = 0; i < script.length; i++) {
		 if(script[i].innerHTML.length>0){
			try{
				window.eval("(function(){" + script[i].innerHTML + "})()");
			}catch(e){
			} 
		 }
	}
}

//判断是否为正确的日期。
String.prototype.IsDate=function()
{
	var d = new Date(this.replace(/\-/g,"/").replace(/\./g,"/"));
	return !isNaN(d);
}

Date.DateDiff = function(strInterval,dtStart,dtEnd){   
  switch(strInterval) {   
	  case "s":return parseInt((dtEnd - dtStart)/1000);   
	  case "n":return parseInt((dtEnd - dtStart)/60000);   
	  case "h":return parseInt((dtEnd - dtStart)/3600000);   
	  case "d":return parseInt((dtEnd - dtStart)/86400000);   
	  case "w":return parseInt((dtEnd - dtStart)/(86400000*7));   
	  case "m":return dtEnd.getMonth()- dtStart.getMonth();   
	  case "y":return dtEnd.getFullYear() - dtStart.getFullYear();   
  }   
}

window.ControlVisible = function(ctl){ //判断一个元素是否被隐藏
	while(ctl && ctl.tagName != "BODY" && ctl.tagName != "HTML"){
		if(ctl.style.display.toLowerCase()=="none" || ctl.style.visibility.toLowerCase()=="hidden" ){
			return false;
		}
		ctl = ctl.parentElement;
	} 
	return true;
}
//===============================js操作cookie============================
function GetCookieVal(offset)
//获得Cookie解码后的值
{
var endstr = document.cookie.indexOf (";", offset);
if (endstr == -1)
endstr = document.cookie.length;
return unescape(document.cookie.substring(offset, endstr));
}

//---------------------------
function SetCookie(name, value)
//设定Cookie值
{
var expdate = new Date();
var argv = SetCookie.arguments;
var argc = SetCookie.arguments.length;
var expires = (argc > 2) ? argv[2] : null;
var path = (argc > 3) ? argv[3] : null;
var domain = (argc > 4) ? argv[4] : null;
var secure = (argc > 5) ? argv[5] : false;
if(expires!=null) expdate.setTime(expdate.getTime() + ( expires * 1000 ));
document.cookie = name + "=" + escape (value) +((expires == null) ? "" : ("; expires="+ expdate.toGMTString()))
+((path == null) ? "" : ("; path=" + path)) +((domain == null) ? "" : ("; domain=" + domain))
+((secure == true) ? "; secure" : "");
}

//---------------------------------
function DelCookie(name)
//删除Cookie
{
var exp = new Date();
exp.setTime (exp.getTime() - 1);
var cval = GetCookie (name);
document.cookie = name + "=" + cval + "; expires="+ exp.toGMTString();
}

//------------------------------------
function GetCookie(name)
//获得Cookie的原始值
{
var arg = name + "=";
var alen = arg.length;
var clen = document.cookie.length;
var i = 0;
while (i < clen)
{
var j = i + alen;
if (document.cookie.substring(i, j) == arg)
return GetCookieVal (j);
i = document.cookie.indexOf(" ", i) + 1;
if (i == 0) break;
}
return null;
}
//=================================================================================

//document.onmousedown = function(){
//	if(window.event.button==1){
//		var obj = window.event.srcElement;
//		if(obj.tagName=="A"){
//			if(obj.href.toLowerCase().indexOf("bill.asp?")>0){
//				obj.href = "javascript:PageOpen('" + obj.href + "',1000,750,null)"
//			}
//		}
//	}
//}
function divdlgtoolmv(obj){

	obj.className = obj.className.indexOf("_out")>0 ? obj.className.replace("_out","") : obj.className + "_out"
}

function divdlgclick(obj,style){
	var div = obj.parentElement.parentElement;
	switch(style){
		case 0 :
			jQuery(div.getElementsByTagName("span")[0]).trigger("onclick");
			break;
		case 1 :
			if(!obj.maxed|| obj.maxed == ""){
				obj.maxed = div.style.left + "|" + div.style.top + "|" + div.offsetWidth + "px|" + div.offsetHeight + "px"
 				div.style.left = "0px"
				div.style.top = "0px"
				div.style.width = document.documentElement.offsetWidth + "px";
				div.style.height = document.documentElement.offsetHeight + "px";
				obj.className = "dvt_maxedbar"
				div.children[0].style.width = (div.offsetWidth - 4) + "px";
				div.children[0].style.height = (div.offsetHeight - 7) + "px";
				div.children[0].rows[0].cells[0].style.width = (div.offsetWidth-40) + "px";
				div.children[0].rows[1].cells[0].children[0].style.width = (div.offsetWidth-30) + "px";
				div.children[0].rows[1].cells[0].style.height = (div.offsetHeight-44) + "px";
				div.children[0].rows[1].cells[0].children[0].style.height = (div.offsetHeight-58) + "px";
			}
			else{
				var v = obj.maxed.split("|")
				obj.maxed = ""
				var w = v[2].replace("px","")
				var h = v[3].replace("px","")

				div.children[0].rows[1].cells[0].children[0].style.height = (h - 58) + "px";
				div.children[0].rows[1].cells[0].children[0].style.width = (w - 30) + "px";
				div.children[0].rows[0].cells[0].style.width = (w - 40) + "px";
				div.children[0].rows[1].cells[0].style.height = (h - 44) + "px";
				div.children[0].style.width = (w - 4) + "px";
				div.children[0].style.height = (h - 7) + "px";
			
				div.style.left = v[0];
				div.style.top = v[1];
				div.style.width = v[2];
				div.style.height = v[3];
				obj.className = "dvt_maxbar"
			}
			break;
		default:
	}
}

window.getTopPageXY = function(win, initx, inity) {
	while(win && win.parent && win.parent!=win) {
		var hs = false;
		var frms = win.parent.document.getElementsByTagName("iframe");
		for(var i = 0 ; i<frms.length; i++) {
			if(frms[i].contentWindow==win || frms[i].window==win) {
				frm = frms[i];
				var p = frm.getBoundingClientRect();
				initx = initx*1 + p.left;
				inity = inity*1 + p.top;
				hs = true;
				break;
			}
		}
		if(hs == false) {
			var frms = win.parent.document.getElementsByTagName("frame");
			for(var i = 0 ; i<frms.length; i++) {
				if(frms[i].contentWindow==win || frms[i].window==win) {
					frm = frms[i];
					var p = frm.getBoundingClientRect();
					initx = initx*1 + p.left;
					inity = inity*1 + p.top;
					break;
				}
			}
		}
		win = win.parent;
	}
	return {x:initx, y:inity };
}

window.autoMovePageXY = function(rc, w, h, win) {
	var sw = win.document.body.offsetWidth;
	if(sw > 50 && sw < (rc.x*1 + w*1)) {
		rc.x = sw - w; 
	}
	return rc;
}


window.ArrayExists = function (array , item){
	for (var i = 0; i < array.length  ; i ++ )
	{
		if(array[i]==item){	return true;}
	}
	return false;
}

Number.prototype.format = function () {
    var nAfterDot = window.floatnumber;
    var srcStr = this.toString();
    if (isNaN(srcStr)) return "0";
	var i = parseFloat(srcStr)>=0?1:-1;
	srcStr = (Math.round(srcStr * i * Math.pow(10, nAfterDot)) / Math.pow(10, nAfterDot) * i).toFixed(8).toString();//此处为了防止js更改小数为科学计数法导致下面截取错误，所以用toFixed(8)转换成长度为8位小数位数（目前系统最大支持8位小数）
    var v = srcStr.split(".");
    var num = v.length == 1 ? (srcStr + "." + "000000000000".substr(0, nAfterDot)) : (srcStr + "000000000000").substr(0, srcStr.indexOf(".") + 1 + nAfterDot*1);
    return num;
}
String.prototype.format = Number.prototype.format;

window.ObjectClone = function(){   
    var objClone;   
    if (this.constructor == Object){   
        objClone = new this.constructor();    
    }else{   
        objClone = new this.constructor(this.valueOf());    
    }   
    for(var key in this){   
        if ( objClone[key] != this[key] ){    
            if ( typeof(this[key]) == 'object' ){    
                objClone[key] = this[key].Clone();   
            }else{   
                objClone[key] = this[key];   
            }   
        }   
    }   
    objClone.toString = this.toString;   
    objClone.valueOf = this.valueOf;   
    return objClone;    
} 

if(window.GetIE10SafeXmlHttp) {
	//GetIE10SafeXmlHttp函数定义在setup.js中，如果存在该函数，还原xmlhttp的含义
	xmlHttp = GetIE10SafeXmlHttp();
}

window.$ID = function(id){
	return document.getElementById(id);
}

document.oninput = function(e) {
	var code = e.target.getAttribute("onpropertychange");
	eval("(function(){" + code + "})").call(e.target);
}

if (!window.AutoHandleToNet) { //可能被setup.js嵌套调用，需要判断一下
	window.AutoHandleToNet = function (billtype, fromid, actionname, ext) {
		var xhttp = new XMLHttpRequest();
		xhttp.open('GET', '../../../SYSN/view/AspVirBill/AutoHandlerASPBill.ashx?billtype=' + billtype + "&fromid=" + fromid + "&actionname=" + actionname + (ext ? ext : ""), false);
		xhttp.send();
	}
}