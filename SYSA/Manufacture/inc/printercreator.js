//var SpanExp = /<SPAN class=DataBody contentEditable=false dbname="\d+.\w+">[a-zA-Z_0-9\u4e00-\u9fa5]+<\/SPAN>/g;//--数据标签正则表达式
var SpanExp = /<SPAN( class="*CtrlData"*| contentEditable="*false"*| unselectable="*on"*| dbname="*\d+\.[\w\_]+"*){4}>[a-zA-Z_0-9\u4e00-\u9fa5（）:]+<\/SPAN>/g;
var DataExp = /"\d+\.[\w\_]+"/g;//--数据字段正则表达式
window.setInterval("CollectGarbage();", 10000);//--释放内存

var  currpageContainerCtls = new Array();  //记录每次激活控件时当前页面的容器控件及容器html元素，以及位置坐标、层次

function getExp(rowStr){//--获取正则表达式
	var SpanExp1 = '/<SPAN( class="*CtrlData"*| contentEditable="*false"*| unselectable="*on"*| dbname="*' + rowStr + '"*){4}>[a-zA-Z_0-9\\u4e00-\\u9fa5（）:]+<\\/SPAN>/g';
	return eval(SpanExp1);
}

//获取控件坐标
function GetObjectPos(element,model) {
    if (arguments.length > 2 || element == null) {
        return null;
    }
    var elmt = element;
    var offsetTop = elmt.offsetTop;
    var offsetLeft = elmt.offsetLeft;
    var offsetWidth = elmt.offsetWidth;
    var offsetHeight = elmt.offsetHeight;
    elmt = elmt.offsetParent;
    while (elmt) {
		// add this judge 
		if (model!=1)
		{	
		
			if (elmt.style.position == 'absolute' || elmt.style.position == 'relative'
				|| (elmt.style.overflow != 'visible' && elmt.style.overflow != '')) {
				//break;  Binry.2014.2.13.暂时注释, 如别的div
			}
		}

		offsetTop += elmt.offsetTop;
		offsetLeft += elmt.offsetLeft;
		 elmt = elmt.offsetParent;
    }	
    return { top: offsetTop, left: offsetLeft, width: offsetWidth, height: offsetHeight };
} 

function clearPrinterText(){
	//清除一下打印控制符
	var hkey_root,hkey_path,hkey_key   
    hkey_root="HKEY_CURRENT_USER";
    hkey_path="\\Software\\Microsoft\\Internet Explorer\\PageSetup\\";
      //这个是用来设置打印页眉页脚的，你可以设置为空或者其它
      try{   
            var RegWsh = new ActiveXObject("WScript.Shell"); 
              
            hkey_key="header";
            RegWsh.RegWrite(hkey_root+hkey_path+hkey_key,"");
            
            hkey_key="footer";
            RegWsh.RegWrite(hkey_root+hkey_path+hkey_key,"");
            
      }catch(e){
			//alert(e.description);
      }

}
function showview(){
	clearPrinterText();
	document.getElementById("wb").swapNode(document.getElementById("FrameBorderPage"));
	try{
		PrintQZ();
		document.getElementById("wb").ExecWB(7,1);
		ResetQZ();
		document.getElementById("wb").swapNode(document.getElementById("FrameBorderPage"));
	}catch(e){
		document.getElementById("wb").swapNode(document.getElementById("FrameBorderPage"));
		alert("无法启用浏览器内置组件，您可能需要手动调整浏览器的安全设置。")
	}
}
function doprint(){
	var pageBody = document.getElementById("FrameBorderPage");
	var html = pageBody.innerHTML;
	var id = document.getElementById("id").value;
	var formid = document.getElementById("formid").value;
	var isSum = document.getElementById("isSum").value;
	ajax.regEvent("SavePrintInfo");
	ajax.addParam("id",id);
	ajax.addParam("formid",formid);
	ajax.addParam("isSum",isSum);
	//ajax.addParam("html",escape(html));
	//ajax.exec();
	var v = ajax.send();//alert(v)
	if (v == "true"){
		PrintQZ();
		document.getElementById("wb").swapNode(document.getElementById("FrameBorderPage"));
		window.print();
		ResetQZ();
		document.getElementById("wb").swapNode(document.getElementById("FrameBorderPage"));
	}else{
		alert("打印参数错误，请与管理员联系！")
	}
}

function doprintHistory(){
	var id = document.getElementById("id").value;
	ajax.regEvent("SavePrintHistory");
	ajax.addParam("id",id);
	//ajax.exec();
	var v = ajax.send();//alert(v)
	if (v == "true"){
		document.getElementById("wb").swapNode(document.getElementById("FrameBorderPage"));
		window.print();
		document.getElementById("wb").swapNode(document.getElementById("FrameBorderPage"));
	}else{
		alert("打印参数错误，请与管理员联系！")
	}
}

function colorListChange(lbox){
	var txt = window.getParent(lbox,3).cells[0].children[0]
	txt.value=lbox.value;
	txt.parentElement.parentElement.style.backgroundColor=lbox.value;
	txt.style.color = lbox.options[lbox.selectedIndex].style.color;
}

function attListChange(lbox){
	var txt = window.getParent(lbox,3).cells[0].children[0]
	var txt1 = window.getParent(lbox,3).cells[0].children[1]
	txt.value=lbox.value;
	for(var i = 0; i < lbox.options.length; i++){
		if(lbox.options[i].selected){
			txt1.value = lbox.options[i].innerText
		}
	}
}

function DBListChange(lbox){
	var txt = window.getParent(lbox,3).cells[0].children[0]
	for (var i = 0; i < lbox.length; i++){
		if(lbox[i].selected){
			txt.value=lbox[i].text;
		}
	}
	if (lbox.value != ""){
		window.curreditSpan.obj.dataid = lbox.value;
	}
}

//function colorListButton(){
//	var html = "<div style='position:relative;width:16px;overflow:hidden;height:16px;left:-2px'>" 
//			  + "<select onchange='colorListChange(this)' class='colorbox'>" 
//			  +"<option value='white' style='background-color:white;color:#000'>white</option>"
//			  +"<option value='red' style='background-color:red;color:white;'>red</option>"
//			  +"<option value='orange' style='background-color:orange;color:white'>orange</option>"
//			  +"<option value='yellow' style='background-color:yellow;color:#aaaa00'>yellow</option>"
//			  +"<option value='green' style='background-color:green;color:white'>green</option>"
//			  +"<option value='blue' style='background-color:blue;color:white'>blue</option>"
//			  +"<option value='indigo' style='background-color:Indigo;color:white'>Indigo</option>"
//			  +"<option value='purple' style='background-color:Purple;color:white'>Purple</option>"
//			  +"<option value='black' style='background-color:black;color:#ccc'>black</option>"
//			  +"<option value='aliceblue' style='background-color:aliceblue;color:#000'>aliceblue</option>"
//			  +"<option value='antiquewhite' style='background-color:antiquewhite;color:#000'>antiquewhite</option>"
//			  +"<option value='chartreuse' style='background-color:chartreuse;color:#000'>chartreuse</option>"
//			  +"<option value='gold' style='background-color:gold;color:white'>gold</option>"
//			  +"<option value='cornsilk' style='background-color:cornsilk;color:#000'>cornsilk</option>"
//			  +"<option value='magenta' style='background-color:magenta;color:#000'>magenta</option>"
//			  +"<option value='mediumpurple' style='background-color:mediumpurple;color:white'>mediumpurple</option>"
//			  +"<option value='sienna' style='background-color:sienna;color:white'>sienna</option>"
//			  +"<option value='darkgray' style='background-color:darkgray;color:white'>darkgray</option>"
//			  +"<option value='gray' style='background-color:gray;color:white'>gray</option>"
//			  +"<option value='limegreen' style='background-color:limegreen;color:white'>limegreen</option>"
//			  +"<option value='lime' style='background-color:lime;color:white'>lime</option>"
//			  +"<option value='' style='background-color:transparent;color:#000'>默认</option>"
//			  +"</select></div>"
//	return html
//}
//
//function fontListButton(){
//	var html = "<div style='position:relative;width:16px;overflow:hidden;height:16px;left:-2px'>" 
//			  + "<select onchange='attListChange(this)' class='fontbox'>" 
//			  +"<option value='宋体'>宋体</option>"
//			  +"<option value='黑体'>黑体</option>"
//			  +"<option value='隶书'>隶书</option>"
//			  +"<option value='新宋体'>新宋体</option>"
//			  +"<option value='幼圆'>幼圆</option>"
//			  +"<option value='微软雅黑'>微软雅黑</option>"
//			  +"<option value='仿宋_GB2312'>仿宋_GB2312</option>"
//			  +"<option value='方正舒体'>方正舒体</option>"
//			  +"<option value='方正姚体'>方正姚体</option>"
//			  +"<option value='华文彩云'>华文彩云</option>"
//			  +"<option value='华文仿宋'>华文仿宋</option>"
//			  +"<option value='华文琥珀'>华文琥珀</option>"
//			  +"<option value='华文楷体'>华文楷体</option>"
//			  +"<option value='华文隶书'>华文隶书</option>"
//			  +"<option value='华文行楷'>华文行楷</option>"
//			  +"<option value='华文彩云'>华文彩云</option>"
//			  +"<option value='华文彩云'>华文彩云</option>"
//			  +"<option value='arial'>arial</option>"
//			  +"<option value='Arial Black'>Arial Black</option>"
//			  +"<option value='fixedsys'>fixedsys</option>"
//			  +"<option value='system'>system</option>"
//			  +"</select></div>"
//	return html
//}
//
//
//function fontSizeListButton(){
//	var html = "<div style='position:relative;width:16px;overflow:hidden;height:16px;left:-2px'>" 
//			  + "<select onchange='attListChange(this)' class='fontbox'>" 
//			  +"<option value='10px'>10px</option>"
//			  +"<option value='12px'>12px</option>"
//			  +"<option value='13px'>13px</option>"
//			  +"<option value='14px'>14px</option>"
//			  +"<option value='16px'>16px</option>"
//			  +"<option value='18px'>18px</option>"
//			  +"<option value='22px'>22px</option>"
//			  +"<option value='28px'>28px</option>"
//			  +"<option value='36px'>36px</option>"
//			  +"<option value='48px'>48px</option>"
//			  +"<option value='56px'>56px</option>"
//			  +"<option value='72px'>72px</option>"
//			  +"<option value='88px'>88px</option>"
//			  +"<option value='120px'>120px</option>"
//			  +"<option value='160px'>160px</option>"
//			  +"</select></div>"
//	return html
//}
//
//function BoolListButton(){
//	var html = "<div style='position:relative;width:16px;overflow:hidden;height:16px;left:-2px'>" 
//			  + "<select onchange='attListChange(this)' class='fontbox'>" 
//			  +"<option value='true'>是 true</option>"
//			  +"<option value='false'>否 false</option>"
//			  +"</select></div>"
//	return html
//}
//
//function TimeListButton(){
//	var html = "<div style='position:relative;width:16px;overflow:hidden;height:16px;left:-2px'>" 
//			  + "<select onchange='attListChange(this)' class='fontbox'>" 
//			  +"<option value=''>默认</option>"
//			  +"<option value='&Y-&M-&D &H:&N:&S'>yyyy-mm-dd hh:nn:ss</option>"
//			  +"<option value='&Y年&M月&D日 &H:&N:&S'>yyyy年mm月dd日 hh:nn:ss</option>"
//			  +"<option value='&Y-&M-&D'>yyyy-mm-dd</option>"
//			  +"<option value='&Y年&M月&D日'>yyyy年mm月dd日</option>"
//			  +"<option value='&H:&N:&S'>hh:nn:ss</option>"
//			  +"</select></div>"
//	return html
//}

var SelectList = {
	Color:{
		Options:[
			{text:"white",value:"white",style:"background-color:white;color:#000"},
			{text:"red",value:"red",style:"background-color:red;color:white;"},
			{text:"orange",value:"orange",style:"background-color:orange;color:white"},
			{text:"yellow",value:"yellow",style:"background-color:yellow;color:#aaaa00"},
			{text:"green",value:"green",style:"background-color:green;color:white"},
			{text:"blue",value:"blue",style:"background-color:blue;color:white"},
			{text:"indigo",value:"indigo",style:"background-color:Indigo;color:white"},
			{text:"purple",value:"purple",style:"background-color:Purple;color:white"},
			{text:"black",value:"black",style:"background-color:black;color:#ccc"},
			{text:"aliceblue",value:"aliceblue",style:"background-color:aliceblue;color:#000"},
			{text:"antiquewhite",value:"antiquewhite",style:"background-color:antiquewhite;color:#000"},
			{text:"chartreuse",value:"chartreuse",style:"background-color:chartreuse;color:#000"},
			{text:"gold",value:"gold",style:"background-color:gold;color:white"},
			{text:"cornsilk",value:"cornsilk",style:"background-color:cornsilk;color:#000"},
			{text:"magenta",value:"magenta",style:"background-color:magenta;color:#000"},
			{text:"mediumpurple",value:"mediumpurple",style:"background-color:mediumpurple;color:white"},
			{text:"sienna",value:"sienna",style:"background-color:sienna;color:white"},
			{text:"darkgray",value:"darkgray",style:"background-color:darkgray;color:white"},
			{text:"gray",value:"gray",style:"background-color:gray;color:white"},
			{text:"limegreen",value:"limegreen",style:"background-color:limegreen;color:white"},
			{text:"lime",value:"lime",style:"background-color:lime;color:white"},
			{text:"默认",value:"",style:"background-color:transparent;color:#000"}
		]
	},
	FontFamily:{
		Options:[
			{text:"默认",value:"",style:""},
			{text:"宋体",value:"宋体",style:""},
			{text:"黑体",value:"黑体",style:""},
			{text:"隶书",value:"隶书",style:""},
			{text:"新宋体",value:"新宋体",style:""},
			{text:"幼圆",value:"幼圆",style:""},
			{text:"微软雅黑",value:"微软雅黑",style:""},
			{text:"仿宋_GB2312",value:"仿宋_GB2312",style:""},
			{text:"方正舒体",value:"方正舒体",style:""},
			{text:"方正姚体",value:"方正姚体",style:""},
			{text:"华文彩云",value:"华文彩云",style:""},
			{text:"华文仿宋",value:"华文仿宋",style:""},
			{text:"华文琥珀",value:"华文琥珀",style:""},
			{text:"华文楷体",value:"华文楷体",style:""},
			{text:"华文隶书",value:"华文隶书",style:""},
			{text:"华文行楷",value:"华文行楷",style:""},
			{text:"华文彩云",value:"华文彩云",style:""},
			{text:"arial",value:"arial",style:""},
			{text:"Arial Black",value:"Arial Black",style:""},
			{text:"fixedsys",value:"fixedsys",style:""},
			{text:"system",value:"system",style:""}
		]
	},
	FontSize:{
		Options:[
			{text:"默认",value:"",style:""},
			{text:"10px",value:"10px",style:""},
			{text:"12px",value:"12px",style:""},
			{text:"13px",value:"13px",style:""},
			{text:"14px",value:"14px",style:""},
			{text:"16px",value:"16px",style:""},
			{text:"18px",value:"18px",style:""},
			{text:"22px",value:"22px",style:""},
			{text:"28px",value:"28px",style:""},
			{text:"36px",value:"36px",style:""},
			{text:"48px",value:"48px",style:""},
			{text:"56px",value:"56px",style:""},
			{text:"72px",value:"72px",style:""},
			{text:"88px",value:"88px",style:""},
			{text:"120px",value:"120px",style:""},
			{text:"160px",value:"160px",style:""}
		]
	},
	BooLean:{
		Options:[
			{text:"默认",value:"",style:""},
			{text:"是",value:"true",style:""},
			{text:"否",value:"false",style:""}
		]
	},
	TimeType:{
		Options:[
			{text:"默认",value:"",style:""},
			{text:"yyyy-mm-dd hh:nn:ss",value:"&Y-&M-&D &H:&N:&S",style:""},
			{text:"yyyy年mm月dd日 hh:nn:ss",value:"&Y年&M月&D日 &H:&N:&S",style:""},
			{text:"yyyy-mm-dd",value:"&Y-&M-&D",style:""},
			{text:"yyyy年mm月dd日",value:"&Y年&M月&D日",style:""},
			{text:"hh:nn:ss",value:"&H:&N:&S",style:""},
			{text:"年份[yyyy]",value:"&Y",style:""},
			{text:"月份[mm]",value:"&M",style:""},
			{text:"日期[dd]",value:"&D",style:""},
			{text:"小时[hh]",value:"&H",style:""},
			{text:"分钟[nn]",value:"&N",style:""},
			{text:"秒[ss]",value:"&S",style:""}
		]
	},
	Direction:{
		Options:[
			{text:"默认",value:"",style:""},
			{text:"横向",value:"横向",style:""},
			{text:"纵向",value:"纵向",style:""}
		]
	}
};

function GetSelectList(type){
	type = type.toLowerCase();
	switch(type){
		case "color":
			var Items = SelectList.Color.Options
			break;
		case "fontsize":
			var Items = SelectList.FontSize.Options
			break;
		case "fontfamily":
			var Items = SelectList.FontFamily.Options
			break;
		case "boolean":
			var Items = SelectList.BooLean.Options
			break;
		case "timetype":
			var Items = SelectList.TimeType.Options
			break;
		case "direction":
			var Items = SelectList.Direction.Options
			break;
		default:
			var Items = SelectList.BooLean.Options
	}
	var html = "<div style='position:relative;width:16px;overflow:hidden;height:16px;left:-2px'>"
	html = html + "<select onchange='attListChange(this)' class='fontbox'>"
	for (var i = 0; i< Items.length; i++){
		html = html + "<option value='" + Items[i].value + "' style='" + Items[i].style + "'>" + Items[i].text + "</option>"
	}
	html = html + "</select></div>";
	return html
}
function GetSelectListText(type,v){
	type = type.toLowerCase();
	switch(type){
		case "color":
			var Items = SelectList.Color.Options
			break;
		case "fontsize":
			var Items = SelectList.FontSize.Options
			break;
		case "fontfamily":
			var Items = SelectList.FontFamily.Options
			break;
		case "boolean":
			var Items = SelectList.BooLean.Options
			break;
		case "timetype":
			var Items = SelectList.TimeType.Options
			break;
		case "direction":
			var Items = SelectList.Direction.Options
			break;
		default:
			var Items = SelectList.BooLean.Options
	}
	for(var i = 0; i < Items.length; i++){
		if(Items[i].value == v){
			return Items[i].text;
		}
	}
}


//function DBListButton(){
//	var html = "<div style='position:relative;width:16px;overflow:hidden;height:16px;left:-2px'>" 
//	html = html + "<select onchange='DBListChange(this)' class='fontbox'>" 
//	var dbname = "xxx";
//	for (var i = 0; i < datafields.length; i++){
//		if (datafields[i].t != dbname && datafields[i].r == window.curreditSpan.obj.ResolveType){
//			dbname = datafields[i].t;
//			html = html + "<option value='" + datafields[i].tid + "'> " + datafields[i].t + "</option>";
//		}
//	}
//	html = html + "</select></div>"
//	return html
//}


function attvSelect(box){//--允许选择内容
	window.event.cancelBubble = true;
	return true;
}
function showattrlist(div){ //显示属性
	var html = "<table style='width:100%;table-layout:fixed'>"
	var obj = div.obj;
	if (obj.action == "show"){return false;}//解析页面终止生成菜单
	if(obj){
		var w = (div.children[1].children[0])?div.children[1].children[0].offsetWidth:div.children[1].offsetWidth;
		var h = (div.children[1].children[0])?div.children[1].children[0].offsetHeight:div.children[1].offsetHeight;
		html = html + "<tr><td class='attlabel'>类型:</td><td class='attvalue'><table><tr><td style='padding-left:3px;' disabled>"
					+ obj.name +"</td><td></td></tr></table></td></tr>"
		if(obj.ResolveType == 3){
			html = html + "<tr><td class='attlabel'>明细:</td><td class='attvalue'><table><tr><td class='attv2' disabled>"
			if(obj.DataID){
				ajax.regEvent("LoadDataTitle");
				ajax.addParam("dataID",obj.DataID);
				var title = ajax.send();
				if(title == "false"){
					title = "未绑定明细";
				}else{
					title = title;
				}
			}else{
				var title = "未绑定明细";
			}
			html = html + "<div class=pattvalue style='color:#666;padding-left:3px;overflow:hidden;line-height:22px;'>" + title + "</div>";
			html = html + "</td><td>"
			if(obj.DataID){
				html = html + "<input onclick='DelDataID()' title='解除明细绑定' type=image src='../../images/smico/attrib.gif' style='position:relative;left:-1px'>"
			}
			html = html + "</td></tr></table></td></tr>"
		}
		
		html = html + "<tr><td class='attlabel'>横坐标:</td><td class='attvalue'><table><tr><td>"
					+ "<input onselectstart='return attvSelect(this)' type=text onpropertychange='ExpLen(this);if(window.contEdit!=0){updateattr(this)}' onfocus='this.fs = 1' onkeyup='ExpLen(this)' onblur='this.fs = 0;ExpLen(this)' att='div.style.left' id='attlist_xzb' class=pattvalue value='" + PxToMM(div.offsetLeft,"x") + "mm'></td><td></td></tr></table></td></tr>"
		
		html = html + "<tr><td class='attlabel'>纵坐标:</td><td class='attvalue'><table><tr><td class='attv2'>"
					+ "<input onselectstart='return attvSelect(this)' type=text  onpropertychange='ExpLen(this);if(window.contEdit!=0){updateattr(this)}' onfocus='this.fs = 1' onkeyup='ExpLen(this)' onblur='this.fs = 0;ExpLen(this)' att='div.style.top' id='attlist_yzb' class=pattvalue value='" + PxToMM(div.offsetTop,"y") + "mm'></td><td></td></tr></table></td></tr>"
		
		html = html + "<tr><td class='attlabel'>宽度:</td><td class='attvalue'><table><tr><td class='attv2'>"
					+ "<input id='CtrlInput_W' onselectstart='return attvSelect(this)' type=text  onpropertychange='ExpLen(this);if(window.contEdit!=0){updateattr(this)}' onfocus='this.fs = 1' onkeyup='ExpLen(this)' onblur='this.fs = 0;ExpLen(this)' att='div.children[1].children[0].style.width' id='attlist_wzb' class=pattvalue value='" + PxToMM(w,"x") + "mm'></td><td></td></tr></table></td></tr>"
		
		html = html + "<tr><td class='attlabel'>高度:</td><td class='attvalue'><table><tr><td class='attv2'>"
					+ "<input id='CtrlInput_H' onselectstart='return attvSelect(this)' type=text  onpropertychange='ExpLen(this);if(window.contEdit!=0){updateattr(this)}' onfocus='this.fs = 1' onkeyup='ExpLen(this)' onblur='this.fs = 0;ExpLen(this)' att='div.children[1].children[0].style.height' id='attlist_hzb' class=pattvalue value='" + PxToMM(h,"y") + "mm'></td><td></td></tr></table></td></tr>"
		
//		html = html + "<tr><td class='attlabel'>文字颜色:</td><td class='attvalue'><table><tr><td class='attv2'>"
//					+ "<input onselectstart='return attvSelect(this)' type=text onpropertychange='if(window.contEdit!=0){updateattr(this)}' att='div.children[1].style.color' class=pattvalue value='" + div.children[1].style.color + "' readonly></td><td>" + GetSelectList("color") + "</td></tr></table></td></tr>"
//		
//		html = html + "<tr><td class='attlabel'>背景颜色:</td><td class='attvalue'><table><tr><td class='attv2'>"
//					+ "<input onselectstart='return attvSelect(this)' type=text onpropertychange='if(window.contEdit!=0){updateattr(this)}' att='div.children[1].style.backgroundColor' class=pattvalue value='" + div.children[1].style.backgroundColor + "' readonly></td><td>" + colorListButton() + "</td></tr></table></td></tr>"
//
//		html = html + "<tr><td class='attlabel'>字体:</td><td class='attvalue'><table><tr><td class='attv2'>"
//					+ "<input onselectstart='return attvSelect(this)' type=text att='div.children[1].style.fontFamily' onclick='setAttFont()' class=pattvalue value='" + getFontText() + "' readonly></td><td><input onclick='setAttFont()' type=image src='../../images/smico/attrib.gif' style='position:relative;left:-1px'></td></tr></table></td></tr>"
		
		//html = html + "<tr><td class='attlabel'>文字大小:</td><td class='attvalue'><table><tr><td class='attv2'>"
		//			+ "<input onselectstart='return attvSelect(this)' type=text   onpropertychange='ExpLen(this);if(window.contEdit!=0){updateattr(this)}' onfocus='this.fs = 1' onkeyup='ExpLen(this)' onblur='this.fs = 0;ExpLen(this)' att='div.children[1].style.fontSize' class=pattvalue value='" + div.children[1].style.fontSize + "'></td><td>" + fontSizeListButton() + "</td></tr></table></td></tr>"
		for (var item in obj)
		{
			if (item.indexOf("att_")==0){
				html = html + "<tr><td class='attlabel'>" + item.replace("att_","") + ":</td><td class='attvalue'>" + getobjectvalue(obj,item) + "</td></tr>"
			}
		}
	
	}
	html = html + "</table>"
	document.getElementById("grpchild1000").innerHTML = html
	var sboxs = document.getElementById("grpchild1000").getElementsByTagName("select")
	for (var i=0;i<sboxs.length ; i ++ )
	{
		
			try{
				//sboxs[i].value = window.getParent(sboxs[i],3).cells[0].children[0].value.toLowerCase();
				var v = window.getParent(sboxs[i],3).cells[0].children[0].value;
//				var zdy = 1;
//				for (var ii = 0; ii < sboxs[i].options.length; ii++){
//					if(v ==  sboxs[i].options[ii].value){
//						zdy = 0;
//					}
//				}
//				if (zdy == 1){
//					var opt = document.createElement("option");
//					opt.value = v;
//					opt.innerText = v;
//					sboxs[i].appendChild(opt);
//				}
				sboxs[i].value = v;
				//sboxs[i].fireEvent("onchange");//应用下拉框颜色效果
			}
			catch(e){}
	}

}


function updateattr(lbox){//--根据左面面板值更新控件数据JSON值
	var objstr = lbox.att;
	var div = window.curreditSpan;
	var objstr = lbox.att;
	switch (objstr){
//		case "div.children[1].style.color":
//			div.obj.color = lbox.value;
//			break;
//		case "div.children[1].style.backgroundColor":
//			div.obj.backgroundColor = lbox.value;
//			break;
//		case "div.children[1].style.fontFamily":
//			div.obj.fontFamily = lbox.value;
//			break;
//		case "div.children[1].style.fontSize":
//			div.obj.fontSize = lbox.value;
//			break;
		case "div.children[1].children[0].style.height":
			//if(!isNaN(lbox.value)){lbox.value = lbox.value +"mm"}
			div.obj.height = lbox.value;
			break;
		case "div.children[1].children[0].style.width":
			//if(!isNaN(lbox.value)){lbox.value = lbox.value +"mm"}
			div.obj.width = lbox.value;
			break;
		case "div.style.left":
			//if(!isNaN(lbox.value)){lbox.value = lbox.value +"mm"}
			div.obj.left = lbox.value;
			break;
		case "div.style.top":
			//if(!isNaN(lbox.value)){lbox.value = lbox.value +"mm"}
			div.obj.top = lbox.value;
			break;
		default:
	}
	try{
		switch (lbox.tagName.toLowerCase()){
			case "div":
				var MyValue =  eval("lbox.innerHTML");
				eval(objstr + "= MyValue");
				break;
			default:
				if(objstr == "div.style.left" || objstr == "div.style.top" || objstr == "div.children[1].children[0].style.height" || objstr == "div.children[1].children[0].style.width"){
					if(isNaN(lbox.value)){
						eval(objstr + "=lbox.value");
					}else{
						eval(objstr + "=lbox.value +'mm'");
					}
					if(objstr == "div.children[1].children[0].style.height"){
						//--防止某些情况height被自动设置为固定值
						//--（例如：有style="border-bottom:1pt solid #fff;的div标签在拖动改变大小时，会自动增加height值）
						if(div.obj.name == "文字"){
							div.children[1].children[0].style.height = "100%";
							if(isNaN(lbox.value)){
								div.children[1].children[0].style.minHeight=lbox.value;
							}else{
								div.children[1].children[0].style.minHeight=lbox.value +'mm';
							}
						}
					}
				}else{
					eval(objstr + "=lbox.value");
				}
		}
		
	}catch(e){
		
	}
//	if(div.obj.TDWidth){//--重新定义表格宽度
//		SetTableWidth(div.obj)
//	}
}


function upControlAttr(box,att){//--根据左面面板值更新控件样式
	
	//try{
		updateattr(box);//--更新控件数据
		
		var obj =window.curreditSpan.obj;
		if(obj.attchange){//--触发更新事件
			obj.attchange(att);
		}
	//}
	//catch(e){}
}

