var edStyle = null;
var editwindow =  null;//编辑器winodw对象
var toolbarHeight = 48;
var vTimehand = 0;
var parentBox = null ; //父对象数据容器
var currMode = 1;     //当前模式
var currRange = null;
var menuPoping = 0;   //所有菜单是否处于弹出状态
var currPopMenu = null;
var mustPopMenu = null;
var tooldataitems1 = [
	["b","img/B.gif","加粗"],["i","img/I.gif","斜体"],["u","img/U.gif","下划线"],["-"],
	["left","img/left.gif","左对齐"],["center","img/center.gif","居中"],["right","img/right.gif","右对齐"],
	["indent","img/indent.gif","减少缩进量"],["outdent","img/outdent.gif","增加缩进量"],["fontColor","img/font_color.gif","选择字体颜色"],["-"],["+H","img/sizeplus.gif","增高编辑区"],["_H","img/sizeminus.gif","减小编辑区"]
]

var cMenu1 = [["","设计模式",1],["","代码编辑",""],["","预览",""]];
var cMenu2 = [["","撤销",""],["-"],["","剪切",""],["","复制",""],["","粘贴",""]]

// 浏览器版本检测
var BrowserInfo = new Object() ;
if (window.ActiveXObject)
{
	BrowserInfo.MajorVer = navigator.appVersion.match(/MSIE (.)/)[1] ;
	BrowserInfo.MinorVer = navigator.appVersion.match(/MSIE .\.(.)/)[1] ;
	BrowserInfo.IsIE55OrMore = BrowserInfo.MajorVer >= 6 || ( BrowserInfo.MajorVer >= 5 && BrowserInfo.MinorVer >= 5 ) ;
}else{
	BrowserInfo.IsIE55OrMore = true;
}


function getContextMenuArray(mMenu){
	switch(mMenu){
		case "视图(V)": return cMenu1;
		case "编辑(E)": return cMenu2;
		default:return new Array();
	}
}

function ContextItemClick(i,mtext,ctext){
	document.getElementById("Context_MM").style.left = "-10000px";
	switch(mtext){
		case "视图(V)":
			switch(ctext){
				case "设计模式": cMenu1[0][2] = 1 ; cMenu1[1][2] = 0 ; cMenu1[2][2] = 0;  modechange(1) ; break;
				case "代码编辑": cMenu1[0][2] = 0 ; cMenu1[1][2] = 1 ; cMenu1[2][2] = 0;  modechange(2) ; break;
				case	"预览" : cMenu1[0][2] = 0 ; cMenu1[1][2] = 0 ; cMenu1[2][2] = 1;  modechange(3) ; break;
			}
			return;
		case "编辑(E)":
			break;
		default:
			break;
	}
}

