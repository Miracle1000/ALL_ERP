function tu(obj){
    $(obj).addClass("toolitem").removeClass("toolitem_hover");
}

function tm(obj){
    $(obj).addClass("toolitem_hover").removeClass("toolitem");
}

//提示消息类
var tips = {
temp : {},
/***
* 弹出提示
*
* @param string msg 提示文字内容
* @param string id 要弹出提示的目标对象的id,如果id错误/null/false/0则主窗口弹出
* @param int time 定时消失时间毫秒数,如果为null/0/false则不定时
* @param string color 提示内容的背景颜色格式为#000000
* @param int width 提示窗宽度,默认300
*/
show : function(msg, id, time, color, width)
{
if(!tipsOpen) return false;
var target = this._get(id);
if(!target) { id = 'window'; }

//如果弹出过则移除重新弹出
if(this._get(id+'_tips')) { this.remove(id); }

//设置默认值
msg = msg || 'error';
color = color || '#ea0000';
width = width || 300;
time = time ? parseInt(time) : false;

if(id=='window') {
var y = document.body.clientHeight/2+document.body.scrollTop;
var x = (document.body.clientWidth-width)/2;
var textAlign = 'center', fontSize = '15',fontWeight = 'bold';
} else {
//获取对象坐标信息
for(var y=0,x=0; target!=null; y+=target.offsetTop, x+=target.offsetLeft, target=target.offsetParent);
var textAlign = 'left', fontSize = '12',fontWeight = 'bold';
}

//弹出提示
var tipsDiv = this._create({display:'block',position:'absolute',zIndex:'1001',width:(width-2)+'px',left:(x+10)+'px',padding:'5px',color:'#ffffff',fontSize:fontSize+'px',backgroundColor:color,textAlign:textAlign,fontWeight:fontWeight,filter:'Alpha(Opacity=70)',opacity:'0.3'}, {id:id+'_text', innerHTML:msg, onclick:function(){tips.hidden(id);}});
document.body.appendChild(tipsDiv);
tipsDiv.style.top = (y-tipsDiv.offsetHeight-2+10)+'px';
//document.body.appendChild(this._create({display:'block',position:'absolute',zIndex:'1000',width:(width+10)+'px',height:(tipsDiv.offsetHeight-2)+'px',left:x+'px',top:(y-tipsDiv.offsetHeight-11)+'px',backgroundColor:color,filter:'Alpha(Opacity=30)',opacity:'0.7'}, {id:id+'_bg'}));
/*
if(id!='window') {
var arrow = this._create({display:'block',position:'absolute',overflow:'hidden',zIndex:'999',width:'20px',height:'10px',left:(x+20)+'px',top:(y-13)+'px'}, {id:id+'_arrow'});
arrow.appendChild(this._create({display:'block',overflow:'hidden',width:'0px',height:'10px',borderTop:'10px solid '+color,borderRight:'10px solid #fff', borderLeft:'10px solid #fff',filter:'Alpha(Opacity=70)',opacity:'0.8'}));
document.body.appendChild(arrow);
}
*/
//标记已经弹出
this.temp[id] = id;

//如果定时关闭
if(time) { setTimeout(function(){tips.hidden(id);}, time) }

return id;
},
/***
* 隐藏提示
*
* @param string id 要隐藏提示的id,如果要隐藏主窗口提示id为window,如果要隐藏所有提示id为空即可
*/
hidden : function(id)
{
if(!tipsOpen) return false;
if(!id) { for(var i in this.temp) { this.hidden(i); } return; }
var t = this._get(id+'_text'), d = this._get(id+'_bg'), a = this._get(id+'_arrow');
if(t) { t.parentNode.removeChild(t); }
if(d) { d.parentNode.removeChild(d); }
if(a) { a.parentNode.removeChild(a); }
},
_create : function(set, attr)
{
var obj = document.createElement('div');
for(var i in set) { obj.style[i] = set[i]; }
for(var i in attr) { obj[i] = attr[i]; }
return obj;
},
_get : function(id)
{
return document.getElementById(id);
}
};