function getobjectvalue(obj,att){//--生成自定义属性的左侧控制板
	var v = eval("obj." + att);
	var t = eval("obj.attType." + att);
	if (t == "color" || t == "timetype" || t == "boolean" || t == "direction"){
		return "<table><tr><td class='attv2'>"
				+ "<input onselectstart='return attvSelect(this)' type=hidden onpropertychange='upControlAttr(this,\"" + att + "\")' att='div.obj." + att
				+ "' class=pattvalue value='" + v + "' readonly>"
				+"<input type=text class=pattvalue value='" + GetSelectListText(t,v) + "' readonly></td><td>" +  GetSelectList(t) + "</td></tr></table>";
	}else{
		switch(t){
			case "img"://--图片类型
				return "<table><tr><td class='attv2'><div onselectstart='return attvSelect(this)'att='div.obj." + att + "' class=pattvalue style='color:#666;padding-left:3px;overflow:hidden;line-height:22px;display:none;' att='div.obj." + att 
				+ "'>" + v + "</div>&nbsp;</td><td><input onclick='ImgUploadWindow(this)' type=image src='../../images/smico/attrib.gif' style='position:relative;left:-1px' title='点击设置" + att.replace(/att_/g,"") +  "属性'></td></tr></table>";
				break;
			case "num"://--数字类型
				return "<table><tr><td class='attv2'><input onkeydown='window.event.cancelBubble = true;return true;' onselectstart='return attvSelect(this)' onfocus='this.fs=1' onblur='this.fs=0;upControlAttr(this,\"" + att + "\");' onpropertychange='ExpNum(this);if(this.fs==0){upControlAttr(this,\"" + att + "\")}' att='div.obj." + att 
				+ "' class=pattvalue value='" + v + "' /></td></tr></table>"
				break;
			case "line"://--线条样式类型
				return "<table><tr><td class='attv2'><div onselectstart='return attvSelect(this)'att='div.obj." + att + "' class=pattvalue style='color:#666;padding-left:3px;overflow:hidden;line-height:22px;display:none;'>" + v + "</div>&nbsp;</td><td><input onclick='showLineStyleWindow(this)' type=image src='../../images/smico/attrib.gif' style='position:relative;left:-1px' title='点击设置" + att.replace(/att_/g,"") +  "属性'></td></tr></table>";
				break;
			case "text"://--文本类型
				return "<table><tr><td class='attv2'><div contentEditable='true' onkeydown='window.event.cancelBubble = true;return true;' onselectstart='return attvSelect(this)' onfocus='this.fs=1' onblur='this.fs=0;upControlAttr(this,\"" + att + "\");' onpropertychange='if(this.fs==0){upControlAttr(this,\"" + att + "\")}' att='div.obj." + att 
				+ "' class=pattvalue>" + v + "</div></td></tr></table>"
				break;
			default:
				return "<table><tr><td class='attv2'><div contentEditable='true'onkeydown='window.event.cancelBubble = true;return true;' onselectstart='return attvSelect(this)' onfocus='this.fs=1' onblur='this.fs=0;upControlAttr(this,\"" + att + "\");' onpropertychange='if(this.fs==0){upControlAttr(this,\"" + att + "\")}' att='div.obj." + att 
				+ "' class=pattvalue>" + v + "</div></td></tr></table>"
		}
	}
}



function showArrayList(button){//弹出层，并根据数组生成对应数的选择框
	var tr = window.getParent(button,6);
	var att = tr.cells[0].innerText.replace(":","")
	if(!tr){return false}
	var div = window.DivOpen("sadaaasd",att + "设置",500,320,'a','b',true,12,true,1)
	try{
		var v = tr.getElementsByTagName("div")[0].att;
		div.obj =  window.curreditSpan.obj;
		var ex = '/<SPAN class=CountBody contentEditable=false>[a-zA-Z_0-9\\u4e00-\\u9fa5]+<\\/SPAN>/g;'
		div.obj.ex = ex;
		var list = eval(v)
		var ctrlType = eval("div.obj.attType.att_"+att);
		var html = "<table style='width:100%' style='border-collapse:collapse;'>"
		for (var i=0;i<list.length ; i ++ )
		{
			//--修改：改为div接收数据  修改者：赵宇飞  修改时间：2014-03-26
			html = html + "<tr>"
			if (list[i].constructor == Array){
				for(var ii = 0;ii < list[i].length;ii++){
					html = html + "<td class='arraylisttext'><div onkeydown='window.event.cancelBubble = true;return true;arrayChange(this)' onkeyup='arrayChange(this);' contentEditable='true' name='" + i + "," + ii + "' style='overflow:hidden' tabindex='0'>" + list[i][ii] + "</div></td>"
					if (ctrlType == "data"){
						html = html + "<td><button class=wavbutton style='width:20px' title='选择数据项目' onclick='arrayselectdatasrc(this)'><img src='../../images/smico/search.gif'></button></td>"
					}
				}
			}else{
				html = html + "<td style='width:5%;text-align:center;font-weight:bold'>" + (i+1) + "</td><td style='width:90%'><div class='arraylisttext' onpropertychange='window.event.cancelBubble = true;arrayChange(this)' onkeydown='window.event.cancelBubble = true;return true;arrayChange(this)' onkeyup='arrayChange(this);' contentEditable='true' tabindex='0'>" + list[i] + "</div></td>"
				if (ctrlType == "count"){
					html = html + "<td><select onchange='SetCount(this)'><option value='默认'>默认</option><option value='当页'>当页</option><option value='全部'>全部</option></select></td>"
				}
				if (ctrlType == "data" || ctrlType == "count"){
					html = html + "<td><button class=wavbutton style='width:20px' title='选择数据项目' onclick='arrayselectdatasrc(this)'><img src='../../images/smico/search.gif'></button></td>"
				}
/*				if (ctrlType == "count"){
					html = html + "<td><select onchange='SetCount(this)'><option value=''>默认</option><option value='合计'>合计</option><option value='平均'>平均</option><option value='最大'>最大</option><option value='最小'>最小</option></select><select onchange='SetCount(this)'><option value=''>空</option><option value='当页'>当页</option><option value='全部'>全部</option></select><select  onchange='SetCount(this)'><option value=''>空</option>"
					for(var ii = 0; ii < list.length; ii++){
						html = html + "<option value='第" + (ii+1) + "列'>第" + (ii+1) + "列</option>"
					}
					html = html + "</select></td>";
				}*/
			}
			html = html + "</tr>"
			//--修改结束
		}
		html = html + "</table>";
		div.innerHTML = html;
		div.att = att;
		div.linkrow =  tr
	}catch(e){
		div.innerText = "\n 提取属性失败，描述：" + e.message;	
	}
}

function SetCount(input){
	var tr = getParent(input,2);
	var s1 = tr.cells[2].children[0].value;
	//var span = "<SPAN class=DataBody title=平均当页第1列 contentEditable=false>1</SPAN>"
	var ex = window.curreditSpan.obj.ex;//--获得匹配方式
	ex = eval(ex)
	var html = tr.cells[1].children[0].innerHTML;
	if (s1){
		var span = "<SPAN class=CountBody contentEditable=false >" + s1 + "</SPAN>"
		if(html.match(ex)){
			html = html.replace(ex,"");
			html = span + html;
		}else{
			html = span + html;
		}
		tr.cells[1].children[0].innerHTML = html;
	}
}

function insertDataSrc(obj){
	return function(txt,tag){
		window.contextBodyMenu.hide();
		obj.innerHTML = obj.innerHTML + "<span dbname='" + tag + "' class='DataBody' contentEditable='false' >" + txt + "</span>";
		window.curreditSpan.obj.dataid = tag.split(".")[0];//--数据源绑定
		obj.focus();
		obj.fireEvent("onkeyup");
	}
}

function showdatsrcMenu(obj){
	var m =  new contextmenu(insertDataSrc(obj))
	var currcls = "xxx"
	var RlvType=window.curreditSpan.obj.ResolveType;
	var dataid = window.curreditSpan.obj.dataid;
	var imenu = null;
	for (var i = 0;i<datafields.length; i++ )
	{
		if(datafields[i].r==RlvType){
			if (dataid){//--如果控件已绑定数据源，则只显示对应数据源的列表
				if(datafields[i].tid ==dataid){
					if(currcls!=datafields[i].t){
						currcls =datafields[i].t;
						imenu = m.add();
						imenu.text = currcls;
						imenu.childmenu = new contextmenu(insertDataSrc(obj))
						imenu.childmenu.width = 150
						imenu.imageurl = "../../images/smico/folder.gif"
					}
					var mm = imenu.childmenu.add()
					mm.text = datafields[i].v;
					mm.tag = datafields[i].tid + "." + datafields[i].n;
					mm.imageurl = "../../images/smico/attrib.gif"
				}
			}else{
				if(currcls!=datafields[i].t){
					currcls =datafields[i].t;
					imenu = m.add();
					imenu.text = currcls;
					imenu.childmenu = new contextmenu(insertDataSrc(obj))
					imenu.childmenu.width = 150
					imenu.imageurl = "../../images/smico/folder.gif"
				}
				var mm = imenu.childmenu.add()
				mm.text = datafields[i].v;
				mm.tag = datafields[i].tid + "." + datafields[i].n;
				mm.imageurl = "../../images/smico/attrib.gif"
			}
		}
	}
	m.width = obj.offsetWidth
	window.contextBodyMenu = m
	m.show(obj)
}

function arrayselectdatasrc(button){
	var input = button.parentElement.parentElement.cells[1].children[0]
	showdatsrcMenu(input)
}

function arrayChange(tbox){
	var div = window.getParent(tbox,5)
	var list = new Array();
	//var tbox = div.getElementsByTagName("textarea");
	var tbox = div.getElementsByTagName("div");
	for (var i = 0;i<tbox.length ;i++ )
	{
		if (tbox[i].name){
			var name = tbox[i].name.split(",");
			if (typeof(list[name[0]]) == "undefined"){
				list[name[0]] = eval("['']");
			}
			list[name[0]][name[1]] = tbox[i].innerHTML;
		}else{
			list[i] = tbox[i].innerHTML;
		}
		//alert(list)
	}
	eval("div.obj.att_" + div.att + "= list;")
	//----修改：改用div接收回传数据  修改时间：2014-03-26  修改者：赵宇飞
	//div.linkrow.cells[1].getElementsByTagName("input")[0].value = list;
	div.linkrow.cells[1].getElementsByTagName("div")[0].innerHTML = list;
	//----
	div.obj.attchange("att_" + div.att);
}

function getMaxzIndex(div){
	var zindex = 1
	//var divs = document.getElementById("pagebody").getElementsByTagName("div")
	var divs = window.ActPage.children[1].children[0].getElementsByTagName("div")
	for (var i=0;i<divs.length ;i++ )
	{
		if(divs[i].className.indexOf("printerctl")>=0){
			var dindex = divs[i].style.zIndex
			if(dindex.length==0 || isNaN(dindex)){dindex = 0}
			if(zindex<dindex){zindex=dindex}
		}
	}
	var dindex = div.style.zIndex
	if(dindex.length==0 || isNaN(dindex)){dindex = 0}
	return  dindex<=zindex ? zindex*1 + 1 :  dindex;
}

function delcontrol(){
	if(window.curreditSpan){
		var div = window.curreditSpan;
		if(window.confirm("确定要删除该组件？")){
			bodyPanelMsDown()
			div.outerHTML = "";
			document.getElementById("grpchild1000").innerHTML ="";
			window.curreditSpan=null;
		}
	}
}

//根据子html元素获取控件div
function getCtlDivByHtmlObject(htmlobj) {
	while(htmlobj) {
		if (htmlobj.tagName=="DIV" && htmlobj.className=="PrintPageBody")
		{
			//直接返回当前页面
			return htmlobj;
		}
		if(htmlobj.className.indexOf("printerctl ")==0) {
			var cname = htmlobj.getAttribute("controlname");
			if(cname && cname.length > 0 ) {
				return htmlobj;
			} 
		}
		htmlobj = htmlobj.parentNode;
	}
	return null;
}

//根据子控件获取父控件
function getParentByControl(ctl) {
	return getCtlDivByHtmlObject(ctl.parentNode);
}

//清理映射数组
function clearCurrPageContainerCtls() {
	for (var i = 0; i < currpageContainerCtls.length ; i ++ ){currpageContainerCtls[i] = null;}
	currpageContainerCtls = new Array();
}

//创建映射数组
function getCurrPageContainerCtls(currdiv) {
	var divs = window.ActPage.getElementsByTagName("div");
	currpageContainerCtls = new Array();
	for (var i = 0; i < divs.length ; i++)
	{
		if(divs[i].getAttribute("clt_Container")==1) {
			var div =  divs[i];
			var l = currpageContainerCtls.length;
			var ctl = getCtlDivByHtmlObject(div);
			var posv = GetObjectPos(div);
			var iscurr = (ctl == currdiv ? 1 : 0 );
			currpageContainerCtls[l] = {control: ctl,  parentctl: getParentByControl(ctl), cndiv: div, pos: posv, zindex: ctl.style.zIndex, IsCurr: iscurr, selected: 0};
		}
	}
}

//设置激活的状态
function setCurrCanSelectContainerCtl(x, y) {
	for (var i = 0; i < currpageContainerCtls.length ; i++)
	{
		var item = currpageContainerCtls[i];
		if(item.IsCurr==0) {
			var l = item.pos.left;
			var t = item.pos.top;
			var w = item.pos.width;
			var h = item.pos.height;
			if(l < x && (x -l) < w  && t < y && (y-t) < h) {
				item.cndiv.style.border = "2px solid red";
				item.selected = 1;
			}
			else{
				item.cndiv.style.border = "";
				item.selected = 0;
			}
		}
		else{
			item.cndiv.style.border = "";
			item.selected = 0;
		}
	}
}

function sureCurrCanSelectContainerCtl(div) {
	var ctl = getCtlDivByHtmlObject(div);
	for (var i = 0; i < currpageContainerCtls.length ; i++)
	{
		if(currpageContainerCtls[i].selected==1) {
			var cdiv = currpageContainerCtls[i].cndiv;
			var nuldiv = document.createElement("div");
			cdiv.appendChild(nuldiv);
			nuldiv.swapNode(div);
			nuldiv.parentNode.removeChild(nuldiv);
			return;
		}	
	}
}

function controlmsdown(div){
	return function(){
		if (window.curreditSpan && window.curreditSpan!=div)
		{
			window.curreditSpan.className = "printerctl msout";
			bodyPanelMsDown();
		}
		window.curreditSpan = div;
		if(document.getElementById("CtrlDelButton2014")){
			document.getElementById("CtrlDelButton2014").style.cssText = "";
			document.getElementById("CtrlDelButton2014").disabled = false;
			document.getElementById("CtrlDelButton2014").title = "删除激活的控件";
		}
		if (!div.style.zIndex || div.style.zIndex > 0){//--置底的图片，不触发
			div.style.zIndex = getMaxzIndex(div)
		}
		div.className = "printerctl active";
		div.style.cursor="move";
		if(!window.curreditSpan.obj.IsLocked || window.curreditSpan.obj.IsLocked == false){
			div.canmove=1;
		}else{
			div.canmove=0;
		}//alert(div.canmove)
		div.ox =  window.event.clientX;
		div.oy =  window.event.clientY;
		div.setCapture();
		getCurrPageContainerCtls(div);
		showLine1(1);
		showattrlist(div);//显示属性
		TableActive();//--设置表格单元格宽度
		//document.title = div.obj.RightMenu;
		if(div.obj.RightMenu){
			div.oncontextmenu = function(){
				ShowRightMenu()
				return false;
			}
		}
		if(div.children[1].children[0] && div.children[1].children[0].tagName.toLowerCase() == "table"){
			var tb = div.children[1].children[0];
			tb.onmousedown = function(){
				TDSelectMD();
				//tb.onclick = "";
			}
			tb.onmouseup = function(){
				TDSelectMV();
				//tb.onclick = function(){event.cancelBubble = true;TDSelectClick()}
				//var eTb = event.srcElement;alert(eTb)
			}
			//tb.onclick = function(){TDSelectClick()}
		}
		window.event.cancelBubble = true; 
		try{
			document.getElementById("CtrlLineTool").style.display = "none";//--隐藏线条设置框
		}
		catch(e){
		
		}
		document.onmousedown = null;
		//document.title= new Date().getTime()
	}
}

function controlmsdbclick(div){//--空间鼠标双击事件
	return function(){
		if(div.obj.CtrlEvent){
			if (div.obj.CtrlEvent.FireEvent){div.obj.CtrlEvent.FireEvent(div.obj)}
		}
	}
}

function bodyPanelMsDown(){//--取消控件激活函数，已在在pagemodel.asp中调用
	if (window.curreditSpan){
		window.curreditSpan.className = "printerctl msout";
		if(window.curreditSpan.obj.CtrlEvent){
			if (window.curreditSpan.obj.CtrlEvent.CallBackEvent){//---调用控件的回调函数
				window.curreditSpan.obj.CtrlEvent.CallBackEvent(window.curreditSpan.obj);
			}
		}
		if(document.getElementById("CtrlDelButton2014")){
			document.getElementById("CtrlDelButton2014").style.cssText = "filter:gray";
			document.getElementById("CtrlDelButton2014").disabled = true;
			document.getElementById("CtrlDelButton2014").title = "删除激活的控件【现未激活控件】";
		}
		window.curreditSpan=null;
	}
	if(document.getElementById("grpchild1000")){document.getElementById("grpchild1000").innerHTML = ""}
}

function controlmsmove(div){
	return function(){
		if(div.canmove==1){
			var x = window.event.clientX;
			var y = window.event.clientY;
			setCurrCanSelectContainerCtl(x, y);
			if(!div.preX || isNaN(div.preX)) {
				div.preX = x;
				div.preY = y;
			}
			else{
				 var x0 = div.preX - x;
				 var y0 = div.preY - y;
				 div.style.left = PxToMM((div.offsetLeft - x0),"x") + "mm";
				 div.style.top = PxToMM((div.offsetTop - y0),"y") + "mm";
				 div.obj.left = div.style.left;
				 div.obj.top = div.style.top;
				 div.preX = x;
				 div.preY = y; 
				 window.contEdit = 0
				 document.getElementById("attlist_yzb").value = div.style.top;
				 document.getElementById("attlist_xzb").value = div.style.left;
				 window.contEdit = 1
			}
		}
	}
}

function controlmsup(div){
	return function(){
		div.style.cursor="default";
		div.releaseCapture();
		div.canmove=0;
		sureCurrCanSelectContainerCtl(div);
		div.preX=window.asdasda;
	}
}

function buildControl(name,RlvType){//添加控件，并设置基本属性；
	ajax.regEvent("loadControl")
	ajax.addParam("name",name)
	var r = ajax.send()
	try{
		var obj = eval(r)
	}catch(e){
		alert("加载错误\n\n" + r + "\n\n" + e.message)
		return
	}
	if (!obj.initHTML){return false;}
	var div = createControlWindow();
	CtrlEvent(div.parentElement);//--绑定控件鼠标事件
	AddCtrlEvent(obj)//--绑定控件内置事件
	div.parentElement.obj = obj;
	div.parentElement.controlname = name
	obj.controldiv = div;
	obj.ResolveType = RlvType;
	obj.left = div.parentElement.style.left;
	obj.top = div.parentElement.style.top;
	obj.id = div.id;
	div.innerHTML = obj.initHTML
	if (window.curreditSpan){
		bodyPanelMsDown();
	}
	window.curreditSpan=div.parentElement;
	div.parentElement.fireEvent("onmousedown");
	div.parentElement.fireEvent("onmouseup");
	return div;
}




function ReBuildControl(json){//控件重载并渲染
	var div = createControlWindow();
	var obj = json;	
	//alert(obj.action)
	AddCtrlEvent(json);//--绑定控件内置事件
	if(obj.action != "show"){CtrlEvent(div.parentElement);};//如果不是解析页面，就绑定事件
	unescapeJSON(obj);//--解码JSON
	div.parentElement.obj = obj;
	div.parentElement.controlname = obj.name;
	obj.controldiv = div;
	if (window.curreditSpan){
		bodyPanelMsDown();
	}
	window.curreditSpan=div.parentElement;
	//obj.ResolveType = RlvType;
	//alert(isNaN(obj.id))
	if(isNaN(obj.id)){obj.id = div.id;};
	//bodyPanelMsDown()
	RenderingCtrl(obj);
	if (!obj.left)
	{
		obj.left = div.parentElement.style.left;
	}
	if (!obj.top)
	{
		obj.top = div.parentElement.style.top;
	}
	//bodyPanelMsDown();
	//window.curreditSpan=div.parentElement;
	div.parentElement.fireEvent("onmousedown");
	div.parentElement.fireEvent("onmouseup");
	return div;
}


function createControlWindow(){//创建新的控件容器，绑定事件
	var div = document.createElement("div");
	div.className = "printerctl msout";
	div.innerHTML = "<div class='printercltool'></div><div class='printerctlbody'>新控件</div>";
	var movediv = document.createElement("div");
	movediv.className = "printerclresize";
	movediv.title = "拖动改变控件宽度和高度";
	movediv.onmousedown = function(){ResizeMD()};
	div.appendChild(movediv);
	//div.onmouseover = function(){div.className = "printerctl active"}
	//div.onmouseout = function(){div.className = "printerctl msout"}
	div.style.left = Math.floor(Math.random()*50+10) + "px";
	div.style.top = Math.floor(Math.random()*50+10) + "px";
	//document.getElementById("pagebody").appendChild(div);
	window.ActPage.children[1].children[0].appendChild(div);
	var PageID = window.ActPage.id;
	var ctrlNum = getCtrlNum() + 1;
	var ctrlID = PageID + "_C" +ctrlNum;//--生成控件编号（编号规则：页面编号+"_C"+控件ID值（此ID为页面生成，非数据库ID））
	div.children[1].id = ctrlID;
	return div.children[1];
}

function ResizeMD(){
	document.body.style.cursor = "se-resize";
	div = window.curreditSpan;
	div.setCapture();
	var resizeDiv = div.children[2];
	resizeDiv.preX = window.event.x;
	resizeDiv.preY = window.event.y;
	document.onmousemove = function(){ResizeMV()}
	document.onmouseup = function(){ResizeMU()}
	window.event.cancelBubble = true;
}
function ResizeMV(){
	div = window.curreditSpan;
	var resizeDiv = div.children[2];
	var bodyDiv = div.children[1];
	if (!resizeDiv.preX || isNaN(resizeDiv.preX)){resizeDiv.preX = window.event.x}
	if (!resizeDiv.preY || isNaN(resizeDiv.preY)){resizeDiv.preY = window.event.y}
	var x0 = window.event.x - resizeDiv.preX;
	var y0 = window.event.y - resizeDiv.preY;
	var w1 = bodyDiv.children[0].clientWidth;
	var w2 = bodyDiv.children[0].offsetWidth;
	var h1 = bodyDiv.children[0].clientHeight;
	var h2 = bodyDiv.children[0].offsetHeight;
	if(w1 != w2){//--受边框影响，不同的标签，对边框的处理不相同。
		bodyDiv.children[0].style.width = w1;
		if(w1 == bodyDiv.children[0].clientWidth){
			var w = bodyDiv.children[0].clientWidth + x0;
			//var h = bodyDiv.children[0].clientHeight + y0;
		}else{
			bodyDiv.children[0].style.width = w2;
			var w = bodyDiv.children[0].offsetWidth + x0;
			//var h = bodyDiv.children[0].offsetHeight + y0;
		}
	}
	else{
		var w = bodyDiv.children[0].offsetWidth + x0;
	}
	if(h1 != h2){//--受边框影响，不同的标签，对边框的处理不相同。
		bodyDiv.children[0].style.height = h1;
		if(h1 == bodyDiv.children[0].clientHeight){
			var h = bodyDiv.children[0].clientHeight + y0;
		}else{
			bodyDiv.children[0].style.height = h2;
			var h = bodyDiv.children[0].offsetHeight + y0;
		}
	}
	else{
		var h = bodyDiv.children[0].offsetHeight + y0;
	}
	//document.title = w+"|"+h
	//var w = bodyDiv.children[0].clientWidth + x0;
	//var h = bodyDiv.children[0].clientHeight + y0;
	//bodyDiv.children[0].style.width = w + "px";
	document.getElementById("CtrlInput_W").value =  PxToMM(w) + "mm";
	document.getElementById("CtrlInput_H").value =  PxToMM(h) + "mm";
	resizeDiv.preX = window.event.x;
	resizeDiv.preY = window.event.y;
}
function ResizeMU(){
	document.body.style.cursor = "default";
	document.onmousemove = "";
	document.onmouseup = "";
}

function CtrlEvent(div){//控件鼠标事件绑定
	div.onmousedown = controlmsdown(div)
	div.onmouseup = controlmsup(div)
	div.onmousemove = controlmsmove(div)
	div.ondblclick = controlmsdbclick(div)
}

function AddCtrlEvent(json){//--绑定控件内置事件，事件存于控件文件的CtrlEvent属性里
	if (json.CtrlEvent)
	{
		for (var Item in json.CtrlEvent)
		{
			eval("json." + Item + " = json.CtrlEvent." +Item)
		}
	}
	return json;
}
function DelCtrlEvent(json){//--移除控件内置事件，用于存储时，避免出现存储错误 ；并可以保证控件的可扩展性
	if (json.CtrlEvent)
	{
		for (var Item in json.CtrlEvent)
		{
			eval("delete json." + Item)
		}
	}
	delete json.CtrlEvent;
	return json;
}
function DelDataID(){//删除明细控件绑定的数据
	if(!confirm("解除明细绑定，会删除控件内已插入的私有部件！\n按确认按钮继续操作，按取消按钮退出操作！")){
		return false;
	}
	var Exp1 = getExp("\d+\.[\w\_]+|1");
	var Exp2 = getExp("\d+\.[\w\_]+|2");
	div = window.curreditSpan;
	if (div){
		var obj = div.obj;
		if(obj.DataID){
			var tb = div.children[1].children[0];
			if(tb.tagName.toLowerCase() == "table"){
				var tbody = tb.children[1];
				for(var i = 0; i < tbody.rows[0].cells.length; i++){
					var td = tbody.rows[0].cells[i];
					td.fireEvent("ondblclick");//--触发单元格编辑事件
					var html = td.children[0].innerHTML;
					html = html.replace(SpanExp,"&nbsp;")
					html = html.replace(Exp1,"&nbsp;")
					html = html.replace(Exp2,"&nbsp;")
					td.children[0].innerHTML = html;
					obj.CtrlEvent.CallBackEvent()//--触发控件回调事件
				}
				var tbody = tb.children[2];
				for(var i = 0; i < tbody.rows[0].cells.length; i++){
					var td = tbody.rows[0].cells[i];
					td.fireEvent("ondblclick");//--触发单元格编辑事件
					//var html = td.children[0].innerHTML;
					html = html.replace(SpanExp,"&nbsp;")
					html = html.replace(Exp1,"&nbsp;")
					html = html.replace(Exp2,"&nbsp;")
					td.children[0].innerHTML = html;
					obj.CtrlEvent.CallBackEvent()//--触发控件回调事件
				}
				delete obj.DataID;
				showattrlist(div)
			}
		}
	}
}

function RenderingCtrl(obj){//----渲染控件
	//--获取控件当前的自定义属性
	var r = "";
	if(!window.printCtlCache) {
		window.printCtlCache = new Array();	
	}
	for(var i = 0 ; i < window.printCtlCache.length; i ++) {
		if(window.printCtlCache[i][0]==obj.name) {
			r = window.printCtlCache[i][1];
		}	
	}
	if(r=="") {
		ajax.regEvent("loadControl");
		ajax.addParam("name",obj.name);
		r = ajax.send();
		window.printCtlCache[window.printCtlCache.length] = [obj.name, r];
	}
	try{
		var obj_model = eval(r)
	}catch(e){
		alert("加载错误\n\n" + r + "\n\n" + e.message)
		return
	}
	//--获取完成
	var div =window.curreditSpan.children[1];
	div.innerHTML = obj.initHTML;
	var Exp = /\-?\d+(\.\d+)?((mm)|(cm)|(px))?/g;//--匹配长度、宽度、横坐标、纵坐标
	if(obj.left){div.parentElement.style.left = obj.left.match(Exp)[0];};
	if(obj.top){div.parentElement.style.top = obj.top.match(Exp)[0];};
	if(obj.backgroundColor){div.style.backgroundColor = obj.backgroundColor;};
	if(obj.fontFamily){div.style.fontFamily = obj.fontFamily;};
	if(obj.color){div.style.color = obj.color;};
	if(obj.fontSize){div.style.fontSize = obj.fontSize;};
	if(obj.width){div.children[0].style.width = obj.width.match(Exp)[0];};
	obj.isShowDate = 0;//--将显示内部数据的开关打开
	if(obj.height){
		if(obj.name == "文字"){
			div.children[0].style.minHeight = obj.height.match(Exp)[0];
		}else{
			div.children[0].style.height = obj.height.match(Exp)[0];
		}
	};
	if(obj.textDecoration){div.style.textDecoration = obj.textDecoration;};
	if(obj.fontStyle){div.style.fontStyle = obj.fontStyle;};
	if(obj.fontWeight){div.style.fontWeight = obj.fontWeight;};
	//--如果控件的自定义属性项增加、减少或发生改变，防止出现控件可操作属性项与预设属性项不一致而出现错误
	for (var Item in obj_model)//--遍历控件预设属性项，并对缺失的属性项赋值
	{
		if (Item.indexOf("att_")==0){
			if(typeof(eval("obj."+Item)) == "undefined"){
				eval("obj." + Item + " = obj_model." + Item + ";")//--缺失项赋默认值
			}
		}
	}
	for (var Item in obj_model)//--触发属性更改
	{
		if (obj.attchange){
			obj.attchange(Item);
		}
	}
	for (var Item in obj)//--遍历存储的数据，移除与控件预设属性项不同的数据
	{
		if (Item.indexOf("att_")==0){//--对比控件自定义属性项与数据库中的自定义属性项，移除冗余的自定义属性
			if(typeof(eval("obj_model."+Item)) == "undefined"){
				//obj.attchange(Item);
				delete obj[Item];
			}
		}
	}
	//--自定义属性对比完成
	
	if(obj.TDWidth){//--重新定义表格宽度
		SetTableWidth(obj)
	}
}