function toolitemfun(key){
	switch(key){
		case "b": //粗体
			exec("Bold","")
			break;
		case "i": //斜体
			exec("Italic","")
			break;
		case "u"://下划线
			exec("Underline","")
			break;
		case "center"://居中
			exec("JustifyCenter","")
			break;
		case "left"://左对齐
			exec("JustifyLeft","")
			break;
		case "right"://右对齐
			exec("JustifyRight","")
			break;
		case "indent"://减少缩进
			exec("Indent","")
			break;
		case "outdent"://增加缩进
			exec("Outdent","")
			break;
				case "fontColor"://选择颜色
			ShowDialog('Dialog/selcolor.htm?action=forecolor', 280, 250, true)
			break;
				case "+H"://增加高度
			sizeChange(300);
			break;
				case "_H"://减少高度
			sizeChange(-300);
			break;
		default:
			return;
	}

}
function pageinit(id){
	
	var scrollbarcss = "scrollbar-shadow-color:#ffffff;scrollbar-highlight-color:#ffffff;scrollbar-face-color:#d9d9d9;scrollbar-3dlight-color:#d9d9d9;scrollbar-darkshadow-color:#d9d9d9;scrollbar-track-color:#ffffff;scrollbar-arrow-color:#ffffff"
	edStyle = document.getElementById("editarea").style;
	editwindow = document.getElementById("editarea").contentWindow;
	if (id.length==0){editwindow.document.write("<style>body{" + scrollbarcss + "}</style><body></body>")}
	else{
		try{
			var  parentBoxs = window.parent.document.getElementsByName(id)
			if(parentBoxs.length>0){ parentBox =  parentBoxs[0];}
			else{parentBox = window.parent.document.getElementById(id)}
			if (parentBox){editwindow.document.write("<style>body{" + scrollbarcss + "}</style><body>" + parentBox.value + "</body>");}
			else{editwindow.document.write("<style>body{" + scrollbarcss + "}</style><body></body>")}
		}
		catch(e){
			alert("无法获取【" + id + "】对象所包含的值。\n\n请确认是否由于存在跨域访问而引发该问题。")
		}
	}
	editwindow.document.designMode = "on";
	if(editwindow.addEventListener){  //FF    绑定编辑器操作时的更改
		editwindow.document.addEventListener("keyup",saveselection,false);
		editwindow.document.addEventListener("mouseup",saveselection,false);
		editwindow.document.addEventListener("mousedown",hideContextMenu,false);
		editwindow.addEventListener("blur",editorupdate,false);
		editwindow.document.addEventListener("click",editorclick,false);
		document.addEventListener("click",allclick,false)
		document.addEventListener("mousedown",hideContextMenu,false);
	}else{  //IE chrome   
		editwindow.document.attachEvent("onkeyup",saveselection);
		editwindow.document.attachEvent("onmouseup",saveselection);
		editwindow.document.attachEvent("onmousedown",hideContextMenu);
		editwindow.attachEvent("onblur",editorupdate);
		editwindow.document.attachEvent("onclick",editorclick);
		document.attachEvent("onclick",allclick);
		document.attachEvent("onmousedown",hideContextMenu);
	}  
	
	if (document.getElementById("menubar"))
	{
		creatmenu(); //创建主菜单
	}
	else{
		document.getElementById("toolbar").style.height = "26px";
		document.getElementById("toolbar").style.backgroundPositionY = "-20px"
	}

	createtoolitems("toolitems1",tooldataitems1) //工具栏
	window.setTimeout("editwindow.focus()",300);
	pageresizeIE();
	//sizeChange(-100);
}
function editorclick (){
	keepselection();
	allclick();
}
function keepselection(){
	 currRange = editwindow.document.selection.createRange();
}
function keydownEvent(){

}

function pageresize(){
	var newHeight = window.document.body.offsetHeight.toString().replace("px","")*1;
	edStyle.height = ( newHeight  - toolbarHeight - 1) + "px"
	document.getElementById("editareacode").style.height = edStyle.height;
	return true;
}

