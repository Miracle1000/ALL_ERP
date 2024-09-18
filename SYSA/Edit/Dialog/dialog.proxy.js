window.NotIE = false;
function __firefox(){HTMLElement.prototype.__defineGetter__("runtimeStyle",__element_style);
window.constructor.prototype.__defineGetter__("event",__window_event);
Event.prototype.__defineGetter__("srcElement",__event_srcElement);}
function __element_style(){return this.style;}
function __window_event(){return __window_event_constructor();}
function __event_srcElement(){return this.target;}
function __window_event_constructor(){if(document.all){return window.event;}
var _caller=__window_event_constructor.caller;
while(_caller!=null){var _argument=_caller.arguments[0];
if(_argument){var _temp=_argument.constructor;
if(_temp.toString().indexOf("Event")!=-1){return _argument;}}
_caller=_caller.caller;}
return null;}
if(window.addEventListener&&HTMLElement.prototype.__defineGetter__){__firefox();}
var isDivModel = window.location.href.indexOf("isdivModel=1")>0;
document.write("<style>fieldset{border:1px solid #aaa} body{overflow:hidden;background-color:#e4e2e2}</style>");
if(isDivModel) {
	window.NotIE = true;
	document.write("<style>input[type='file']{font-size:12px}</style>");
	//div模拟模式
	window.dialogArguments = top.curreWebEditorFrame;
	window.close = window.dialogArguments.divdlgClick;
	window.dialogArguments.eWebEditor = window.dialogArguments;
	window.parent.dialogArguments = new Object();
	window.parent.dialogArguments.document = window.dialogArguments.parentDocument;
	function CSelectColor(colortype) {
		top.currEWebColorSelBox =  document.getElementById("s_" + colortype);
		top.currEColorSelBoxClose = function(){
			top.document.getElementById("w_e_color_seldiv_bg").style.display="none";
			top.document.getElementById("w_e_color_seldiv").style.display="none";
		}
		top.currEcolorSelV = function(v) {
			//document.getElementById("s_" + colortype).style.backgroun = v;
			document.getElementById("d_" + colortype).value = v;
		} 
		var doc = top.document;
		var div = doc.getElementById("w_e_color_seldiv");
			var w1 = 220, h1 = 230;
		if(!div) {
			bgdiv = doc.createElement("div");
			bgdiv.id = "w_e_color_seldiv_bg";
			bgdiv.style.cssText = "z-index:1000100;position:fixed;top:0px;left:0px;width:100%;height:100%;background-color:rgba(153,153,170,0.5)";
			doc.body.appendChild(bgdiv);
			div = doc.createElement("div");
			div.id = "w_e_color_seldiv";
			div.innerHTML = "<div style='height:26px;margin:3px 3px 0px 3px'>"
					+ "<div id='eWebEditor_dlgdiv_title' style='color:#000;font-size:12px;float:left;padding:3px 0px 0px 3px;'>&nbsp;</div>"
					+ "<div id='eWebEditor_dlgdiv_btn' title='关闭' onclick='top.currEColorSelBoxClose()'  onmouseout='this.style.backgroundColor=\"#8EA1C1\";this.style.borderColor=\"#6e81a1\"'"
					+" onmouseover='this.style.backgroundColor=\"#E76E82\";this.style.borderColor=\"#B74e6e\"' "
					+"style='line-height:15px;cursor:pointer;color:white;text-align:center;font-weight:bold;width:14px;height:14px;"
					+"border-radius:8px;margin-top:4px;margin-right:3px;float:right;background-color:#8EA1C1;border:1px solid #6e81a1'>×</div>"
					+ "</div>"
					+ "<table border=0 cellspacing=0 cellpadding=0 style='table-layout:fixed;cursor:pointer;margin-left:6px;width:" + (w1-12) + "px;height:" + (h1-50) + "px'>" + GetColorDlgHTML() + "</table>"
					+ "<div style='padding:3px 0px 0px 6px;color:#000'>当前颜色值：<span id='w_e_color_seldiv_v'></span></div>"
			doc.body.appendChild(div);

		}
		var dlgdiv = top.document.getElementById("eWebEditor_dlgdiv");
		var l = dlgdiv.style.left.replace("px","")*1;
		var t = dlgdiv.style.top.replace("px","")*1;
		var w = dlgdiv.offsetWidth;
		var h = dlgdiv.offsetHeight;
		var l = parseInt(l + (w - w1)/2);
		var t = parseInt(t + (h - h1)/2);
		div.style.cssText = "z-index:1000111;position:fixed;left:" + l + "px;top:" + t + "px;width:" + w1 + "px;height:" + h1 + "px;"
						+ "border:1px solid #fff;background-color:#E3E7F0;border-radius:3px;-webkit-box-shadow: 0px 0px 15px;-moz-box-shadow:0px 0px 15px;box-shadow: 0px 0px 15px;";
	
	}
	SelectColor = CSelectColor;
}
else{
	window.onerror = function(sMessage,sUrl,sLine){
		alert("sMessage=" + sMessage + "\n\nsUrl=" + sUrl + "\n\nsLine=" + sLine + "行");
	}
}