/*
document.onclick = function(){
if(!tipsOpen) return false;
tips.hidden();
}
*/

function showTips(tobj,flg)
{
	if(flg)
	{
		try{
			var trobj=tobj.parentElement.parentElement.parentElement.rows[0];
			var indexid = getRealColIdx(tobj);
			var tbobj = document.getElementById("headField_"+indexid);
			if(tbobj.tagName.toLowerCase()!="td"){indexid = indexid-1;};
			tbobj = document.getElementById("headField_"+indexid);
			var showtxt=tbobj.getElementsByTagName("div")[0].innerHTML;
			tips.show(showtxt,tobj.id,null,null,100);
		}catch(e){}
	}
	else
	{
		tips.hidden(tobj.id);
	}
}

function getRealColIdx(tdobj)
{
	var trobj=tdobj.parentElement;
	//edit by boyong 20121015
	var tbobj=tdobj.parentElement.parentElement.parentElement.rows[0];
	var colSpans=0;
	for(var i=0;i<tbobj.cells.length;i++)
	{
	    //先获取colSpan值
		if(tbobj.cells[i].colSpan>1){
		   colSpans=colSpans+(tbobj.cells[i].colSpan-1);
		}
	}
    colSpans=colSpans+i;
	//获得头部组合
	var headid=new Array(colSpans);
	var k=0;
	i=0;
	for(i;i<tbobj.cells.length;i++){
		if(tbobj.cells[i].colSpan>1){
		   headid[k]=i;
		   k++;
		   headid[k]=i;
		}else{
		   headid[k]=i;
		}
		k++;
	}
	for(var i=0;i<colSpans;i++)
	{
		if(trobj.cells[i]==tdobj){
			return i;
		}
	}
}


function Myopen(objid){ //根据传递的参数确定显示的层
	jQuery('#'+objid).toggle().css({
		left:310,top:10
	});
}

var xmlHttpNode = false;
try
{
  xmlHttpNode = new ActiveXObject("Msxml2.XMLHTTP");
}
catch (e)
{
  try
  {
    xmlHttpNode = new ActiveXObject("Microsoft.XMLHTTP");
  }
  catch (e2)
  {
    xmlHttpNode = false;
  }
}
if (!xmlHttpNode && typeof XMLHttpRequest != 'undefined')
{
  xmlHttpNode = new XMLHttpRequest();
}

function open1()
{
	//加try防止页面没有加载完成就点击该按钮
	try
	{
		$('#dd').window().dialog('open').show();
	}
	catch (e)
	{

	}
}

function OrderDialog()
{
	$('#FieldOrderSelect').show().dialog('open');
	if(top!=window)
	{
	    var bodyw = document.body.clientWidth;
	    if (document.getElementById("tableid")) {
	        if (bodyw < document.getElementById("tableid").offsetWidth*1) {
	            bodyw = document.getElementById("tableid").offsetWidth * 1;
	        }
	    }
	    var lpos = (bodyw - document.getElementById('FieldOrderSelect').offsetWidth) / 2;
		$('#FieldOrderSelect').dialog('move', { left: lpos, top: 100 });
		if(parent.document.getElementById('cFF'))
		{
				parent.document.getElementById('cFF').style.height=(parseInt(parent.document.getElementById('cFF').style.height)<600?600:document.body.offsetHeight)+"px";
		}
	}
}

function FieldDialog()
{
	$('#FieldSelected').show().dialog({}).dialog('open');
	if(top!=window)
	{
		var lpos=(document.body.clientWidth-document.getElementById('FieldSelected').offsetWidth)/2;
		$('#FieldSelected').dialog('move',{left:lpos,top:100});
		if(parent.document.getElementById('cFF'))
		{
				parent.document.getElementById('cFF').style.height=(parseInt(parent.document.getElementById('cFF').style.height)<600?600:document.body.offsetHeight)+"px";
		}
	}
	$('#FieldSelected').find("div").show();
}

function close1()
{
	$('#dd').dialog('close');
}