function pageresizeIE(){
	//var newHeight = window.document.body.offsetHeight.toString().replace("px","")*1;
//	if(newHeight>0){
//		newHeight = ( newHeight  - toolbarHeight - 1) + "px"
//	}
//	else{
//		newHeight = window.document.documentElement.offsetHeight.toString().replace("px","")*1;
//		newHeight = ( newHeight  - toolbarHeight - 1) + "px"
//	}
//	edStyle.cssText= "height:" + newHeight ;
//	document.getElementById("editareacode").style.cssText =  "height:" + newHeight;
	var newHeight=$('body').height();
	if(newHeight>0){
		newHeight = ( newHeight  - toolbarHeight - 1)
	}
	else
	{
		var mWin=$('#eWebEditor1', window.parent.document);
		newHeight =mWin.height();
		newHeight = ( newHeight  - toolbarHeight - 1) ;
	}
	$('#editareacode').css({'height':newHeight+25});
	$('#editarea').css({'height':newHeight+25});
	
}
function modechange(index){
	//try{
	var cm = currMode;
	if(index==currMode){return false;}
	var index2 = (index == 1? 2 : 1)
	//document.getElementById("l2rtab" + index).className = "l2rtab l2rsel";
	//document.getElementById("l2rtab" + index2).className = "l2rtab l2rnosel";
	currMode = index;

	if(index==1){
		document.getElementById("editareacode").style.display="none"
		document.getElementById("editarea").style.display="block"
		editwindow.document.body.innerHTML = document.getElementById("editareacode").value;
		editwindow.document.designMode = "on"

	}
	else if(index==2){
		document.getElementById("editarea").style.display = "none"
		document.getElementById("editareacode").style.display="block"
		document.getElementById("editareacode").value = editwindow.document.body.innerHTML;
	}
	else{
		if(cm==2){
			document.getElementById("editareacode").style.display="none"
			document.getElementById("editarea").style.display="block"
			editwindow.document.body.innerHTML = document.getElementById("editareacode").value;
		}
		
		if(window.ActiveXObject){
			var html = editwindow.document.body.innerHTML;
			editwindow.location.reload();
			editwindow.document.designMode = "off";
			editwindow.document.write("<body>" + html + "</body>");
		}
		else{
			editwindow.document.designMode = "off";
		}
	
	}
	disToolBar((index!=1))
	//}catch(e){
	//	alert(e.message)
	//}
}
function disToolBar(value){
	//document.getElementById("toolitems1").disabled = value;
	var tool1 = document.getElementById("toolitems1")
	var ctl = tool1.getElementsByTagName("div");
	for (var i = 0;i<ctl.length ;i++ ){ctl[i].disabled = value;}
	var ctl = tool1.getElementsByTagName("table");
	for (var i = 0;i<ctl.length ;i++ ){ctl[i].disabled = value;}
	var ctl = tool1.getElementsByTagName("button");
	for (var i = 0;i<ctl.length ;i++ ){ctl[i].disabled = value;}
	var ctl = tool1.getElementsByTagName("span");
	for (var i = 0;i<ctl.length ;i++ ){ctl[i].disabled = value;}
	var ctl = tool1.getElementsByTagName("td");
	for (var i = 0;i<ctl.length ;i++ ){ctl[i].disabled = value;}
}

function swapNode(node1,node2)
{
	var parent = node1.parentNode;//父节点
	var t1 = node1.nextSibling;//两节点的相对位置
	var t2 = node2.nextSibling;
	if(t1) parent.insertBefore(node2,t1);
	else parent.appendChild(node2);
	if(t2) parent.insertBefore(node1,t2);
	else parent.appendChild(node1);
}

function UpdateValue(){ //更新文本框数据
	if(parentBox){
		if(currMode==1){
			parentBox.value = editwindow.document.body.innerHTML;
		}
		else{
			parentBox.value = document.getElementById("editareacode").value;
		}
	}
}

function editorupdate(){
	UpdateValue()
	return true;
}
/********创建菜单*******/
function getStrActualLen(sChars) //获取字符串真实长度
{
    return sChars.replace(/[^\x00-\xff]/g,"xx").length;
}

function mitemmouseover(item){
	mustPopMenu  = item;
	if(menuPoping!=1){
		item.style.backgroundColor = "#06246A";
		item.children[0].style.backgroundColor = "#B6BDD2";
	}
	else{
		if(currPopMenu!=item){
			
			showContextMenu(item)
		}
	}
}

function mitemmouseout(item){

	if(menuPoping!=1){
		item.style.backgroundColor = "transparent";
		item.children[0].style.backgroundColor = "transparent";
	}
}

function contextitemover(item){
	if(item.className=="M_item"){
		item.className = "selected M_item"
		item.style.backgroundColor = "#06246A"
	}
	else{
		item.className = "M_item"
		item.style.backgroundColor = "transparent"
	}
}