function escapeJSON(obj){//--将JSON的自定义属性进行编码
	for (var Item in obj)
	{
		//document.title = Item
		if (Item.indexOf("att_")==0){
			if (eval("obj."+Item).constructor == Array){//对于数组类型的自定义属性进行编码
				var UnValue = "";
				for (var i = 0;i < eval("obj."+Item).length; i++)
				{	
					var UnValue1 = "";
					if (eval("obj."+Item)[i].constructor == Array){
						for (var ii = 0; ii < eval("obj."+Item)[i].length; ii++){
							UnValue1 = UnValue1 + ",'" + escape(eval("obj."+Item)[i][ii]) + "'";//二维数组循环进行编码
						}
						UnValue1 = UnValue1.replace(",","");
						UnValue = UnValue + ",[" + UnValue1 + "]";
					}else{
						UnValue = UnValue + ",'" + escape(eval("obj."+Item)[i]) + "'";//循环进行编码
					}
				}
				UnValue = UnValue.replace(",","");
				UnValue= eval("[" + UnValue + "]");//编码后，重新生成数组
				eval("obj."+Item+"=UnValue");
			}else{
				var UnValue = escape(eval("obj."+Item));//将非数组自定义属性进行编码
				eval("obj."+Item+"=UnValue");
			}
		}
	}
}