var window_onload = function() {
	if(!window.ActiveXObject){
		var objs = document.getElementsByTagName("iframe");
		for (var i = 0; i < objs.length ; i++ )
		{
			if(objs[i].id!="") { eval("window." + objs[i].id + "=document.getElementById(\"" + objs[i].id + "\");if(!window." + objs[i].id + ".contentWindow){window." + objs[i].id + ".contentWindow=window." + objs[i].id + ".window}"); }
		}
		objs = document.getElementsByTagName("input");
		for (var i = 0; i < objs.length ; i++ )
		{
			if(objs[i].id!="") { eval("window." + objs[i].id + "=document.getElementById(\"" + objs[i].id + "\")"); }
		}
		objs = document.getElementsByTagName("div");
		for (var i = 0; i < objs.length ; i++ )
		{
			if(objs[i].id!="") { eval("window." + objs[i].id + "=document.getElementById(\"" + objs[i].id + "\")"); }
		}
		objs = document.getElementsByTagName("table");
		for (var i = 0; i < objs.length ; i++ )
		{
			if(objs[i].id!="") { eval("window." + objs[i].id + "=document.getElementById(\"" + objs[i].id + "\")"); }
		}
		objs = document.getElementsByTagName("td");
		for (var i = 0; i < objs.length ; i++ )
		{
			if(objs[i].id!="") { eval("window." + objs[i].id + "=document.getElementById(\"" + objs[i].id + "\")"); }
		}

		var ifm = document.getElementsByTagName("iframe")[0];
		if(ifm && ifm.id == "d_file") {
			window.d_file = ifm;
			window.d_file.myform = window.d_file.contentWindow.document.getElementsByName("myform")[0];
			window.d_file.myform.uploadfile = d_file.contentWindow.document.getElementsByName("uploadfile")[0];
			window.d_file.CheckUploadForm = d_file.contentWindow.CheckUploadForm;
		}
	}

	if(window.d_file && !window.d_file.contentWindow) {  //兼容老IE
		window.d_file.contentWindow = window.d_file.window;
	}
	
	if(isDivModel){ window.SelectColor = CSelectColor; }
	if(window.onDlgLoad) {window.onDlgLoad()}
}
if(window.addEventListener){
	window.addEventListener("load", window_onload, false);
}else{
	setTimeout(function(){
		window_onload();
	},500);
}

function GetColorDlgHTML() {
	var htmls = new Array();
	var cnum = new Array(1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0);
	for(i = 0; i < 16; i ++){
		htmls.push('<TR>');
		for(j = 0; j < 30; j ++){
			n1 = j % 5;
			n2 = Math.floor(j / 5) * 3;
			n3 = n2 + 3;

			wcccc(htmls, (cnum[n3] * n1 + cnum[n2] * (5 - n1)),
			(cnum[n3 + 1] * n1 + cnum[n2 + 1] * (5 - n1)),
			(cnum[n3 + 2] * n1 + cnum[n2 + 2] * (5 - n1)), i);
		}

		htmls.push('</TR>');
	}
	return htmls.join("");
}

function ToHex(n) {	
	var hexch = new Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
	var h, l;
	n = Math.round(n);
	l = n % 16;
	h = Math.floor((n / 16)) % 16;
	return (hexch[h] + hexch[l]);
}

function wcccc(htmls, r, g, b, n){

	r = ((r * 16 + r) * 3 * (15 - n) + 0x80 * n) / 15;
	g = ((g * 16 + g) * 3 * (15 - n) + 0x80 * n) / 15;
	b = ((b * 16 + b) * 3 * (15 - n) + 0x80 * n) / 15;
	htmls.push('<TD onclick="top.currEcolorSelV(this.bgColor);top.currEColorSelBoxClose()" BGCOLOR=#' + (ToHex(r) + ToHex(g) + ToHex(b)) + ' onmouseover="document.getElementById(\'w_e_color_seldiv_v\').innerHTML=this.bgColor"></TD>');
}