function hidField(chkobj,event)
{
	if(event.stopPropagation) {
		event.stopPropagation();
	} else {
		event.cancelBubble = true;
	};
	var jstarget=document.getElementsByTagName("table");
	var tbobj=null;
	for(var i=0;i<jstarget.length;i++)
	{
		var jsflg = jstarget[i].getAttribute("jsflg");
		if(jsflg=="1")
		{
			tbobj=jstarget[i];
			break;
		}
	}
	//更新排序列的显示与隐藏
	var keyId = chkobj.getAttribute("value2");
	document.getElementById("sortcol_" + keyId).style.display = chkobj.checked ? "" : "none";

	//edit by boyong 20121023 此处用于判断是否有分表头
	var colSpans=0;
	for(var i=0;i<tbobj.rows[0].cells.length;i++)
	{
	    //先获取colSpan值
		if(tbobj.rows[0].cells[i].colSpan>1){
		   colSpans=colSpans+1;
		}
	}
	
	for(var i=0;i<tbobj.rows.length;i++)
	{
		
	  if(colSpans==0){///////原条件，无分拆
		  if(i==0) tbobj.rows[i].cells[parseInt(chkobj.value)].style.width=tbobj.rows[i].cells[parseInt(chkobj.value)].getElementsByTagName("div")[0].innerText.length*18+"px";
			try
			{
				tbobj.rows[i].cells[parseInt(chkobj.value)].style.display=chkobj.checked?"":"none";
			}
			catch(e){}
	  }else{////////////////////////条件二，有分拆情况出现
		if(i>1){
		try
		{
			tbobj.rows[i].cells[parseInt(chkobj.value)].style.display=chkobj.checked?"":"none";
		}
		catch(e){}
		}else{

		try{
			if(i==0){
				var c=document.getElementById("headField_"+parseInt(chkobj.value));
				if(chkobj.checked){
				   //选中状态
				   if(c){}else{location.reload();}
				   if(isNaN(c.colSpan)){ //是不是没有表头
				         var b=document.getElementById("headField_"+(parseInt(chkobj.value)-1));
						 if(!isNaN(b.colSpan)){
						   if(document.getElementById("headField_"+(parseInt(chkobj.value)-1)).style.display=="none"){
						   document.getElementById("headField_"+(parseInt(chkobj.value)-1)).style.display="";
						   }else{
						 	b.colSpan=b.colSpan+1;}
						 }else{
						  document.getElementById("headField_"+(parseInt(chkobj.value)-1)).style.display="";
						 }
				   }else{//有表头情况,此处有两种
					  if((parseInt(chkobj.value)+1)>i){
					     if(document.getElementById("headField_"+parseInt(chkobj.value)).style.display==""){
							 var b=document.getElementById("headField_"+(parseInt(chkobj.value)+1));
						 }else{
							 var b=document.getElementById("headField_"+(parseInt(chkobj.value)));//通常最后二行相同，因此简单处理
						 }
					  }else{ //如果不是最后一行
				      var b=document.getElementById("headField_"+(parseInt(chkobj.value)+1));
					  }
					  if(isNaN(b.colSpan)){
					    if(document.getElementById("headField_"+parseInt(chkobj.value)).style.display=="none"){
						  document.getElementById("headField_"+parseInt(chkobj.value)).style.display="";
						}else{
						var e=document.getElementById("headField_"+(parseInt(chkobj.value)));
						e.colSpan=e.colSpan+1;
						}
					  }else{
					 document.getElementById("headField_"+parseInt(chkobj.value)).style.display="";
					 document.getElementById("headField_"+parseInt(chkobj.value)).style.width="80px";
					 }
				   }
				}else{
				   //隐藏状态
				   if(c.colSpan>1){
				   		c.colSpan=c.colSpan-1;
				   }else{
					   if(isNaN(c.colSpan)){//如果表头已经合并，看前一个有没有，有则处理
						 var b=document.getElementById("headField_"+(parseInt(chkobj.value)-1));
						 if((b.colSpan>1)){ b.colSpan=b.colSpan-1;}else{
						  document.getElementById("headField_"+(parseInt(chkobj.value)-1)).style.display="none";
						 }
					   }else{
						 
					     document.getElementById("headField_"+parseInt(chkobj.value)).style.display="none";
					   }
				   }

				}
			}else if(i==1){
			 document.getElementById("headField_child"+parseInt(chkobj.value)+"_1").style.display=chkobj.checked?"":"none";
			}
		}catch(e){}

	 	}

	}
		//如果没有记录的话，需要改变第二行的colspan属性，否则会出现黑格
		if(tbobj.rows.length<3&&i==1)
		{
			var cLength=0;//计算有多少列是可见的,以此来给colspan属性赋值
			for(var j=0;j<tbobj.rows[0].cells.length;j++){if(tbobj.rows[0].cells[j].style.display!="none") cLength++;}
			tbobj.rows[i].cells[0].colSpan=cLength;
		}
	}

	if(colSpans==0){
	var trobj=tbobj.rows[0];88
	}else{ //有分拆情况
	var trobj=tbobj.rows[2];88
	}
	var introvalue="";

	var ckboxs = document.getElementById("visibleCol").getElementsByTagName("input")
	for(var i=0;i<ckboxs.length;i++)
	{
		var box = ckboxs[i]
		if(box.type=="checkbox" && box.checked) {
			introvalue+=(introvalue==""? box.getAttribute("value2") : "," + box.getAttribute("value2"))
		}
	}

 	var url = "../store/SaveShowFields.asp?o=" + mFieldsSettingIndex + "&s="+escape(introvalue)+"&"+Math.round(Math.random()*100);
	xmlHttpNode.open("GET", url, true);
	xmlHttpNode.setRequestHeader("If-Modified-Since","0");
	xmlHttpNode.onreadystatechange = function(){
		if (xmlHttpNode.readyState == 4)
		{
			if(xmlHttpNode.responseText!=1) {
				alert("设置失败");
			}else{
					var cookieWidth="";
					for(var tri=0;tri<trobj.cells.length;tri++)
					{
						cookieWidth+=cookieWidth==""?trobj.cells[tri].offsetWidth:","+trobj.cells[tri].offsetWidth;
					}
					SetCookie("cookieWidth_" + mFieldsSettingIndex + "",cookieWidth);
			}
			xmlHttpNode.abort();
		}
	}
	xmlHttpNode.send(null);
	if (window.OtherhidField) { window.OtherhidField();}
}

