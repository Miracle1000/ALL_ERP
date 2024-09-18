window.DivOpen = function(id ,title, mWidth,mHeight,mTop,mLeft,disbg,bgAph,disShade,buttonStyle) {  // 弹出层对话框
	var div = document.getElementById("divdlg_" + id)
	var w = 700 , h = 420 ,  l, t , rdiv
	
	if(!isNaN(mWidth)){w = mWidth;}
	if(!isNaN(mHeight)){h = mHeight;}
	if (!isNaN(mTop)) { t = mTop; } else { t = 140 + document.documentElement.scrollTop + document.body.scrollTop; }
	if(!isNaN(mLeft)){l = mLeft;} else { l = document.documentElement.scrollLeft + (document.documentElement.offsetWidth - w) / 2;}
	if(isNaN(buttonStyle)) {buttonStyle = 0}
	if(!div){
		div = document.createElement("DIV");
		div.style.cssText = "display:none;padding:0px;cursor:defualt" ;
		div.id = "divdlg_" + id
		document.body.appendChild(div)
		//document.body.insertBefore(div,document.body.all[0]);
		html = "<table onselectstart='return false' style='width:" + (w-4) + "px;height:" + (h-7) + "px;' class='divForm' onclick='this.parentElement.style.zIndex=window.GetDivIndex()'>"
		if(!title){title = ""}
		html = html +  "<tr style='cursor:move' onmousedown='window.moveDiv(this.parentElement.parentElement.parentElement)'><td style='width:" + (w-40) + "px;text-align:left;height:22px;padding:2px;padding-left:5px;color:#222222'><b>" + title + "</b></td>" 
					+  "<td style='text-align:right;;width:30px;cursor:default;'><span style='cursor:default;' onclick='window.DivClose(this);document.body.style.overflow=\"\";if(this.afterclick){this.afterclick()}'><b style='font-family:Webdings;font-size:12px;color:#222'>r</b></span>&nbsp;&nbsp;</td></tr>"
		html = html +  "<tr><td colspan=2 style='padding:7px;height:" + (h-44) + "px' valign=top><div class='divdlgBody' style='width:" + (w-30) + "px;height:" + (h-58) + "px;overflow:hidden;padding:4px' onmousewheel='return window.disScrollParent(this)'></div></td></tr></table>"
		if(!window.XMLHttpRequest){ html = html + "<iframe id='" + id + "_hideFrame' style='position:absolute;z-index:-1;top:0px;left:0px;width:" + (w-4) + "px;height:" + (h-7) + "px' frameborder=0></iframe>" }
		switch(buttonStyle){
			case 0:
				html = html + "<div style='position:absolute;top:8px;right:12px;width:20px'>"
							
				break;
			case 1:
				html = html + "<div style='position:absolute;top:8px;right:12px;width:auto;width:40px'>"
							
							+ "<div title='最大化' class='dvt_maxbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,1)'></div></div>"
				break
			case 2:
				html = html + "<div style='position:absolute;top:8px;right:12px;width:auto;width:60px'>"
							
							+ "<div title='最大化' class='dvt_maxbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,1)'></div>"
							+ "<div title='最小化' class='dvt_minbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,2)'></div>"
							+ "</div>"
			case 3:
				html = html + "<div style='position:absolute;top:8px;right:12px;width:auto;width:60px'>"
							
							+ "<div title='最小化' class='dvt_minbar_out' onmouseover='divdlgtoolmv(this)' onmouseout='divdlgtoolmv(this)' onclick='divdlgclick(this,2)'></div>"
							+ "</div>"
			default:
		}

		div.innerHTML = html
		if(disbg){
			divbg = document.createElement("DIV");
			divbg.className = "DisDivBgCss";
			divbg.style.backgroundImage = "url()";
			divbg.style.backgroundColor = "#444466";
			document.body.appendChild(divbg) //insertBefore(divbg,document.body.all[0]);
			div.bgDiv = divbg
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
	if(div.bgDiv){
		try
		{
			if(disbg){
				if (!isNaN(bgAph))
				{
					div.bgDiv.filters.Alpha.Opacity=bgAph;
				}
				div.bgDiv.style.display = "block"
			}
		}
		catch (e){divbg.className=""}
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
			div.children[0].rows[1].cells[0].style.height = (mHeight-44) + "px"
			div.children[0].rows[1].cells[0].children[0].style.height = (mHeight-58) + "px"
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


window.moveDiv = function(div){
	div.setCapture();
	div.mv_x = div.offsetLeft;
	div.mv_y = div.offsetTop;
	div.preX = null;
	div.dtTop = null;
	div.onmousemove = function(){
		if(!div.preX) {
			div.preX = window.event.screenX
			div.preY = window.event.screenY
			div.dtTop = window.event.clientY - div.offsetTop ;
		}
		else{
			 x0 = div.preX - window.event.screenX
			 y0 = div.preY - window.event.screenY
			div.style.left = (div.offsetLeft - x0) + "px";
			if(div.offsetTop - y0<0){
				div.style.top = "0px"; 
			}
			else{
				div.style.top = (div.offsetTop - y0) + "px";
			}
			div.preX = window.event.screenX
			div.preY = window.event.screenY 
		}
	}
	div.onmouseup = function(){
		div.preX = null;
		div.onmousemove = function(){}
		div.releaseCapture();
	}
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
			if(divChild.bgDiv){
				divChild.bgDiv.style.display = "none"
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

document.onmousemove = function () {  //移动层
	var div = window.onmovediv;
	if(div){
		if(!div.preX) {
			div.preX = window.event.x
			div.preY = window.event.y
			
		}
		else{
			 x0 = div.preX - window.event.x
			 y0 = div.preY - window.event.y
			 div.style.left = (div.offsetLeft - x0) + "px";
			 div.style.top = (div.offsetTop - y0) + "px";
			 div.preX = window.event.x
			 div.preY = window.event.y 
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

function divdlgtoolmv(obj){

	obj.className = obj.className.indexOf("_out")>0 ? obj.className.replace("_out","") : obj.className + "_out"
}

function divdlgclick(obj,style){
	var div = obj.parentElement.parentElement;
	switch(style){
		case 0 :
			$(div.getElementsByTagName("span")[0]).trigger("click");
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
				div.all[0].rows[0].cells[0].style.width = (div.offsetWidth-40) + "px";
				div.all[0].rows[1].cells[0].all[0].style.width = (div.offsetWidth-30) + "px";
				div.all[0].rows[1].cells[0].style.height = (div.offsetHeight-44) + "px";
				div.all[0].rows[1].cells[0].all[0].style.height = (div.offsetHeight-58) + "px";
			}
			else{
				var v = obj.maxed.split("|")
				obj.maxed = ""
				var w = v[2].replace("px","")
				var h = v[3].replace("px","")

				div.all[0].rows[1].cells[0].all[0].style.height = (h - 58) + "px";
				div.all[0].rows[1].cells[0].all[0].style.width = (w - 30) + "px";
				div.all[0].rows[0].cells[0].style.width = (w - 40) + "px";
				div.all[0].rows[1].cells[0].style.height = (h - 44) + "px";
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
    srcStr = (Math.round(srcStr * Math.pow(10, nAfterDot)) / Math.pow(10, nAfterDot)).toString();
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