function ContextMenuItem(arrdata) {
	var obj = new Object();
	obj.text = "新菜单";
	obj.ico = "";
	obj.checked = false;
	if(arrdata[0]){obj.ico = arrdata[0];}
	if(arrdata[1]){obj.text = arrdata[1];}
	if(arrdata[2]){obj.checked = (arrdata[2]==1);}
	obj.icoHTML = (obj.ico.length > 0 ? "<img src='" + obj.ico + "'>" : "");
	if(obj.checked==true){obj.icoHTML = "<img src='img/checked.gif'>";}
	return obj;
}
var xx = 0
function CreateContextMenu(button,arrdata,dock){
	
	var key = "MM";
	var id = "Context_" + key;
	var div = document.getElementById(id);
	var toppan = document.getElementById(id + "_top")
	if(!div){
		div = document.createElement("div");
		div.className = "ContextMenubg";
		toppan = document.createElement("div");
		toppan.className = "ContextMenubgTop"
		document.body.appendChild(div)
		document.body.appendChild(toppan)
		toppan.id = id + "_top";
	}
	var html = ""
	var max = 5;
	
	div.id = id;
	menuPoping = 1 
	
	
	for (var i = 0; i < arrdata.length ; i ++ )
	{
		if(arrdata[i].length>1){
			var item = new ContextMenuItem(arrdata[i])
			var currlen = getStrActualLen(item.text);
			max = currlen  > max ? currlen  : max;
			html = html + "<div class=M_item onmousedown='ContextItemClick(" + i + ",\"" + button.innerText + "\",\"" + item.text + "\")' onselectstart='return false' onmouseover='contextitemover(this)' onmouseout='contextitemover(this)'><div class='M_itemBody'>"
						+ "<span class=M_item_Ico>" + item.icoHTML  + "</span>"
						+ "<span class=M_item_Text><span class=M_item_context>" + item.text + "</span></span>"
						+ "</div></div>"
			item = null;
		}
		else{
			html = html + "<div class=M_item style='height:3px;overflow:hidden' onselectstart='return false'>"
						+ "<div style='height:1px;border-top:1px solid #888899;margin-left:26px;margin-top:1px;margin-bottom:1px'></div>"
						+ "</div>"
		}
	}
	
	if(div.children.length>0){
		div.removeChild(div.children[0])
	}
	var dv =document.createElement("DIV")
	dv.className = "ContextMenuBody"
	dv.innerHTML =  html
	div.appendChild(dv)
	

	div.style.width = (40 + max*7) + "px";

	
	if(dock==0){
		var pos = getElementPos(button)
		div.style.left = pos.x + "px";
		div.style.top = (button.offsetHeight + pos.y*1) + "px";
		toppan.style.width = (button.offsetWidth -2) + "px";
		toppan.style.left = pos.x + "px"
		toppan.style.top = (button.offsetHeight + pos.y*1-1) + "px";
	}

	if ( arrdata.length>0)
	{
		toppan.style.display = "block"
		div.style.display = "block"
	}
	else{
		toppan.style.left =  "-10000px"
		div.style.left = "-10000px"
	}
}

function hideContextMenu(){
	if(!currPopMenu){return false}
	if(currPopMenu==mustPopMenu){mustPopMenu=null;return false}
	var button = currPopMenu
	button.setAttribute("popod",0);
	button.style.backgroundColor = "transparent";
	button.children[0].style.backgroundColor = "transparent";
	var id = "Context_MM";
	var div = document.getElementById(id);
	var toppan = document.getElementById(id + "_top")
	if(div){
		div.style.left= "-10000px";
		toppan.style.left = "-10000px";
	}
	currPopMenu = null;
	menuPoping = 0;
}

function showContextMenu(button,e,dock){ //弹出菜单
	
	if(button==currPopMenu){return true}
	if(!dock){dock = 0} //默认向下弹出
	button.setAttribute("popod",1);
	menuPoping = 1;

	if(currPopMenu ){
		currPopMenu.setAttribute("popod",0);
		currPopMenu.style.backgroundColor = "transparent";
		currPopMenu.children[0].style.backgroundColor = "transparent";
	}
	currPopMenu = button;
	button.style.backgroundColor = "#666666";
	button.children[0].style.backgroundColor = "#F9F8F7";
	var arrdata = getContextMenuArray(button.innerText);

	CreateContextMenu(button,arrdata,dock);
}
/********结束创建菜单*******/
function creatmenu(){
	var mbar = document.getElementById("menubar");
	if(!mbar) {return false;}
	var mlist = new Array("编辑(<u>E</u>)","插入(<u>I</u>)","格式(<u>O</u>)","表格(<u>A</u>)","视图(<u>V</u>)","工具(<u>T</u>)","帮助(<u>H</u>)")
	var html = "<table><tr><td><input type=image src='img/logo.gif' style='cursor:pointer' title='智邦国际 专业品牌' onclick='window.open(\"http://www.zbintel.com/\")'></td>"
	for (var i = 0 ; i < mlist.length ; i++ )
	{
		html = html + "<td class='menuitem' onmouseover='mitemmouseover(this)' onmouseout='mitemmouseout(this)' onmousedown='showContextMenu(this,event)'><span>" + mlist[i] + "</span></td>"
	}
	html = html + "</tr></table>"
	mbar.innerHTML = html;
}