function unescapeJSON(obj){//将JSON数据进行解码 ;如果json的值是数组，则最多支持到二维数组
	for (var Item in obj)
	{
		if (Item.indexOf("att_")==0){
			var a = eval("obj."+Item);
			var UnValue = "";
			if (a.constructor == Array){//--如果值是数组，则遍历数组
				
				for (var i = 0;i < a.length;i++)
				{
					var UnValue1 = "";
					if (a[i].constructor == Array)//--如果值为数组，则遍历
					{
						for (var ii = 0; ii < a[i].length; ii++)
						{
							UnValue1 = UnValue1 + ",'" + unescape(a[i][ii]).replace(/'/g,"&apos;") + "'";//解码，并替换单引号，避免影响数组生成；
						}
						UnValue1 = UnValue1.replace(",","").replace(/\r\n/g,"").replace(/\n/g,"<br />");//--替换所有回车换行，避免解析出错
						UnValue1= "[" + UnValue1 + "]";
						UnValue = UnValue + "," + UnValue1;
					}
					else
					{
						UnValue = UnValue + ",'" + unescape(a[i]).replace(/'/g,"&apos;") + "'";//解码，并替换单引号，避免影响数组生成；
					}
				}
				UnValue = UnValue.replace(",","").replace(/\r\n/g,"").replace(/\n/g,"");
				UnValue= eval("[" + UnValue + "]");//解码后，重新生成数组
				for (var i = 0;i < UnValue.length;i++)
				{
					if (UnValue[i].constructor == Array)
					{
						for(var ii = 0;ii < UnValue[i].length ; ii++)
						{
							UnValue[i][ii] = UnValue[i][ii].replace(/&apos;/g,"'");//数组生成后，替换回单引号
						}
					}
					else
					{
						UnValue[i] = UnValue[i].replace(/&apos;/g,"'");//数组生成后，替换回单引号
					}
				}
				eval("obj."+Item+"=UnValue");
			}else{
				var UnValue = unescape(a);//非数组型自定义属性进行解码
				eval("obj."+Item+"=UnValue");
			}
		}
	}
}


function Resolve(json){//--解析控件的数据，获取数据控件的动态数据，存储到二维数组里
	if (json.attType){
		for(var Item in json.attType){//--查找数据类型为data的自定义属性
			if(eval("json.attType." + Item) == "data"){//--数据类型
				var data = eval("json." + Item)//--获取需要解析的数据值
				data.getRows = getRows;//--事件绑定
				var Rows = data.getRows()//--获取格式化后的数据源列名称
				delete data.getRows;//--删除事件
				//alert(Rows+"|"+json.name)
				
				if (Rows != ""){
					Rows = Rows.split(",").sort()
					var tem = ""
					var x = new Array();
					for(var i = 0; i < Rows.length; i++){
						if (tem != Rows[i]){
							tem = Rows[i];
							x[x.length] = Rows[i];
						}
					}
					Rows = SerializeArray(x);//alert(Rows)
					ajax.regEvent("LoadData");
					ajax.addParam("formid",formid);
					ajax.addParam("Rows",Rows);
					ajax.addParam("DataID",json.DataID);//alert(Rows+"|"+json.DataID)
					ajax.addParam("isSum",isSum);
					ajax.addParam("ResolveType",json.ResolveType);//alert(json.DataID);
					//ajax.addParam("DataID",json.dataid);//alert(Rows)
					var Datas = ajax.send();//--获取数据,包含数据列和合计列信息
					//alert(Datas+"|"+json.name+"|"+Item)
					Datas = Datas.replace(/\r\n/g,"<br />");
					Datas = Datas.replace(/\n/g,"<br />");
					Datas = eval("["+Datas+"]");
					if(!json.attValue){
						json.attValue= {};
					}
					eval("json.attValue." + Item + "=Datas");
					//alert(eval("json.attValue." + Item ))
				}else{
					var Datas = new Array;
					Datas[0] = eval("json." + Item);
					for (var i = 0; i < Datas[0].length; i++){
						Datas[0][i] = "&nbsp;";//--清空数据行模板
					}
					eval("json.attValue= {}");
					eval("json.attValue." + Item + "=Datas");
				}
			}
		}
	}
	return json;
}

function FormatJson(json){//--格式化动态数据:将动态数据套用模板的样式
	if (json.attValue){
		json.Count = {};
		for (var Item in json.attValue){
			var v = eval("json.attValue."+Item);//--获取所有数据
			var m = eval("json."+Item);//--获取数据的原始模板
			var t = new Array()
			var c = new Array();
			for (var i = 0; i < v.length; i++)//--行循环开始
			{
				t[i] = m.slice();//--根据模板新添一行
				for (var ii = 0; ii < v[i].length; ii++){//--行内数据环开始
					//alert(v[i])
					//alert(v[i][ii][0])
					//var SpanExp1 = '/<SPAN class=DataBody contentEditable=false dbname="' + v[i][ii][0] + '">[a-zA-Z_0-9\\u4e00-\\u9fa5]+<\\/SPAN>/g';//--获得匹配表达式
					var SpanExp1 = '/<SPAN( class="*CtrlData"*| contentEditable="*false"*| unselectable="*on"*| dbname="*' + v[i][ii][0] + '"*){4}>[a-zA-Z_0-9\\u4e00-\\u9fa5]+<\\/SPAN>/g';
					if(!c [v[i][ii][0]]){c [v[i][ii][0]] = new Array()}//--将每一字段的数值，存入数组
					c [v[i][ii][0]] [i]= v[i][ii][1]
					SpanExp1 = eval(SpanExp1);//--生成匹配正则表达式
					//alert(SpanExp1)
					document.title = v[i][ii][0];//alert(v[i][ii][1])
					for(var iii =0 ;iii < t[i].length; iii++ ){//--列匹配开始
						//alert(m[iii].match(SpanExp))
						//t[i][iii].replace(SpanExp1,v[i][ii][0]);
						//alert(v[i][ii][0])
						
						t[i][iii] = t[i][iii].replace(SpanExp1,v[i][ii][1]);
					}
				}
			}
			eval("json."+Item+"=t");
			eval("json.Count."+Item+"=c");//--获得各字段数据
		}
	}
	return json;
}


function getRows(){//--获取控件动态数据列集合，中间用“,”隔开
	var o = this;
	
	var res = [], hash = {};
	for(var i = 0; i < o.length; i ++){//--剔除数组重复项
		if(!hash[o[i]]){
			res.push(o[i]);
			hash[o[i]] = true;
		}
	}
	o = res;
	
	var r = new Array;
	for (var i = 0; i < o.length; i++){
		o[i] = unescape(o[i]).replace(/'/g,"&apos;");//--替换单引号，避免出错
		r[i] = o[i].match(SpanExp);//--用正则表达式从值中匹配出数据标签
		if (r[i] != null){
			for(var ii = 0; ii < r[i].length; ii++){
				r[i][ii] = r[i][ii].match(DataExp);//--从每个数据标签中，提取出数据源的数据
				for (var iii = 0; iii < r[i][ii].length; iii++){
					r[i][ii][iii] = r[i][ii][iii].replace(/"/g,"")
				}
			}
		}
	}
	//alert(SerializeArray(r))
	return SerializeArray(r);
	//return r;
}


function SerializeArray(array){//--【递归函数】数组格式化函数,转化数组为文本
	var o = array;
	var str = ""
	for (var i = 0; i < o.length; i++){
		if (o[i] != null){
			if (o[i].constructor == Array){
				str = str + "," + SerializeArray(o[i]);
			}else{
					str = str + "," + o[i] ;
			}
		}
	}
	str = str.replace(",","");
	return str;
}

//-------------------------------------------------------------------================================================================
function ActivePage(obj){//--激活模板页面
	var Pages = obj.parentElement.children;
	for (var i = 0 ;i < Pages.length ; i++)
	{
		Pages[i].className = "PrintPage";//--取消其他页面的激活状态
	}
	obj.className = "PrintPage ActivePage";//--将当前页面设为激活
	window.ActPage = obj;//--发布通知
	ScrollStaff();//--重定位纵标尺位置
}
function addpage(){//添加模板页面;  一定要以对象的形式进行操作，如果以文本形式操作，会导致已加入的页面事件失效
	var div = document.getElementById("FrameBorderPage");
	ajax.regEvent("AddPage");
	var pageStr = ajax.send();
	//div.innerHTML = div.innerHTML + "<br style='page-break-after:always;' /><div class='PrintPage' onClick='ActivePage(this)'>" + pageStr + "</div>";
	var br = document.createElement("br");
	br.style.cssText = "page-break-after:always;";
	var page = document.createElement("div");
	var pageNum = getPageNum() + 1;
	page.id = "P" + pageNum;//--根据页面ID最大值，设置新增页面的ID
	page.className = "PrintPage";
	page.onclick = function(){ActivePage(this)};
	page.innerHTML = pageStr;
	SetPage(page);
	div.appendChild(br);
	div.appendChild(page);
	return page;
}
function delpage(){//删除模板页面,会删除当前激活的页面，但至少会保留一页
	var div = document.getElementById("FrameBorderPage");
	var pages = div.children;
	var pageNum = pages.length;
	if (pageNum == 1)
	{
		alert("请至少保留一张页面！");
		return false;
	}
	var actPage = 0;
	for (var i= 0; i < pageNum ; i++)//--查询激活页面
	{
		if (pages[i].tagName.toLowerCase() == "div" && pages[i].className == "PrintPage ActivePage")
		{
			//pages[i].removeNode(true);//--删除激活的页面
			actPage = i;
			var message = "当前激活的页面即将被删除,\n点击确定完成操作，点击取消终止操作！";
			if (!confirm(message)){
				return false;
			}
		}
	}
	if(actPage < pageNum-1)
	{
		pages[actPage].removeNode(true);//--当页面不是最后一页，删除页面和后面的分页符，并激活下一页
		pages[actPage].removeNode(true);//--删除操作使后面的对象歉意，所以不必改变参数
		ActivePage(pages[actPage]);
	}
	else
	{
		pages[actPage].removeNode(true);//--当页面是最后一页时，删除本页，删除前面的分页符，激活前面的页面
		pages[actPage-1].removeNode(true);
		ActivePage(pages[actPage-2]);
	}
}

function getPageNum(){//--获取模板内页面ID的最大值
	var pages = document.getElementById("FrameBorderPage").children;
	var num = 0;
	for (var i = 0 ; i < pages.length ; i++)
	{
		if (pages[i].tagName.toLowerCase() == "div")
		{
			var PageNum = parseInt(pages[i].id.replace("P",""));
			num = (num > PageNum) ? num : PageNum;
		}
	}
	return num;
}
function getCtrlNum(){//--获取激活页面内控件ID的最大值
	var atvPage = window.ActPage;
	var PageID = atvPage.id
	var ctrls = atvPage.children[1].children[0].children;//--获取激活页面的所有控件
	var num= 0;
	for(var i = 0; i < ctrls.length; i++)//--冒泡比较，取ID最大值
	{
		ctrlNum = parseInt(ctrls[i].children[1].id.replace(PageID + "_C",""));
		num =(isNaN(ctrlNum)) ? num : (num > ctrlNum) ? num : ctrlNum;//--ctrlNum不存在，num值不变；否则比较num与ctrlNum，取二者大的；
	}
	return num;
}

function pSizeChange(input){//--更换页面大小和横纵向
	var xz = window.pageSetting.XZ;
	var MyBody = getParent(input,2)
	var v = MyBody.children[1].children[2].value;
	//var v = input.value;
	if(v == "自定义"){//--自定义页面尺寸，弹出对话窗口，并终止原事件
		window.SizeInput = MyBody.children[1].children[2];//--记录触发弹出窗口的下拉框
		setSizeCustom();
		return false;
	}
	window.pageSetting.T_pageSize = v;
	v = v.split(",")
	var hx = MyBody.children[2].children;
	var isHX = "0";
	for (var i = 0; i < hx.length; i++)
	{
		if (hx[i].checked){isHX = hx[i].value}
	}
	window.pageSetting.T_pageHX = isHX;
	if (parseInt(isHX) == 0){
		var wth = v[0];
		var hgt = v[1] - xz;
	}else{
		var wth = v[1];
		var hgt = v[0] - xz;
		
	}
	var pPadding = window.pageSetting.T_pagePadding;
	pPadding = pPadding.split(",")
	var t = pPadding[0];
	var b = pPadding[2]
	var p = document.getElementById("FrameBorderPage").children;//--所有页面和分页符
	if (p){
		for (var i = 0; i < p.length; i++){
			if (p[i].tagName.toLowerCase() == "div"){
				p[i].style.width = wth + "mm";
				p[i].style.height = hgt + "mm";
				p[i].children[1].style.height = (hgt - t - b > 0) ? hgt - t - b + "mm" : 0 + "mm";
			}
		}
	}
	SetStaff_X(window.staff_X);//--更新标尺刻度位置
	SetStaff_Y(window.staff_Y);//--更新标尺刻度位置
}

function setSizeCustom(){
	var div = window.DivOpen("setSizeCustom","自定义",296,150,200,'b',true,10);
	div.innerHTML = "<div style='width:280px;height:110px;background:#fff;position:relative;left:-8px;top:-8px;border:1px solid #aaaacc;color:#000;'></div>";
	div.childNodes[0].innerHTML = document.getElementById("SettingSizeCustom").innerHTML;
	//document.getElementById("divdlg_setCustom").style.zIndex = 100000000;
	//document.getElementById("divdlg_sadadad").style.zIndex = 0;
	//div.childNodes[0].childNodes[0].cells[1].childNodes[0].value = v;
	
	psz = window.pageSetting.T_pageSize;
	psz = psz.split(",")
	var tb = div.childNodes[0].childNodes[0];
	tb.cells[1].children[0].value = psz[0];
	tb.cells[1].children[1].value = psz[1];
	
	var divs = document.getElementsByTagName("div");
	var d = document.createElement("div");
	d.style.cssText = "width:100%; height:100%; left:0px; top:0px; position:absolute;background:url(../../images/smico/TouMing.gif)";//--用透明gif遮挡层下内容
	d.id = "tmc";
	if(document.getElementById("divdlg_sadadad")){//--用透明层遮盖原对话框
		document.getElementById("divdlg_sadadad").appendChild(d);
	}
	document.getElementById("divdlg_setSizeCustom").style.zIndex = 100000000 ;
}

function CheckSize(input){//--验证自定义尺寸，只许输入正整数
	var v = input.value;
	if (v.match(/\D/g)){
		input.value = v.replace(/\D/g,"");
	}
}

function SizeCustomOK(button){//--完成自定义页面尺寸设置
	var input = window.SizeInput;//--获取触发事件的下拉框
	var tb = getParent(button,4);
	var w = tb.cells[1].children[0].value;
	var h = tb.cells[1].children[1].value;
	var v = w + "," + h;
	var zdy = true;
	for(var i = 0; i < input.options.length; i++){
		if(input.options[i].value == v){
			zdy = false;
			input.options[i].selected = true;
		}
	}
	if(zdy){
		var opt = document.createElement("option");
		opt.value = v;
		opt.innerText = w + "mm * " + h + "mm";
		opt.selected = true;
		input.appendChild(opt);
	}
	pSizeChange(input); //--更新页面尺寸
	if(document.getElementById("tmc")){
		document.getElementById("tmc").removeNode(true);//--删除遮盖的透明层
	}
	window.DivClose(button);//--关闭对话框；
}

function SizeCustomCancle(button){
	var input = window.SizeInput;//--获取触发事件的下拉框
	var v = window.pageSetting.T_pageSize;
	for(var i = 0; i < input.options.length; i++){
		if(input.options[i].value == v){
			input.options[i].selected = true;
		}
	}
	if(document.getElementById("tmc")){
		document.getElementById("tmc").removeNode(true);//--删除遮盖的透明层
	}
	window.DivClose(button);//--关闭对话框；
}

function getPageWidth(){
	var PageSize = window.pageSetting.pageSize;
	if(window.pageSetting.pageHX){
		var hx = window.pageSetting.pageHX;
	}else{
		var hx = "0";
	}
	PageSize = PageSize.split(",")
	if (parseInt(hx) == 0){
		var w = PageSize[0];
	}else{
		var w = PageSize[1];
	}
	return w;
}
function getPageHeight(){
	var PageSize = window.pageSetting.pageSize;
	if(window.pageSetting.pageHX){
		var hx = window.pageSetting.pageHX;
	}else{
		var hx = "0";
	}
	PageSize = PageSize.split(",")
	if (parseInt(hx) == 0){
		var w = PageSize[1];
	}else{
		var w = PageSize[0];
	}
	return w;
}

function pPaddingChange(input){//--模板留白设置
	var tb = getParent(input,4);
	var xz = window.pageSetting.XZ;
	if (input.value.match(/[^0-9\.]/g)){//--只允许输入数字
		input.value = input.value.replace(/[^0-9\.]/g,'');
	}else{
		var l = getParent(input,4).cells[1].children[0].value;
		var r = getParent(input,4).cells[3].children[0].value;
		var t = getParent(input,4).cells[5].children[0].value;
		var b = getParent(input,4).cells[7].children[0].value;
		pageSize = window.pageSetting.T_pageSize;//--验证页面参数合理性
		pageSize = pageSize.split(",")
		pageHX = window.pageSetting.T_pageHX;
		if(parseInt(pageHX) == 0){
			w = pageSize[0];
			h = pageSize[1]
		}else{
			w = pageSize[1]
			h = pageSize[0]
		}
		var pages = document.getElementById("FrameBorderPage").children;
		switch (input.id){
			case "PagePadding1"://--l
				l = (l == "")?0 : l;//--验证页面参数合理性
				r = (r == "")?0 : r;
				var num = (parseFloat(l) + parseFloat(r) > w)? parseFloat(w) - parseFloat(r) -1 : l; //--留一毫米，便于拖动标尺
				if (num != l){input.value = num}
				for (var i = 0; i < pages.length; i++){
					if(pages[i].tagName.toLowerCase() == "div"){
						pages[i].children[0].style.marginLeft =  num + "mm";
						pages[i].children[1].style.marginLeft =  num + "mm";
						pages[i].children[2].style.marginLeft =  num + "mm";
					}
				}
				l = num;
				break;
			case "PagePadding2"://--r
				l = (l == "")?0 : l;//--验证页面参数合理性
				r = (r == "")?0 : r;
				var num = (parseFloat(l) + parseFloat(r) > w)? parseFloat(w) - parseFloat(l) -1 : r; //--留一毫米，便于拖动标尺
				if (num != r){input.value = num}
				for (var i = 0; i < pages.length; i++){
					if(pages[i].tagName.toLowerCase() == "div"){
						pages[i].children[0].style.marginRight =  num + "mm";
						pages[i].children[1].style.marginRight =  num + "mm";
						pages[i].children[2].style.marginRight =  num + "mm";
					}
				}
				break;
			case "PagePadding3"://--t
				t = (t == "")?0 : t;//--验证页面参数合理性
				b = (b == "")?0 : b;
				var num = (parseFloat(t) + parseFloat(b) > h)? parseFloat(h) - parseFloat(b) -1 : t; //--留一毫米，便于拖动标尺
				if (num != t){input.value = num}
				for (var i = 0; i < pages.length; i++){
					if(pages[i].tagName.toLowerCase() == "div"){
						pages[i].children[0].style.height =  num + "mm";
						pages[i].children[1].style.height =  (getPageHeight() - num - b - xz >0)?(getPageHeight() - num - b - xz) +"mm":0 +"mm";
					}
				}
				break;
			case "PagePadding4"://--b
				t = (t == "")?0 : t;//--验证页面参数合理性
				b = (b == "")?0 : b;
				var num = (parseFloat(t) + parseFloat(b) > h)? parseFloat(h) - parseFloat(t) -1 : b; //--留一毫米，便于拖动标尺
				if (num != b){input.value = num}
				for (var i = 0; i < pages.length; i++){
					if(pages[i].tagName.toLowerCase() == "div"){
						pages[i].children[2].style.height =  num + "mm";
						pages[i].children[1].style.height =  (getPageHeight() - t - num - xz >0)?(getPageHeight() - t - num - xz) +"mm":0 +"mm";
					}
				}
				break;
			default:
		}
		window.pageSetting.T_pagePadding = t + "," + r + "," + b + "," + l;
		SetStaff_X(window.staff_X);//--设置标尺刻度
		SetStaff_Y(window.staff_Y);//--更新标尺刻度位置
	}
	
}

function HeaderChange(input){//--更换页眉页脚
	//window.pageSetting.T_pageYM
	//window.pageSetting.T_pageYJ
	var ymText = window.pageSetting.T_pageYM;
	ymText = ymText.split("$@tr@$");
	var yjText = window.pageSetting.T_pageYJ;
	yjText = yjText.split("$@tr@$");
	var p = document.getElementById("FrameBorderPage").children;
	var td = getParent(input,1);
	var v = (input.value == "空")? "&nbsp;" : input.value;
	if (td.id.indexOf("ym") == 0){
		var n = parseInt(td.id.replace("ym",""));
		if(v == "自定义"){//--自定义时，终止函数，事件交由自定义对话框处理
			window.ymyj = ymText[n-1];
			window.ymyjInput = input;
			setCustom();
			return false;
		}
		ymText[n-1] = v;
		if (p){//--更新所有页眉
			for (var i = 0; i < p.length; i++){
				if (p[i].tagName.toLowerCase() == "div"){
					p[i].children[0].children[1].children[0].cells[n-1].innerText = v.replace(/&amp;/g,"&");
				}
			}
		}
	}else if(td.id.indexOf("yj") == 0){
		var n = parseInt(td.id.replace("yj",""));
		if(v == "自定义"){//--自定义时，终止函数，事件交由自定义对话框处理
			window.ymyj = yjText[n-1];
			window.ymyjInput = input;
			setCustom();
			return false;
		}
		yjText[n-1] = v;
		if (p){//--更新所有页脚
			for (var i = 0; i < p.length; i++){
				if (p[i].tagName.toLowerCase() == "div"){
					p[i].children[2].children[0].children[0].cells[n-1].innerText = v.replace(/&amp;/g,"&");
				}
			}
		}
	}
	window.pageSetting.T_pageYM = ymText[0] + "$@tr@$" + ymText[1] + "$@tr@$" + ymText[2];
	window.pageSetting.T_pageYJ = yjText[0] + "$@tr@$" + yjText[1] + "$@tr@$" + yjText[2]
}

function SetPage(page){//--根据页面设置，设定页面尺寸 、边距、页眉页脚
	var div = page;
	var xz = window.pageSetting.XZ;
	if (window.pageSetting.pageSize){
		var PageSize = window.pageSetting.pageSize;
		if(window.pageSetting.pageHX){
			var hx = window.pageSetting.pageHX;
		}else{
			var hx = "0";
		}
		PageSize = PageSize.split(",")
		if (parseInt(hx) == 0){
			div.style.width = PageSize[0] + "mm";
			div.style.height = PageSize[1] - xz + "mm";
		}else{
			div.style.width = PageSize[1] + "mm";
			div.style.height = PageSize[0] - xz + "mm";
		}
	}
	if (window.pageSetting.pagePadding){
		var padding = window.pageSetting.pagePadding.split(",")
		var t = (padding[0] == "")?0:padding[0];
		var r = (padding[1] == "")?0:padding[1];
		var b = (padding[2] == "")?0:padding[2];
		var l = (padding[3] == "")?0:padding[3];
		div.children[0].style.height =  t + "mm";//--顶部留白
		div.children[1].style.height = (getPageHeight() - t - b -xz >0)?(getPageHeight() - t - b -xz) +"mm":0 +"mm";//--内容高度
		div.children[2].style.height =  b + "mm";//--底部留白
		div.children[1].style.marginLeft =  l + "mm";//--左留白
		div.children[1].style.marginRight =  r + "mm";//--右留白
		div.children[0].style.marginLeft =  l + "mm";//--左留白
		div.children[0].style.marginRight =  r + "mm";//--右留白
		div.children[2].style.marginLeft =  l + "mm";//--左留白
		div.children[2].style.marginRight =  r + "mm";//--右留白
		var w = div.style.width.replace(/\D/g,"")
		if (t < 10 || w - l - r < 30){
			div.children[0].children[0].style.display =  "none";
		}else{
			div.children[0].children[0].style.display =  "block";
		}//--隐藏页头图标
		if (t < 5 || w - l - r < 30){
			div.children[0].children[1].style.display =  "none";
		}else{
			div.children[0].children[1].style.display =  "block";
			div.children[0].children[1].style.paddingTop = t - 5 + "mm";
		}//--隐藏页头文本
		if (b < 5 || w - l - r < 30){
			div.children[2].children[0].style.display =  "none";
		}else{
			div.children[2].children[0].style.display =  "block";
		}//--隐藏页脚文本
	}
	if (window.pageSetting.pageYM){//--设置页眉
		var ym = window.pageSetting.pageYM.split("$@tr@$");
		for (var i = 0; i < ym.length; i++){
			div.children[0].children[1].children[0].cells[i].innerText = ym[i].replace(/&amp;/g,"&");
		}
	}
	if (window.pageSetting.pageYJ){//--设置页脚
		var yj = window.pageSetting.pageYJ.split("$@tr@$");
		for (var i = 0; i < yj.length; i++){
			div.children[2].children[0].children[0].cells[i].innerText = yj[i].replace(/&amp;/g,"&");
		}
	}
}

function SettingOK(button){//--点击确定，完成页面设置
	window.pageSetting.pageSize = window.pageSetting.T_pageSize;
	window.pageSetting.pageHX = window.pageSetting.T_pageHX;
	window.pageSetting.pagePadding = window.pageSetting.T_pagePadding;
	window.pageSetting.pageYM = window.pageSetting.T_pageYM;
	window.pageSetting.pageYJ = window.pageSetting.T_pageYJ;
	SetStaff_X(window.staff_X);//--更新标尺刻度位置
	SetStaff_Y(window.staff_Y);//--更新标尺刻度位置
	window.DivClose(button);//--关闭对话框；
}
function SettingCancle(button){//--点击取消，取消操作
	var page = document.getElementById("FrameBorderPage").children;
	for (var i = 0; i < page.length; i++){
		if(page[i].tagName.toLowerCase() == "div"){
			SetPage(page[i]);//--重置页面设定
		}
	}
	window.pageSetting.T_pageSize = window.pageSetting.pageSize;
	window.pageSetting.T_pageHX = window.pageSetting.pageHX;
	window.pageSetting.T_pagePadding = window.pageSetting.pagePadding;
	window.pageSetting.T_pageYM = window.pageSetting.pageYM;
	window.pageSetting.T_pageYJ = window.pageSetting.pageYJ;
	SetStaff_X(window.staff_X);//--更新标尺刻度位置
	SetStaff_Y(window.staff_Y);//--更新标尺刻度位置
	window.DivClose(button);//--关闭对话框；
}

function ResolveHeader(str){//--解析页眉页脚
	var a = str.split("$@tr@$");
	var d = new Date();
	var yyyy = d.getYear();
	var mm = d.getMonth();
	mm = parseInt(mm) + 1;
	var dd = d.getDate();
	var hh = d.getHours();
	var nn = d.getMinutes();
	var ss = d.getSeconds();
	var time1 = yyyy + "-" + mm + "-" + dd; //--短格式的日期
	var time2 = yyyy + "年" + mm + "月" + dd + "日"; //--长格式的日期
	var time3 = yyyy + "-" + mm + "-" + dd + " " + hh + ":" + nn + ":" + ss; //--时间
	var time4 = hh + ":" + nn + ":" + ss; //--采用24小时制的时间
	for (var i = 0; i < a.length; i++){
		switch (a[i].replace(/^ | $/g,"")){
			case "短格式的日期":
				a[i] = time1;
				break;
			case "长格式的日期":
				a[i] = time2;
				break;
			case "时间":
				a[i] = time3;
				break;
			case "采用24小时制的时间":
				a[i] = time4;
				break;
			case "总页数的第 # 页":
				a[i] = "Page &P of &p";//--&p为动态数值，代表当前页码,&P 为总页数
				break;
			case "总页数":
				a[i] = "&P";
				break;
			case "页码":
				a[i] = "&p";//--&p为动态数值，代表当前页码
				break;
			default://--解析自定义属性，并替换通配符
				a[i] = a[i].replace(/&d/g,time1);
				a[i] = a[i].replace(/&D/g,time2);
				a[i] = a[i].replace(/&t/g,time3);
				a[i] = a[i].replace(/&T/g,time4);
				//a[i] = a[i].replace(/&P/g,pageNum);
				a[i] = a[i].replace(/&w/g,"标题");
		}
	}
	var header = a[0] + "$@tr@$" + a[1] + "$@tr@$" + a[2];
	return header;
}

function setHeader(){
	//var p = document.getElementById("FrameBorderPage").children;
	var p = PageObjs;
	var num = 0;
	pageNum = window.TplPage.PageNum;
	for (var i = 0; i < p.length; i++){
		if(p[i].tagName.toLowerCase() == "div"){
			num = parseInt(window.TplPage.PageStart) + parseInt(i);
			if (window.pageSetting.pageYM){//--设置页眉
				var ym = window.pageSetting.pageYM.split("$@tr@$");
				for (var ii = 0; ii < ym.length; ii++){
					p[i].children[0].children[1].children[0].cells[ii].innerText = ym[ii].replace(/&p/g,num).replace(/&P/g,pageNum);
				}
			}
			if (window.pageSetting.pageYJ){//--设置页脚
				var yj = window.pageSetting.pageYJ.split("$@tr@$");
				for (var ii = 0; ii < yj.length; ii++){
					p[i].children[2].children[0].children[0].cells[ii].innerText = yj[ii].replace(/&p/g,num).replace(/&P/g,pageNum);
				}
			}
		}
	}
}
function setCustom(){
	var div = window.DivOpen("setCustom","自定义",296,150,200,'b',true,10);
	div.innerHTML = "<div style='width:280px;height:110px;background:#fff;position:relative;left:-8px;top:-8px;border:1px solid #aaaacc;color:#000;'></div>";
	div.childNodes[0].innerHTML = document.getElementById("SettingCustom").innerHTML;
	//document.getElementById("divdlg_setCustom").style.zIndex = 100000000;
	//document.getElementById("divdlg_sadadad").style.zIndex = 0;
	
	var ymyj = window.ymyj;
	var v = ymyj;
	switch (ymyj){
		case "标题":
			v = "&w";
			break;
//		case "URL":
//			v = "&u";
//			break;
		case "页码":
			v = "&p";
			break;
		case "总页数":
			v = "&P";
			break;
		case "总页数的第 # 页":
			v = "Page &p of &P";
			break;
		case "短格式的日期":
			v = "&d";
			break;
		case "长格式的日期":
			v = "&D";
			break;
		case "时间":
			v = "&t";
			break;
		case "采用24小时制的时间":
			v = "&T";
			break;
		default:
	}
	div.childNodes[0].childNodes[0].cells[1].childNodes[0].value = v;
	var divs = document.getElementsByTagName("div");
	var d = document.createElement("div");
	d.style.cssText = "width:100%; height:100%; left:0px; top:0px; position:absolute;background:url(../../images/smico/TouMing.gif)";//--用透明gif遮挡层下内容
	d.id = "tmc";
	if(document.getElementById("divdlg_sadadad")){
		document.getElementById("divdlg_sadadad").appendChild(d);
	}
	document.getElementById("divdlg_setCustom").style.zIndex = 100000000 ;
}

function CustomOK(button){//--确认自定义设置，关闭对话框，更新页眉页脚属性值
	var input= window.ymyjInput;//--触发弹出窗口的复选框
	//alert(getParent(input,4).outerHTML)
	var td = getParent(input,1);
	var v = window.ymyj;//--原属性值
	var tb = getParent(button,4);//--自定义框的table
	var v1 = tb.cells[1].childNodes[0].value;//--自定义框的值
	v1 = (v1.replace(/ /g,"") == "" || v1.replace(/ /g,"") == "空")? "" : v1;
	switch (v1){//--匹配通配符
		case "&w":
			ymyj = "标题";
			break;
//		case "&u":
//			ymyj = "URL";
//			break;
		case "&p":
			ymyj = "页码";
			break;
		case "&P":
			ymyj = "总页数";
			break;
		case "Page &p of &P":
			ymyj = "总页数的第 # 页";
			break;
		case "&d":
			ymyj = "短格式的日期";
			break;
		case "&D":
			ymyj = "长格式的日期";
			break;
		case "&t":
			ymyj = "时间";
			break;
		case "&T":
			ymyj = "采用24小时制的时间";
			break;
		default:
			ymyj = v1;
	}

	var zdy = true;
	for(var i = 0; i < input.options.length; i++){//--选中值所代表的下拉项
		if (input.options[i].value == ymyj){
			input.options[i].selected = true;
			zdy = false;//--该项为非自定义项
		}
	}
	var wth = input.offsetWidth;
	if (zdy){//--追加新自定义项
		var opt = document.createElement("option");
		opt.value = ymyj;
		opt.innerText = ymyj;
		opt.selected = true;
		input.appendChild(opt);
	}
	input.style.width = wth + "px";//--避免下拉列表变形
	HeaderChange(input);//--更新页眉页脚
	
	
	if(document.getElementById("tmc")){
		document.getElementById("tmc").removeNode(true);//--删除遮盖的透明层
	}
	window.DivClose(button);//--关闭对话框；
}

function CustomCancle(button){//--取消自定义设置，关闭对话框，并还原复选框属性值
	var input= window.ymyjInput;//--触发弹出窗口的下拉框
	var v = window.ymyj;//--该下拉框原始值
	for (var i = 0; i < input.options.length; i++){//--重新选中原下拉项
		if(input.options[i].value == v){
			input.options[i].selected = true;
		}
	}
	if(document.getElementById("tmc")){
		document.getElementById("tmc").removeNode(true);//--删除遮盖的透明层
	}
	window.DivClose(button);//--关闭对话框；
}



//-------------------------------------------------------------------===================================================================


function selectInsertObj(){
	try{
		var obj=window.curreditSpan.children[0];
		if(!obj) {obj=window.curreditSpan}
		obj.setActive();
	}
	catch(e){}
}
function doseting(){//--打开页面设置对话框，并根据页面设置，设定选项的值
	var div = window.DivOpen("sadadad","页面设置",510,380,'a','b',true,10);
	div.innerHTML = "<div style='position:relative;left:-9px;top:-8px;width:494px;height:340px;background-color:#fff;border:1px solid #aaaacc;color:#000' id='PageSetting'></div>";
	div.children[0].innerHTML = document.getElementById("pageconfig").innerHTML;
	var pSizeType = div.children[0].children[0].children[1].children[2];//--获取页面尺寸
	var SizeZdy = true;
	for (var i = 0; i < pSizeType.options.length; i++){
		if(pSizeType.options[i].value == window.pageSetting.pageSize){
			SizeZdy= false;
			pSizeType.options[i].selected = true;
		}
	}
	var w = window.pageSetting.pageSize.split(",")[0];
	var h = window.pageSetting.pageSize.split(",")[1];
	if (SizeZdy){//--追加自定义页面尺寸
		var opt = document.createElement("option");
		opt.value = window.pageSetting.pageSize;
		opt.selected = true;
		opt.innerText = w + "mm * " + h + "mm";
		pSizeType.appendChild(opt);
	}
	var page_hx = div.children[0].children[0].children[2].children;//--获取页面横纵向
	for(var i = 0; i < page_hx.length; i++){
		if (page_hx[i].value == window.pageSetting.pageHX){
			page_hx[i].checked = true;
		}
	}
	var pPadding = div.children[0].children[1].children[1];//---获取页面留白
	var vPadding = window.pageSetting.pagePadding;
	vPadding = vPadding.split(",");
	pPadding.cells[1].children[0].value = vPadding[3];
	pPadding.cells[3].children[0].value = vPadding[1];
	pPadding.cells[5].children[0].value = vPadding[0];
	pPadding.cells[7].children[0].value = vPadding[2];
	var pYMYJ = div.children[0].children[3].children[1];//--获取页眉页脚
	var vYM = window.pageSetting.pageYM;
	vYM = vYM.split("$@tr@$");
	for (var i = 0; i < vYM.length; i++){
		var s = div.children[0].children[3].children[1].cells[i*2+3].children[0];//--设置对应下拉框的值
		var zdy = true;
		for (var ii = 0; ii < s.options.length; ii++){
			if (s.options[ii].value == vYM[i]){
				s.options[ii].selected = true;
				zdy = false;
			}
		}
		if (zdy){//--追加自定义选项
			var opt = document.createElement("option");
			opt.value = vYM[i];
			opt.innerText = vYM[i];
			opt.selected = true;
			s.appendChild(opt)
		}
	}
	var vYJ = window.pageSetting.pageYJ;
	vYJ = vYJ.split("$@tr@$");
	for (var i = 0; i < vYJ.length; i++){
		var s = div.children[0].children[3].children[1].cells[i*2+3+1].children[0];//--设置对应下拉框的值
		var zdy = true;
		for (var ii = 0; ii < s.options.length; ii++){
			if (s.options[ii].value == vYJ[i]){
				s.options[ii].selected = true;
				zdy = false;
			}
		}
		if (zdy){//--追加自定义选项
			var opt = document.createElement("option");
			opt.value = vYJ[i];
			opt.innerText = vYJ[i];
			opt.selected = true;
			s.appendChild(opt)
		}
	}
}

document.getElementsByTagName("html")[0].className = "standard";
function mv(obj){obj.style.backgroundColor="#445594";obj.children[0].style.backgroundColor="#CCDFEF"}
function ut(obj){obj.style.backgroundColor="transparent";obj.children[0].style.backgroundColor="transparent"}

function GetBodyHTML(){//获取页面HTML
	
	//var divs = document.getElementById("pagebody").getElementsByTagName("div")
	var divs = window.ActPage.children[1].children[0].getElementsByTagName("div")
	for (var i=0;i<divs.length;i++ )
	{
		if(divs[i].className=="printerctl" || divs[i].className.indexOf("printerctl ")>=0){
			divs[i].objSerialize = Serialize(divs[i].obj)
		}
	}
	//var html = document.getElementById("pagebody").innerHTML
	var html = window.ActPage.children[1].children[0].innerHTML
	var url = "http://" + window.location.hostname
	while (html.indexOf(url)>0)
	{html =  html.replace(url,"")}
	return  html
}

function GetCrtlsJSON(){//获取所有控件的JSON，提取其属性和自定义属性存入新的JSON并进行编码，序列化
	//var divs = document.getElementById("pagebody").getElementsByTagName("div")
	var divs = window.ActPage.children[1].children[0].getElementsByTagName("div")
	var html = "";
	var PageID = window.ActPage.id;
	for (var i=0;i<divs.length;i++ )
	{
		if(divs[i].className=="printerctl" || divs[i].className.indexOf("printerctl ")>=0){
			var obj = divs[i].obj;
			eval("var MyJson = {name:'" + obj.name + "'}");
			for (var Item in obj){//提取控件的标准属性和自定义属性
				if (Item != "initHTML" && Item != "RightMenu"){
					eval("MyJson." + Item + " = obj." + Item);
				}
			}
			DelCtrlEvent(MyJson);//--移除控件的内置事件
			escapeJSON(MyJson);//--自定义属性进行编码；
			//alert(obj.id)
			html = html + "&#1;" + obj.name + "&#2;" + Serialize(MyJson) + "&#2;" +obj.id;
		}
	}
	html = html.replace("&#1;","")
	html = PageID + "&#0;" + html;
	var url = escape("http://" + window.location.hostname)
	while (html.indexOf(url)>0)
	{html =  html.replace(url,"")}
	return  html;
}


function dosave(isOut){
	//var pSizeBox = document.getElementById("pSizeType")
	//var pSize = pSizeBox.value.split(",")
	//return false;
	var title = document.getElementById("t_title");//--标题长度验证
	if (title.value.replace(/ /g,"") == ""){
		title.focus();
		title.style.color = "#f00";
		title.parentElement.children[2].innerText = "* " + title.getAttribute("msg");
		return false;
	} else if (title.value.length > title.getAttribute("maxlength")) {
		title.focus();
		title.style.color = "#f00";
		title.parentElement.children[2].innerText = "* " + title.getAttribute("msg");
		return false;
	}
	title = title.value;
	//var p_type = document.getElementById("p_type").value;
	var t_model = document.getElementById("t_model");
	if (t_model && t_model.checked == true){
		t_model = t_model.value;
	}else{
		t_model = 0;
	}
	var t_default = document.getElementById("t_default");
	if (t_default && t_default.checked == true){
		t_default = t_default.value;
	}else{
		t_default = 0;
	}
	var t_gate1 = "1";
	try{
		if(document.getElementById("t_gate1")){
			t_gate1 = document.getElementById("t_gate1").value;
		}
	}catch(e){}
	if(t_gate1+"" == ""){t_gate1 = "1"}
	var t_main = document.getElementById("t_main").value;
	if(t_main.toString() == "1"){
		ajax.regEvent("ChechMain")
		ajax.addParam("Sort",document.getElementById("sort").value)
		ajax.addParam("id",document.getElementById("model_ID").value)
		var r = ajax.send()
		if(r.toString() != "0"){
			alert("已存在主模板，主模板只能有一个，请选择添加副模板！");
			return false;
		}
	}
	if (!isOut)
	{
		isOut = 0
	}
	//var t_remark = document.getElementById("t_remark").value;
	ajax.regEvent("doSave")
	ajax.addParam("ID",document.getElementById("model_ID").value)
	ajax.addParam("Sort",document.getElementById("sort").value)
	ajax.addParam("title",title)
	//ajax.addParam("p_type",p_type)
	ajax.addParam("t_main",t_main)
	ajax.addParam("t_model",t_model)
	ajax.addParam("t_default",t_default)
	ajax.addParam("t_gate1",t_gate1)
	//ajax.addParam("t_remark",t_remark)
	ajax.addParam("isOut",isOut) //--是否是导出模式：1是，0否
	ajax.addParam("PageTop",escape(window.pageSetting.pageYM));//--页眉（进行编码）
	ajax.addParam("PageBottom",escape(window.pageSetting.pageYJ));//--页脚(进行编码)
	ajax.addParam("PagePadding",window.pageSetting.pagePadding);//--留白
	ajax.addParam("PageSize",window.pageSetting.pageSize);//--尺寸
	ajax.addParam("PageHX",window.pageSetting.pageHX);//--横向
	
	var Pages = document.getElementById("FrameBorderPage").children;
	var atvid = window.ActPage.id;
	json_str = ""
	for (var i = 0 ; i < Pages.length ; i++)
	{
		if (Pages[i].tagName.toLowerCase() == "div")
		{
			ActivePage(Pages[i]);
			json_str = json_str + "&#9;" + GetCrtlsJSON();
		}
	}
	json_str = json_str.replace("&#9;","")
	ActivePage(document.getElementById(atvid));//--重新激活存储的激活页面
	//{PageCoding&#0;[CtrlName&#2;CtrlJson&#2;CtrlCoding]&#1;[CtrlName&#2;CtrlJson&#2;CtrlCoding]}&#9;{PageCoding&#0;[CtrlName&#2;CtrlJson&#2;CtrlCoding]&#1;[CtrlName&#2;CtrlJson&#2;CtrlCoding]}  //数据格式，大括号和中括号是为了看起来方便加上的，数据里没有
	ajax.addParam("JSON",json_str)
	//alert(json_str)
	ajax.exec()
	return true;
	//var r = ajax.send()
	//document.getElementById("t_title").value = r;
}

function Serialize(obj){  //序列化
	if(!obj){return "\"\""}
	switch(obj.constructor){   
	   case Object:   
            var str = "{";   
            for(var o in obj){   
               str += o + ":" + Serialize(obj[o]) +",";   
           }   
          if(str.substr(str.length-1) == ",")   
               str = str.substr(0,str.length -1);   
            return str + "}";   
           break;   
        case Array:               
            var str = "[";   
            for(var o in obj){   
               str += Serialize(obj[o]) +",";   
            }   
            if(str.substr(str.length-1) == ",")   
              str = str.substr(0,str.length -1);   
            return str + "]";   
            break;   
       case Boolean:   
           
		   return "\"" + obj.toString() + "\"";   
           break;   
        case Date:   
            return "\"" + obj.toString() + "\"";   
            break;   
       case Function: 
		     return  obj.toString() ;
            break;   
        case Number:   
            return "\"" + obj.toString() + "\"";   
            break;    
        case String:   
			return "\"" + obj.toString() + "\"";   
            break; 
		default:
			return "\"\"";   
    }   
}  




function GetTableHead(list) {
	var heads = new Array()
	var maxRow=1
	var getheadByXY = function (x,y){
		for(var t = 0 ; t < heads.length ;t ++){
			if(heads[t] && heads[t].x == x && heads[t].y == y ){
				return t
			} 
		}
		return -1;
	}
	for(var i=0;i<list.length;i++){
		var rc = list[i].split("_").length
		if(maxRow<rc){maxRow=rc}
	}
	for(var i=0;i<list.length;i++){
		var cols = list[i].split("_")
		for(var ii = cols.length ; ii<maxRow ; ii++){
			cols[ii] = ""
		}
		if(maxRow<rc){maxRow=rc}
		for(var ii = 0 ; ii < cols.length;ii++){
			heads[heads.length] = {x : i , y : ii, txt: cols[ii] , colspan:1 , rowspan : 1}
		}
		for(var ii=cols.length-1; ii>0; ii--){
			var y0 = getheadByXY(i,ii-1)
			var y1 = getheadByXY(i,ii)
			if(heads[y1].txt == ""){
				
				if(heads[y0]){heads[y0].rowspan = heads[y0].rowspan*1 + heads[y1].rowspan*1;heads[y1] = null; }
			}
		}
	}
	
	for(var i = 0 ; i < maxRow ; i ++){
		for(var ii=list.length-1;ii>0;ii--){
			var h1 = getheadByXY(ii,i)
			var h0 = getheadByXY(ii-1,i)
			if(heads[h0] && heads[h1] && heads[h0].txt==heads[h1].txt){
				heads[h0].colspan = heads[h0].colspan*1 + heads[h1].colspan*1
				heads[h1] = null
			}
		}
	}

	var html = ""
	for(var i = 0 ; i < maxRow ; i ++){
		html = html  + "<tr>"
		for(var ii=0;ii<list.length;ii++){
			var h = heads[getheadByXY(ii,i)]
			if(h){
				html = html  + "<th colspan=" + h.colspan + " rowspan=" + h.rowspan + " align=center>" + h.txt + "</th>"
			}
		}
		html = html  + "</tr>"
	}
	return html
 }

function GetTableFoot(list) {
	var heads = new Array()
	var maxRow=1
	var getheadByXY = function (x,y){
		for(var t = 0 ; t < heads.length ;t ++){
			if(heads[t] && heads[t].x == x && heads[t].y == y ){
				return t
			} 
		}
		return -1;
	}
	for(var i=0;i<list.length;i++){
		var rc = list[i].split("_").length
		if(maxRow<rc){maxRow=rc}
	}
	for(var i=0;i<list.length;i++){
		var cols = list[i].split("_")
		for(var ii = cols.length ; ii<maxRow ; ii++){
			cols[ii] = ""
		}
		if(maxRow<rc){maxRow=rc}
		for(var ii = 0 ; ii < cols.length;ii++){
			heads[heads.length] = {x : i , y : ii, txt: cols[ii] , colspan:1 , rowspan : 1}
		}
		for(var ii=cols.length-1; ii>0; ii--){
			var y0 = getheadByXY(i,ii-1)
			var y1 = getheadByXY(i,ii)
			if(heads[y1].txt == ""){
				
				if(heads[y0]){heads[y0].rowspan = heads[y0].rowspan*1 + heads[y1].rowspan*1;heads[y1] = null; }
			}
		}
	}
	
	for(var i = 0 ; i < maxRow ; i ++){
		for(var ii=list.length-1;ii>0;ii--){
			var h1 = getheadByXY(ii,i)
			var h0 = getheadByXY(ii-1,i)
			if(heads[h0] && heads[h1] && heads[h0].txt==heads[h1].txt){
				heads[h0].colspan = heads[h0].colspan*1 + heads[h1].colspan*1
				heads[h1] = null
			}
		}
	}

	var html = ""
	for(var i = 0 ; i < maxRow ; i ++){
		html = html  + "<tr>"
		for(var ii=0;ii<list.length;ii++){
			var h = heads[getheadByXY(ii,i)]
			if(h){
				html = html  + "<td colspan=" + h.colspan + " rowspan=" + h.rowspan + ">" + h.txt + "</td>"
			}
		}
		html = html  + "</tr>"
	}
	return html
}


function js_getDPI() {//--获取屏幕DPI
    var arrDPI = new Array();
    if (window.screen.deviceXDPI != undefined) {
        arrDPI[0] = window.screen.deviceXDPI;
        arrDPI[1] = window.screen.deviceYDPI;
    }
    else {
        var tmpNode = document.createElement("DIV");
        tmpNode.style.cssText = "width:1in;height:1in;position:absolute;left:0px;top:0px;z-index:99;visibility:hidden";
        document.body.appendChild(tmpNode);
        arrDPI[0] = parseInt(tmpNode.offsetWidth);
        arrDPI[1] = parseInt(tmpNode.offsetHeight);
        tmpNode.parentNode.removeChild(tmpNode);    
    }
    return arrDPI;
}

function PxToMM(px,xy){//--像素转毫米
	var arrDPI = js_getDPI();
	if (xy == "x"){
		mm = px * 25.4 / arrDPI[0]
	}else{
		mm = px * 25.4 / arrDPI[1]
	}
	mm = mm.toFixed(2);//--保留小数两位
	return mm;
}

//====================================================================================================================
//--标尺与游标
function CreateStaff_X(){//--创建横轴标尺
	var staffBody = document.createElement("div");//--标尺容器
	staffBody.style.width = "210mm";
	staffBody.className = "staff_XBody";
	var staff = document.createElement("div");//--标尺
	staff.className = "staff_X";
	staff.style.width = "200mm"
	staff.onselectstart = function(){return false};
	var dl = document.createElement("dl");//--刻度
	dl.className = "PageCursor";
	dl.onselectstart = function(){return false};
	dl.style.width = "301cm";//--刻度长度
	//var html = "<dd onmousedown='L_StaffMD(this)' style='cursor:move'><span></span></dd>"
	var Zero = document.createElement("dd");
	Zero.innerHTML = "<span></span>";
	Zero.onmousedown = function(){L_StaffMD(this.parentElement.parentElement)};
	Zero.style.width = "1cm";
	Zero.style.cursor = "col-resize";
	for (var i = 1; i < 151; i++){
		var dd = document.createElement("dd");
		dd.innerHTML = 151 - i;
		dd.style.width = "1cm";
		dl.appendChild(dd);
	}
	dl.appendChild(Zero);
	for (var i = 1; i < 151; i++){
		var dt = document.createElement("dt");
		dt.innerHTML = i;
		dt.style.width = "1cm";
		dl.appendChild(dt);
	}
	var cursor_T = document.createElement("div");//--上游标
	cursor_T.className = "cursor_T";
	cursor_T.onselectstart = function(){return false};
	cursor_T.onmousedown = function(){CursorMD(this)};
	cursor_T. cursortype = "X";
	var cursor_B = document.createElement("div");//--下游表
	cursor_B.className = "cursor_B";
	cursor_B.onselectstart = function(){return false};
	cursor_B.onmousedown = function(){CursorMD(this)};
	cursor_B. cursortype = "X";
	var cursor_LineY = document.createElement("div");//--虚线
	cursor_LineY.className = "cursor_LineY";
	cursor_LineY.id = "cursor_Line1";
	var staff_R = document.createElement("div");//--右部灰暗区域
	staff_R.innerHTML = "<span onmousedown = 'R_StaffMD(this.parentElement)'></span>";
	staff_R.className = "staff_R";
	staff_R.onselectstart = function(){return false};
	staff.appendChild(dl);//--标尺
	//staff.appendChild(cursor_T);//--上游标
	//staff.appendChild(cursor_B);//--下游表
	//staff.appendChild(cursor_LineY);//--虚线
	staffBody.appendChild(staff);//--标尺容器
	staffBody.appendChild(staff_R);//--标尺容器
	var PageStaff_X = document.createElement("div");//--定位容器，位于body内，用于实现标尺滚动跟随
	PageStaff_X.style.cssText = "overflow:hidden;height:16px;position:absolute;background:#fff;";
	PageStaff_X.style.width = document.getElementById("FramePage").offsetWidth - 18 + "px";
	PageStaff_X.style.left = document.getElementById("FramePage").offsetLeft + 1 + "px";
	PageStaff_X.style.top = document.getElementById("FramePage").parentElement.offsetTop + 1 + "px";
	PageStaff_X.style.height = document.getElementById("framemargintop").offsetHeight;
	PageStaff_X.style.zIndex = 17;
	PageStaff_X.appendChild(staffBody);
	var title =document.getElementById("framemargintop").cloneNode(true);//--复制标题节点。不可以直接操作标题div，否则会导致页面结构变化，是其它函数出现错误
	PageStaff_X.appendChild(title);
	document.body.appendChild(PageStaff_X);
	dl.style.left = -(dt.offsetWidth*150 + Zero.offsetWidth) + "px";//--初始化标尺0刻度位置
	window.staff_X = staffBody;
	return staffBody;
}

function SetStaff_X(Staff){//--设置横向标尺
	if(Staff){
		//document.title = new Date().getTime();
		//document.title = Staff.children[0].canMove;
		PageSizeCheck()//--检查页面参数的合理性
		if(!Staff.children[0].canMove){Staff.children[0].canMove = 0}
		if(!Staff.children[1].canResize){Staff.children[0].canResize = 0}
		if(Staff.children[0].canMove == 1 || Staff.children[1].canResize == 1){//--根据是否拖动，选择数据来源
			var pageSize = window.pageSetting.pageSize;
			var pageHX = window.pageSetting.pageHX;
			var pagePadding = window.pageSetting.pagePadding;
		}else{
			var pageSize = window.pageSetting.T_pageSize;
			var pageHX = window.pageSetting.T_pageHX;
			var pagePadding = window.pageSetting.T_pagePadding;
		}
		if(!pageSize){pageSize = "210,297"}
		pageSize = pageSize.split(",");
		if(pageSize[0] == undefined || isNaN(pageSize[0]) || pageSize[0] =="" || pageSize[1] == undefined || isNaN(pageSize[1]) || pageSize[1] ==""){
			pageSize = "210,297";
			pageSize = pageSize.split(",")
		}
		
		if(!pageHX){pageHX = 0}
		var w = (parseInt(pageHX) == 0) ? pageSize[0] : pageSize[1];
		
		if(!pagePadding){pagePadding = "10,10,10,10"}
		pagePadding = pagePadding.split(",")
		if(pagePadding[0] == undefined || isNaN(pagePadding[0]) || pagePadding[0] ==""){pagePadding[0] = "0"}
		if(pagePadding[1] == undefined || isNaN(pagePadding[1]) || pagePadding[1] ==""){pagePadding[1] = "0"}
		if(pagePadding[2] == undefined || isNaN(pagePadding[2]) || pagePadding[2] ==""){pagePadding[2] = "0"}
		if(pagePadding[3] == undefined || isNaN(pagePadding[3]) || pagePadding[3] ==""){pagePadding[3] = "0"}
		var Staff_L = Staff.children[0];
		var Staff_R = Staff.children[1];
		Staff_R.style.width = pagePadding[1] +"mm";
		Staff_L.style.left = pagePadding[3] +"mm";
		var w1 =(w - pagePadding[1] - pagePadding[3] > 0)?w - pagePadding[1] - pagePadding[3]:0;
		Staff_L.style.width = w1 + "mm";
		Staff.style.width = w + "mm";
		Staff_R.style.left = w - pagePadding[1] + "mm";
		//document.title = pagePadding +"|"+w1;
		//--定位横向标尺
		var L = parseInt(document.getElementById("FrameBorderPage").children[0].offsetLeft);
		//Staff.style.left = L + "px";
		Staff.style.bottom = 0 + "px";
		ScrollStaff()//--定位标尺刻度
		Staff.parentElement.style.width = document.getElementById("FramePage").offsetWidth - 19 + "px";//--更新容器宽度
		Staff.parentElement.style.left = document.getElementById("FramePage").offsetLeft + 1 + "px";//--更新容器左侧位置
		document.getElementById("FramePage").onscroll = function (){ScrollStaff()}//--设置标尺滚动跟随
	}
}

function CreateStaff_Y(){//--创建纵轴标尺
	var staffBody = document.createElement("div");//--标尺容器
	staffBody.style.height = "297mm";
	staffBody.className = "staff_YBody";
	var staff = document.createElement("div");//--标尺
	staff.className = "staff_Y";
	staff.style.height = "200mm"
	staff.onselectstart = function(){return false};
	var dl = document.createElement("dl");//--刻度
	dl.className = "PageCursor";
	dl.onselectstart = function(){return false};
	dl.style.height = "301cm";//--刻度长度
	//var html = "<dd onmousedown='L_StaffMD(this)' style='cursor:move'><span></span></dd>"
	var Zero = document.createElement("dd");
	Zero.innerHTML = "<span class='border'></span>";
	Zero.onmousedown = function(){T_StaffMD(this.parentElement.parentElement)};
	Zero.style.height = "1cm";
	Zero.style.cursor = "row-resize";
	for (var i = 1; i < 151; i++){
		var dd = document.createElement("dd");
		dd.innerHTML = "<span>"+(151 - i)+"</span>";
		dd.style.height = "1cm";
		dl.appendChild(dd);
	}
	dl.appendChild(Zero);
	for (var i = 1; i < 151; i++){
		var dt = document.createElement("dt");
		dt.innerHTML = "<span>"+i+"</span>";
		dt.style.height = "1cm";
		dl.appendChild(dt);
	}
	var cursor_L = document.createElement("div");//--上游标
	cursor_L.className = "cursor_L";
	cursor_L.onselectstart = function(){return false};
	cursor_L.onmousedown = function(){CursorMD(this)};
	cursor_L. cursortype = "Y";
	var cursor_R = document.createElement("div");//--下游表
	cursor_R.className = "cursor_R";
	cursor_R.onselectstart = function(){return false};
	cursor_R.onmousedown = function(){CursorMD(this)};
	cursor_R. cursortype = "Y";
	var cursor_LineX = document.createElement("div");//--虚线
	cursor_LineX.className = "cursor_LineX";
	cursor_LineX.id = "cursor_Line1";
	var staff_B = document.createElement("div");//--右部灰暗区域
	staff_B.innerHTML = "<span onmousedown = 'B_StaffMD(this.parentElement)'></span>";
	staff_B.className = "staff_B";
	staff_B.onselectstart = function(){return false};
	staff.appendChild(dl);//--标尺
	//staff.appendChild(cursor_L);//--上游标
	//staff.appendChild(cursor_R);//--下游表
	//staff.appendChild(cursor_LineX);//--虚线
	staffBody.appendChild(staff);//--标尺容器
	staffBody.appendChild(staff_B);//--标尺容器
	var PageStaff_Y = document.createElement("div");//--定位容器，位于body内，用于实现标尺滚动跟随
	PageStaff_Y.style.cssText = "overflow:hidden;width:16px;position:absolute;";
	PageStaff_Y.style.height = document.getElementById("FramePage").offsetHeight -18 + "px";
	PageStaff_Y.style.left = document.getElementById("FramePage").offsetLeft + document.getElementById("FramePage").children[1].children[0].offsetLeft -16 + "px";
	PageStaff_Y.style.top = document.getElementById("FramePage").parentElement.offsetTop +1 + "px";
	PageStaff_Y.style.zIndex = 16;
	PageStaff_Y.appendChild(staffBody);
	document.body.appendChild(PageStaff_Y);
	dl.style.top = -(dt.offsetHeight*150 + Zero.offsetHeight -1) + "px";//--初始化标尺0刻度位置
	staffBody.style.left = "0px";
	staffBody.style.top = "0px";
	window.staff_Y = staffBody;
	return staffBody;
}

function SetStaff_Y(Staff){//--设置纵向标尺
	if(Staff){
		//document.title = new Date().getTime();
		//document.title = Staff.children[0].canMove;
		PageSizeCheck()//--检查页面参数的合理性
		if(!Staff.children[0].canMove){Staff.children[0].canMove = 0}
		if(!Staff.children[1].canResize){Staff.children[0].canResize = 0}
		if(Staff.children[0].canMove == 1 || Staff.children[1].canResize == 1){//--根据是否拖动，选择数据来源
			var pageSize = window.pageSetting.pageSize;
			var pageHX = window.pageSetting.pageHX;
			var pagePadding = window.pageSetting.pagePadding;
		}else{
			var pageSize = window.pageSetting.T_pageSize;
			var pageHX = window.pageSetting.T_pageHX;
			var pagePadding = window.pageSetting.T_pagePadding;
		}
		if(!pageSize){pageSize = "210,297"}
		pageSize = pageSize.split(",");
		if(pageSize[0] == undefined || isNaN(pageSize[0]) || pageSize[0] =="" || pageSize[1] == undefined || isNaN(pageSize[1]) || pageSize[1] ==""){
			pageSize = "210,297";
			pageSize = pageSize.split(",")
		}
		
		if(!pageHX){pageHX = 0}
		var h = (parseInt(pageHX) == 0) ? pageSize[1] : pageSize[0];
		
		if(!pagePadding){pagePadding = "10,10,10,10"}
		pagePadding = pagePadding.split(",")
		if(pagePadding[0] == undefined || isNaN(pagePadding[0]) || pagePadding[0] ==""){pagePadding[0] = "0"}
		if(pagePadding[1] == undefined || isNaN(pagePadding[1]) || pagePadding[1] ==""){pagePadding[1] = "0"}
		if(pagePadding[2] == undefined || isNaN(pagePadding[2]) || pagePadding[2] ==""){pagePadding[2] = "0"}
		if(pagePadding[3] == undefined || isNaN(pagePadding[3]) || pagePadding[3] ==""){pagePadding[3] = "0"}
		var Staff_T = Staff.children[0];
		var Staff_B = Staff.children[1];
		Staff_B.style.height = pagePadding[2] +"mm";
		Staff_T.style.top = pagePadding[0] +"mm";
		var h1 =(h - pagePadding[0] - pagePadding[2] > 0)?h - pagePadding[0] - pagePadding[2]:0;
		Staff_T.style.height = h1 + "mm";
		Staff_B.style.top = h - pagePadding[2] + "mm";
		Staff.style.height = h + "mm";
		//Staff_B.style.top = h - Staff.children[1] + "mm";
		//--定位纵向标尺
		var T = parseInt(document.getElementById("FrameBorderPage").offsetTop);
		Staff.style.left = 0 + "px";
		//Staff.style.top = T + "px";
		Staff.parentElement.style.left = document.getElementById("FramePage").offsetLeft + document.getElementById("FramePage").children[1].children[0].offsetLeft -16 + "px";//--更新标尺容器位置
		Staff.parentElement.style.height = (document.getElementById("FramePage").offsetHeight -18 > 0)?document.getElementById("FramePage").offsetHeight -18:0 + "px";//--更新标尺容器高度
		ScrollStaff()//--定位标尺刻度
		document.getElementById("FramePage").onscroll = function (){ScrollStaff()}//--设置标尺滚动跟随
	}
}

function ScrollStaff(){//--标尺滚动跟随
	if(window.staff_Y){
		var m = document.getElementById("FramePage").scrollTop;
		var p = document.getElementById("FramePage").children[1].offsetTop;
		var p1 = window.ActPage.offsetTop
		window.staff_Y.style.top = -m + p + p1 + "px";
		//document.title = window.ActPage.offsetTop
	}
	if(window.staff_X){
		var m = document.getElementById("FramePage").scrollLeft;
		var p = document.getElementById("FramePage").children[1].children[0].offsetLeft;
		window.staff_X.style.left = -m + p + "px";
		//document.title = document.getElementById("FramePage").scrollLeft + "|" + document.getElementById("FramePage").children[1].children[0].offsetLeft;
	}
	
}

function PageSizeCheck(){//--检查页面设置的合理性
	for (var i = 0 ; i < 2; i++){
		if (i == 0){
			var pageSize = window.pageSetting.pageSize;
			var pageHX = window.pageSetting.pageHX;
			var pagePadding = window.pageSetting.pagePadding;
		}else{
			var pageSize = window.pageSetting.T_pageSize;
			var pageHX = window.pageSetting.T_pageHX;
			var pagePadding = window.pageSetting.T_pagePadding;
		}
		if(!pageSize){pageSize = "210,297"}
		pageSize = pageSize.split(",");
		if(pageSize[0] == undefined || isNaN(pageSize[0]) || pageSize[0] =="" || pageSize[1] == undefined || isNaN(pageSize[1]) || pageSize[1] ==""){
			pageSize = "210,297";
			pageSize = pageSize.split(",")
		}
		if(!pageHX){pageHX = 0}
		var w = (parseInt(pageHX) == 0) ? parseFloat(pageSize[0]) : parseFloat(pageSize[1]);
		var h = (parseInt(pageHX) == 0) ? parseFloat(pageSize[1]) : parseFloat(pageSize[0]);
		if(!pagePadding){pagePadding = "10,10,10,10"}
		pagePadding = pagePadding.split(",")
		if(pagePadding[0] == undefined || isNaN(pagePadding[0]) || pagePadding[0] ==""){pagePadding[0] = "0"}
		if(pagePadding[1] == undefined || isNaN(pagePadding[1]) || pagePadding[1] ==""){pagePadding[1] = "0"}
		if(pagePadding[2] == undefined || isNaN(pagePadding[2]) || pagePadding[2] ==""){pagePadding[2] = "0"}
		if(pagePadding[3] == undefined || isNaN(pagePadding[3]) || pagePadding[3] ==""){pagePadding[3] = "0"}
		var t = parseFloat(pagePadding[0]);
		var r = parseFloat(pagePadding[1]);
		var b = parseFloat(pagePadding[2]);
		var l = parseFloat(pagePadding[3]);
		t = (t > h)? h : t;
		b = (b > h)? h : b;
		b = (b + t >= h)? h - t : b;
		l = (l > w)? w : l;
		r = (r > w)? w : r;
		r = (r + l >= w)? w - l : r;
		if(i == 0){
			window.pageSetting.pagePadding = t+ "," + r + "," + b + "," + l;
		}else{
			window.pageSetting.T_pagePadding = t+ "," + r + "," + b + "," + l;
			//document.title = t+ "," + r + "," + b + "," + l
		}
	}
}

//--标尺事件
function L_StaffMD(obj){//--横标尺左侧点击事件
	//var staff = obj.parentElement;
	document.body.style.cursor = "col-resize";
	obj.preX = window.event.clientX;
	obj.canMove = 1;
	document.onmousemove = function (){L_StaffMV(obj)}
	document.onmouseup = function (){L_StaffMU(obj)}
}
function L_StaffMV(obj){//--横标尺左侧拖动事件
	if (obj.canMove == 1){
		if (!obj.preX || isNaN(obj.preX)){
			obj.preX = window.event.clientX;
		}else{
			var div = obj;
			var div_R = div.parentElement.children[1];
			var x0 = obj.preX - window.event.clientX
			var L = div.offsetLeft - x0;
			var X  = (L >= 0) ? L: 0;//--控制边界
			X = (X <= div_R.offsetLeft) ? X : div_R.offsetLeft;
			div.style.left = X + "px";
			div.style.width = (div_R.offsetLeft - div.offsetLeft) + "px";
			if(L >= 0 && L <= div_R.offsetLeft){obj.preX = window.event.clientX;}
			var pagePadding = window.pageSetting.pagePadding;
			pagePadding = pagePadding.split(",");
			pagePadding[3] = PxToMM(div.offsetLeft);
			window.pageSetting.pagePadding = pagePadding[0] + "," + pagePadding[1] + "," + pagePadding[2] + "," + pagePadding[3];
			var page = document.getElementById("FrameBorderPage").children;
			for (var i = 0; i < page.length; i++){
				if(page[i].tagName.toLowerCase() == "div"){
					SetPage(page[i]);//--重置页面设定
				}
			}
		}
	}
}
function L_StaffMU(obj){//--横标尺左侧鼠标松开事件
	obj.canMove = 0;
	document.onmousemove = "";
	document.body.style.cursor = "";
}

function R_StaffMD(obj){//--横标尺右侧点击事件
	document.body.style.cursor = "col-resize";
	obj.preX = window.event.clientX;
	obj.canResize = 1;
	document.onmousemove = function (){R_StaffMV(obj)}
	document.onmouseup = function (){R_StaffMU(obj)}
}
function R_StaffMV(obj){//--横标尺右侧拖动事件
	if (obj.canResize == 1){
		if (!obj.preX || isNaN(obj.preX)){
			obj.preX = window.event.clientX;
		}else{
			var div_L = obj.parentElement.children[0];
			var x0 = obj.preX - window.event.clientX;
			var L = obj.offsetLeft - x0;
			var X = (L > div_L.offsetLeft)? L : (div_L.offsetLeft);
			if(L > div_L.offsetLeft && obj.offsetWidth + x0 >= 1){
				obj.style.left = X + "px";
				obj.preX = window.event.clientX;
				obj.style.width = ((obj.offsetWidth + x0 >= 1)?obj.offsetWidth + x0:1) +"px";//--改变右部阴影区宽度
				div_L.style.width = (obj.offsetLeft - div_L.offsetLeft) + "px";//--改变标尺游标区宽度
			}
			//document.title = obj.style.width+"|"+obj.offsetWidth;
			var pagePadding = window.pageSetting.pagePadding;
			pagePadding = pagePadding.split(",");
			pagePadding[1] = PxToMM(obj.offsetWidth);
			window.pageSetting.pagePadding = pagePadding[0] + "," + pagePadding[1] + "," + pagePadding[2] + "," + pagePadding[3];
			var page = document.getElementById("FrameBorderPage").children;
			for (var i = 0; i < page.length; i++){
				if(page[i].tagName.toLowerCase() == "div"){
					SetPage(page[i]);//--重置页面设定
				}
			}
		}
	}
}
function R_StaffMU(obj){//--横标尺右侧鼠标松开事件
	obj.canResize = 0;
	document.onmousemove = "";
	document.body.style.cursor = "";
}

function T_StaffMD(obj){//--纵标尺上部点击事件
	//var staff = obj.parentElement;
	document.body.style.cursor = "row-resize";
	obj.preY = window.event.clientY;
	obj.canMove = 1;
	document.onmousemove = function (){T_StaffMV(obj)}
	document.onmouseup = function (){T_StaffMU(obj)}
}
function T_StaffMV(obj){//--纵标尺上部拖动事件
	if (obj.canMove == 1){
		if (!obj.preY || isNaN(obj.preY)){
			obj.preY = window.event.clientY;
		}else{
			var div = obj;
			var div_B = div.parentElement.children[1];
			var y0 = obj.preY - window.event.clientY;
			var T = div.offsetTop - y0;
			var Y  = (T >= 0) ? T: 0;//--控制边界
			Y = (Y <= div_B.offsetTop) ? Y : div_B.offsetTop;
			div.style.top = Y + "px";
			div.style.height = (div_B.offsetTop - div.offsetTop) + "px";
			if(T >= 0 && T <= div_B.offsetTop){obj.preY = window.event.clientY;}
			var pagePadding = window.pageSetting.pagePadding;
			pagePadding = pagePadding.split(",");
			pagePadding[0] = PxToMM(div.offsetTop);
			window.pageSetting.pagePadding = pagePadding[0] + "," + pagePadding[1] + "," + pagePadding[2] + "," + pagePadding[3];
			var page = document.getElementById("FrameBorderPage").children;
			for (var i = 0; i < page.length; i++){
				if(page[i].tagName.toLowerCase() == "div"){
					SetPage(page[i]);//--重置页面设定
				}
			}
		}
	}
}
function T_StaffMU(obj){//--纵标尺上部鼠标松开事件
	obj.canMove = 0;
	document.onmousemove = "";
	document.body.style.cursor = "";
}

function B_StaffMD(obj){//--纵标尺底部点击事件
	document.body.style.cursor = "row-resize";
	obj.preY = window.event.clientY;
	obj.canResize = 1;
	document.onmousemove = function (){B_StaffMV(obj)}
	document.onmouseup = function (){B_StaffMU(obj)}
}
function B_StaffMV(obj){//--纵标尺底部拖动事件
	if (obj.canResize == 1){
		if (!obj.preY || isNaN(obj.preY)){
			obj.preY = window.event.clientY;
		}else{
			var div_T = obj.parentElement.children[0];
			var y0 = obj.preY - window.event.clientY;
			var T = obj.offsetTop - y0;
			var Y = (T > div_T.offsetTop)? T : (div_T.offsetTop);
			if(T > div_T.offsetTop && obj.offsetHeight + y0 >= 1){
				obj.style.top = Y + "px";
				obj.preY = window.event.clientY;
				obj.style.height= ((obj.offsetHeight + y0 >= 1)?obj.offsetHeight + y0:1) +"px";//--改变右部阴影区宽度
				div_T.style.height = (obj.offsetTop - div_T.offsetTop) + "px";//--改变标尺游标区宽度
			}
			//document.title = obj.style.width+"|"+obj.offsetWidth;
			var pagePadding = window.pageSetting.pagePadding;
			pagePadding = pagePadding.split(",");
			pagePadding[2] = PxToMM(obj.offsetHeight);
			window.pageSetting.pagePadding = pagePadding[0] + "," + pagePadding[1] + "," + pagePadding[2] + "," + pagePadding[3];
			var page = document.getElementById("FrameBorderPage").children;
			for (var i = 0; i < page.length; i++){
				if(page[i].tagName.toLowerCase() == "div"){
					SetPage(page[i]);//--重置页面设定
				}
			}
		}
	}
}
function B_StaffMU(obj){//--纵标尺底部鼠标松开事件
	obj.canResize = 0;
	document.onmousemove = "";
	document.body.style.cursor = "";
}

//---游标事件
function CursorMD(obj){
	obj.canMove = 1;
	window.event.cancelBubble = true;
	document.onmousemove = function (){CursorMV(obj)}
	document.onmouseup = function (){CursorMU(obj)}
}
function CursorMV(obj){
	if (obj.canMove == 1){
		if (obj.cursortype == "X"){
			if (!obj.preX || isNaN(obj.preX)){
				obj.preX = window.event.clientX;
			}else{
				var w = obj.parentElement.offsetWidth;
				var x0 = obj.preX - window.event.clientX;
				var X = obj.offsetLeft - x0;
				var L = (X >= -4) ? X : -4;
				L = (L <= w-4) ? L : w-4;
				obj.style.left = L + "px";
				if (X >= -4 && X <= w-4){obj.preX = window.event.clientX;}
				var Line = document.getElementById("cursor_Line1");
				Line.style.left = L + 4 + "px";
				Line.style.display = "block";
				//document.title = obj.parentElement.offsetWidth;
			}
		}else{
			if (!obj.preY || isNaN(obj.preY)){
				obj.preY = window.event.clientY;
			}else{
				var h =obj.parentElement.offsetHeight
				var y0 = obj.preY - window.event.clientY;
				var Y = obj.offsetTop - y0
				var T = (Y >= 0) ? Y : 0;
				T = (T <= h) ? T : h;
				obj.style.top = T + "px";
				if(Y >= 0 && Y <= h){obj.preY = window.event.clientY;}
				var Line = document.getElementById("cursor_Line2");
				Line.style.top = T + 4 + "px";
				Line.style.display = "block";
			}
		}
	}
}
function CursorMU(obj){
	obj.canMove = 0;
	document.onmousemove = "";
	var Line = document.getElementById("cursor_Line1");
	if(Line){Line.style.display = "none";}
	var Line = document.getElementById("cursor_Line2");
	if(Line){Line.style.display = "none";}
}

function cssValue(o,s){//--获取对象的 padding 或 margin 值，例如：cssValue(lxj,'padding-top')
	var r;
	function camelize(s) {
		return s.replace(/-(\w)/g, function (strMatch, p1){
			  return p1.toUpperCase();
		});
	}
	if(!+'\v1'){
		if(s.indexOf('-')!=-1) s=camelize(s);
		r=o.currentStyle[s]
	}else{
		r=document.defaultView.getComputedStyle(o, null).getPropertyValue(s);
	}
	return r
}

function TableActive(){
	var div = window.curreditSpan;
	if(!div.children[1].children[0]){return false}
	if(div.children[1].children[0].tagName.toLowerCase() == "table"){
		var tb = div.children[1].children[0];
		var tr = tb.rows;//--获取行集合
		var td = tb.cells;//--获取单元格集合
		for (var i = 0; i < td.length; i++){
			td[i].onmousemove = function(){TDMouseOver(this)}
		}
	}
}

function TDMouseOver(td){
	var div = window.curreditSpan;
	var X = window.event.x;
	var L = td.offsetLeft;
	var L1 = (div)?div.offsetLeft:0;
	var L2 = td.parentElement.parentElement.parentElement.offsetLeft
	X = X - L1 -L2;
	var W = td.offsetWidth;
	if (X >= L && X <= L + 5){//--鼠标在单元格前段拖动时，改变前一单元格宽度
		if(td.cellIndex > 0){
			td.style.cursor = "col-resize";
			var PreTd = td.parentElement.cells[td.cellIndex -1];
			td.onmousedown = function(){TDMouseDown(PreTd)}
		}
	}else if(X >= L + W - 5 && X <= L +W){
		if(td.cellIndex < td.parentElement.cells.length){
			td.style.cursor = "col-resize";
			td.onmousedown = function(){TDMouseDown(td)}
		}
	}else{
		//window.event.cancelBubble = true;
		td.style.cursor = "";
		td.onmousedown = "";
	}
}

function TDMouseDown(td){
	GetTableWidth()//--获取表格宽度参数
	window.event.cancelBubble = true;
	td.preX = window.event.x;
	td.width = td.clientWidth;
	showLine(1);
	document.onmousemove = function(){
		TDMouseMove(td);
	}
	document.onmouseup = function(){TDMouseUp(td)}
}

function TDMouseMove(td){
	var tb = td.parentElement.parentElement.parentElement;
	var zb = CheckSelectedTD(td);
	if(!zb){return false;}
	var zbx = parseInt(zb.split(",")[1]);
	var num = zbx + parseInt(td.colSpan) - 1;
	if(!td.preX || isNaN(td.preX)){
		td.preX = window.event.x;
		td.preY = window.event.y;
	}else{
		var tArray = window.curreditSpan.obj.TDWidth ;
		var div = window.curreditSpan;
		var X = window.event.x;
		var Y = window.event.y;
		var x0 = X - td.preX;
		var y0 = Y - td.preY;
		td.preX = window.event.x;
		td.preY = window.event.y;
		tArray[num] = tArray[num] + x0;
		window.curreditSpan.obj.TDWidth = tArray;
		window.curreditSpan.style.cursor = "col-resiz";
		document.body.style.cursor = "col-resize";
		//SetTableWidth(window.curreditSpan.obj)//--更新表格样式
		//document.getElementById("CtrlInput_W").value =  PxToMM(tArray[tArray.length-1]) + "mm";//--更新表格宽度:主要是用来更新最后一列单元格拖动造成的表格总尺寸变化
	}
}

function TDMouseUp(td){
	window.curreditSpan.style.cursor = "";
	document.body.style.cursor = "";
	var tArray = window.curreditSpan.obj.TDWidth ;
	document.getElementById("CtrlInput_W").value =  PxToMM(tArray[tArray.length-1]) + "mm";
	SetTableWidth(window.curreditSpan.obj)//--更新表格样式
	GetTableWidth();
	document.onmousemove = "";
	document.onmouseup = "";
}

function GetTdArray(){
	var div = window.curreditSpan.children[1];
	var tb = div.children[0];
	var tr = tb.rows;//--获取行集合
	var td = tb.cells;//--获取单元格集合
	var num = 0;
	if (tr){//--计算表格列数
		for (var i = 0; i < tr[0].cells.length; i++){
			num = num + tr[0].cells[i].colSpan;
		}
	}
	var tArray = new Array();//--表数组,用来记录坐标位置的单元格
	for (var i = 0; i < td.length; i++){
		var x = td[i].cellIndex;
		var y = td[i].parentElement.rowIndex;
		var x1 = td[i].colSpan;
		var y1 = td[i].rowSpan;
		if (!tArray[y]){tArray[y] = new Array();}//--行数组
		for1:for (var ii = 0; ii < num; ii ++){
			if(!tArray[y][ii]){//--定位自身坐标，匹配第一个存在的，跳出循环
				for (var n = 0; n < y1; n++){
					for (var nn = 0; nn < x1; nn++){
						if(!tArray[y + n]){tArray[y + n] = new Array();}
						tArray[y + n][ii + nn] = td[i];
					}
				}
				break for1;
			}
		}
	}
	return tArray;
}

function GetTableWidth(){//--获取表格单元格宽度数据
	var tArray = GetTDobj();//--表数组,用来记录坐标位置的单元格
	
	var lArray = new Array();
	for (var i = 0; i < tArray.length; i ++){
		for(var ii = 0; ii < tArray[i].length; ii++){
			if(tArray[i][ii]){
				if(tArray[i][ii].parentElement.parentElement.style.display != "none"){//--查看thead、tbody、tfoot的显示状态
					var len = tArray[i][ii].offsetLeft + tArray[i][ii].offsetWidth;//--获取各单元格右边框距表格左边框的距离；
					if(!lArray[ii]){//--生成长度数组
						lArray[ii] = len;
					}else{
						lArray[ii] = (lArray[ii] > len) ? len : lArray[ii];
					}
				}
			}
		}
	}
	if(window.curreditSpan.obj){window.curreditSpan.obj.TDWidth = lArray;}
}

function SetTableWidth(obj){//--重新定义表格宽度
	var div = window.curreditSpan;
	if(div.children[1].children[0].tagName.toLowerCase() == "table"){
		var tb = div.children[1].children[0];
		var tArray = GetTDobj()//--更新表格对象数组
		//--
		if (!div.obj.TDWidth){GetTableWidth()}//--如果单元格宽度数据不存在，则重新获取
		var lArray = div.obj.TDWidth;

		ResetTdobjCount()//--重置计数器
		for(var i = 0; i < tArray.length; i++){
			for(var ii = 0; ii < tArray[i].length; ii++){
				//--重写单元格宽度设置功能：尽量不要在循环体内使用CheckSelectedTD函数
				if(!tArray[i][ii].objCount || isNaN(!tArray[i][ii].objCount)){//--判断跨行（列）计数器的默认值
					tArray[i][ii].objCount = 0;
				}
				tArray[i][ii].objCount = parseInt(tArray[i][ii].objCount) + 1;
				if(tArray[i][ii].objCount == 1){
					var x = i;
					var y = ii;
					var colnum = parseInt(tArray[i][ii].colSpan);
					var rownum = parseInt(tArray[i][ii].rowSpan);
					var L = (lArray[y - 1])? parseInt(lArray[y - 1]) : 0;
					var R = parseInt(lArray[y - 1 + colnum]);
					var pl = cssValue(tArray[i][ii],"padding-left");
					pl = pl.replace(/\D/g,"");
					var pr = cssValue(tArray[i][ii],"padding-right");
					pr = pr.replace(/\D/g,"");
					tArray[i][ii].style.width = (R - L - pl - pr > 0)?R - L - pl - pr:0;
				}
				
//				var zb = CheckSelectedTD(tArray[i][ii]);
//				var x = parseInt(zb.split(",")[0]);
//				var y = parseInt(zb.split(",")[1]);
//				var colnum = parseInt(tArray[i][ii].colSpan);
//				var rownum = parseInt(tArray[i][ii].rowSpan);
//				var L = (lArray[y - 1])? parseInt(lArray[y - 1]) : 0;
//				var R = parseInt(lArray[y - 1 + colnum]);
//				var pl = cssValue(tArray[i][ii],"padding-left");
//				pl = pl.replace(/\D/g,"");
//				var pr = cssValue(tArray[i][ii],"padding-right");
//				pr = pr.replace(/\D/g,"");
//				tArray[i][ii].style.width = (R - L - pl - pr > 0)?R - L - pl - pr:0;
				//alert(L +"|"+ R)
			}
		}
	}
}


//--文本框输入限制
function ExpNum(input){//--只可以输入正整数
	var v = input.value;
	if(v.match(/\D/g)){
		input.value = v.replace(/\D/g,"")
		return false;
	}
}
function ExpLen(input){//--只可以输入长度（数字 + mm /px / cm）
	var v = input.value;
	if (input.fs == 0){
		var Exp = /\-?\d+(\.\d+)?((mm)|(cm)|(px)|(pt))?/g;
		if(v.match(Exp)){
			if(v != v.match(Exp)[0]){
				input.value = v.match(Exp)[0];
			}
		}
	}else{
		var Exp = /[^\d\.cmptx\-]|^[^\-0-9]/g;
		if(v.match(Exp)){
				
				input.value = v.replace(Exp,"");
		}
	}
}


function setAttFont(){//--打开字体设置弹出窗
	var div = window.DivOpen("setAttFont","字体设置",456,320,200,'b',true,10);
	div.innerHTML = "<div style='width:440px;height:280px;background:#F0F0F0;position:relative;left:-8px;top:-8px;border:1px solid #aaaacc;color:#000;overflow:hidden;'></div>";
	div.childNodes[0].innerHTML = document.getElementById("AttFontSet").innerHTML;
	var obj = window.curreditSpan.obj;
	if (obj){//--根据控件字体设置，初始化弹窗数据
		var ff = obj.fontFamily;
		var fs = obj.fontSize;
		var fy_B =  obj.fontWeight;
		var fy_I =  obj.fontStyle;
		var fu = obj.textDecoration;
		var tb = div.children[0].children[0];
		var FFBox = tb.rows[1].cells[0].children[0];
		var FYBox = tb.rows[1].cells[1].children[0];
		var FSBox = tb.rows[1].cells[2].children[0];
		var FUBox_U = tb.rows[3].cells[0].children[0].children[2].children[0];
		var FUBox_K = tb.rows[3].cells[0].children[0].children[1].children[0];
		if(fy_B == "bold"){var b = 1}else{var b = 0}
		if(fy_I == "italic"){var i = 2}else{var i = 0}
		switch(b + i){
			case 0:
				var fy = "常规";
				break;
			case 1:
				var fy = "加粗";
				break;
			case 2:
				var fy = "斜体";
				break;
			case 3:
				var fy = "加粗 斜体";
				break;
			default:
				var fy = "常规";
		}
		FFBox.value = ff;
		if (!fs || fs == ""){fs = 14}
		FSBox.value = fs;
		FYBox.value = fy;
		//line-through underline
		if(fu){
			if (fu.indexOf("underline") >= 0){FUBox_U.checked = true}else{FUBox_U.checked = false}
			if (fu.indexOf("line-through") >= 0){FUBox_K.checked = true}else{FUBox_K.checked = false}
		}
		//document.title = tb.tagName
	}
}

function AFS_FFChange(input){//--字体选择触发事件：实现文本框与列表框联动
	var tb = getParent(input,4);
	var IBox = tb.rows[1].cells[0].children[0];
	var SBox = tb.rows[2].cells[0].children[0];
	var Epl = tb.rows[3].cells[1].children[0].children[1];//--示例容器
	var cType = input.tagName.toLowerCase();
	var v = input.value;
	for(var i = 0; i < SBox.options.length; i++){//--列表跳转到最相近的选项
		if (SBox.options[i].value.indexOf(v) >= 0){
			SBox.options[i].selected = true;
			if (cType == "select"){
				IBox.value = SBox.value;//--由select触发时，更新文本框值
			}else{
				SBox.outerHTML = SBox.outerHTML;//--更新列表选项位置
			}
			break;
		}
	}
	var SBox = tb.rows[2].cells[0].children[0];//--重新获取列表对象
	Epl.style.fontFamily = SBox.value;//--示例应用字体设置
}

function AFS_FYChange(input){//--字形选择触发事件：实现文本框与列表框联动
	var tb = getParent(input,4);
	var IBox = tb.rows[1].cells[1].children[0];
	var SBox = tb.rows[2].cells[1].children[0];
	var Epl = tb.rows[3].cells[1].children[0].children[1];//--示例容器
	var cType = input.tagName.toLowerCase();
	var v = input.value;
	for(var i = 0; i < SBox.options.length; i++){//--列表跳转到最相近的选项
		if (SBox.options[i].value.indexOf(v) >= 0){
			SBox.options[i].selected = true;
			if (cType == "select"){
				IBox.value = SBox.value;//--由select触发时，更新文本框值
			}else{
				SBox.outerHTML = SBox.outerHTML;//--更新列表选项位置
			}
			break;
		}
	}
	var SBox = tb.rows[2].cells[1].children[0];//--重新获取列表对象
	//Epl.style.fontFamily = SBox.value;//--示例应用字体设置
	switch (SBox.value){
		case "常规":
			var B = "normal"; 
			var I = "normal";
			break;
		case "加粗":
			var B = "bold"; 
			var I = "normal";
			break;
		case "斜体":
			var B = "normal"; 
			var I = "italic";
			break;
		case "加粗 斜体":
			var B = "bold"; 
			var I = "italic";
			break;
		default:
			var B = "normal"; 
			var I = "normal";
	}
	Epl.style.fontStyle = I;//--示例应用字体设置
	Epl.style.fontWeight = B;//--示例应用字体设置
}


function AFS_FSChange(input){//--文字大小选择触发事件：实现文本框与列表框联动
	var tb = getParent(input,4);
	var IBox = tb.rows[1].cells[2].children[0];
	var SBox = tb.rows[2].cells[2].children[0];
	var Epl = tb.rows[3].cells[1].children[0].children[1];//--示例容器
	var cType = input.tagName.toLowerCase();
	var v = input.value;
	for(var i = 0; i < SBox.options.length; i++){//--列表跳转到最相近的选项
		if (SBox.options[i].value.indexOf(v) == 0 || SBox.options[i].innerText.indexOf(v) == 0){
			SBox.options[i].selected = true;
			if (cType == "select"){
				IBox.value = SBox.options[i].innerText;//--由select触发时，更新文本框值
			}else{
				SBox.outerHTML = SBox.outerHTML;//--更新列表选项位置
			}
			break;
		}
	}
	var SBox = tb.rows[2].cells[2].children[0];//--重新获取列表对象
	Epl.style.height = SBox.value;
	Epl.style.fontSize = SBox.value;//--示例应用字体设置
}

function AFS_FUChange(input){//--下划线、删除线触发事件
	var tb = getParent(input,6);
	var UBox = tb.rows[3].cells[0].children[0].children[2].children[0];//-下划线
	var KBox = tb.rows[3].cells[0].children[0].children[1].children[0];//--删除线
	var Epl = tb.rows[3].cells[1].children[0].children[1];//--示例容器
	if(UBox.checked){//--使用1248码，便于以后扩展复选框
		var u = 1;
	}else{
		var u = 0;
	}
	if(KBox.checked){
		var k = 2;
	}else{
		var k = 0;
	}
	switch(u + k){
		case 0:
			Epl.style.textDecoration = "";
			break;
		case 1:
			Epl.style.textDecoration = "underline";
			break;
		case 2:
			Epl.style.textDecoration = "line-through";
			break;
		case 3:
			Epl.style.textDecoration = "line-through underline";
			break;
		default:
			Epl.style.textDecoration = "";
	}
}

function DoAttFontSet(button){//--确认字体设置
	var tb = getParent(button,4);
	var Epl = tb.rows[3].cells[1].children[0].children[1];
	var obj = window.curreditSpan.obj;
	obj.fontFamily = Epl.style.fontFamily;
	obj.fontSize = Epl.style.fontSize.replace(/px/g,"");
	obj.fontWeight =  Epl.style.fontWeight;
	obj.fontStyle =  Epl.style.fontStyle;
	obj.textDecoration = Epl.style.textDecoration;
	RenderingCtrl(obj);
	showattrlist(window.curreditSpan);
	window.DivClose(button);
}

function getFontText(){//--获取字体信息
	var obj = window.curreditSpan.obj;
	var ff =obj.fontFamily;
	var fs = obj.fontSize;
	var fw = obj.fontWeight;
	var ft = obj.fontStyle;
	var str = "";
	if (ff){str = str + ff}
	if (fw == "bold"){str = str + " 加粗"}
	if (ft == "italic"){str = str + " 斜体"}
	if (fw != "bold" && ft != "italic"){str = str + " 常规"}
	if (fs){
		switch(fs){
			case "42pt":
				str = str + " " + "初号";
				break;
			case "36pt":
				str = str + " " + "小初";
				break;
			case "26pt":
				str = str + " " + "一号";
				break;
			case "24pt":
				str = str + " " + "小一";
				break;
			case "22pt":
				str = str + " " + "二号";
				break;
			case "18pt":
				str = str + " " + "小二";
				break;
			case "16pt":
				str = str + " " + "三号";
				break;
			case "15pt":
				str = str + " " + "小三";
				break;
			case "14pt":
				str = str + " " + "四号";
				break;
			case "12pt":
				str = str + " " + "小四";
				break;
			case "1.05pt":
				str = str + " " + "五号";
				break;
			case "9pt":
				str = str + " " + "小五";
				break;
			case "7.5pt":
				str = str + " " + "六号";
				break;
			case "6.5pt":
				str = str + " " + "小六";
				break;
			case "5.5pt":
				str = str + " " + "七号";
				break;
			case "5pt":
				str = str + " " + "八号";
				break;
			default:
				str = str + " " + fs;
		}
	}
	return str;
}



function titleChange(input){
	var staff_X = window.staff_X;
	var title = staff_X.parentElement.children[1];
	if (title){
		//title.innerText = input.value + "打印模板设计";
	}
}

function appendEditor(obj){//--相控件中增加编辑框
	if(!window.editor){window.editor = {}}
	if(!obj.isedit || isNaN(obj.isedit)){obj.isedit = 0}//--控件编辑状态
	if(obj.isedit == 0){//--插入控件编辑器，并获取控件内容
		var CtrlEditor = document.createElement("div"); 
		CtrlEditor.contentEditable = true;
		//CtrlEditor.style.border = "1px solid #555577";
		CtrlEditor.style.cursor = "text";
		CtrlEditor.style.overflow = "visible";
		CtrlEditor.onmousedown = function(){
			if(event.ctrlKey){
				event.cancelBubble = false;
			}else{
				event.cancelBubble = true;
			}
		}
		CtrlEditor.onselectstart = function(){window.event.cancelBubble=true;return true; }
		CtrlEditor.onmouseup = function(){window.editor.editorRange = document.selection.createRange();}//--记录选区
		CtrlEditor.onkeyup = function(){window.editor.editorRange = document.selection.createRange();}//--记录选区
		//CtrlEditor.onkeydown = function(){obj.style.height = "100%";}
		CtrlEditor.innerHTML = obj.innerHTML;
		obj.innerHTML = "";
		obj.appendChild(CtrlEditor);
		CtrlEditor.focus();
		//CtrlEditor.style.height = "100%";
		//obj.style.border = "1px solid #f00";
		obj.isedit = 1;
		window.editor.editorBody = CtrlEditor;
	}
}
function removeEditor(){//--移除编辑框并更新内容
	if(window.editor){
		var editorBody = window.editor.editorBody;
		if(editorBody){
			var obj = editorBody.parentElement;
			if(obj.isedit == 1){
				var html = editorBody.innerHTML;
				editorBody.removeNode(true);
				//obj.innerHTML = html;
				var div = window.curreditSpan;
				//eval("div.obj." + obj.att + " = html");//--更新内容
				delete window.editor.editorBody;
				delete window.editor.editorRange;
				obj.isedit = 0
			}
		}
	}
}

//==================================================================
//==编辑工具条
function getEditorBody(){
	if(window.editor){
		if(window.editor.editorBody){
			return window.editor.editorBody;
		}else{
			return false;
		}
	}else{
		return false;
	}
}

function getEditorRange(){
	if(window.editor){
		if(window.editor.editorRange){
			return window.editor.editorRange;
		}else{
			return false;
		}
	}else{
		return false;
	}
}

//var SpanExp = /<SPAN( class="*CtrlData"*| contentEditable="*false"*| unselectable="*on"*| dbname="*\d+.\w+"*){4}>[a-zA-Z_0-9\u4e00-\u9fa5]+<\/SPAN>/g;


function Bold(){//--粗体
	var myEditer = getEditorBody()
	if(myEditer){
		document.execCommand("Bold");
	}
}

function Italic(){//--斜体
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("Italic");
	}
}

function Underline(){//--下划线
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("Underline");
	}
}

function StrikeThrough(){//--删除线
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("StrikeThrough");
	}
}

function fontFamily(input){//--字体
	var myEditer = getEditorBody()
	var myRange = getEditorRange()
	if(myEditer){
		var fsExp = /FONT-SIZE: *\d*pt|font-size: *\d*pt/g;
		myEditer.focus();
		//document.execCommand("fontsize","",input.value);
		myRange.select();
		myRange.pasteHTML("<font style='font-family:" + input.value + "'>"+ myRange.htmlText.replace(fsExp,"font-family:"+input.value) +"</font>");
		myRange.select();
	}
}

function fontSize(input){//--字号
	var myEditer = getEditorBody()
	var myRange = getEditorRange()
	if(myEditer){
		var fsExp = /FONT-SIZE: *\d*pt|font-size: *\d*pt/g;
		myEditer.focus();
		//document.execCommand("fontsize","",input.value);
		myRange.select();
		myRange.pasteHTML("<font style='font-size:" + input.value + "'>"+ myRange.htmlText.replace(fsExp,"font-size:"+input.value) +"</font>");
		myRange.select();
	}
}

function fontBlock(input){//--段落
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("FormatBlock","",input.value);
	}
}