var currentResizeTdObj=null;
function MouseDownToResize(event,obj)
{
	obj=obj||this;
	event=event||window.event;
	currentResizeTdObj=obj;
	obj.mouseDownX=event.clientX;
	obj.mouseDownY=event.clientY;
	obj.tdW=obj.offsetWidth;
	obj.tdH=obj.offsetHeight;
	if(obj.setCapture)
	{
		obj.setCapture();
	}
	else
	{
		event.preventDefault();
	}
}
function MouseMoveToResize(event)
{
	if(!currentResizeTdObj) return ;
	var obj=currentResizeTdObj;
	event=event||window.event;
	if(!obj.mouseDownX) return false;
	if(obj.parentNode.rowIndex==0)
	{
		var newWidth=obj.tdW*1+event.clientX*1-obj.mouseDownX;
		if(newWidth>0) obj.style.width = newWidth+"px";
		else obj.style.width =1+"px";
	}
/*
	if(obj.cellIndex==0)
	{
		var newHeight=obj.tdH*1+event.clientY*1-obj.mouseDownY;
		if(newHeight>0) obj.style.height = newHeight;
		else obj.style.height =1;
	}
*/
}

function MouseUpToResize()
{
	if(!currentResizeTdObj) return;
	if (currentResizeTdObj.releaseCapture)
	{
		currentResizeTdObj.releaseCapture();
		var trobj=currentResizeTdObj.parentElement;
		var cookieWidth="";
		for(var tri=0;tri<trobj.cells.length;tri++)
		{
			cookieWidth+=cookieWidth==""?trobj.cells[tri].offsetWidth:","+trobj.cells[tri].offsetWidth;
		}
		SetCookie("cookieWidth_" + mFieldsSettingIndex + "",cookieWidth);
	}
	currentResizeTdObj=null;
}