function createtoolitems(tb,data){ //创建工具栏按钮
	var tb = document.getElementById(tb);
	var tr = tb.rows[0];
	var td = document.createElement("td")
	tr.appendChild(td);
	if(tb.rows[0].cells.length>1){
		td.innerHTML = "<div style='border-left:1px solid #ccc;height:16px;border-right:1px solid white;width:1px'></div>"
	}
	else{
		td.innerHTML = "<img src='img/spliter.gif' style='vertical-align:middle'>"
	}
	for (var i=0;i<data.length;i++ )
	{
		var td = document.createElement("td")
		tr.appendChild(td);
		var dat = data[i]
		if(data[i][0]=="-"){
			td.innerHTML = "<div class=divspliter></div>"
		}
		else{
			td.innerHTML ="<div  onselectstart='return false' title='" + data[i][2] + "' onclick='toolitemfun(\"" + data[i][0] + "\")' onmouseout='toolitemmv(this)' onmouseover='toolitemmv(this)' class=toolitemborder><div class=toolitembg><img src='" + data[i][1] + "'></div></div>"
		}	
	}
}

function toolitemmv(div){
	if(div.children[0].style.backgroundColor=='' || div.style.backgroundColor=="transparent"){
		div.style.backgroundColor="#0A246A"
		div.children[0].style.backgroundColor="#B6BDD2"
	}
	else{
		div.children[0].style.backgroundColor="transparent"
		div.style.backgroundColor="transparent"
	}
}



function droptextmove(tb){
	tb.className = "selectcleart";
}
function droptextout(tb){
	if (tb.work!=1)
	{tb.className = "cleart";}
}
function saveselection(){//保存选择状态
	keepselection();
	UpdateValue();
	return true;
}
function showfontlist(srcobjID){ //显示字体列表
	allclick()
	document.getElementById("fbox1").work = 1;
	if(!window.fontlistmenu){
		var fonts = new Array("宋体","新宋体","宋体-PUA","黑体","楷体_GB2312","仿宋_GB2312","方正舒体","方正姚体","华文彩云","华文仿宋","华文琥珀","华文楷体","华文隶书","华文宋体","华文细黑","华文行楷","华文新魏","华文中宋","隶书","宋体-方正超大字符集","幼圆","Arial","System","Fixedsys","Verdana","Terminal","Webdings","Wingdings 2","Wingdings 3");
		window.fontlistmenu = new ListMenu();
		for (var i=0;i<fonts.length ; i++ )
		{window.fontlistmenu.add("",fonts[i],"font-family:" + fonts[i] + ";font-14px;height:18px;margin-top:4px");}
		window.fontlistmenu.srcElement = document.getElementById("fbox1");
		document.getElementById(srcobjID).moveControl = window.fontlistmenu.srcElement;
	}
	window.fontlistmenu.show(document.getElementById(srcobjID),0,0,180,160);
}

function showfontsizelist(srcobjID){ //显示字体列表
	allclick();
	document.getElementById("fbox2").work = 1;
	if(!window.fontsizelistmenu){
		var fonts = new Array(1,2,3,4,5,6,7);
		window.fontsizelistmenu = new ListMenu();
		for (var i=0;i<fonts.length ; i++ )
		{window.fontsizelistmenu.add("",fonts[i],"font-14px;height:16px;margin-top:4px");}
		window.fontsizelistmenu.srcElement = document.getElementById("fbox2");
		document.getElementById(srcobjID).moveControl = window.fontsizelistmenu.srcElement;
	}
	window.fontsizelistmenu.show(document.getElementById(srcobjID),0,0,60,154);
}