function Olist(){//--有序列表
	var myEditer = getEditorBody()		
	if(myEditer){
		myEditer.focus();
		document.execCommand("InsertOrderedList");
	}
} 

function Ulist(){//--无序列表
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("InsertUnorderedList");
	}
}

function Indent(){//--增加缩进
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("Indent");
	}
}

function Outdent(){//--减少缩进
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("Outdent");
	}
}

function sp(){//--上标
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("SuperScript");
	}
}

function sb(){//--下标
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("SubScript");
	}
}

function LText(){//--居左
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("JustifyLeft");
	}
}

function RText(){//--居右
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("JustifyRight");
	}
}

function CText(){//--居中
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("JustifyCenter");
	}
}

function FText(){//--两端对齐
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("JustifyFull");
	}
}

function Cut(){//--剪切
	var myEditer = getEditorBody()
	if(myEditer){
		document.execCommand("Cut");
	}
}

function Copy(){//--复制
	var myEditer = getEditorBody()
	if(myEditer){
		document.execCommand("Copy");
	}
}

function Paste(){//--粘贴
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("Paste");
	}
}

function Undo(){//--撤销
	var myEditer = getEditorBody()
	if(myEditer){
		document.execCommand("Undo");
	}
}

function Redo(){//--重做
	var myEditer = getEditorBody()
	if(myEditer){
		document.execCommand("Redo");
	}
}