//改变表格行列宽函数
function ResizeTable_Init(table,needChangeWidth,needChangeHeight)
{
	if(!needChangeWidth && !needChangeHeight)	return;
	var oTh=table.rows[0];
	if(needChangeWidth)
	{
		for(var i=0;i<oTh.cells.length;i++)
		{
			var cell=oTh.cells[i];
			cell.style.cursor="e-resize";
			cell.style.width=cell.offsetWidth+"px";
			cell.onmousedown =MouseDownToResize;
		}
	}
	/*
	if(needChangeHeight)
	{
		for(var j=0;j<table.rows.length;j++)
		{
			var cell=table.rows[j].cells[0];
			cell.style.cursor="s-resize";
			cell.onmousedown =MouseDownToResize;
		}
	}
	if(needChangeWidth && needChangeHeight) oTh.cells[0].style.cursor="se-resize";
	*/
	table.style.width=null;
	table.style.tableLayout="fixed";
}

//获得Cookie解码后的值
function GetCookieVal(offset)
{
	var endstr = document.cookie.indexOf (";", offset);
	if (endstr == -1)	endstr = document.cookie.length;
	return unescape(document.cookie.substring(offset, endstr));
}

//---------------------------
//设定Cookie值
function SetCookie(name,value)
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
//删除Cookie
function DelCookie(name)
{
	var exp = new Date();
	exp.setTime (exp.getTime() - 1);
	var cval = GetCookie (name);
	document.cookie = name + "=" + cval + "; expires="+ exp.toGMTString();
}

//------------------------------------
//获得Cookie的原始值
function GetCookie(name)
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

objid=function(id){return (typeof(id)=='object')?id:document.getElementById(id);}