/*弹出列表*/
function ListMenu(){
	var obj = new Object();
	obj.list = new Array();
	obj.srcElement = null;
	obj.add = function(ico,text,css){
		obj.list[obj.list.length] = {Ico : ico , Text : text , Css : css }
	}
	obj.show = function(control,offsetx,offsety,width,height){
		if(!obj.div){
			var html = "";
			obj.div = document.createElement("div");
			obj.div.className = "ListMenuDiv"
			for (var i = 0 ; i <  obj.list.length; i++)
			{
				html = html + "<div onselectstart='return false' class=ListMenuDivItem onclick='listmenuitemclick(\"" + control.id + "\",this,event)' onmouseover='return listmenuover(this)' onmouseout='return listmenuout(this)'><span class=ListMenuDivItemIco>" + (obj.list[i].Ico.length>0 ? "<img src='" + obj.list[i].Ico + "'>":"")  + "</span><span class=ListMenuDivItemText style='" + obj.list[i].Css + "'>" + obj.list[i].Text + "</span></div>";
			}
			obj.div.innerHTML = html;
			document.body.appendChild(obj.div);
			if(!window.ClickHideControl){
				window.ClickHideControl = new Array()
			}
			window.ClickHideControl[window.ClickHideControl.length] = obj.div;
		}
		var pos = getElementPos(control);
		obj.div.style.left = (pos.x*1 + offsetx*1) + "px";
		obj.div.style.top = (pos.y*1 + offsety*1 + control.offsetHeight) + "px";
		obj.div.style.width = width + "px";
		obj.div.style.height = height + "px";
		obj.div.style.display = "block";
		obj.div.show = 1;
		obj.div.moveControl = control.moveControl
	}
	return obj;
}


function exec(cmd,value){
	if(currRange){
		if(currRange.select){
			 currRange.select();
		}
	}
	if(editwindow.addEventListener){ //FF
		editwindow.document.execCommand(cmd,false,value);
	}
	else{
		editwindow.document.execCommand(cmd,true,value);
	}
}
function currRangeSelect(){
	if(currRange){
		if(currRange.select){
			 currRange.select();
		}
	}
}

function listmenuitemclick(id,item,e){
	if(id=="fontlist1"){ //改变字体名称
		editwindow.focus();
		exec("fontname",item.innerText)
		document.getElementById("fontlist1").value = item.innerText;
		return true;
	}
	if(id=="fontsizelist1"){ //改变字体大小
		editwindow.focus();
		document.getElementById("fontsizelist1").value = item.innerText;
		//currRangeSelect();
		//window.setTimeout("controlsCss('fontsize')",1000)
		exec("fontsize",item.innerText)
	}
}


function controlsCss(css){
	var controls = editwindow.document.selection.createRange().htmlText;
	switch(css){
		case "fontsize":
			alert(controls)
			break;
		default:
			return;
	}

}
function StopClickEvent(e){ //停止对click事件冒泡
	
	if(e.stopPropagation){
		e.stopPropagation();
	}
	else{
		e.cancelBubble = true;
	}
	return false;
}

/**/
function allclick(){
	if(!window.ClickHideControl){
		return false;
	}
	for (var i=0;i<window.ClickHideControl.length;i++ )
	{
		var item = window.ClickHideControl[i]
		if(item.show==1){
			item.style.display = "none";
			item.show = 0;
			if(item.moveControl){
				item.moveControl.work = 0;
				if (item.moveControl.onmouseout)
				{
					if(item.moveControl.fireEvent){
						item.moveControl.fireEvent("onmouseout");
					}
				}
			}
		}
	}
}
function listmenuover(item){
	item.style.backgroundColor = "#222266";
	item.style.color = "#ffffff";
	return false;
}
function listmenuout(item){
	item.style.backgroundColor = "#ffffff";
	item.style.color = "#000";
	return false;
}

function disEvent(e)//禁止pop事件
{  
	e.returnValue = false;
	e.cancelBubble = true;
	return false;  
} 