function RemoveFormat(){//--移除格式
	var myEditer = getEditorBody()
	if(myEditer){
		myEditer.focus();
		document.execCommand("RemoveFormat");
	}
}

function WritingMode(){//--文字方向
	var myEditer = getEditorBody()
	var myRange = getEditorRange()
	if(myEditer){
		//var fsExp = /FONT-SIZE: *\d*pt|font-size: *\d*pt/g;
		myEditer.focus();
		//document.execCommand("fontsize","",input.value);
		myRange.select();
		myRange.pasteHTML("<p class='wordDirection'>"+ myRange.htmlText +"</p>");
		myRange.select();
	}
}

function LineHeight(){//--行间距
	var myEditer = getEditorBody()
	var myRange = getEditorRange()
	if(myEditer){
		var fsExp = /line\-height: *\d*\w{2}|LINE\-HEIGHR: *\d*\w{2}/g;
		myEditer.focus();
		//document.execCommand("fontsize","",input.value);
		myRange.select();
		myRange.pasteHTML("<span style='line-height:50px;'>"+ myRange.htmlText.replace(fsExp,"") +"</span>");
		myRange.select();
	}
}
//===================================================================


//window.setInterval(function(){
//	var spans= document.getElementsByTagName("span")
//	var now=new Date();
//	var year=now.getYear();
//	var month=now.getMonth();
//	var day=now.getDate();
//	var hours=now.getHours();
//	var minutes=now.getMinutes();
//	var seconds=now.getSeconds();
//	if (month<10){month = "0" + month}
//	if (day<10){day = "0" + day}
//	if (hours<10){hours = "0" + hours}
//	if (minutes<10){minutes = "0" + minutes}
//	if (seconds<10){seconds = "0" + seconds}
//	for (var i=0 ; i<spans.length ; i++ )
//	{
//		if(spans[i].className == "currtimenowSpan"){
//			spans[i].innerText = year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + seconds
//		}
//	}
//},1000)

//======================================================
//==线条设置框
function showLineStyleWindow(obj){//--弹出设置框，并设定取消函数
	var toolDiv = document.getElementById("CtrlLineTool"); 
	var toolbg = document.getElementById("CtrlLineToolBody");
	toolbg.style.cssText = "position:absolute;top:0px;left:0px;width:100%;height:100%;display:block";
	toolDiv.style.display = "block";
	toolDiv.style.right = (document.body.offsetWidth-event.clientX) + "px";
	toolDiv.style.top = event.clientY + "px";
	var div = window.curreditSpan;
	var att_input = getParent(obj,4).cells[0].children[0];
	document.getElementById("CtrlLineTool_value").value = eval(att_input.att)
	document.getElementById("CtrlLineTool_att").value = att_input.att;
	document.onmousedown= function(){
		var eObj = event.srcElement;
		var p1 = $(eObj).parents("#CtrlLineTool").length;
		var p2 = $(eObj).parents("#Linesize").length;
		var p3 = $(eObj).parents("#LineStyle").length;
		if(p1 == 0 && p2 == 0 && p3 == 0){
			document.getElementById("CtrlLineTool").style.display = "none";
			document.getElementById("CtrlLineToolBody").style.display = "none";
			document.onmousedown = null;
		}
	}
}
$(document).ready(function(e) {
	$("#CtrlLineToolBody .ColorTool td span").hover(function(e){
		var color = $(this).css("background-color");
		$(this).css({"background":"url(../../images/CtrlsIco/ColorTool_Bg1.gif) no-repeat left top " + color});
		$(this).css({"width":"13px","height":"13px"})
		if($(this).index() == 0 && $(this).index() == $(this).parent().children("span").length - 1){
			$(this).parent().css({"padding":"0px"})
		}
	},function(e){
		var color = $(this).css("background-color");
		$(this).css({"background":color});
		$(this).css({"width":"11px","height":"13px"})
		if($(this).index() == 0 && $(this).index() == $(this).parent().children("span").length - 1){
			$(this).css({"height":"11px"})
			$(this).parent().css({"padding":"1px 0px"})
		}
	});
	$("#CtrlLineToolBody .ColorTool td span").click(function(e) {
		var color = $(this).css("background-color").toLowerCase();
		var v = $("#CtrlLineTool_value").val().toLowerCase();
		var Exp = /#([\da-fA-F]{6}|[\da-fA-F]{3})/g;
		if(color.match(Exp)){v = v.replace(Exp,color)}
		$("#CtrlLineTool_value").val(v);
		var att = $("#CtrlLineTool_att").val();
		var div = window.curreditSpan;
		eval(att + " = v")
		var att1 = att.replace("div.obj.","")
		var div = window.curreditSpan;
		div.obj.attchange(att1)
	});
	$("#CtrlLineToolBody .ColorTool .ToolList .ToolList_Text").hover(function(e){
		$(this).addClass("hover");
		ShowLinStyleSub($(this));
	},function(e){
		$(this).removeClass("hover")
		HiddeLinStyleSub($(this))
	});
	$("#CtrlLineToolBody .ColorSub div").hover(function(){
		$(this).addClass("hover")
	},function(){
		$(this).removeClass("hover")
	})
	$("#CtrlLineToolBody .ColorSub div").click(function(e) {
		var v = $("#CtrlLineTool_value").val().toLowerCase();
		var v1 = $(this).children("input").val().toLowerCase();
		var Exp1 = /\d+(\.\d+)?pt/g;
		var Exp2 = /solid|dashed|dotted|double/g;
		if(v1.match(Exp1)){v = v.replace(Exp1,v1)}
		if(v1.match(Exp2)){v = v.replace(Exp2,v1)}
		$("#CtrlLineTool_value").val(v);
		$(this).parent().css("display","none");
		var att = $("#CtrlLineTool_att").val();
		var div = window.curreditSpan;
		eval(att + " = v")
		var att1 = att.replace("div.obj.","")
		var div = window.curreditSpan;
		div.obj.attchange(att1)
	});
	$("#LineStyle,#Linesize").mouseover(function(e) {
		$(this).css("display","block")
	});
	$("#LineStyle,#Linesize").mouseleave(function(e) {
		$(this).css("display","none")
	});
});
function ShowLinStyleSub(obj){
	var att = obj.children("input").val();
	var SubMenu = eval("document.getElementById('"+att+"')");
	$(SubMenu).css("display","block");
	var ww = $(window).width();
	var l = obj.offset().left;
	var t = obj.offset().top;
	var r = obj.width() + l;
	var mw = $(SubMenu).width()
	if(r + mw > ww){
		var ml = l - mw
	}else{
		var ml = r;
	}
	$(SubMenu).css("left",ml + "px");
	$(SubMenu).css("top",obj.offset().top + "px");
}
function HiddeLinStyleSub(obj){
	var att = obj.children("input").val();
	var SubMenu = eval("document.getElementById('"+att+"')");
	$(SubMenu).css("display","none");
}
//========================================================


function ImgUploadWindow(input){//--图片导入弹出框
	var div = window.DivOpen("setImgUpload","图片导入",540,240,200,'b',true,10,1);
	var att = getParent(input,4).cells[0].children[0].att;
	div.innerHTML = "<iframe style='width:524px;height:200px;background:#F0F0F0;position:relative;left:-8px;top:-8px;border:0px solid #aaaacc;color:#000;' frameBorder='no' noResize='noresize' scrolling='no' src='../../load/newload/PrinterUPImage.asp'></iframe><input type='hidden' att='" + att + "' id='setImgUpload_Close'>";
}


function TdSplitToolChangeText(radio){//--单元格拆分对话框单选框切换函数
	var tb = radio.parentElement.parentElement.parentElement.parentElement;
	var radio1 = tb.cells[1].children[0];
	var radio2 = tb.cells[3].children[0];
	var TextTb = tb.cells[4];
	if(radio1.checked){
		TextTb.innerText = "行数(N):";
	}else if(radio2.checked){
		TextTb.innerText = "列数(C):";
	}else{
		TextTb.innerText = "行数(N):";
	}
}

function TdSplitWindow(){//--单元格拆分弹出框
	var div = window.DivOpen("setImgUpload","拆分单元格",356,160,200,'b',true,10,1);
	div.innerHTML = "<div style='width:340px;height:120px;background:#F0F0F0;position:relative;left:-8px;top:-8px;border:0px solid #aaaacc;color:#acaccc;'></div>";
	var tdSplit = document.getElementById("TdSplitBody");
	div.children[0].innerHTML = tdSplit.innerHTML;
}
function TdSplitOK(input){
	if(window.RMenu && window.RMenu.srcElt){
		var div = input.parentElement.parentElement.parentElement;
		var tb = div.children[0].children[0];
		var radio1 = tb.cells[1].children[0];
		var radio2 = tb.cells[3].children[0];
		var num = tb.cells[5].children[0].value;
		if(radio1.checked){
			TDsplit(window.RMenu.srcElt,"h",num);
		}else if(radio2.checked){
			TDsplit(window.RMenu.srcElt,"l",num);
		}else{
			TDsplit(window.RMenu.srcElt,"h",num);
		}
	}
	window.curreditSpan.obj.CtrlEvent.getTableDate()//--更新数据
	window.DivClose(input);
}
function TdSplitCancle(input){
	window.DivClose(input);
}

//==========================================================
//==表格控件操作函数
function insertAfter(newEl, targetEl){//--向后插入元素对象
	var parentEl = targetEl.parentNode;
	
	if(parentEl.lastChild == targetEl)
	{
		parentEl.appendChild(newEl);
	}else
	{
		parentEl.insertBefore(newEl,targetEl.nextSibling);
	}            
}
	//td.parentElement.insertBefore(nTd,td);
	//insertAfter(nTd,td);

function GetTDobj(){//--获取单元格对象的集合
	var tArray = new Array();//--表数组,用来记录坐标位置的单元格
	if(!window.curreditSpan){return tArray;return false;}
	var tb = window.curreditSpan.children[1].children[0];
	if(tb.tagName.toLowerCase() != "table"){return tArray;return false;}
	var tr = tb.rows;//--获取行集合
	var td = tb.cells;//--获取单元格集合
	for (var i = 0; i < td.length; i++){//--循环所有单元格
		var x = parseInt(td[i].cellIndex);//--获取单元格起始位置，所跨的行数和列数
		var y = parseInt(td[i].parentElement.rowIndex);
		var x1 = parseInt(td[i].colSpan);
		var y1 = parseInt(td[i].rowSpan);
		if (!tArray[y]){tArray[y] = new Array();}//--检查行数组，不存在就进行创建
		var sx = parseInt(tArray[y].length) ;//--默认追加到最后的位置
		for1:for (var ii = 0; ii < tArray[y].length; ii ++){
			if(!tArray[y][ii]){//--定位自身坐标，行内遍历，找到第一个空位置，跳出循环
				var sx = ii;
				break for1;
			}
		}
		var errNum = 0;
		for (var m = sx; m < sx + x1; m++){
			for(var n = y; n < y + y1; n++){
				if(!tArray[n]){tArray[n] = new Array()}
				if(tArray[y][m] && tArray[y][m] != td[i]){//--如果列首位置是否被占用，并且占位单元格不是本单元各，则进行错误处理
					errNum = errNum + 1;
					//if(errNum == 1)(td[i].colSpan = n - y)//--更新跨列数值
				}
				if(errNum == 0){//--如果列首位置已被占用，则后续所有单元格都为空普通单元格
					var MyTD = td[i];//--要占位的单元格
				}else{
					var MyTD = td[i].cloneNode(true);
					MyTD.innerHTML = "&nbsp;";
					MyTD.colSpan = 1;
					MyTD.rowSpan = 1;
				}
				if(!tArray[n][m]){tArray[n][m] = td[i]};
			}
		}
	}
	return tArray;
}

function TDsplit(td,stype,snum){//--拆分单元格（列）
	ResetTdobjCount()
	var splitNum = parseInt(snum);//--拆分数量
	var splitType  = stype;//--拆分类型（行:h/列:l）
	if(splitNum == 1){return false;}//--不拆分则终止函数
	var Tobj = GetTDobj();//--更新表格对象数组
	var zb = CheckSelectedTD(td);//--获取单元格坐标
	if(zb){
		var x = parseInt(zb.split(",")[0]);
		var y = parseInt(zb.split(",")[1]);
	}else{
		return false;//--无坐标则终止函数
	}
	//--列拆分
	if(splitType == "l"){
		if(td.colSpan >= splitNum){
			td.colSpan = parseInt(td.colSpan) - splitNum + 1;
			for (var i = 0; i < splitNum-1; i++){
				var nTd = td.cloneNode(false);//--复制被拆分的单元格
				nTd.innerHTML = "&nbsp;";
				nTd.colSpan = 1;//--设定单元格跨列
				insertAfter(nTd,td);
			}
		}else{
			for (var i = 0; i < splitNum - 1; i++){
				var nTd = td.cloneNode(false);//--复制被拆分的单元格
				nTd.innerHTML = "&nbsp;";
				nTd.colSpan = 1;//--设定单元格跨列
				insertAfter(nTd,td);
			}
			var num = Math.abs(splitNum - td.colSpan);
			for(var i = 0; i < Tobj.length; i++){
				if(Tobj[i][y] != td){
					if(!Tobj[i][y].objCount || isNaN(!Tobj[i][y].objCount)){//--判断跨行（列）计数器的默认值
						Tobj[i][y].objCount = 0;
					}
					Tobj[i][y].objCount = parseInt(Tobj[i][y].objCount) + 1;
					if(Tobj[i][y].objCount == 1){
						Tobj[i][y].colSpan = Tobj[i][y].colSpan + num;
					}
					//if(Tobj[i][y].objCount == Tobj[i][y].rowSpan){Tobj[i][y].objCount = 0}
				}
			}
			td.colSpan = 1;
		}
	}else{//--行拆分
		if(td.rowSpan >= splitNum){
			for (var i = 0; i < splitNum-1; i++){
				var nTd = td.cloneNode(false);//--复制被拆分的单元格
				nTd.innerHTML = "&nbsp;";
				nTd.rowSpan = 1;//--设定单元格跨行
				//insertAfter(nTd,td)
				var lx = parseInt(x) + parseInt(td.rowSpan) -1;
				var ly = parseInt(y) + parseInt(td.colSpan) -1;
				var yy = 0;
				var t = "a";//--判断是向前插入还是向后插入
				for1:for(var ii = 0; ii < Tobj[lx-i].length; ii++){
					if(Tobj[lx-i][ii] != td && Tobj[lx-i][ii].rowSpan == 1){
						yy = ii;
						if(yy > ly){
							t = "b";
							break for1;
						}
					}
				}
				if(t == "b"){
					Tobj[lx-i][yy].parentElement.insertBefore(nTd,Tobj[lx-i][yy]);
				}else{
					insertAfter(nTd,Tobj[lx-i][yy])
				}
			}
			td.rowSpan = td.rowSpan - splitNum + 1;//--设定跨行数
		}else{
			for (var i = 0; i < td.rowSpan - 1; i++){
				var nTd = td.cloneNode(false);//--复制被拆分的单元格
				nTd.innerHTML = "&nbsp;";
				nTd.rowSpan = 1;//--设定单元格跨行
				//insertAfter(nTd,td)
				var lx = parseInt(x) + parseInt(td.rowSpan) -1;
				var ly = parseInt(y) + parseInt(td.colSpan) -1;
				var yy = 0;
				var t = "a";
				for1:for(var ii = 0; ii < Tobj[lx-i].length; ii++){
					if(Tobj[lx-i][ii] != td && Tobj[lx-i][ii].rowSpan == "1"){
						yy = ii;
						if(yy > ly){
							t = "b";
							break for1;
						}
					}
				}
				if(t == "b"){
					Tobj[lx -i][yy].parentElement.insertBefore(nTd,Tobj[lx-i][yy]);
				}else{
					insertAfter(nTd,Tobj[lx-i][yy]);
				}
			}
			for(var i = 0; i < splitNum - td.rowSpan; i++){
				var nTr = document.createElement("tr");
				var nTd = td.cloneNode(false);//--复制被拆分的单元格
				nTd.innerHTML = "&nbsp;";
				nTd.rowSpan = 1;//--设定单元格跨行
				nTr.appendChild(nTd);
				insertAfter(nTr,td.parentElement);
			}
			var num = Math.abs(splitNum - td.rowSpan);
			for(var i = 0; i < Tobj[x].length; i++){
				if(Tobj[x][i] != td){
					if(!Tobj[x][i].objCount || isNaN(!Tobj[x][i].objCount)){//--判断跨行（列）计数器的默认值
						Tobj[x][i].objCount = 0;
					}
					Tobj[x][i].objCount = parseInt(Tobj[x][i].objCount) + 1;
					if(Tobj[x][i].objCount == 1){
						Tobj[x][i].rowSpan = Tobj[x][i].rowSpan + num;
					}
					//if(Tobj[x][i].objCount == Tobj[x][i].colSpan){Tobj[x][i].objCount = 0}
				}
			}
			td.rowSpan = 1;
		}
	}
}