function URLencode(sStr)
{
	return escape(sStr).replace(/\+/g, '%2B').replace(/\"/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F');
}

function urlSubmit(frmobj)
{
	var wch = true
	var fobj=frmobj==undefined?document.getElementById('dd'):frmobj;
	var formpara="";
	//查找INPUT，保存其值
	var obj=fobj.getElementsByTagName("input");
	for(var i=0;i<obj.length;i++)
	{
		//增加校验功能 2012.10.24.tan
		var oitem = obj[i];
		var msg = ""; //校验不成功显示的消息
		var rule = oitem.getAttribute("rule");	//校验规则
		if(rule && rule.length > 0)
		{
			try{
				var me = oitem;	//用关键字me表示当前元素
				if(!eval(rule)) { wch = false; }
				msg = oitem.getAttribute("msg");
			}
			catch(e) {
				wch = false
				msg = e.message;
			}
			var id  = "for_" + oitem.name  + "_" + oitem.id;
			var msgpanel = document.getElementById(id);
			if(!msgpanel)
			{
				msgpanel=document.createElement("Span");
				msgpanel.id = id;
				msgpanel.style.cssText = "color:red;font-size:12px";
				oitem.parentNode.insertBefore(msgpanel, oitem.nextSibling);
			}
			msgpanel.innerHTML = msg;
			msgpanel.style.display = wch ? "none" : "inline";
		}
		//校验结束;
		if(wch==true)
		{
			if(oitem.name&&oitem.name.indexOf('showFields')!=0&&!oitem.Searchflg&&(((oitem.type=="checkbox"||oitem.type=="radio")&&oitem.checked)||((oitem.type=="text"||oitem.type=="hidden")&&oitem.value!="")))
			{
				formpara+=(formpara==""?"":"&")+oitem.name+"="+URLencode(oitem.value);
			}
		}
	}
	if (wch == false)
	{
		return false;
	}
	var obj=fobj.getElementsByTagName("select");
	for(var i=0;i<obj.length;i++)
	{
		if(obj[i].value) formpara+=(formpara==""?"":"&")+obj[i].name+"="+URLencode(obj[i].value);
	}
	window.location= script_name + "?"+formpara;
}

function UpFieldOrder(linkobj,flg)
{
	var trobj=linkobj.parentElement.parentElement.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	if(flg)
	{
		var rIdx=trobj.rowIndex;
		var i=rIdx;
		var row = tbobj.rows[i];
		while(--i>=0&&row.getAttribute("mflg")!="1"){}
		if(i>=0)
		{
			try{
				tbobj.rows[i].swapNode(trobj);
			}catch(e){
				swapNode(tbobj.rows[i],trobj);
			}
			$(trobj).trigger("mouseout");
		}
	}
	else
	{
		var rIdx=trobj.rowIndex;
		var i=rIdx;
		var row = tbobj.rows[i];
		while(++i<tbobj.rows.length&&row.getAttribute("mflg")!="1"){}
		if(i<tbobj.rows.length)
		{
			try{
				tbobj.rows[i].swapNode(trobj);
			}catch(e){
				swapNode(tbobj.rows[i],trobj);
			}
			$(trobj).trigger("mouseout");
		}
	}
}

function SaveFieldOrder(act)
{
	var dvobj=document.getElementById("FieldOrderSelect");
	var tbobj=dvobj.getElementsByTagName("table")[0];
	var strFieldOrder="";
	for(var i=0;i<tbobj.rows.length;i++)
	{
		if(act=="save")
		{
			//strFieldOrder+=(strFieldOrder==""?"":",")+tbobj.rows[i].mvalue;
			strFieldOrder+=(strFieldOrder==""?"":",")+tbobj.rows[i].getAttribute("mvalue");
		}
		else if(act=="reset")
		{
			strFieldOrder+=(strFieldOrder==""?"":",")+i
		}
	}
	var url = "../store/SaveShowFields.asp?o=" + (10000+mFieldsSettingIndex*1) + "&s="+escape(strFieldOrder)+"&"+Math.round(Math.random()*100);
	xmlHttpNode.open("GET", url, false);
	xmlHttpNode.onreadystatechange = function(){
		if (xmlHttpNode.readyState == 4){
			xmlHttpNode.abort();
			DelCookie('cookieWidth_' + mFieldsSettingIndex + '');  //清除列宽记录
			$('#FieldOrderSelect').window('close'); //关闭设置窗口
			window.location.replace(window.location.href.replace("###",""));//重新载入页面
		}
	}
  	xmlHttpNode.send();
}

function setSort(linkobj,sorttype)
{
	var lobj=linkobj.parentElement.getElementsByTagName("a");
	if(linkobj.style.color=="red")
	{
		linkobj.style.color="#2F496E";
	}
	else
	{
		for(var i=0;i<lobj.length;i++)
		{
			lobj[i].style.color=lobj[i]==linkobj?"red":"#2F496E";
		}
	}

	var trobj=linkobj.parentElement.parentElement;
	var spobj=trobj.getElementsByTagName("span")[0];
	spobj.style.color="black";
	for(var i=0;i<lobj.length;i++)
	{
		if(lobj[i].style.color=="red")
		{
			spobj.style.color="red";
			return;
		}
	}
}

function DoSort(tbobj)
{
	var lobj=tbobj.getElementsByTagName("a");
	var strpx="";
	for(var i=0;i<lobj.length;i++)
	{
		if(lobj[i].style.color=="red")
		{
			strpx+=(strpx==""?"":"_")+lobj[i].getAttribute("svalue")+"-"+lobj[i].getAttribute("stype");
		}
	}
	gotourl('px='+strpx);
}

function chgOrder(linkobj,flg)
{
	var trobj=linkobj.parentElement.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	var tridx=trobj.rowIndex;
	if(flg==1&&tridx>0)
	{
		tbobj.rows[tridx-1].swapNode(trobj);
	}
	else if(flg==0&&tridx<tbobj.rows.length-2)
	{
		tbobj.rows[tridx+1].swapNode(trobj);
	}
}