/*获取坐标*/
function getElementPos(el) {
 var ua = navigator.userAgent.toLowerCase();
 var isOpera = (ua.indexOf('opera') != -1);
 var isIE = (ua.indexOf('msie') != -1 && !isOpera); // not opera spoof
 if(el.parentNode === null || el.style.display == 'none') {
  return false;
 }      
 var parent = null;
 var pos = [];     
 var box;     
 if(el.getBoundingClientRect)    //IE
 {         
  box = el.getBoundingClientRect();
  var scrollTop = Math.max(document.documentElement.scrollTop, document.body.scrollTop);
  var scrollLeft = Math.max(document.documentElement.scrollLeft, document.body.scrollLeft);
  return {x:box.left + scrollLeft, y:box.top + scrollTop};
 }else if(document.getBoxObjectFor)    // gecko    
 {
  box = document.getBoxObjectFor(el); 
  var borderLeft = (el.style.borderLeftWidth)?parseInt(el.style.borderLeftWidth):0; 
  var borderTop = (el.style.borderTopWidth)?parseInt(el.style.borderTopWidth):0; 
  pos = [box.x - borderLeft, box.y - borderTop];
 } else    // safari & opera    
 {
  pos = [el.offsetLeft, el.offsetTop];  
  parent = el.offsetParent;     
  if (parent != el) { 
   while (parent) {  
    pos[0] += parent.offsetLeft; 
    pos[1] += parent.offsetTop; 
    parent = parent.offsetParent;
   }  
  }   
  if (ua.indexOf('opera') != -1 || ( ua.indexOf('safari') != -1 && el.style.position == 'absolute' )) { 
   pos[0] -= document.body.offsetLeft;
   pos[1] -= document.body.offsetTop;         
  }    
 }              
 if (el.parentNode) { 
    parent = el.parentNode;
   } else {
    parent = null;
   }
 while (parent && parent.tagName != 'BODY' && parent.tagName != 'HTML') { // account for any scrolled ancestors
  pos[0] -= parent.scrollLeft;
  pos[1] -= parent.scrollTop;
  if (parent.parentNode) {
   parent = parent.parentNode;
  } else {
   parent = null;
  }
 }
 return {x:pos[0], y:pos[1]};
}


/*给FF加innerText属性*/
(function (bool) {
    function setinnerText(o, s) {
        while (o.childNodes.length != 0) {
            o.removeChild(o.childNodes[0]);
        }

        o.appendChild(document.createTextNode(s));
    }

    function getinnerText(o) {
        var sRet = "";

        for (var i = 0; i < o.childNodes.length; i ++) {
            if (o.childNodes[i].childNodes.length != 0) {
                sRet += getinnerText(o.childNodes[i]);
            }

            if (o.childNodes[i].nodeValue) {
                if (o.currentStyle.display == "block") {
                    sRet += o.childNodes[i].nodeValue + "\n";
                } else {
                    sRet += o.childNodes[i].nodeValue;
                }
            }
        }

        return sRet;
    }

    if (bool) {
        HTMLElement.prototype.__defineGetter__("currentStyle", function () {
            return this.ownerDocument.defaultView.getComputedStyle(this, null);
        });

        HTMLElement.prototype.__defineGetter__("innerText", function () {
            return getinnerText(this);
        })

        HTMLElement.prototype.__defineSetter__("innerText", function(s) {
            setinnerText(this, s);
        })
    }
})(/Firefox/.test(window.navigator.userAgent));

// 改变编辑区高度
function sizeChange(size){
	if (!BrowserInfo.IsIE55OrMore){
		return false;
	}
	for (var i=0; i<parent.frames.length; i++){
		if (parent.frames[i].document==self.document){
			var obj=parent.frames[i].frameElement;
			var height = parseInt(obj.offsetHeight);
			if (height+size>=200){
				obj.height=height+size;

			}
			break;
		}
	}
}
// 选颜色
function SelectColor(what){
	var dEL = document.all("d_"+what);
	var sEL = document.all("s_"+what);
	var url = "Dialog/selcolor.htm?color="+encodeURIComponent(dEL.value);
	var arr = showModalDialog(url,window,"dialogWidth:280px;dialogHeight:250px;help:no;scroll:no;status:no");
	if (arr) {
		dEL.value=arr;
		sEL.style.backgroundColor=arr;
	}
}
// 显示无模式对话框
function ShowDialog(url, width, height, optValidate) {
	if (optValidate) {
		//if (!validateMode()) return;
	}
	editarea.focus();
	var arr = showModalDialog(url, window, "dialogWidth:" + width + "px;dialogHeight:" + height + "px;help:no;scroll:no;status:no");
	editarea.focus();
}