function TableAddRow(td){//--插入行（向上插入）
	ResetTdobjCount()
	var Tobj = GetTDobj()//--更新表格对象数组
	var zb = CheckSelectedTD(td);//--获取单元格坐标
	if(zb){
		var x = parseInt(zb.split(",")[0]);
		var y = parseInt(zb.split(",")[1]);
	}else{
		return false;//--无坐标则终止函数
	}
	var nTr = document.createElement("tr");
	for(var i = 0; i < Tobj[x].length; i++){
		if(Tobj[x][i].rowSpan == 1){
			if(!Tobj[x][i].objCount || isNaN(!Tobj[x][i].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[x][i].objCount = 0;
			}
			Tobj[x][i].objCount = parseInt(Tobj[x][i].objCount) + 1;
			if(Tobj[x][i].objCount == 1){
				nTr.appendChild(Tobj[x][i].cloneNode(true))
			}
			if(Tobj[x][i].objCount == Tobj[x][i].colSpan){Tobj[x][i].objCount = 0}
			Tobj[x][i].innerHTML = "&nbsp;";
			var ThisTr = Tobj[x][i].parentElement;
		}else if(Tobj[x][i].rowSpan > 1){
			if(!Tobj[x][i].objCount || isNaN(!Tobj[x][i].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[x][i].objCount = 0;
			}
			Tobj[x][i].objCount = parseInt(Tobj[x][i].objCount) + 1;
			if(Tobj[x][i].objCount == 1){
				Tobj[x][i].rowSpan = parseInt(Tobj[x][i].rowSpan) + 1;
			}
			//if(Tobj[x][i].objCount == Tobj[x][i].colSpan){Tobj[x][i].objCount = 0}
		}
		if(ThisTr){insertAfter(nTr,ThisTr);}
	}
}

function TableAddRow_After(td){//--插入行（向下插入）
	ResetTdobjCount()
	var Tobj = GetTDobj()//--更新表格对象数组
	var zb = CheckSelectedTD(td);//--获取单元格坐标
	if(zb){
		var x = parseInt(zb.split(",")[0]) + parseInt(td.rowSpan) -1;
		var y = parseInt(zb.split(",")[1]);
	}else{
		return false;//--无坐标则终止函数
	}
	var nTr = document.createElement("tr");
	for(var i = 0; i < Tobj[x].length; i++){
		if(Tobj[x][i].rowSpan == 1){
			if(!Tobj[x][i].objCount || isNaN(!Tobj[x][i].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[x][i].objCount = 0;
			}
			Tobj[x][i].objCount = parseInt(Tobj[x][i].objCount) + 1;
			if(Tobj[x][i].objCount == 1){
				var nTd = Tobj[x][i].cloneNode(true)
				nTr.appendChild(nTd)
				nTd.innerHTML = "&nbsp;";
			}
			if(Tobj[x][i].objCount == Tobj[x][i].colSpan){Tobj[x][i].objCount = 0}
			//Tobj[x][i].innerHTML = "&nbsp;";
			var ThisTr = Tobj[x][i].parentElement;
		}else if(Tobj[x][i].rowSpan > 1){
			if(!Tobj[x][i].objCount || isNaN(!Tobj[x][i].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[x][i].objCount = 0;
			}
			Tobj[x][i].objCount = parseInt(Tobj[x][i].objCount) + 1;
			if(Tobj[x][i].objCount == 1){
				Tobj[x][i].rowSpan = parseInt(Tobj[x][i].rowSpan) + 1;
			}
			if(Tobj[x][i].objCount == Tobj[x][i].colSpan){Tobj[x][i].objCount = 0}
		}
		if(ThisTr){insertAfter(nTr,ThisTr);}
	}
}

function TableDelRow(td){//--删除行
	ResetTdobjCount()
	var Tobj = GetTDobj()//--更新表格对象数组
	var zb = CheckSelectedTD(td);//--获取单元格坐标
	if(zb){
		var x = parseInt(zb.split(",")[0]) + parseInt(td.rowSpan) - 1;
		var y = parseInt(zb.split(",")[1]);
	}else{
		return false;//--无坐标则终止函数
	}
	var num = parseInt(td.parentElement.rowIndex) + parseInt(td.rowSpan) - 1;
	for(var i = 0; i < Tobj[x].length; i++){//--循环坐标行内单元格
		if(Tobj[x][i]){
			if(Tobj[x][i].rowSpan > 1){//--找出跨行单元格
				if(!Tobj[x][i].objCount || isNaN(!Tobj[x][i].objCount)){//--判断跨行（列）计数器的默认值
					Tobj[x][i].objCount = 0;
				}
				Tobj[x][i].objCount = parseInt(Tobj[x][i].objCount) + 1;
				if(Tobj[x][i].objCount == 1){
					var zb1 = CheckSelectedTD(Tobj[x][i]);
					var x1 = parseInt(zb1.split(",")[0]);
					var y1 = parseInt(zb1.split(",")[1]);
					if(x1 != x){//--表格本行内存在跨行单元格时，准备进行追加语移除操作
						Tobj[x][i].rowSpan = parseInt(Tobj[x][i].rowSpan) - 1;//--表格非本行内单元格跨行数减一
					}else{
						Tobj[x][i].objCount = 0;//--表格非本行内单元格计数器清零，并准备进行追加与移除
						var doRm = true;
					}
				}
			}
		}
	}
	if(doRm){//--开始追加与移除
		var nTr = document.createElement("tr");//--创建行
		var n = parseInt(x) + 1;
		if(Tobj[n]){//--将本行内开始的跨行单元格（从本行才开始跨行的）和下一行开始的的单元格 的副本 追加到创建的行
			for(var i = 0; i < Tobj[n].length; i++){
				var zb2 = CheckSelectedTD(Tobj[n][i]);
				var x2 = parseInt(zb2.split(",")[0]);
				var y2 = parseInt(zb2.split(",")[1]);
				if(x2 == n){
					if(!Tobj[n][i].objCount || isNaN(!Tobj[n][i].objCount)){//--判断跨行（列）计数器的默认值
						Tobj[n][i].objCount = 0;
					}
					Tobj[n][i].objCount = parseInt(Tobj[n][i].objCount) + 1;
					if(Tobj[n][i].objCount == 1){
						nTr.appendChild(Tobj[n][i].cloneNode(true));
					}
				}else{
					if(x2 == x){
						if(!Tobj[n][i].objCount || isNaN(!Tobj[n][i].objCount)){//--判断跨行（列）计数器的默认值
							Tobj[n][i].objCount = 0;
						}
						Tobj[n][i].objCount = parseInt(Tobj[n][i].objCount) + 1;
						if(Tobj[n][i].objCount == 1){
							var oTd = Tobj[n][i].cloneNode(true);
							oTd.rowSpan = parseInt(Tobj[n][i].rowSpan) - 1;//--跨行数减一:注意，克隆后 获取 oTd.rowSpan，值为1，所以用克隆前的单元格属性
							nTr.appendChild(oTd);
						}
					}
				}
			}
		}
		td.parentElement.parentElement.parentElement.rows[parseInt(num)+1].removeNode(true)//--移除原来的下一行
		insertAfter(nTr,td.parentElement.parentElement.parentElement.rows[num]);//--将新行最佳到本行后
	}
	td.parentElement.parentElement.parentElement.rows[num].removeNode(true);//--移除本行
}

function TableAddColumn(td){//--插入列（向前插入）
	ResetTdobjCount()
	var Tobj = GetTDobj()//--更新表格对象数组
	var zb = CheckSelectedTD(td);//--获取单元格坐标
	if(zb){
		var x = parseInt(zb.split(",")[0]);
		var y = parseInt(zb.split(",")[1]);
	}else{
		return false;//--无坐标则终止函数
	}
	for(var i = 0; i < Tobj.length; i++){
		if(Tobj[i][y].colSpan == 1){
			if(!Tobj[i][y].objCount || isNaN(!Tobj[i][y].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[i][y].objCount = 0;
			}
			Tobj[i][y].objCount = parseInt(Tobj[i][y].objCount) + 1;
			if(Tobj[i][y].objCount == 1){
				insertAfter(Tobj[i][y].cloneNode(true),Tobj[i][y]);
				Tobj[i][y].innerHTML = "&nbsp;";
			}
		}else if(Tobj[i][y].colSpan > 1){
			if(!Tobj[i][y].objCount || isNaN(!Tobj[i][y].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[i][y].objCount = 0;
			}
			Tobj[i][y].objCount = parseInt(Tobj[i][y].objCount) + 1;
			if(Tobj[i][y].objCount == 1){
				Tobj[i][y].colSpan = parseInt(Tobj[i][y].colSpan) + 1;
			}
		}
	}
}

function TableAddColumn_After(td){//--插入列(向后插入)
	ResetTdobjCount()
	var Tobj = GetTDobj()//--更新表格对象数组
	var zb = CheckSelectedTD(td);//--获取单元格坐标
	if(zb){
		var x = parseInt(zb.split(",")[0]);
		var y = parseInt(zb.split(",")[1]) + parseInt(td.colSpan) -1;
	}else{
		return false;//--无坐标则终止函数
	}
	for(var i = 0; i < Tobj.length; i++){
		if(Tobj[i][y].colSpan == 1){
			if(!Tobj[i][y].objCount || isNaN(!Tobj[i][y].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[i][y].objCount = 0;
			}
			Tobj[i][y].objCount = parseInt(Tobj[i][y].objCount) + 1;
			if(Tobj[i][y].objCount == 1){
				var nTd = Tobj[i][y].cloneNode(true);
				insertAfter(nTd,Tobj[i][y]);
				nTd.innerHTML = "&nbsp;";
			}
		}else if(Tobj[i][y].colSpan > 1){
			if(!Tobj[i][y].objCount || isNaN(!Tobj[i][y].objCount)){//--判断跨行（列）计数器的默认值
				Tobj[i][y].objCount = 0;
			}
			Tobj[i][y].objCount = parseInt(Tobj[i][y].objCount) + 1;
			if(Tobj[i][y].objCount == 1){
				Tobj[i][y].colSpan = parseInt(Tobj[i][y].colSpan) + 1;
			}
		}
	}
}

function TableDelColumn(td){//--删除列
	ResetTdobjCount()
	var Tobj = GetTDobj()//--更新表格对象数组
	var zb = CheckSelectedTD(td);//--获取单元格坐标
	if(zb){
		var x = parseInt(zb.split(",")[0]);
		var y = parseInt(zb.split(",")[1]) + parseInt(td.colSpan) -1;
	}else{
		return false;//--无坐标则终止函数
	}
	for(var i = 0; i < Tobj.length; i++){
		if(Tobj[i][y]){
			if(Tobj[i][y].colSpan == 1){
				if(!Tobj[i][y].objCount || isNaN(!Tobj[i][y].objCount)){//--判断跨行（列）计数器的默认值
					Tobj[i][y].objCount = 0;
				}
				Tobj[i][y].objCount = parseInt(Tobj[i][y].objCount) + 1;
				if(Tobj[i][y].objCount == 1){
					Tobj[i][y].removeNode(true);
				}
			}else if(Tobj[i][y].colSpan > 1){
				if(!Tobj[i][y].objCount || isNaN(!Tobj[i][y].objCount)){//--判断跨行（列）计数器的默认值
					Tobj[i][y].objCount = 0;
				}
				Tobj[i][y].objCount = parseInt(Tobj[i][y].objCount) + 1;
				if(Tobj[i][y].objCount == 1){
					Tobj[i][y].colSpan = parseInt(Tobj[i][y].colSpan) - 1;
				}
			}
		}
	}
}

//function TableSum(){
//	ResetTdobjCount()
//	var Tobj = GetTDobj()//--更新表格对象数组
//	var zb = CheckSelectedTD(td);//--获取单元格坐标
//	if(zb){
//		var x = parseInt(zb.split(",")[0]);
//		var y = parseInt(zb.split(",")[1]);
//	}else{
//		return false;//--无坐标则终止函数
//	}
//}
var TableSum = {};

TableSum.ShowSumWindow = function(){
	var div = window.DivOpen("setAttFont","插入合计",456,320,200,'b',true,10);
	div.innerHTML = "<div style='width:440px;height:280px;background:#F0F0F0;position:relative;left:-8px;top:-8px;border:1px solid #aaaacc;color:#000;overflow:hidden;'></div>";
	var divBody = document.getElementById("TbSum");
	var tb = divBody.children[0].children[0];
	var select1 = tb.cells[0].children[0].children[1];
	select1.innerHTML = "";
	var spans = TableSum.GetSumRows();
	var TempStr = ""
	for (var i = 0; i < spans.length; i++){
		if(TempStr != spans[i]){
			TempStr = spans[i];
			var opn = document.createElement("option");
			opn.innerText = spans[i].match(/>[a-zA-Z_0-9\u4e00-\u9fa5（）]+</)[0].replace(/[><]/g,"");
			opn.value = spans[i].match(DataExp)[0].replace(/"/g,"");
			select1.appendChild(opn);
		}
	}
	div.children[0].innerHTML = divBody.innerHTML;
}

TableSum.CloseSumWindow = function(input){
	window.DivClose(input);
}

TableSum.GetSumRows = function(){
	var div = window.curreditSpan;
	var tb = div.children[1].children[0];
	if(tb.tagName.toLowerCase() != "table" || !div.obj.DataID || !div.obj.tbDate){
		return false;
	}
	var Exp = getExp(div.obj.DataID+"\\.[\\w_]+(_Num|_Money|_MoneyCn)");
	var tbody = div.obj.tbDate.tbody;
	var text = ""
	if (tbody){
		for(var ii = 0; ii < tbody.rows[0].cells.length; ii++){
			text = text + unescape(tbody.rows[0].cells[ii].text);
		}
	}
	if(text.match(Exp)){
		var spans = text.match(Exp).sort();
	}
	return spans
}

TableSum.InsertSumSpan = function(input){
	var divBody = getParent(input,6);
	var tb = divBody.children[0].children[0];
	var select1 = tb.cells[0].children[0].children[1];
	var select2 = tb.cells[1].children[0].children[1];
	var index = select1.selectedIndex;
	if(index >= 0){
		var t1 = select1.options[index].text;
		var v1 = select1.options[index].value;
	}
	else{
		alert("请选择合计的项！");
		select1.focus();
		return false;
	}
	var index2 = select2.selectedIndex;
	var t2 = select2.options[index2].text;
	var v2 = select2.options[index2].value;
	var span = '<SPAN class=CtrlData contentEditable=false dbname="' + v1 + '|' + v2 + '" unselectable="on">' + t2 + ':' + t1 + '</SPAN>';
	//var Exp = getExp("\\d\\.[\\w_]+\\|\\d");alert(Exp)
	var td = window.RMenu.srcElt;
	td.innerHTML = td.innerHTML + span;
	window.curreditSpan.obj.CtrlEvent.getTableDate();
	window.DivClose(input)
}

function CheckSelectedTD(td){//--获取所选单元格的坐标
	var Tobj = GetTDobj()//--更新表格对象数组
	if(Tobj){
		for1:for (var i = 0; i < Tobj.length; i++){
			if(Tobj[i]){
				for2:for(var ii = 0; ii < Tobj[i].length; ii++){
					if(td == Tobj[i][ii] && !zb){
						var zb = i + "," + ii
					}
				}
			}
		}
	}
	return zb;
}

function TDMerge(){//--合并选取的单元格
	if(window.TableSeletion && window.TableSeletion.TdArea){
		var Tobj = GetTDobj();
		ResetTdobjCount();
		var zbs = window.TableSeletion.TdArea;
		var x1 = parseInt(zbs.split(",")[0]);
		var y1 = parseInt(zbs.split(",")[1]);
		var x2 = parseInt(zbs.split(",")[2]);
		var y2 = parseInt(zbs.split(",")[3]);
		var delNum = 0;
		for(var i = x1; i <= x2; i++){
			for(var ii = y1; ii <= y2; ii++){
				if(!Tobj[i][ii].objCount || isNaN(!Tobj[i][ii].objCount)){//--判断跨行（列）计数器的默认值
					Tobj[i][ii].objCount = 0;
				}
				Tobj[i][ii].objCount = parseInt(Tobj[i][ii].objCount) + 1;
				if(Tobj[i][ii] && Tobj[i][ii].objCount == 1 && Tobj[i][ii] != Tobj[x1][y1]){
					Tobj[x1][y1].innerHTML = Tobj[x1][y1].innerHTML + Tobj[i][ii].innerHTML;
					//Tobj[i][ii].removeNode(true);
					if(Tobj[i][ii].parentElement.cells.length > 1){//--判断行内是否有其他元素，如果有，则移除本单元格，否则删除本行
						Tobj[i][ii].removeNode(true);
					}else if(Tobj[i][ii].parentElement.cells.length == 1){
						for(var n =0; n < Tobj[i][ii].rowSpan; n++){
							TableDelRow(Tobj[i][ii]);
							delNum = delNum + 1
						}
					}
				}
			}
		}
		Tobj[x1][y1].rowSpan = parseInt(x2) - parseInt(x1) + 1 - delNum;//--计算跨行数和跨列数，并从跨行数中减去删除行的数量
		Tobj[x1][y1].colSpan = parseInt(y2) - parseInt(y1) + 1;
		UnTdSelect()//--取消选区样式
	}
}

function TdSelecttion(startTd,endTd){//--递归函数，获取选区的 起始 和 终点 位置
	var Tobj = GetTDobj();//--获取单元格坐标
	var zb1 = CheckSelectedTD(startTd);
	var zb2 = CheckSelectedTD(endTd);
	
	var trs = startTd.parentElement.parentElement.rows;//--获取thead，或者tbody，或者tfoot 的起始行和终点行 rowIndex
	var tsx = trs[0].rowIndex;
	var tex = trs[trs.length - 1].rowIndex;
	
	var sx1 = parseInt(zb1.split(",")[0]);
	var sy1 = parseInt(zb1.split(",")[1]);
	var ex1 = parseInt(sx1) + parseInt(startTd.rowSpan) - 1;
	var ey1 = parseInt(sy1) + parseInt(startTd.colSpan) - 1;
	var sx2 = parseInt(zb2.split(",")[0]);
	var sy2 = parseInt(zb2.split(",")[1]);
	var ex2 = parseInt(sx2) + parseInt(endTd.rowSpan) - 1;
	var ey2 = parseInt(sy2) + parseInt(endTd.colSpan) - 1;
	
	var sx = Math.min(sx1,ex1,sx2,ex2);
	var sy = Math.min(sy1,ey1,sy2,ey2);
	var ex = Math.max(sx1,ex1,sx2,ex2);
	var ey = Math.max(sy1,ey1,sy2,ey2);
	var s_sx = sx;
	var s_sy = sy;
	var s_ex = ex;
	var s_ey = ey;
//	return sx +","+sy +","+ex +","+ey;
	for(var i = sx; i <= ex; i++){
		for (var ii = sy; ii <= ey; ii++){
			var slzb = CheckSelectedTD(Tobj[i][ii]);
			var slsx = parseInt(slzb.split(",")[0]);
			var slsy = parseInt(slzb.split(",")[1]);
			var slex = parseInt(slsx) + parseInt(Tobj[i][ii].rowSpan) - 1;
			var sley = parseInt(slsy) + parseInt(Tobj[i][ii].colSpan) - 1;
			s_sx = Math.min(s_sx,slsx,slex,s_ex);
			s_sy = Math.min(s_sy,s_ey,slsy,sley);
			s_ex = Math.max(s_sx,slsx,slex,s_ex);
			s_ey = Math.max(s_sy,s_ey,slsy,sley);
		}
	}
//	return s_sx +","+s_sy +","+s_ex +","+s_ey ;
	if(s_sx == sx && s_sy == sy && s_ex == ex && s_ey == ey){
		sx = (sx > tsx) ? sx : tsx;//--如果选区超出thead或tbody或tfoot，则对选区范围限制在起始单元格所在的thead或tbody或tfoot之内
		ex = (ex <= tex) ? ex : tex;
		return sx +","+sy +","+ex +","+ey;
	}else{
		return TdSelecttion(Tobj[s_sx][s_sy],Tobj[s_ex][s_ey]);
	}
}

function DoTdSelect(){
	var Tobj = GetTDobj();
	if(!window.TableSeletion || !window.TableSeletion.TdArea){return false;}
	var zbs = window.TableSeletion.TdArea;
	var x1 = parseInt(zbs.split(",")[0]);
	var y1 = parseInt(zbs.split(",")[1]);
	var x2 = parseInt(zbs.split(",")[2]);
	var y2 = parseInt(zbs.split(",")[3]);
	for(var i = x1; i <= x2; i++){
		for(var ii = y1; ii <= y2; ii++){
			Tobj[i][ii].className = "TdSelected";
		}
	}
}

function UnTdSelect(){
	var Tobj = GetTDobj();
	if(!window.TableSeletion || !window.TableSeletion.TdArea){return false;}
	var zbs = window.TableSeletion.TdArea;
	var x1 = parseInt(zbs.split(",")[0]);
	var y1 = parseInt(zbs.split(",")[1]);
	var x2 = parseInt(zbs.split(",")[2]);
	var y2 = parseInt(zbs.split(",")[3]);
	for(var i = x1; i <= x2; i++){
		for(var ii = y1; ii <= y2; ii++){
			Tobj[i][ii].className = "";
		}
	}
	delete window.TableSeletion.TdArea;
}

function TDSelectMD(){
	//if(window.curreditSpan){window.curreditSpan.obj.CtrlEvent.CallBackEvent();}
	if(event.button == 1){
		UnTdSelect()
	}
	if(event.ctrlKey){
		event.cancelBubble = true;
		UnTdSelect()
		if(!window.TableSeletion){window.TableSeletion = {}};
		var elmt = document.elementFromPoint(event.clientX,event.clientY);
		var nTd = GetEventTd(elmt,GetTDobj());
		if(nTd){
			window.TableSeletion.StartTd = nTd;
			var zbs = TdSelecttion(nTd,nTd);
			window.TableSeletion.TdArea = zbs;
		}else{
			var Tobj = GetTDobj();
			window.TableSeletion.StartTd = Tobj[0][0];
			var zbs = TdSelecttion(Tobj[0][0],Tobj[0][0]);
			window.TableSeletion.TdArea = zbs;
		}
	}
}
function TDSelectMV(){
	//document.title = document.elementFromPoint(event.clientX,event.clientY).innerText
	if(event.ctrlKey && event.button == 1){
		event.cancelBubble = true;
		var elmt = document.elementFromPoint(event.clientX,event.clientY);
		var nTd = GetEventTd(elmt,GetTDobj());
		if(nTd){
			var StartTd = window.TableSeletion.StartTd;
			var zbs = TdSelecttion(StartTd,nTd);
			window.TableSeletion.TdArea = zbs;
			DoTdSelect();
		}else{
			//document.title = "false";	
		}
	}
}
function TDSelectClick(){
	UnTdSelect();
}

function GetEventTd(obj,tdArray){
	if(obj){
		for1:for (var i = 0; i < tdArray.length; i++){
			for2:for (var ii = 0; ii < tdArray[i].length; ii++){
				if(obj == tdArray[i][ii]){
					var nTd = obj;
					break for2;
				}
			}
			if(nTd){break for1;}
		}
		if(nTd){
			return nTd;
		}else{
			return GetEventTd(obj.parentElement,tdArray)
		}
	}
}
function ShowRightMenu(){
	var Tobj = GetTDobj();
	window.RMenu ={};
	var elmt = document.elementFromPoint(event.clientX,event.clientY);
	var nTd = GetEventTd(elmt,GetTDobj());
	window.RMenu.srcElt = nTd;
	var RightMenu = window.curreditSpan.obj.RightMenu;
	var menuBody = document.getElementById("RightMenuBody");
	menuBody.style.display ="block";
	menuBody.style.left = event.clientX -5;
	menuBody.style.top = event.clientY -5;
	var mb = document.getElementById("RightMenuBody").children[0];
	mb.innerHTML = "";
	for (var Item in RightMenu){
		var text = eval("RightMenu."+ Item +".text");
		var ico = eval("RightMenu."+ Item +".ico");
		var subMenu = document.createElement("div");
		subMenu.className = "ToolList_Text";
		subMenu.onclick = eval("RightMenu."+ Item +".Event()");;
		subMenu.innerHTML = "<img src='../../images/CtrlsIco/" + ico + "' width='23' height='23' />" +text;
		mb.appendChild(subMenu);
		//mb.innerHTML = mb.innerHTML + subMenu.outerHTML
	}
}
function HiddeRightMenu(){
	var menuBody = document.getElementById("RightMenuBody");
	if(menuBody){
		menuBody.style.display ="none";
	}
}

$(document).ready(function(e) {
	$("#RightMenuBody .ToolList .ToolList_Text").live("mouseover",function(e){
		$(this).addClass("hover");
	});
	$("#RightMenuBody .ToolList .ToolList_Text").live("mouseleave",function(e){
		$(this).removeClass("hover");
	});
});

function ResetTdobjCount(){//--重置单元格计数器
	var Tobj = GetTDobj()//--更新表格对象数组
	if(Tobj){
		for (var i = 0; i < Tobj.length; i++){
			if(Tobj[i]){
				for(var ii = 0; ii < Tobj[i].length; ii++){
					if(Tobj[i][ii]){
						Tobj[i][ii].objCount = 0;
					}
				}
			}
		}
	}
}

function ShowRow(){
	var Tobj = GetTDobj()//--更新表格对象数组
	var x = ""
	for (var i = 0; i < Tobj[0].length; i++){
		x = x+Tobj[0][i].outerHTML +"\n"
	}
	document.title = x
}

function DrowTable(){//--根据单元格矩阵生成表格
	ResetTdobjCount()
	var Tobj = GetTDobj()//--更新表格对象数组
	var tb = document.createElement("table");//--创建表格对象
	var thead = document.createElement("thead");
	var tbody = document.createElement("tbody");
	var tfoot = document.createElement("tfoot");
	for (var i = 0; i < Tobj.length; i++){//--循环行
		var tr = document.createElement("tr");//--创建对应行对象
		var trParent = "table";
		for (var ii = 0; ii < Tobj[i].length; ii++){//--循环行轴内单元格对象
			if(Tobj[i][ii]){//--判断该坐标是否存在单元格对象
				if(!Tobj[i][ii].objCount || isNaN(!Tobj[i][ii].objCount)){//--判断跨行（列）计数器的默认值
					Tobj[i][ii].objCount = 0;
				}
				Tobj[i][ii].objCount = parseInt(Tobj[i][ii].objCount) + 1;
				if(Tobj[i][ii].objCount == 1){
					var TD_Clone = Tobj[i][ii].cloneNode(true);
					TD_Clone.objCount = 0;//--计数器归零
					tr.appendChild(TD_Clone);//--追加行内单元格
				}
				if(Tobj[i][ii].objCount == (Tobj[i][ii].rowSpan * Tobj[i][ii].colSpan)){Tobj[i][ii].objCount = 0;}//==计数器归零
				var tdParent = Tobj[i][ii].parentElement.parentElement.tagName.toLowerCase();
				if(trParent != tdParent){trParent = tdParent}//--判断所属区域
			}
		}
		switch(trParent){
			case "table":
				tbody.appendChild(tr);
				break;
			case "thead":
				thead.appendChild(tr);
				break;
			case "tbody":
				tbody.appendChild(tr);
				break;
			case "tfoot":
				tfoot.appendChild(tr);
				break;
			default:
				tbody.appendChild(tr);
		}
	}
	tb.appendChild(thead);
	tb.appendChild(tbody);
	tb.appendChild(tfoot);
	//document.getElementById("tt").appendChild(tb);
	//document.getElementById("tt").innerText = tb.outerHTML;
	//document.getElementById("tt1").innerText = document.getElementById("MyTb").outerHTML;
	return tb.outerHTML;
}

//============================================================


function showLine(num){//--跟随鼠标的虚线；按下鼠标出现，鼠标弹起小时；参数：1 竖线 2 横线 3 横竖都有
	var aPage = window.ActPage.children[1].children[0];
	var h = aPage.clientHeight;
	var w = aPage.clientWidth;
	var t = aPage.offsetTop;
	var l = aPage.offsetLeft;
	var L1 = document.createElement("div");
	L1.style.cssText = "width:0px; overflow:hidden;position:absolute;border-left:dotted 1px #000;"
	L1.style.height = h;
	L1.style.left = event.x;
	L1.style.top = 0;
	L1.style.zIndex = 11111112;
	
	var L2 = document.createElement("div");
	L2.style.cssText = "height:0px;line-height:0px;font-size:0px; overflow:hidden;position:absolute;border-top:dotted 1px #000;"
	L2.style.width = w;
	L2.style.top = event.y;
	L2.style.left = 0;
	L2.style.zIndex = 11111112;
	
	document.attachEvent("onmousemove",function(){//--追加事件
		if(L1){L1.style.left =  event.x;}
		if(L2){L2.style.top =  event.y;}
	})

	document.attachEvent("onselectstart",function(){return false})
	
	document.attachEvent("onmouseup",function(){
		document.onmousemove = "";
		document.onselectstart = "";
		if(L1){L1.removeNode(true);}
		if(L2){L2.removeNode(true);}
	})
	
	switch(num){
		case 1:
			aPage.appendChild(L1);
			break;
		case 2:
			aPage.appendChild(L2);
			break;
		case 3:
			aPage.appendChild(L1);
			aPage.appendChild(L2);
			break;
		default:
			document.body.appendChild(L1);
			document.body.appendChild(L2);
	}
}

function showLine1(num){//--跟随鼠标的虚线；按下鼠标出现，鼠标弹起小时；参数：1 竖线 2 横线 3 横竖都有
	var aPage = window.ActPage.children[1].children[0];
	var aPage1 = document.getElementById("FramePage");
	var h = aPage1.clientHeight;
	var w = aPage1.clientWidth;
	var t = window.curreditSpan.offsetTop+ 16;
	var l = window.curreditSpan.offsetLeft;
	var L1 = document.createElement("div");
	L1.style.cssText = "width:0px; overflow:hidden;position:absolute;border-left:dotted 1px #000;"
	L1.style.height = h;
	L1.style.left = event.clientX - event.x + window.curreditSpan.offsetLeft -3;
	L1.style.top = document.getElementById("pageinfo").offsetHeight + document.getElementById("billtopbardiv").offsetHeight;
	L1.style.zIndex = 11111112;
	
	var L2 = document.createElement("div");
	L2.style.cssText = "height:0px;line-height:0px;font-size:0px; overflow:hidden;position:absolute;border-top:dotted 1px #000;"
	L2.style.width = w;
	L2.style.top = t;
	L2.style.left = 0;
	L2.style.zIndex = 11111112;
	
	document.attachEvent("onmousemove",function(){//--追加事件
		if(L1 && window.curreditSpan){L1.style.left = event.clientX - event.x + window.curreditSpan.offsetLeft -3}
		if(L2 && window.curreditSpan){L2.style.top =  window.curreditSpan.offsetTop+16;}
	})

	document.attachEvent("onselectstart",function(){return false})
	
	document.attachEvent("onmouseup",function(){
		document.onmousemove = "";
		document.onselectstart = "";
		if(L1){L1.removeNode(true);}
		if(L2){L2.removeNode(true);}
	})
	
	switch(num){
		case 1:
			document.body.appendChild(L1);
			break;
		case 2:
			document.body.appendChild(L2);
			break;
		case 3:
			document.body.appendChild(L1);
			document.body.appendChild(L2);
			break;
		default:
			document.body.appendChild(L1);
			document.body.appendChild(L2);
	}
}

//--人民币大写转换成数字
function ReRmb(str){
	var numList, rmbList
	rmbstr = "分,角,元,拾,佰,仟,万,拾,佰,仟,亿,拾,佰,仟,万";
	numstr = "零,壹,贰,叁,肆,伍,陆,柒,捌,玖";
	numList = "零,壹,贰,叁,肆,伍,陆,柒,捌,玖".split(",")
	rmbList = "分,角,元,拾,佰,仟,万,拾,佰,仟,亿,拾,佰,仟,万".split(",")
	for(var i = 0; i < rmbList.length; i++){
		var str1 = rmbList[i];
		rmbList[i] = new Array()
		rmbList[i][0] = str1;
	}
	str = str.replace(/整/g,"");//alert(str)
	for(var i = str.length - 1; i >=0; i--){
		var str1 = str.substr(i,1)
		//var str2 = str.substr(i-1,1)
		if(rmbstr.indexOf(str1) >= 0){
			if (i > 0){
				var str2 = str.substr(i-1,1)
			}else{
				var str2 = "零";
			}
			if(numstr.indexOf(str2) < 0){
				var str2 = "零";
			}
			for1:for(var ii = 0; ii < rmbList.length; ii++){
				if(rmbList[ii][0] == str1 && !rmbList[ii][1]){
					rmbList[ii][1] = str2;
					for(var iii = 0; iii < ii; iii++){
						if(!rmbList[iii][1]){
							rmbList[iii][1] = "零"
						}
					}
					break for1;
				}
			}
		}
	}
	var str3 = ""
	for(var i = rmbList.length - 1; i >= 0; i--){
		if(!rmbList[i][1]){rmbList[i][1] = "零"}
		str3 = str3 + rmbList[i][1]
	}
	for(var i = 0; i < numList.length; i++){
		str3 = str3.replace(eval("/"+numList[i]+"/g"),i);
	}
	if(str.indexOf("负") == 0){
		str3 = "-" + str3;
	}
	str3 = str3 / 100;
	return str3;
}
//--数字转大写人民币
function Rmb(num){
	num = num.replace(/,/g,'');
	var numList, rmbList
	rmbstr = "分,角,元,拾,佰,仟,万,拾,佰,仟,亿,拾,佰,仟,万";
	numstr = "零,壹,贰,叁,肆,伍,陆,柒,捌,玖";
	numList = "零,壹,贰,叁,肆,伍,陆,柒,捌,玖".split(",")
	rmbList = "分,角,元,拾,佰,仟,万,拾,佰,仟,亿,拾,佰,仟,万".split(",")
	//rmbList = "万,仟,佰,拾,亿,仟,佰,拾,万,仟,佰,拾,元,角,分".split(",")
	for(var i = 0; i < rmbList.length; i++){
		var str1 = rmbList[i];
		rmbList[i] = new Array()
		rmbList[i][0] = str1;
	}
	var num1 = Math.abs(num) * 100;
	num1 = num1.toString();
	if(num1.indexOf(".") >=0){
		num1 = num1.substr(0,num1.indexOf("."));//alert(num1)
	}
	var num2 = ""
	for(var i = num1.length - 1; i >= 0; i--){
		num2 = num2 + num1.substr(i,1)
	}//alert(num2)
	num1 =num2
	for(var i = 0; i < numList.length; i++){
		num1 =num1.replace(eval("/"+i+"/g"),numList[i])
	}//alert(num1)
	for(var i = 0; i < num1.length; i++){
		if(rmbList[i]){
			rmbList[i][1] = num1.substr(i,1);
		}
	}
	var rmbCn = ""
	for(var i = rmbList.length - 1; i >= 0; i--){
		if(rmbList[i][1]){
			rmbCn = rmbCn + rmbList[i][1];
			rmbCn = rmbCn + rmbList[i][0];
		}
	}//alert(rmbCn)
	rmbCn = rmbCn.replace(/零(仟|佰|拾|角)/g,"零").replace(/(零)+/g,"零").replace(/零(万|亿|元)/g,"$1").replace(/(亿)万|壹(拾)/g,"$1$2").replace(/^元零?|零分/g,"").replace(/元$/g,"元整");
	//alert(rmbCn)
	return rmbCn
}


//--获取导出代码【开始】=====================================================
function GetOutCode(outType){//--获取导出的vml代码
	window.out={oType:outType}
	
	var PageSet = {
		XZ : "1",
		pageSize : "210,297",
		pageHX : "0",
		pagePadding : "10,10,10,10",
		pageYM : " $@tr@$ $@tr@$ ",
		pageYJ : " $@tr@$ $@tr@$ "
	}
	if(window.pageSetting){
		var setting = window.pageSetting;
	}else{
		var setting = PageSet;
	}
	//--获取页面长度和宽度
	var PageSize = setting.pageSize;
	if(setting.pageHX == "0"){
		var pageWidth = PageSize.split(",")[0];
		var pageHeight = PageSize.split(",")[1];
	}else{
		var pageWidth = PageSize.split(",")[1];
		var pageHeight = PageSize.split(",")[0];
	}
	
	var wodrPics = document.getElementById("WordPic");
	wodrPics.value = "";
	var pages = document.getElementById("FrameBorderPage").children;
	var vml = "<style>";
	vml = vml + "table{";
	vml = vml + "font-size:12px;";
	vml = vml + "line-height:24px;";
	vml = vml + "border:0 none;";
	vml = vml + "}";
	vml = vml + "p{";
	vml = vml + "font-size:12px;";
	vml = vml + "line-height:24px;";
	vml = vml + "}";
	vml = vml + "td{";
	vml = vml + "font-size:12px;";
	vml = vml + "line-height:24px;";
	vml = vml + "border:0 none;";
	vml = vml + "}";
	vml = vml + "@page{mso-page-border-surround-header:no;mso-page-border-surround-footer:no;}";
	vml = vml + "@page WordSection1{size:" + pageWidth + "mm " + pageHeight + "mm;margin:0cm 0cm 0cm 0cm;}";
	vml = vml + "div.WordSection1{page:WordSection1;}";
	vml = vml + "</style>";
	if(pages){
		for (var i = 0; i < pages.length; i++){
			if(pages[i].tagName.toLowerCase() == "div"){
				vml = vml + "<div class=WordSection1 style='layout-grid:15.6pt'>";
				vml = vml + GetOutPage(pages[i],i);
				vml = vml + "</div>";
			}
		}
	}
	return vml;
}
function GetOutPage(PageObj,page){//--获取页面导出代码
	var PageSet = {
		XZ : "1",
		pageSize : "210,297",
		pageHX : "0",
		pagePadding : "10,10,10,10",
		pageYM : " $@tr@$ $@tr@$ ",
		pageYJ : " $@tr@$ $@tr@$ "
	}
	if(window.pageSetting){
		var setting = window.pageSetting;
	}else{
		var setting = PageSet;
	}
	//--获取页面长度和宽度
	var PageSize = setting.pageSize;
	if(setting.pageHX == "0"){
		var pageWidth = PageSize.split(",")[0];
		var pageHeight = PageSize.split(",")[1];
	}else{
		var pageWidth = PageSize.split(",")[1];
		var pageHeight = PageSize.split(",")[0];
	}
	//--获取页面留白
	var PagePadding = setting.pagePadding;
	var PageTop = PagePadding.split(",")[0];
	var PageRight = PagePadding.split(",")[0];
	var PageBottom = PagePadding.split(",")[0];
	var PageLeft = PagePadding.split(",")[0];
	
	var W1 = (pageWidth - PageLeft - PageRight > 0) ? pageWidth - PageLeft - PageRight : 0;
	var H1 = (pageHeight - PageTop - PageBottom > 0) ? pageHeight - PageTop - PageBottom : 0;
	
	objYM = PageObj.children[0];
	objYJ = PageObj.children[2];
	objPageBody = PageObj.children[1].children[0];
	
	var vml = "<v:group editas=3D'canvas' style='width:" + pageWidth + "mm;height:" + pageHeight + "mm;margin-top:" + pageHeight*page/2 + "mm; mso-position-horizontal-relative:char;mso-position-vertical-relative:line' coordsize=3D'" + pageWidth + "," + pageHeight + "' coordorigin=3D'-" + PageLeft + ",-" + PageTop + "'>";
	vml = vml + "<o:lock v:ext=3D'edit' aspectratio=3D't'/>";
	vml = vml + "<v:shape type=3D'#_x0000_t75' style='position:absolute;width:" + pageWidth + "mm;height:" + pageHeight + "mm;visibility:visible;mso-wrap-style:square'>";
	vml = vml + "<v:fill o:detectmouseclick=3D't'/>";
	vml = vml + "<v:path o:connecttype=3D'none'/>";
	vml = vml + "</v:shape>";
	
	vml = vml + GetOutYM(objYM,W1,PageTop);
	
	for(var i = 0; i < objPageBody.children.length; i++){
		vml = vml + GetOutCtrl(objPageBody.children[i]);
	}
	
	vml = vml + GetOutYJ(objYJ,W1,PageBottom,H1);
	
	vml = vml + "<w:wrap type=3D'none'/>";
	vml = vml + "<w:anchorlock/>";
	vml = vml + "</v:group>";
	return vml;
}

function GetOutYM(YMObj,W,H){//--获取页眉导出代码
	var vml = "<v:shape type=3D'#_x0000_t202' style='position:absolute;TOP: -" + H + "mm; LEFT: 0mm; WIDTH: " + W + "mm; HEIGHT: " + H + "mm;visibility:visible;' stroked=3D'f'>";
	vml = vml + "<v:textbox>";
	vml = vml + "<table cellpadding=0 cellspacing=0 width='100%'>";
	vml = vml + "<tr><td><div>";
	vml = vml + YMObj.innerHTML;
	vml = vml + "</div></td></tr>";
	vml = vml + "</table>";
	vml = vml + "</v:textbox>";
	vml = vml + "</v:shape>";
	return vml;
}
function GetOutYJ(YJObj,W,H,H1){//--获取页脚导出代码
	var vml = "<v:shape type=3D'#_x0000_t202' style='position:absolute;TOP: " + H1 + "mm; LEFT: 0mm; WIDTH: " + W + "mm; HEIGHT: " + H + "mm;visibility:visible;' stroked=3D'f'>";
	vml = vml + "<v:textbox>";
	vml = vml + "<table cellpadding=0 cellspacing=0 width='100%'>";
	vml = vml + "<tr><td><div>";
	vml = vml + YJObj.innerHTML;
	vml = vml + "</div></td></tr>";
	vml = vml + "</table>";
	vml = vml + "</v:textbox>";
	vml = vml + "</v:shape>";
	return vml;
}

function GetOutCtrl(CtrlObj){//--获取控件导出代码
	var otype = window.out.oType;
	if(!otype){
		otype = "word"
	}
	var l = CtrlObj.offsetLeft;
	var t = CtrlObj.offsetTop;
	var w = CtrlObj.offsetWidth;
	var h = CtrlObj.offsetHeight;
	l = PxToMM(l,"x");
	t = PxToMM(t,"x");
	w = PxToMM(w,"x");
	h = PxToMM(h,"x");
	
	if(otype == "word"){
		var vml = "<v:shape type=3D'#_x0000_t202' style='position:absolute;TOP: " + t + "mm; LEFT: " + l + "mm; WIDTH: " + (parseFloat(w)+parseFloat(5)) + "mm; HEIGHT: " + h + "mm;visibility:visible;' stroked=3D'f'>";
		vml = vml + "<v:textbox>";
		vml = vml + "<table cellpadding=0 cellspacing=0 width='100%'>";
		vml = vml + "<tr><td><div>";
		
		vml = vml + "<table cellpadding=0 cellspacing=0 width='100%'>";//--增加一个外层表格，防止内容里的表格左边框被遮盖
		vml = vml + "<tr><td style='padding-left:1px;'>";
		vml = vml + CtrlObj.innerHTML;
		var imgs = CtrlObj.getElementsByTagName("img");
		var wodrPics = document.getElementById("WordPic");
		for (var i =0; i < imgs.length; i++){
			wodrPics.value = wodrPics.value + imgs[i].outerHTML;
		}
		vml = vml + "</td></tr>";
		vml = vml + "</table>";
		
		vml = vml + "</div></td></tr>";
		vml = vml + "</table>";
		vml = vml + "</v:textbox>";
		vml = vml + "</v:shape>";
	}
	else{
		var vml = "<v:shape type=3D'#_x0000_t202' style='position:absolute;TOP: " + t + "mm; LEFT: " + l + "mm; WIDTH: " + (parseFloat(w)+parseFloat(5)) + "mm; HEIGHT: " + h + "mm;visibility:visible;' stroked=3D'f'>";
		vml = vml + "<v:textbox>";
		vml = vml + "<table cellpadding=0 cellspacing=0 width='100%'>";
		vml = vml + "<tr><td><div>";
		
		vml = vml + "<table cellpadding=0 cellspacing=0 width='100%'>";//--增加一个外层表格，防止内容里的表格左边框被遮盖
		vml = vml + "<tr><td style='padding-left:1px;'>";
		html = CtrlObj.innerHTML;
		imgHTML = "";
		var imgs = CtrlObj.getElementsByTagName("img");
		var wodrPics = document.getElementById("WordPic");
		for (var i =0; i < imgs.length; i++){
			var l1 = imgs[i].offsetLeft;
			var t1 = imgs[i].offsetTop;
			l1 = PxToMM(l1,"x");
			t1 = PxToMM(t1,"x");
			html = html.replace(imgs[i].outerHTML,"");
			imgs[i].style.left = (parseFloat(l) + parseFloat(l1)) + "mm";
			imgs[i].style.top = (parseFloat(t) + parseFloat(t1)) + "mm";
			wodrPics.value = wodrPics.value + imgs[i].outerHTML;
			imgHTML = imgHTML + imgs[i].outerHTML;
		}
		vml = vml + html;
		vml = vml + "</td></tr>";
		vml = vml + "</table>";
		
		vml = vml + "</div></td></tr>";
		vml = vml + "</table>";
		vml = vml + "</v:textbox>";
		vml = vml + "</v:shape>";
		vml = vml + imgHTML;
	}
	return vml;
}

function OutExcelHTML(){
	var wodrPics = document.getElementById("WordPic");
	wodrPics.value = "";
	var pages = document.getElementById("FrameBorderPage").children;
	var html = "";
	if(pages){
		for(var i = 0; i < pages.length; i++){
			if(pages[i].tagName.toLowerCase() == "div"){
				html = html + OutExcel_GetPage(pages[i]);
			}
		}
	}
	return html;
}

function OutExcel_GetPage(PageObj){
	var objPageBody = PageObj.children[1].children[0];
	var Ctrls = objPageBody.children;
	var y = [];
	for(var i = 0; i < Ctrls.length; i++){
		y[i] = Ctrls[i];
	}
	y = y.sort(function(a,b){return a.offsetTop>b.offsetTop?1:-1});//--根据offsetTop从小到大排序
	var tr = [];
	var num = 30;//--容差值(px)
	var top = -100000;
	for(var i = 0; i < y.length; i++){//--生成行列的二维数组
		if(y[i].offsetTop - top > num){//--超过容差值时，另起一行
			tr[tr.length] = []
			tr[tr.length - 1].push(y[i]);
		}else{
			if(!tr[0]){
				tr[0] = [];
			}
			tr[tr.length - 1].push(y[i]);
		}
	}
	for(var i = 0; i < tr.length; i++){
		if(tr[i]){
			tr[i] = tr[i].sort(function(a,b){return a.offsetLeft>b.offsetLeft?1:-1});//--根据offsetLeft从小到大排序
		}
	}
	var html = "<table>";
	for(var i = 0; i < tr.length; i++){
		html = html + "<tr>";
		for(var ii = 0; ii < tr[i].length; ii++){
			if(tr[i][ii].children[1] && tr[i][ii].children[1].children[0] && tr[i][ii].children[1].children[0].tagName.toLowerCase() == "table"){
				tr[i][ii].children[1].children[0].style.border = tr[i][ii].children[1].children[0].style.borderLeft;
			}
			html = html + "<td>&nbsp;</td><td>" + tr[i][ii].outerHTML + "</td>";
			var imgs = tr[i][ii].getElementsByTagName("img");
			var wodrPics = document.getElementById("WordPic");
			for (var iii =0; iii < imgs.length; iii++){
				wodrPics.value = wodrPics.value + imgs[iii].outerHTML;
			}
		}
		html = html + "</tr>";
		html = html + "<tr><td></td></tr>";
	}
	html = html + "</table>";
	html = html + "<table><tr><td>&nbsp;</td></tr></table>";
	return html;
}


//--获取导出代码【结束】=====================================================

//--数字格式化函数，可以控制小数位数，自动四舍五入，添加逗号。
function fmoney(s, n) { 
	s = (s+"").replace(/,/g,"")
	n = n > 0 && n <= 20 ? n : 2; 
	var f = "";
	if((s + "").match(/-/)){
		s = Math.abs(s);
		f = "-"
	}
	s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(n) + ""; 
	var l = s.split(".")[0].split("").reverse(), r = s.split(".")[1]; 
	t = ""; 
	for (i = 0; i < l.length; i++) { 
		t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : ""); 
	} 
	return f + t.split("").reverse().join("") + "." + r; 
} 


//=========================================================================
//--公司章调用和拖动功能
var currId = 0;
var imgpos = 40;
function loadSignImage(box) {//--显示输入密码界面
	if (box.value != "") {
		document.getElementById("dlgdiv").style.display = "block";
		document.getElementById("dlgtit").innerHTML = "请输入" + box.options[box.selectedIndex].text + "的使用密码";
		document.getElementById("s_pwd").value = "";
		currId = box.value;
	}
}

function signPwdCheck() {//--检查密码，并绑定事件
	var pwd = document.getElementById("s_pwd").value;
	var t = new Date();
	var div = document.createElement("div");
	$(div).load("../../setjm/signUpload.asp?__msgid=ckpwd&id=" + currId + "&value=" + pwd + "&t=" + t.getTime(),function(e){
		var r = div.innerHTML;
		if (r != "ok") {
			alert(r + "  ");
		}
		else {
			var PrtBody = document.getElementById("FrameBorderPage");
			var img = document.createElement("img");
			img.id = ("signimg_" + t.getTime()).replace(".", "");
			imgpos = imgpos + 10;
			imgpos = imgpos > 300 ? 50 : imgpos;
			img.style.cssText = "position:absolute;top:" +  parseInt(imgpos * 0.7) + "px;left:" + (parseInt(PrtBody.children[0].offsetLeft) + parseInt(imgpos)) + "px;z-Index:910000;filter:Chroma(Color=#FFFFFF);border:none 0;"
			img.src = "../../sdk/getdata.asp?id=" + currId + "&pw=" + pwd;
			img.onmousedown = function(){
				window.actImgQZ = img;
				window.InitPos  = { X0: window.event.clientX,  Y0: window.event.clientY ,  initY: img.style.top.replace("px","")*1,  initX: img.style.left.replace("px","")*1};
				InitPos.canmove = 1
				img.setCapture();
				event.cancelBubble = true;
				document.body.style.cursor = "move";
				document.onmousemove = function(){
					QZMouseMove();
				}
			}
			img.onmouseup = function(){
				window.actImgQZ = null;
				img.releaseCapture();
				InitPos.canmove=0;
				document.body.style.cursor = "";
				document.onmousemove = function(){return false};
			}
			PrtBody.appendChild(img);
			document.getElementById("dlgdiv").style.display = "none";
		}
	});
}

function QZMouseMove(){
	var div = window.actImgQZ;
	if(InitPos.canmove==1){
		 var x1 = InitPos.initX+ parseInt(window.event.clientX - InitPos.X0); 
		 var y1 = InitPos.initY + parseInt(window.event.clientY - InitPos.Y0); // document.getElementById("FramePage1").scrollTop - (window.InitPos.Y-window.InitPos.top) - window.bodyfrmTop);
		// top.document.getElementById("billtopbardiv").innerHTML = (y1 + "=" + InitPos.X0 + "=" + InitPos.Y0 + "==" + InitPos.initY + "==" +  window.event.clientY);
		 div.style.left = parseInt(x1)  + "px"; // PxToMM(x1,"x") + "mm";
		 div.style.top =  parseInt(y1)  + "px"; //  PxToMM(y1,"y") + "mm";
	}
}

function ResetQZ(){
	var PrtBody = document.getElementById("FrameBorderPage");
	var l = PrtBody.children[0].offsetLeft;
	var imgs = $(PrtBody).children("img");
	for(var i = 0; i < imgs.length; i ++){
		var img = imgs.get(i);
		img.style.left = PxToMM(img.offsetLeft + l) + "mm";
	}
}
function PrintQZ(){
	var PrtBody = document.getElementById("FrameBorderPage");
	var l = PrtBody.children[0].offsetLeft;
	var imgs = $(PrtBody).children("img");
	for(var i = 0; i < imgs.length; i ++){
		var img = imgs.get(i);
		img.style.left = PxToMM(img.offsetLeft - l) + "mm";
	}
}
//=========================================================================


//=========================================================================
//--获取并格式化模板明细控件信息、页眉页脚信息
//--参数:TplID:模板ID
function GetPrinterCtrlObj(TplID){
	var Page = {//--模板数据默认格式
		P1:{
			P1_C1:{
				Json:{/*jsonText*/}
			},
			P1_C2:{
				Json:{/*jsonText*/}
			}
		}
	}
	var model = {};
	ajax.regEvent("GetTemplateJson");
	ajax.addParam("TplID",TplID);
	var r = ajax.send();//document.write(r)
	eval("model = {Page:" + r + "}");
	
	model.Page1 = {};//--分页用json,含明细控件绑定数据与条数
	for(var P in model.Page){
		eval("model.Page1." + P + " = {}");
		for (var C in eval("model.Page." + P)){
			var ResolveType = eval("model.Page." + P + "." + C + ".Json.ResolveType");
			var DataID = eval("model.Page." + P + "." + C + ".Json.DataID");
			if(ResolveType == 3 && DataID && DataID.length > 0){
				eval("var hs = model.Page." + P + "." + C + ".Json.att_每页行数")
				eval("model.Page1." + P + "." + C + " = {DataID:'" + DataID + "',DataNum:'" + hs + "'}");
			}
		}
	}
	
	
	ajax.regEvent("GetTemplatePageSetting");
	ajax.addParam("TplID",TplID);
	var r = ajax.send();
	if (r == "false"){
		model.PageSetting = window.pageSetting;
	}else{
		eval("var a = {PageSetting:" + r + "}");
		model.PageSetting = a.PageSetting;
	}
	model.PageSetting.XZ = window.pageSetting.XZ;
	model.PageSetting.pageYJ = unescape(model.PageSetting.pageYJ);
	model.PageSetting.pageYM = unescape(model.PageSetting.pageYM);
	//alert(Serialize(model.PageSetting));
	return model;
}

function GetPrinterPageObj(TplID,FormID,PageInfo){//alert(FormID)
	//var t1 = new Date().getTime()
	var model = GetPrinterCtrlObj(TplID);
	//var t2 = new Date().getTime()
	//alert((t2-t1)/1000)
	PageInfo.model = model;
	var CtlsJson = model.Page1;
	var DataArray = [];
	for (var P in CtlsJson){
		eval("var p = CtlsJson." + P);
		var num = 0;
		for(var C in p){
			eval("var DataID = p." + C + ".DataID");
			eval("var DataNum = p." + C + ".DataNum");
			DataArray.push(DataID + "," + DataNum + "," + P);
			num = num + 1;
		}
		if (num == 0){
			DataArray.push("0,0," + P);
		}
	}
	var res = [], hash = {};
	for(var i = 0; i < DataArray.length; i ++){//--剔除数组重复项
		if(!hash[DataArray[i]]){
			res.push(DataArray[i]);
			hash[DataArray[i]] = true;
		}
	}//alert(res);return false
	var DataStr = res.join("|").toString();//alert(DataStr+"\n"+FormID+"\n"+isSum+"\n"+PageInfo.pageStart+"\n"+PageInfo.pageEnd)
	ajax.regEvent("CtrlPageNum");
	ajax.addParam("DataStr",DataStr);
	ajax.addParam("formid",FormID);
	ajax.addParam("isSum",isSum);
	ajax.addParam("StartNum",PageInfo.pageStart);
	ajax.addParam("EndNum",PageInfo.pageEnd);
	var r = ajax.send();
	//alert(r);document.write(r);return false
	eval("var rJson = {" + r + "}");
	

	PageInfo.start = rJson.start;
	PageInfo.end = rJson.end;
	PageInfo.pageNum = rJson.num;
	PageInfo.forms = rJson.forms;
	if (PageInfo.pageNum % PageInfo.pageSize == 0){
		PageInfo.AllPage = PageInfo.pageNum / PageInfo.pageSize;
	}else{
		PageInfo.AllPage = (PageInfo.pageNum - (PageInfo.pageNum % PageInfo.pageSize)) / PageInfo.pageSize + 1;
	}
	return PageInfo;
}


function GetRowsJSon(model){
	model.Page2 = {};//alert(Serialize(model.Page));
	for(var P in model.Page){
		eval("model.Page2." + P + " = {}");
		for (var C in eval("model.Page." + P)){
			var json = eval("model.Page." + P + "." + C + ".Json");
			if(json.CtrlEvent.GetDataRows){
				json.GetDataRows = json.CtrlEvent.GetDataRows;
				json.GetDataRows();
			}
			//if(){
			var ResolveType = json.ResolveType;
			var DataID = json.DataID;//alert(DataID);
			//}
			//if(DataID && DataID.length > 0){
				//eval("model.Page2." + P + "." + C + " = {DataID:'" + DataID + "',ResolveType:'" + ResolveType + "'}");
			//}
			eval("model.Page2." + P + "." + C + " = {}");
			for(var Item in json.attType){//--查找数据类型为data的自定义属性
				if(eval("json.attType." + Item) == "data"){//alert(Item)
					var data = eval("json." + Item)//--获取需要解析的数据值
					data.getRows = getRows;//--事件绑定
					var Rows = data.getRows()//--获取格式化后的数据源列名称
					delete data;//--删除
					if(Rows.length != 0){
						eval("model.Page2." + P + "." + C + "." + Item + " = {DataID:'" + DataID + "',ResolveType:'" + ResolveType + "',Rows:'" + Rows + "'}");
					}
				}	
			}
		}
	}
	return model;
}

function ResolveForms(PageObj2,forms,sort1){
	var a1 = [];
	for(var p in PageObj2){
		for(var c in eval("PageObj2."+p)){
			for(var d in eval("PageObj2."+p+"."+c)){
				var a2 = [];
				a2.push(p);
				a2.push(c);
				a2.push(d);
				a2.push(eval("PageObj2."+p+"."+c+"."+d+".DataID"));
				a2.push(eval("PageObj2."+p+"."+c+"."+d+".ResolveType"));
				a2.push(eval("PageObj2."+p+"."+c+"."+d+".Rows"));
				a2 = a2.join("$$$");
				a1.push(a2);
			}
		}
	}
	a1 = a1.join("|||");
	//alert(a1.toString());
	DataStr = a1.toString();
	ajax.regEvent("ResolveForms");
	ajax.addParam("DataStr",DataStr);
	ajax.addParam("formid",forms);
	ajax.addParam("isSum",isSum);
	ajax.addParam("sort",sort1);
	var r = ajax.send();
	r = r.replace(/\r\n/g,"<br />").replace(/\n/g,"<br />");
	//alert(r);document.write(r);return false;
	eval("var FormDate = " + r);
	return FormDate;//alert()
}

function ResolveCode2(PageObj,forms,sort1){
	
}

//=========================================================================

//function GetPublicModel(id, sort, ModelType){
//	ajax.regEvent("");
//	ajax.addParam("sort",sort);
//	ajax.addParam("id",id);
//	ajax.addParam("ModelType", escape(ModelType));;
//	document.clear();
//	document.write(ajax.send());
//}


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

//判断录入必须是数字,参数idot为1/0,用于判断是否可以录入小数点
function checkOnlyNum(idot){
	if (idot==null){idot=0;}
	var char_code = window.event.charCode ? window.event.charCode : window.event.keyCode;
	if((char_code<48 || char_code >57) && (idot==0 || (idot=1 && char_code!=46))) {return false;}
}

//--条形码生成函数
//--参数：	C1Arr，条形码数据数组，形式：[{formid:2066,code1:{w:'1',d:'',code:'11010000100110110011001100011101011'}},…………]
//--		formid：单据ID
function CreateCode1(C1Arr,formid){
	var html = "<div align='center'>";
	html = html + "<center>";
	html = html + "<table border='0' cellpadding='0' cellspacing='0' style='display:inline-block;'>";
	html = html + "<tr>";
	html = html + "<td height='52' align='center'><table style='display:inline-block'><tr><td><div style='height:52px;overflow:hidden;white-space:nowrap'>@Code1@</div></td></tr></table></td>";
	html = html + "</tr>";
	html = html + "<tr>";
	html = html + "<td height='18' align='center' style='letter-spacing: 3;'>@Data@</td>";
	html = html + "</tr>";
	html = html + "</table>";
	html = html + "</center>";
	html = html + "</div>";
	var Code1 = "";
	var Data = "";
	var DrawWidth = 1;
	var C1HTML = "";
	var l = C1Arr.length;
	for(var i = 0; i < l; i++){
		if (C1Arr[i].formid == formid){
			Data = C1Arr[i].Code1.d;
			Code1 = C1Arr[i].Code1.code;
			DrawWidth = C1Arr[i].Code1.w;
			C1HTML = "<img src='../../../SYSN/view/init/home.ashx?__msgid=sys.fields.getbarcodeimage&width=&codetype=code128&code=" + Data + "&generatelabel=0&height=80'>"
			if (C1Arr[i].title){Data= C1Arr[i].title;}
		}
	}
	html = html.replace(/@Data@/g,Data).replace(/@Code1@/g,C1HTML);
	return html;
}
