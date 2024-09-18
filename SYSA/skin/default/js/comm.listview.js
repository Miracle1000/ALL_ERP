function __lv_recolsize(th, t){
	var cur = th.style.cursor;
	var x = window.event.offsetX;	
	if(t==0) {  //mousemove
		var w = th.offsetWidth;	
		if(th.getAttribute("moveing")=="1") { //移动中
			return;
		}
		if(x<4||(w-x)<4) {
			if(x<4) {
				var vth = th;
				if(th.className.indexOf("lvwheader")==-1) { 
					vth = app.getParent(th,4); 
				}
				if(vth.getAttribute("cindex")=="1") {return;}
				if(vth.previousSibling==null) {return;}
			}
			if(th.getAttribute("defaultCursor")==null) {
				th.setAttribute("defaultCursor", cur);
			}
			if(cur!="col-resize") { th.style.cursor = "col-resize"; }
		}else{
			var defcur = th.getAttribute("defaultCursor");
			if(defcur!=null) { if(cur!=defcur) {th.style.cursor = defcur;} }
		}
		return;
	}
	if(t==1) { //mousedown	
		if(cur!="col-resize") { return; }
		var sc = th;
		th.setAttribute("moveing","1");
		var spliterdiv = document.getElementById("lvw_spliterdiv");
		if(!spliterdiv) {
			spliterdiv = document.createElement("div");
			spliterdiv.id = "lvw_spliterdiv";
			spliterdiv.style.cssText = "position:absolute;display:none;width:3px;overflow:hidden;background-color:#0000aa;height:100px;cursor:col-resize;";
			document.body.appendChild(spliterdiv);
		}
		if(th.className.indexOf("lvwheader")==-1) { th = app.getParent(th,4); }
		var tb = app.getParent(th,3);
		var xy = GetObjectPos(th,1);
		var xy2 = GetObjectPos(tb,1);
		window.__lvw_colrse_init_bgscoll = (document.body.scrollLeft>0?document.body.scrollLeft:document.documentElement.scrollLeft);
		spliterdiv.style.top = xy2.top + "px";
		spliterdiv.style.left = ((xy.left + ( (x < 4) ? 0 : th.offsetWidth ) - 2) + window.__lvw_colrse_init_bgscoll) + "px";
		spliterdiv.style.height = (tb.offsetHeight-2) + "px";
		spliterdiv.style.display = "block";
		window.__lvw_colrse_tb = tb;
		var cols = tb.getElementsByTagName("col");
		if(x < 5) {
			window.__lvw_colrse_cindex =  th.getAttribute("cindex")*1-1;
			var pth = th.previousSibling;
			if(pth && pth.style.display == "none") {
				window.__lvw_colrse_cindex--;
			}
			if(window.__lvw_colrse_cindex-1<0) {return;}
			var col = cols[window.__lvw_colrse_cindex-1];
			var cw =  col.style.width;
			if(isNaN(cw.replace("px",""))==false && cw.length > 0) {
				window.__lvw_colrse_init_width =  col.style.width.replace("px","")*1;
			}else {
				window.__lvw_colrse_init_width =  parseInt(pth.offsetWidth/pth.colSpan);
			}
		}
		else{
			window.__lvw_colrse_cindex =  th.getAttribute("cindex")*1+th.colSpan-1;
			var col = cols[window.__lvw_colrse_cindex-1];
			var cw =  col.style.width;
			if(isNaN(cw.replace("px",""))==false && cw.length > 0) {
				window.__lvw_colrse_init_width =  col.style.width.replace("px","")*1;
			} else {
				window.__lvw_colrse_init_width =  parseInt(th.offsetWidth/th.colSpan);
			}
		}
		window.__lvw_colrse_init_x = window.event.clientX;
		window.__lvw_colrse_init_left = spliterdiv.style.left.replace("px","")*1;
		window.event.returnValue = false;
		window.event.cancelBubble=true;
		app.beginMoveElement(sc, 
			function() { //moving
				var cx = window.event.clientX;
				var xt = cx - window.__lvw_colrse_init_x;
				if(window.__lvw_colrse_init_width + xt<0) {
					 xt = - window.__lvw_colrse_init_width;
				}
				var spliterdiv = document.getElementById("lvw_spliterdiv");
				if(spliterdiv) {
					spliterdiv.style.left = (window.__lvw_colrse_init_left + xt) + "px";
				}
			},
			function () { //move end
				var spliterdiv = document.getElementById("lvw_spliterdiv");
				if(spliterdiv) {
					spliterdiv.style.display = "none";
				}
				sc.setAttribute("moveing","0");
				if(sc.getAttribute("defaultCursor")) { sc.style.cursor  = sc.getAttribute("defaultCursor"); }
				var cx = window.event.clientX;
				var xt = cx - window.__lvw_colrse_init_x;
				if(xt!=0) {
					__lvw_setNewColWidth(xt);
					var tbdiv = app.getParent(th,3);
					var id = tb.id.replace("lvw_dbtable_","");
					__lvw_handlescrolbar(tbdiv, id);
				}
				window.__lvw_colrse_init_x = 0;
				window.__lvw_colrse_init_left = 0;
				window.__lvw_colrse_tb = null;
				window.__lvw_colrse_cindex = -1;
			} 	
		);
	}
}
function __lvw_setNewColWidth(xt) {
	if(window.__lvw_colrse_init_width + xt < 0 ) { xt = -window.__lvw_colrse_init_width;} 
	var tb = window.__lvw_colrse_tb;
	if (tb==null){return;}
	var colcount = 0;
	var cells = tb.rows[0].cells;
	var cols = tb.getElementsByTagName("col");
	var ci = 0;
	var col = null;
	var nw = 0;
	for (var i = 0 ; i < cells.length ; i++)
	{
		var th = cells[i];
		var v = (th.style.display!="none");
		for (var ii =  ci; ii < ci+th.colSpan ; ii ++ )
		{	
			col = cols[ii];
			if (col)
			{		
				if(isNaN(col.style.width.replace("px","")) || col.style.width=="") {
					var iw = th.offsetWidth;
					iw = iw<12 ? 12 : iw;
					col.style.width = (v ? (parseInt(iw/th.colSpan)-1) : 0) + "px" ; 
				} 
				nw = nw + col.style.width.replace("px","")*1 //+th.colSpan;
			}
		}
		ci = ci + th.colSpan;
	}
	if(tb.getAttribute("colresized")==null || tb.getAttribute("colresizedr")==null) {
		tb.setAttribute("colresized","1");
		tb.setAttribute("colresizedr","1");
		for (var i = 0; i< tb.getAttribute("maxheads")*1; i++ )
		{
			var cells = tb.rows[i].cells;
			for (var ii = 0; ii < cells.length ; ii++ )
			{
				cells[ii].style.width = "";
			}
		}
	}
	tb.style.tableLayout = "fixed";
	col = cols[window.__lvw_colrse_cindex-1];
	col.style.width = (window.__lvw_colrse_init_width + xt) + "px";
	tb.style.width = (nw + xt) + "px";
	var div = tb.parentNode.parentNode.parentNode;
	if(div.getAttribute("jEM")!="1"){
		tb.parentNode.style.width = (tb.offsetWidth + 1) + "px";
		div.style.width =  ( tb.offsetWidth + 1) + "px";
	}
	window.__lvw_lastSetcolwT = (new Date()).getTime();
	ajax.regEvent("sys_lvw_SavelvwColwidth");
	ajax.addParam("key16", tb.getAttribute("key16"));
	ajax.addParam("cols",  cols.length);
	ajax.addParam("allw",  div.style.width.replace("px",""));
	for (var i = 0; i < cells.length ; i ++ )//cols可能含有嵌套表格的列所以用cells代替
	{
		ajax.addParam("dbname_" +(i+1), cols[i].getAttribute("dbname"));
		ajax.addParam("width_" +(i+1), cols[i].style.width.replace("px",""));
	}
	ajax.send(function(rx){});
}
function getcolresizedV(id) {
	var tb = document.getElementById("lvw_dbtable_" + id);
	if(tb.getAttribute("colresized")=="1") {
		var  data = new Array();
		var cols = tb.getElementsByTagName("col");
		for (var i = 0; i < cols.length ; i ++ )
		{
			var c = cols[i];
			var db = c.getAttribute("dbname");
			if(c.getAttribute("dbname") =="" && i==0) {
				db = "[!sfd]";
			}
			data[i] =  db + "=" + c.style.width.replace("px","");
		}
		return data.join(";");
	}else {return "";}
}
function __lvw_expheader(mtype,xpName,lvwId)
{var vstate=$ID("__viewstate_lvw_"+lvwId)
if(!vstate){alert("无法获取列表的状态数据");return}
ajax.regEvent("sys_lvw_callback");
ajax.addParam2("backdata",vstate.value);
ajax.addParam("resized",getcolresizedV(lvwId));
__lvw_AutoAppendUrlParams(lvwId);
$ap("cmd","lvwHeaderExplan");
$ap("xpName",xpName);
$ap("mtype",mtype);
$ID("lvw_"+lvwId).innerHTML=ajax.send();
if(window.onlistviewRefresh){window.onlistviewRefresh(lvwId);}
__lvw_autoListWidth(lvwId);}
function __lvwsort(tag,t,id){var newt=(t==0?1:(t==1?2:1));
if(window.__lvw_lastSetcolwT) {
	if((new Date()).getTime()-window.__lvw_lastSetcolwT <500) { return ;}
}
if(window.event.srcElement.style.cursor=="col-resize") {return;}
//var sorttext=$ID("__sortstate_lvw_"+id).value.split(","); 注释掉，去掉同时排序功能
var sorttext = new Array();
var dbname="["+tag.getAttribute("dbname")+"]";
var newst=new Array();
newst[0]=dbname +(newt==2?" desc":"")
for(var i=0;i< sorttext.length;i++)
{if(sorttext[i]!=dbname&&sorttext[i].indexOf(dbname+" ")<0)
{if(sorttext[i].length>0)
{newst[newst.length]=sorttext[i];}}}
if(dbname.indexOf("</")>0&&dbname.indexOf(">")>0)
{return false;}
sorttext=newst.join(",");
var vstate=$ID("__viewstate_lvw_"+id)
if(!vstate){alert("无法获取列表的状态数据");return}
ajax.regEvent("sys_lvw_callback");
ajax.addParam("resized",getcolresizedV(id));
__lvw_AutoAppendUrlParams(id);
ajax.addParam2("backdata",vstate.value);
$ap("cmd","lvwsortevent");
$ap("value",sorttext);
$ap("dbname",dbname);
$ap("dbsort",newt);
var div = $ID("lvw_"+id);
var pmsg = div.getAttribute("cbWaitMsg");pmsg = pmsg?pmsg: "";
ajax.send(function(r){__lvw_callbackUpdateView(id,r);if(window.onlistviewRefresh){window.onlistviewRefresh(id);}},pmsg);}
function __lvw_callbackUpdateView(id, r) {
	var div = $ID("lvw_"+id);
	if(div.getAttribute("jEM")==1) {
		eval("window.lvw_JsonData_"+id + "=" + r);
		var lvw = eval("window.lvw_JsonData_"+id);
		___RefreshListViewByJson(lvw)	
	} else {
		$ID("lvw_"+id).innerHTML=r
	}
}
function __lvw_tabonresize(listtb,id) {
	if(listtb.clientHeight>=listtb.scrollHeight) {
		if(window.scrollHwnd && window.scrollHwnd>0){
			window.clearTimeout(window.scrollHwnd); 
		}
		listtb.scrollTop = 0;	
		setTimeout(function(){
			var tbs = listtb.children;
			if(tbs.length>0) {
				var tb = tbs[0];
				var maxh =  tb.getAttribute("maxheads");
				for (var i = 0; i < maxh ; i++)
				{
					var row = tb.rows[i];
					for (var ii = 0; ii< row.cells.length; ii++)
					{
						row.cells[ii].style.visibility = "visible";
						row.cells[ii].style.top = "1px";
					}
				}
			}
		},10);
		return;
	}
}

//创建固定表头
function createFixHeader(id, listtb, scrollType) {
	if(listtb.clientHeight>=listtb.scrollHeight) {
		return;
	}
	var div = $ID(listtb.id + "_tmp");
	var vtimeout = (600 + (scrollType==0 ? 700 : 0))*1;
	var currScrollType = listtb.getAttribute("scrollType");
	currScrollType = currScrollType == null ? -1 : currScrollType*1;
	listtb.setAttribute("scrollType", scrollType);
	if(div && currScrollType==scrollType) {
		if(window.scrollHwnd && window.scrollHwnd>0){ window.clearTimeout(window.scrollHwnd); }
		window.scrollHwnd = window.setTimeout("__lvw_clearFixedTempHead($ID('" + listtb.id + "'))", vtimeout);
		return false;
	}
	if(div) { div.parentNode.removeChild(div); } 
	var fixCell=listtb.getAttribute("fixedCell");
	div = document.createElement("div");
	div.id = listtb.id + "_tmp";
	div.onscroll = null;
	var sTop = listtb.scrollTop;
	var sLeft = listtb.scrollLeft;
	var rowspans = new Array();
	for (var i=0; i < fixCell; i++) { rowspans[i]=0 }
	var tb = listtb.getElementsByTagName("table")[0];	
	var maxh = tb.getAttribute("maxheads");
	if(scrollType==1) {
		//横向复制HTML
		var html = "<table class='" + tb.className + "' style='" + tb.style.cssText + "'>"
		for (var i = 0; i < maxh ; i ++ )
		{
			 html += tb.rows[i].outerHTML.replace(/visibility\:/,"a:"); 

		}
		html += "</table>";
		div.innerHTML = html;
		var ltb = div.children[0];
		for (var i = 0; i < ltb.rows.length ; i ++ )
		{
			var tr = ltb.rows[i];
			tr.cells[tr.cells.length-1].style.borderRight = "0px";
		}
		var h = tb.rows[maxh].offsetTop;
		var dbg = $ID("lvw_tablebg_" + id);
		var hsvscroll = ((dbg.scrollHeight - dbg.offsetHeight) > 5)
		div.style.cssText = "background-color:#fff;zoom:1;height:" + (h*1+1) + "px;width:" + (listtb.offsetWidth-17*hsvscroll-(app.IeVer==7?1:0)) + "px;overflow:hidden;position:absolute;top:1px;left:1px;z-index:500;border-right:" + (hsvscroll == 0 ? "1":"0") + "px solid #aaa";
		try{
			if(ltb.style.width=="100%") {
				ltb.style.width = (div.style.width.replace("px","")*1+17)+ "px";
			}
			else{
				ltb.style.width = (ltb.style.width.replace("px","")-1)+ "px";
			}
		}catch(e){}
	}
	else{
		//纵向复制HTML
		var html = "<table class='" + tb.className + "' style='" + tb.style.cssText + "'><!--fixcolwidths-->"
		var allw = 0;
		var colws = new Array();
		for (var i = 0; i < tb.rows.length; i++)
		{	
			var row = tb.rows[i];
			var isbreak = false;
			html += "<tr>"
			for (var ii = 0; ii< fixCell; ii++)
			{
				if(rowspans[ii]<=0) {
					var c = row.cells[ii];
					if(c.colSpan > 1) {isbreak = true; break;}
					if(c.rowSpan>1) { rowspans[ii]=rowspans[ii]+c.rowSpan-1; }
					html += c.outerHTML.replace("style=\"", "style=\"height:" + (c.offsetHeight-2) + "px;");
					if(i == 0 ) {
						allw = row.cells[ii+1].offsetLeft > allw ? row.cells[ii+1].offsetLeft : allw; 
						colws[colws.length] ="<col style='width:" + c.offsetWidth + "px;'>";
					}
				}
				else{
				  rowspans[ii] = rowspans[ii]-1;
				}
			}
			html += "</tr>"
			if(isbreak) {break;}
		}
		html += "</table>";
		div.innerHTML = html.replace("<!--fixcolwidths-->", colws.join(""));
		div.children[0].style.width = allw + "px";
		div.children[0].style.backgroundImage = "url()";
		div.style.cssText = "background:#93ffff url(" + window.virpath + "images/m_table_top.jpg) repeat-x;zoom:1;width:px;height:" + (listtb.offsetHeight-18) + "px;overflow:hidden;position:absolute;top:1px;left:0px;z-index:500;";
	}
	$ID("lvw_" + id).appendChild(div);
	if(fixCell>0) { __lvwscrollfixedTopLeft(id, listtb, scrollType, fixCell, maxh); }
	if(scrollType==1) {
		div.scrollLeft = listtb.scrollLeft;
	}
	else {
		div.scrollTop = listtb.scrollTop;
	}
	
	if(window.scrollHwnd && window.scrollHwnd>0){ window.clearTimeout(window.scrollHwnd); }
	window.scrollHwnd = window.setTimeout("__lvw_clearFixedTempHead($ID('" + listtb.id + "'))", vtimeout);
	return true;
}

//创建左上角的固定区域
function __lvwscrollfixedTopLeft(id, listtb, scrollType, fixCell, maxh) {
	var tbdiv = $ID(listtb.id + "_tmp");
	var div = $ID(tbdiv.id + "_fixtopleft");
	if(div) {
		div.style.display = "block";
		if(div.getAttribute("cacheHtml")) {
			div.innerHTML = div.getAttribute("cacheHtml");
			return;
		}
	}
	else{
		div = document.createElement("div");
		div.id = tbdiv.id + "_fixtopleft";
		div.onscroll = null;
	}
	div.innerHTML = tbdiv.innerHTML;
	var w = tbdiv.offsetWidth;
	var h = tbdiv.offsetHeight;
	var tb = listtb.getElementsByTagName("table")[0];
	if(scrollType==1) {
		//竖向滚动
		w = tb.rows[0].cells[fixCell*1].offsetLeft;
	}
	else{
		h = tb.rows[maxh].cells[0].offsetTop;
	}
	var tb = div.children[0];
	for (var i = 0; i < tb.cells.length ; i ++ )
	{
		tb.cells[i].style.visibility = "visible";
	}
	div.style.cssText = "background-color:#ffc999;zoom:1;height:" + h + "px;width:" + w + "px;overflow:hidden;position:absolute;top:1px;left:0px;z-index:600;";
	$ID("lvw_" + id).appendChild(div);
}

//清除列表的固定表头缓存HTML
function __lvw_clearFixedTempHead(tbdiv) {
	var scrollType = tbdiv.getAttribute("scrollType")*1;
	tbdiv.removeAttribute("scrollType");
	var tb = tbdiv.getElementsByTagName("Table")[0];
	var maxh =  tb.getAttribute("maxheads");
	if(scrollType==1) {
		for (var i = 0; i < maxh ; i++)
		{
			var row = tb.rows[i];
			for (var ii = 0; ii< row.cells.length; ii++)
			{
				row.cells[ii].style.visibility = "visible";
			}
		}
	}
	else{
		var rowspans= new Array()
		var fixCell=tbdiv.getAttribute("fixedCell");
		for (var i=0; i < fixCell; i++) { rowspans[i]=0 }
		for (var i = 0; i < tb.rows.length && scrollType==0; i++)
		{
			var row = tb.rows[i];
			for (var ii = 0; ii< fixCell; ii++)
			{
				if(rowspans[ii]<=0) {
					var c = row.cells[ii];
					if(c.rowSpan>1) { rowspans[ii]=rowspans[ii]+c.rowSpan-1; }
					c.style.visibility = "visible";
				}
				else{
				  rowspans[ii] = rowspans[ii]-1;
				}
			}
		}
	}
	var id = tbdiv.id + "_tmp";
	if(!$ID(id)) { return ; }
	var pnode = $ID(id).parentNode;
	pnode.removeChild($ID(id));
	var rjdiv = $ID(id + "_fixtopleft");
	if(rjdiv) {rjdiv.setAttribute("cacheHtml", rjdiv.innerHTML); rjdiv.innerHTML = ""; rjdiv.style.display = "none";}
}

//捕捉鼠标屏蔽事件
function __lvwscrollousewheel(tbdiv, isjemode) {
	if(isjemode==1){ return __lvwJeScroll(tbdiv); } //编辑模式
	if(tbdiv.scrollHeight == tbdiv.offsetHeight + (app.IeVer==6?1:0)) {return true;}  //如果区域高度等于固定条高度，则不需要滚动条
	if( tbdiv.getAttribute("fixh") == 0 ) { return true; } //列表区域的高度是否是固定的。
	var id = tbdiv.id.replace("lvw_tablebg_","");
	var result = !createFixHeader(id, tbdiv, 1);
	if(result==false) { __hideListFixheader(tbdiv); }
	return result;
}
//隐藏需要固定列的实际列数据；
function __hideListFixheader(tbdiv) {
	var tb = tbdiv.getElementsByTagName("Table")[0]; //table
	var maxh = tb.getAttribute("maxheads");
	for (var i = 0; i < maxh ; i++)
	{
		var row = tb.rows[i];
		for (var ii = 0; ii< row.cells.length; ii++)
		{
			row.cells[ii].style.visibility = "hidden";
		}
	}
}

function __lvwdisMiddleBtn(div) {
	//屏蔽中键，防止同时左右滚动，导致表格错位。
	if(window.event.button==4) {
		var oX = div.style.overflowX;
		var oY = div.style.overflowY;
		div.style.overflowX = "hidden";
		div.style.overflowY = "hidden";
		setTimeout(function(){
			div.style.overflowX = oX;
			div.style.overflowY = oY;
		},1)
	}
}

//列表滚动处理
function __lvwscrollfixed(tbdiv,w){
	if( tbdiv.getAttribute("fixh")==0) { return __lvwscrollfixed_old(tbdiv,w); }
	var id = tbdiv.id.replace("lvw_tablebg_","");
	var presTop = tbdiv.getAttribute("presTop"); presTop =(presTop == null? 0 : presTop);
	var presLeft = tbdiv.getAttribute("presLeft"); presLeft =(presLeft == null? 0 : presLeft);
	var sTop = tbdiv.scrollTop;
	var sLeft = tbdiv.scrollLeft;
	if(presTop*1== sTop && presLeft*1 == sLeft) { return; } //当鼠标滚动结束时会出现滚动偏移量相等的情况。
	var tb = tbdiv.getElementsByTagName("Table")[0]; //table
	var maxh = tb.getAttribute("maxheads");
	var fixCell=tbdiv.getAttribute("fixedCell");
	var scrollType = (presTop*1== sTop ? 0 : 1) ;
	if(fixCell==0 && scrollType==0) {
		if(window.scrollHwnd && window.scrollHwnd>0){
			window.clearTimeout(window.scrollHwnd); 
			__lvw_clearFixedTempHead(tbdiv);
		}
		return false;
	}
	tbdiv.setAttribute("presTop", sTop);
	tbdiv.setAttribute("presLeft", sLeft);
	createFixHeader(id, tbdiv, scrollType);
	var rowspans= new Array()
	for (var i=0; i < fixCell; i++) { rowspans[i]=0 }
	if(scrollType==1) {
		//竖向滚动
		for (var i = 0; i < maxh ; i++)
		{
			var row = tb.rows[i];
			for (var ii = 0; ii< row.cells.length; ii++)
			{
				var c = row.cells[ii];
				var style= c.style;
				style.visibility = "hidden";
				style.top = (sTop+1) + "px";
				if(rowspans[ii]<=0) {
					if(c.rowSpan>1) { rowspans[ii]=rowspans[ii]+c.rowSpan-1; }
					if(ii < fixCell*1) {
						style.left =  sLeft + "px";
						style.position = "relative";
						style.zIndex = "30";
					}
					else{
						style.left =  "-1px";
					}
				}
				else {
					 rowspans[ii] = rowspans[ii]-1;
				}
			}
		}
	}
	else {
		//横向滚动
		for (var i = 0; i < tb.rows.length && scrollType==0; i++)
		{
			var isbreak = false;
			var row = tb.rows[i];
			for (var ii = 0; ii< fixCell; ii++)
			{
				if(rowspans[ii]<=0) {
					var c = row.cells[ii];
					if(c.colSpan>0) { isbreak = true; break;}
					if(c.rowSpan>1) { rowspans[ii]=rowspans[ii]+c.rowSpan-1; }
					c.style.cssText = "visibility:hidden;top:" + c.style.top + ";z-index:" + (i< maxh ? "30" : "2") + ";background-Color:white;position:relative;left:" + sLeft + "px;" + (i< maxh ? "" : "border-right:0px;border-bottom:0px;");
				}
				else{
				  rowspans[ii] = rowspans[ii]-1;
				}
			}
			if (isbreak==true) { break;}
		}
	}
	
}
function lvw_tu(bn){bn.className="toolitem";}
function lvw_tm(bn){bn.className="toolitemsel";}
function __lvw_autoListWidth(id){}
function __lvwscrollfixed_old(tbdiv,w) {
var fixCell=tbdiv.getAttribute("fixedCell");
if(fixCell||fixedCell>0){var tb=tbdiv.children[0];
var sleft=(w||w==0)?w:tbdiv.scrollLeft;
if(sleft+tbdiv.offsetWidth>tbdiv.children[0].offsetWidth){sleft=tbdiv.children[0].offsetWidth-tbdiv.offsetWidth;}
for(var i=0;i<tb.rows.length;i++){var tr=tb.rows[i];
var iii=0
var rSpan=1;
for(var ii=0;ii<tr.cells.length;ii++){if(iii<fixCell){var td=tr.cells[ii];
if(td.style.display !="none"){iii=iii+1;
rSpan=td.rowSpan;
if(sleft>0){if(td.getAttribute("fScroll") !=1){td.className=td.className+"_fixed";
td.setAttribute("fScroll",1)}}
else{td.className=td.className.replace("_fixed","");
td.setAttribute("fScroll",0)}
td.style.left=sleft+"px"}}}
i=i+(rSpan-1) * 1;}}}

function __tvwcolresize(div,id,isAutoresize){
__lvw_tabonresize(div, id);
if(isAutoresize==0) {return;}	
var tb=div.children[0];
var dw=tb.getAttribute("datawidth");
var bar=$ID("lvw_sbar_"+id)
if(dw>div.offsetWidth*1.2)
{if(app.IeVer <7){tb.style.width=dw+"px";}
if(bar) bar.style.display="";}
else{
if(tb.style.width=="") {tb.style.display="block";}
if(bar) bar.style.display="none";}}
function __lvwmvarea(id,stype)
{var tb=$ID("lvw_dbtable_"+id);
var div=tb.parentNode;
var sl=div.scrollLeft;
sl=sl+stype * 40;
if(sl<0){sl=0;}
__lvwscrollfixed(div,sl);
div.scrollLeft=sl;}
function Listview(id)
{var o=new Object();
o.beginCallBack=function(cmd){var vstate=$ID("__viewstate_lvw_"+id)
if(!vstate){alert("无法获取列表的状态数据");return}
ajax.regEvent("sys_lvw_callback");
ajax.addParam2("backdata",vstate.value);
ajax.addParam("resized",getcolresizedV(id));
__lvw_AutoAppendUrlParams(id);
$ap("cmd",cmd);}
o.addParam=ajax.addParam;
o.exec=function(){if(!$ID("lvw_"+id)){return false;}
 __lvw_callbackUpdateView(id, ajax.send());
if(window.onlistviewRefresh){window.onlistviewRefresh(id);}
__lvw_autoListWidth(id);}
o.cexcel=function(title)
{
	$.ajax({ url: window.virpath + "../SYSN/view/init/keeper.ashx?cmdType=Hang&stamp=" + (new Date()).getTime(), async: false });
	ajax.regEvent("sys_urldecode");
	ajax.addParam2("v", $ID("__viewstate_lvw_"+id).value);
	var viewdata = ajax.send();
	var ifrm=$ID("listview_dIframe");
	if(!ifrm){
		var div = $DC.createElement("div");
		div.id = "lvw_xls_proc_bar";
		$DC.body.appendChild(div);
		div.style.cssText = "width:460px;position:fixed;_position:absolute;left:28%;top:150px;z-index:10000;"
		var ifrm=$DC.createElement("form");
		ifrm.style.cssText="position:absolute;left:-100px;top:-100px;width:1px;height:1px;display:inline"
		ifrm.id="listview_dIframe";
		ifrm.name="listview_dr";
		ifrm.method="post";
		ifrm.innerHTML="<input type=hidden name='__msgId' id='_lvw_hidedc_msgid' value='sys_lvw_callback'>" +
		"<input type=hidden name='backdata' id='_lvw_hidedc_backdata'>" +
		"<input type=hidden name='title' id='_lvw_hidedc_title'>" +
		"<input type=hidden name='cmd' id='_lvw_hidedc_cmd' value='cexcel'><iframe style='height:1px;width:1px' frameborder=1 id='lvwexcel_frm' name='lvwexcelfrm'></iframe>"
		ifrm.target="lvwexcelfrm";
		$DC.body.appendChild(ifrm);	
	}
	else{
		var div = $ID("lvw_xls_proc_bar")
		if(div.style.display=="block") { return; }
		div.style.display = "block"
	}
	div.innerHTML = ""
		+"<TABLE class=sys_dbgtab8 cellSpacing=0 cellPadding=0  style='width:460px;' align='center'>"
		+"<TBODY>"
			+"<TR><TD style='HEIGHT: 20px' class=sys_dbtl></TD><TD class=sys_dbtc></TD><TD class=sys_dbtr></TD></TR>"
			+"<TR>"
				+"<TD class=sys_dbcl style='padding-top:22px;padding-bottom:22px;'></TD>"
				+"<TD style='border:0px solid #c0ccdd;background-color:white;padding:2px 12px 4px;background-color:#fff;' valign='top' id='lxls_by'>"
					+"<div id='lxls_by_progress'>"
					+"	<span id='lxls_status'>正在生成Excel文档,<span id='lvw_xls_p_bar_st'>请稍候<span id='lxls_t'></span>...</span></span>"
					+"	<div style='margin-top:10px;margin-bottom:10px;border:1px solid #c0ccdd;height:8px;font-size:8px;background-color:white;'>"
					+"		<div id='lxls_pv' style='height:8px;font-size:8px;width:0%;margin-top:0px'></div>"
					+"	</div>"
					+"</div>"
				+"</TD>"
				+"<TD class=sys_dbcr></TD>"
			+"</TR>"
			+"<TR><TD class=sys_dbbl></TD><TD class=sys_dbbc></TD><TD class=sys_dbbr></TD></TR>"
		+"</TBODY>"
		+"</TABLE>"
	$ID("_lvw_hidedc_backdata").value=viewdata;
	$ID("_lvw_hidedc_title").value=title ? title : "";
	ifrm.submit();
	$ID("_lvw_hidedc_backdata").value="";
}
return o;}
function __lvwShowProc(evn,cbox,title)
{if(evn&&evn.length>0){ajax.regEvent(evn);}
if(typeof(cbox)=="string")
{cbox=$ID(cbox);}
cbox.innerHTML="<table style='background-color:#f3f8ff;width:100%;border-top:1px solid #eeeef2;border-bottom:1px solid #eeeef2' cellpadding=2><tr><td style='width:20px;'>&nbsp;</td><td style='padding-top:10px;width:30px'><img height='20' src='"+window.sysskin+"/images/proc.gif'></td>"
+"<td style='width:160px;color:#333388'>"+(title?title:"数据正在加载，请稍等...")+"</td><td width='auto'>&nbsp;</td></tr></table>"}
function __onlvwshowfull(obj,id)
{obj.children[0].value=$ID("__viewstate_lvw_"+id).value;
obj.children[1].value=$DC.getElementsByTagName("head")[0].outerHTML;
return true;}
function lvw_pageto(index,id)
{var vstate=$ID("__viewstate_lvw_"+id)
if(!vstate){return}
ajax.regEvent("sys_lvw_callback");
ajax.addParam2("backdata",vstate.value);
ajax.addParam("resized",getcolresizedV(id));
__lvw_AutoAppendUrlParams(id);
$ap("cmd","newPageIndex");
$ap("value",index)
var div = $ID("lvw_"+id);
var pmsg = div.getAttribute("cbWaitMsg");pmsg = pmsg?pmsg: "";
ajax.send(function(r){__lvw_callbackUpdateView(id,r);if(window.onlistviewRefresh){window.onlistviewRefresh(id);__lvw_autoListWidth(id);}},pmsg);
}
function lvw_refresh(id)
{var vstate=$ID("__viewstate_lvw_"+id)
if(!vstate){return}
ajax.regEvent("sys_lvw_callback")
ajax.addParam2("backdata",vstate.value);
ajax.addParam("resized",getcolresizedV(id));
__lvw_AutoAppendUrlParams(id);
__lvw_callbackUpdateView(id,ajax.send());
if(window.onlistviewRefresh){window.onlistviewRefresh(id);}
__ImgBigToSmall();
__lvw_autoListWidth(id);}
function lvw_cpsize(size,id)
{var vstate=$ID("__viewstate_lvw_"+id)
if(!vstate){return}
var vlistCount = $ID("jlCount_"+id).innerHTML;
var pageindex =  $ID("lvw_pindex_"+id).value;
if(isNaN(pageindex)){alert("输入正确的分页序号");return;}
if(pageindex*1 <1){pageindex=1;}
pageindex = parseInt(pageindex);
var pagecount = Math.ceil(vlistCount/size);
if (pageindex - pagecount>=1){pageindex = pagecount;}
ajax.regEvent("sys_lvw_callback")
ajax.addParam2("backdata",vstate.value);
ajax.addParam("resized",getcolresizedV(id));
__lvw_AutoAppendUrlParams(id);
$ap("cmd","newPageSize")
$ap("value",size)
$ap("pageindex",pageindex)
var div = $ID("lvw_"+id);
var pmsg = div.getAttribute("cbWaitMsg");pmsg = pmsg?pmsg: "";
ajax.send(function(r){__lvw_callbackUpdateView(id,r);if(window.onlistviewRefresh){window.onlistviewRefresh(id);__lvw_autoListWidth(id);}},pmsg);}

function __lvwHeaderChange(sbox, id)
{var vstate=$ID("__viewstate_lvw_"+id)
if(!vstate){return}
ajax.regEvent("sys_lvw_callback")
ajax.addParam2("backdata",vstate.value)
$ap("cmd","headerchance")
$ap("value",sbox.value)
var div = $ID("lvw_"+id);
var pmsg = div.getAttribute("cbWaitMsg");pmsg = pmsg?pmsg: "";
ajax.send(function(r){__lvw_callbackUpdateView(id,r);if(window.onlistviewRefresh){window.onlistviewRefresh(id);__lvw_autoListWidth(id);}},pmsg);}
function __lvwsaveselBoxDef(an,av, box) {
	ajax.regEvent("sys_lvw_callback")
	ajax.addParam2("cmd", "svselhdconfig");
	ajax.addParam2("an", an);
	ajax.addParam("av", av);
	ajax.addParam2("ht", box.checked ? 1 : 0);
	if(window.__lvwsaveselBoxDefEx) { window.__lvwsaveselBoxDefEx(an,av, box);}
	ajax.exec();
}
function lvw_createexcel(id,title)
{
	(new Listview(id)).cexcel(title)
}

function lvw_showcolConfig(id){var vstate=$ID("__viewstate_lvw_"+id);
if(!vstate){return;}
ajax.regEvent("sys_lvw_callback");
ajax.addParam2("backdata",vstate.value);
$ap("cmd","lvwcolConfig");
$ap("id",id);
var div=app.createWindow("sys_lvw_config","列设置","","",60,540,440,2,1,"#f0f0f0");
div.innerHTML=ajax.send();
__lvw_autoListWidth(id);}
function lvw_fctreeexp(img,fullname){var tr=$ID("lcf_"+fullname);
var display=img.src.indexOf("_s")>0?"":"none";
tr=tr.nextSibling;
while (tr&&tr.id.indexOf(fullname)>0){if(display=="none"){if(tr.getAttribute("leef") !=1){var img=tr.getElementsByTagName("img")[0]
if(img.src.indexOf("_s")>0){img.click();}}
tr.style.display="none";}
else{if(tr.id.replace("lcf_"+fullname).split("_").length==2){tr.style.display="";}}
tr=tr.nextSibling;}}
function lvw_saveConfig(id){var tb=$ID("lvw_cfrows_"+id);
var dat=new Array();
for(var i=1;i<tb.rows.length;i++){var tr=tb.rows[i];
if(tr.getAttribute("leef")==1){var field=("@"+tr.id.replace("lcf_","")).replace("@_","").replace("@","");
var visble1=tr.cells[1].children[0].rows[0].cells[2].children[0].value;
var visble2
if(tr.cells[2].children[0])
{visble2=tr.cells[2].children[0].value;}
else
{visble2=""}
var visble3
if(tr.cells[3].children[0])
{visble3=tr.cells[3].children[0].value;}
else
{visble3=""}
var visble4=tr.cells[4].children[0].checked?1:0;
dat[dat.length]=field+","+visble1+","+visble2+","+visble3+","+visble4;}}
var vstate=$ID("__viewstate_lvw_"+id);
if(!vstate){return;}
ajax.regEvent("sys_lvw_callback")
ajax.addParam2("backdata",vstate.value)
$ap("cmd","colsettingSave")
$ap("value",dat.join("|"));
if($ID("lvwbody")) {
app.easyui.closeWindow("showReportSettings");
}else{
app.closeWindow("sys_lvw_config");
}
var r=ajax.send();
if(r.indexOf("lvwframe2")>0)
{__lvw_callbackUpdateView(id,r);}
if(window.onlistviewRefresh){window.onlistviewRefresh(id);}
__lvw_autoListWidth(id);}
function lvw_resetConfig(id){var vstate=$ID("__viewstate_lvw_"+id);
if(!vstate){return;}
ajax.regEvent("sys_lvw_callback");
ajax.addParam2("backdata",vstate.value)
$ap("cmd","colsettingReset")
app.closeWindow("sys_lvw_config");
__lvw_callbackUpdateView(id,ajax.send());
if(window.onlistviewRefresh){window.onlistviewRefresh(id);}
__lvw_autoListWidth(id);}
function lvw_lfckvisble(ckbox,fullname){var ckv=ckbox.checked;
var tr=$ID("lcf_"+fullname);
tr=tr.nextSibling;
while (tr&&tr.id.indexOf(fullname)>0){var fullname2=tr.id.replace("lcf_","");
$ID("lvwvsb_"+fullname2).checked=ckv;
tr=tr.nextSibling;};}
function __lvwpboxkey(box,id,env)
{var m=box.getAttribute("max");
if(window.event.keyCode==13 || env==1)
{if(isNaN(box.value)){return false;}
if(box.value*1 <1){box.value=1;}
if(box.value*1>m){box.value=m;}
lvw_pageto(parseInt(box.value),id);
return false;}
else{var char_code = window.event.charCode ? window.event.charCode : window.event.keyCode;
if((char_code<48 && char_code!=8) || char_code >57){return false;} }}
function lvw_onaddnew(id)
{if(window.listview_onaddnew)
{window.listview_onaddnew(id);}}
function lvw_InsertRow(id, newData)
{
	var vstate=$ID("__viewstate_lvw_"+id)
	if(!vstate){return}
	ajax.regEvent("sys_lvw_callback");
	ajax.addParam2("cmd", "insertRow");
	ajax.addParam2("backdata",vstate.value);
	ajax.addParam("newData", newData.join("\1\5\3"));
	var r = ajax.send();
	var div = document.createElement("div");
	div.innerHTML = "<table>" + r + "</table>"
	var newRow = div.children[0].rows[0];
	var tb = $ID("lvw_dbtable_" + id);
	var nddiv = tb.rows[1].cells[0].getElementsByTagName("DIV");
	if(nddiv.length==1 && nddiv[0].className=="lvw_nulldata") {
		tb.deleteRow(1);
	}
	var nRow = tb.insertRow(tb.rows.length);
	for (var i = 0; i < newRow.cells.length; i++)
	{
		var ntd = nRow.insertCell(nRow.cells.length);
		var otd = newRow.cells[i];
		ntd.innerHTML =  otd.innerHTML;
		ntd.className = otd.className;
	}
//	if(window.onlistviewRefresh){window.onlistviewRefresh(id);}
	//__lvw_autoListWidth(id);
}

function __lvwconfigvckAll(ck) {
	var td = ck.parentNode;
	var tb = $ID(td.id.replace("lvw_ac_v_","lvw_ac_ptb_"))
	for (var i = 0; i < tb.rows.length ; i++ )
	{
		var s = tb.rows[i].cells[td.cellIndex].getElementsByTagName("input");
		if(s.length>0) {
			s[0].checked = ck.checked;
		}
	}
}

function __lvw_AutoAppendUrlParams(lvwId){
	var lvwdiv = $ID("lvw_"+lvwId);
	if (lvwdiv.autoAppendUrlParams!='1') return;

	var allurl = document.URL.split("#")[0].split("?");
	var queryString = "";
	queryString = allurl.length > 1 ? allurl[1] : "";
	var params = queryString.split("&");

	for(var i=0;i<params.length;i++){
		var param = params[i].split('=');
		if (param.length<=1) continue;

		if (param[1].length==0) continue;
		ajax.addParam(param[0],param[1]);
	}
}

//JSON模式编辑开始
//JSON模式编辑.服务端输出列表（初始化）
function ___ResponseListViewByJson(obj){
	function _w(str){document.write(str);}
	if(typeof(obj)!="object"){obj = eval("window.lvw_JsonData_" & obj);}
	var headers = obj.headers;
	var startpos = (obj.pageindex-1)*obj.pagesize;
	var endpos = obj.pageindex*obj.pagesize;
	var selpos =  isNaN(obj.selpos)?0:obj.selpos;
	var recordcount = obj.rows.length;
	var hcount = headers.length;
	var iii = 0;
	for (var ii = 0; ii< hcount; ii++ ){var h = headers[ii];if(h.display!="none"){iii ++;}}
	_w("<tr nulldata=1 style='" + (obj.recordcount>0?"display:none":"") + "'><td class='lvw_index nulldata' style='border-bottom:0px' colspan='" + iii + "'><div class='lvw_nulldata'></div></td></tr>")
	for (var i = startpos;i < (recordcount>endpos?endpos:recordcount)  ; i ++ )
	{
		var cells = obj.rows[i];
		_w("<tr" + (i==selpos?" class='lr_je_sel'":"") + " pos='" + i + "'>");
		iii = 0;
		for (var ii = 0; ii< hcount; ii++ )
		{
			var h = headers[ii];
			if(h.display!="none"){
				_w("<td class='" + (iii==0?"lvw_index":"lvw_cell") + "' " + (h.uitype=="tree"?"style='padding:0px'":"") + " align='" + h.align + "'>");
				_w(__sys_lvw_getItemCellHtml(obj, h, i));
				_w("</td>");
				iii ++;
			}
		}
		_w("</tr>");
	}
	iii = 0;
	_w("<tr allsum=1 style='" + ((obj.allsum!=1||obj.recordcount==0)?"display:none":"") + "'>");
	for (var ii = 0; ii< hcount; ii++ )
	{
		var h = headers[ii];
		if(h.display!="none"){
			_w("<td class='" + (iii==0?"lvw_index":"lvw_cell") + "' style='border-bottom:0px' align='" + h.align + "'>");
			if(iii==0){
				_w("合计");
			}else{
				_w(__RefreshLvwSumCell(obj.sums[ii],h))
			}
			_w("</td>");
			iii ++;
		}
	}
	_w("</tr>");
}

//JSON模式编辑.显示合计值
function __RefreshLvwSumCell(v, h){
	if(v!="*" && h.uitype!="select" && h.uitype!="checkbox") {
		switch(h.dbtype){
			case "money": return (v.toFixed(window.sysConfig.moneynumber)); break;
			case "commprice": return (v.toFixed(window.sysConfig.CommPriceDotNum)); break;
			case "salesprice": return (v.toFixed(window.sysConfig.SalesPriceDotNum)); break;
			case "storeprice": return (v.toFixed(window.sysConfig.StorePriceDotNum)); break;
			case "financeprice": return (v.toFixed(window.sysConfig.FinancePriceDotNum)); break;
			case "number": return(v.toFixed(window.sysConfig.floatnumber));  break;
			case "str": return "";  break;
			default: return(v.toFixed(window.sysConfig.floatnumber));	
		}
	}else{
		return "";
	}
}
//JSON模式编辑.刷新列表（重现渲染）是否需要重置表头
window.___RefreshListViewHeadByJson =false;
//JSON模式编辑.刷新列表（重现渲染）
function ___RefreshListViewByJson(obj, srcfrom , RefreshHead){
	//注意：selpos是按lvw.rows组数下标取值， startpos按lvw.vrows数组取下标
	var headers = obj.headers;
	var id = obj.id;
	var startpos = isNaN(obj.startpos)?(obj.pageindex-1)*obj.pagesize:obj.startpos;
	var endpos = startpos*1 + obj.pagesize*1-1;
	var recordcount = obj.rows.length;
	var Vcount = obj.VRows.length;
	var hcount = headers.length;
	var tb = $ID("lvw_dbtable_" + id);
	var selpos = isNaN(obj.selpos)?0:obj.selpos*1;
	var rows = tb.rows;
	var headcount = 0;
	if(obj.recordcount<recordcount) {obj.recordcount=recordcount;} //防止recordcount不同步
	if(obj.rowhide==0 && obj.rows.length!=obj.VRows.length) {
		obj.VRows = new Array(); Vcount = obj.rows.length; 
		for (var i = 0; i <  Vcount; i++ ){obj.VRows.push(i);}
	}
	//重现表头col变动
	if (RefreshHead && RefreshHead ==true && window.___RefreshListViewHeadByJson==true){
		var colParent = $(tb).find("col").eq(0).parent(0);
		$(tb).find("col").remove();
		for (var ii = 0; ii<hcount ; ii++ ){
			var h = headers[ii];
			if(h.display!="none") {
				$(colParent).append("<col style='width:"+ h.width +"px;background:;' dbname='"+h.dbname+"'  title='"+h.title+"' cansort='0'/>");
			}
		}
	}

	for (var i = 0; i < rows.length ; i++)
	{	
		if (RefreshHead && RefreshHead ==true && window.___RefreshListViewHeadByJson==true && i==0)
		{	//重新表头变动书写
			$(rows[0]).children().remove();
			//合计行变动书写
			$(rows[rows.length-1]).children().remove();
			var thHtml ="";
			var cindex = 0;
			for (var ii = 0; ii<hcount ; ii++ ){
				var h = headers[ii];
				if(h.display!="none") {
					//重新表头变动书写
					cindex = cindex + 1; 
					thHtml = "<th onmousemove='__lv_recolsize(this,0)' onmousedown='__lv_recolsize(this,1)' " +
								"	pid='' id='lvwH_"+id+"_0_"+ cindex +"' colspan='1' rowspan='1' class='lvwheader h_1 " + (ii==0?"l_1":"") + "' dbname='"+h.dbname+"' " +
								"	style='width:"+ h.width +"px;' cindex='"+cindex+"'>"+
								"	<table class='lvwframe4' align='center'><tbody><tr><td style='display:none'></td>"+
								"	<th pid='s_' id='s_lvwH_"+id+"_0_"+ cindex +"' dbname='"+h.dbname+"' style='height:24px;cursor:default;font-size:12px' "+
								"		onmousemove='__lv_recolsize(this,0)' onmousedown='__lv_recolsize(this,1)' nowrap=''>"+h.title+"</th>"+
								"	<td style='display:none'></td></tr></tbody></table></th>";
					$(rows[0]).append(thHtml);
					//合计行变动书写
					thHtml = "<td class='" + (ii==0?"lvw_index":"lvw_cell") + "' style='border-bottom:0px' align='" + h.align + "'>"+(ii==0?"合计":__RefreshLvwSumCell(obj.sums[ii],h))+"</td>"
					$(rows[rows.length-1]).append(thHtml);
				}
			}
			headcount = 0;
		}
		else if(rows[i].getAttribute("nulldata")=="1") {
			headcount = i;
			rows[i].style.display = (recordcount==0?"":"none");
			if (RefreshHead && RefreshHead ==true && window.___RefreshListViewHeadByJson==true){
				$(rows[i]).children(0).attr("colspan",hcount+1);
			}
			break;
		}
	}
	//
	if(endpos>Vcount-1) {endpos=Vcount-1;startpos=endpos-obj.pagesize+1;}
	if(startpos<0) {startpos=0;}
	var dataposcount = endpos-startpos+1;
	var trcount = rows.length-headcount-2;
	//--填补缺少的行
	for (var i = trcount+1; i<=dataposcount; i++)
	{
		var tr = tb.insertRow(tb.rows.length-1);
		for (var ii = 0; ii<hcount ; ii++ ){
			var h = headers[ii];
			if(h.display!="none") {
				var cell = tr.insertCell(-1);
				cell.className = (ii==0?"lvw_index" : "lvw_cell");
				cell.align = h.align; 
			}
		}
	}
	var rowi = headcount;	
	//显示数据
	for (var i = startpos; i<=(endpos*1) ;i++ )
	{
		var iii = 0;
		rowi = headcount+i-startpos+1;
		var tr = rows[rowi];
		var datarowi = obj.VRows[i];
		var olddatrowi = tr.getAttribute("pos");
		tr.className =(datarowi==selpos?"lr_je_sel":"");
		tr.setAttribute("pos",datarowi);
		var cells = obj.rows[datarowi];
		for (var ii = 0; ii< hcount; ii++ )
		{
			var h = headers[ii];
			if(h.display!="none"){
				var htmlo = "";
				var td = tr.cells[iii];
				var eAttr = h.eAttr;
				var htmln =  __sys_lvw_getItemCellHtml(obj, h, datarowi);
				if(td){
					if (eAttr!=null && eAttr.nu==1){
						$(td).attr("nu","1");
					}else{
						$(td).attr("nu","0");
					}
					if(td.getAttribute("cache_HTML")!=htmln) {
						td.setAttribute("cache_HTML",htmln);
						tr.cells[iii].innerHTML = htmln;
					}
				}else{
					var cell = $("<td "+ (eAttr!=null && eAttr.nu==1 ? " nu='1' " : " nu='0' ") +" class='" + (iii==0?"lvw_index":"lvw_cell") + "' " + (h.uitype=="tree"?"style='padding:0px'":"") + " align='" + h.align + "'>" +htmln+ "</td>");
					$(tr).append(cell);
				}
				iii ++;
			}
		}
	}

	//显示空白单元格
	for (var i = rows.length-2; i>rowi; i--)
	{
		var tr = rows[i];
		tr.parentNode.removeChild(tr);
	}

	try{
		//显示求和
		var sumrow = rows[rows.length-1];
		var iii = 0;
		sumrow.removeAttribute("pos");
		for (var ii = 0; ii< hcount; ii++ )
		{
			var h = headers[ii];
			if(h.display!="none"){
				var cel = sumrow.cells[iii];
				if(iii>0){
					cel.innerHTML = __RefreshLvwSumCell(obj.sums[ii],h);
				} else {
					cel.innerHTML = "合计"
				}
				cel.style.borderBottom = "0px";
				cel.style.display = recordcount>0?"":"none";
				iii ++;
			}
		}
		sumrow.style.display = (recordcount&&obj.allsum!=0)>0?"":"none";
		var scrollbg = $ID("lvwjsnscrollbar_" + id);
		if(Vcount>obj.pagesize) {
			scrollbg.style.display ="block";
			__lvw_handlescrolbar($ID("lvw_tablebg_"+ id),id);
			if(srcfrom!="scrollbar") {
				var sbardiv = $ID("lvwscrollbar_" + id); 
				sbardiv.style.height = parseInt((Vcount/obj.pagesize)*100) + "%";
				var scrollTop = (startpos*1.0/Vcount)*sbardiv.offsetHeight;
				if(Vcount>obj.pagesize){
					var sbar = $ID("lvwjsnscrollbar_" + id);
					window.lvw_je_wheelScroll=1;
					$("#lvwjsnscrollbar_" + id).scrollTop(scrollTop);
				}
			}
		}else {
			scrollbg.style.display ="none";
		}
		var nboxem = $ID("lvw_je_enum_" + id);
		if(nboxem) { nboxem.innerHTML =  recordcount;}
	}catch(e){}
}

//JSON模式编辑.初始化列表滚动条
function __lvwjneditscroll(id){
	if(window.lvw_je_wheelScroll==1) {window.lvw_je_wheelScroll=0;return;}
	var lvw = eval("window.lvw_JsonData_"+id);
	var sbardiv = $ID("lvwjsnscrollbar_" + id);
	lvw.startpos = parseInt((sbardiv.scrollTop*1.0/$ID("lvwscrollbar_" + id).offsetHeight)*lvw.VRows.length);
	___RefreshListViewByJson(lvw, "scrollbar");
}

//JSON模式编辑.过滤掉source
function __sys_je_filterSoruce(lvw, rowindex, h, deep){
	if(!deep) {deep=1}
	var fls = "";
	if(isNaN(h.filter)==false) {
		fls = "," + (lvw.rows[rowindex][h.filter*1]+"").replace(/\s/g,"") + ","
	}
	if(app.isArray(h.source)) { 
		if(fls=="") { return h.source; }  //应用过滤调
		var data = new Array();
		for (var i = 0; i <  h.source.length; i ++ )
		{
			var item = h.source[i];
			if(fls=="" || fls.indexOf(","+item[item.length-1]+",")>=0) {  //应用过滤调
				data[data.length] = item;
			}
		}
		return data;
	}
	if(app.isString(h.source)>0) {
		var stype = h.source.split(":")[0];
		if(stype=="treenode") {
			var sdata = h.source.replace(stype+":","");
			var s1 = -1;
			for (var i = 0 ;i< lvw.headers.length ; i++ )
			{
				if( lvw.headers[i].dbname==sdata) {
					s1 = i;
					break;
				}
			}
			if(s1==-1) {return;}
			var psource = lvw.headers[s1].source;
			var pvalue = lvw.rows[rowindex][s1];
			//if(h.dbname=="结构类型" && deep==1) { confirm(lvw.headers[s1].dbname + "=" + pvalue + ";i=" + i + ",h=" + h.dbname + ",currvalue=" + lvw.rows[rowindex][h.i]); }
			if(psource.stype=="tree") {
				var si = 0;
				for (var ii = 0; ii < psource.nodes.length; ii++ )
				{
					var nd = psource.nodes[ii];
					if(nd.value==pvalue) {
						si = ii;
						break;
					}
				}
				nd = psource.nodes[si]
				var data = new Array();
				if(nd && nd.nodeobjs) {
					for (var iii = 0; iii <  nd.nodeobjs.length; iii ++ )
					{
						var item = nd.nodeobjs[iii];
						if(fls=="" || fls.indexOf(","+item.value+",")>=0) {  //应用过滤调
							data[data.length] = [item.text, item.nodeobjs, item.value];
						}
					}
				}
				return data;
			}
			if(app.isString(psource) && psource.indexOf("treenode:")==0) {
				psource = __sys_je_filterSoruce(lvw, rowindex, lvw.headers[s1], deep+1);
				if(psource && psource.length>0) {
					var si  = 0;
					for (var ii = 0; ii < psource.length; ii++ )
					{
						var nd = psource[ii];
						if(nd[2]==pvalue) {
							si = ii;
							break;
						}
					}
					var data = new Array();
					nd = psource[si]
					for (var iii = 0; iii <  nd[1].length; iii ++ )
					{

						var item = nd[1][iii];
						if(fls=="" || fls.indexOf(","+item.value+",")>=0) {  //应用过滤调
							data[data.length] = [item.text, item.nodeobjs, item.value];
						}
					}
					return data;
				}
			}
		}
		return;
	}
	//解析object类型的数据源
	var obj = h.source;
	if(obj.stype=="tree") {
		var data = new Array();
		for (var i = 0; i <  h.source.nodes.length; i ++ )
		{
			var item = h.source.nodes[i];
			if(fls=="" || fls.indexOf(","+item.value+",")>=0) {  //应用过滤调
				data[data.length] = [item.text, item.value];
			}
		}
		return data;
	}
}

function lvw_je_Expnode(id, rowindex, cellindex,disrefsh) {
	var lvw = eval("window.lvw_JsonData_"+id);
	var node = lvw.rows[rowindex][cellindex];
	var nl = node.deeps.length;
	var preexp = true;
	if(node.cot==0) {return false;}
	node.expand = (node.expand==1?0:1);
	for (var i = rowindex+1; i< lvw.rows.length ; i++ )
	{
		var nd = lvw.rows[i][cellindex];
		if(nd.deeps.length<=nl) {break;}
		if(node.expand==0) {
			lvw_je_RowVisible(lvw,i, 0, true)
		}else {
			if(nd.deeps.length==(nl+1)) {
				preexp = (nd.expand==1?1:0)
				lvw_je_RowVisible(lvw,i, 1, true);
			}else {
				lvw_je_RowVisible(lvw,i, preexp, true);
			}
		}
	}
	lvw.VRows.sort(function(a,b){return a>b?1:-1}); 
	if (!disrefsh) {___RefreshListViewByJson(lvw);}
}

function lvw_je_RowVisible(lvw, RowIndex, visible, disAutosort) {
	if(visible) {
		if(lvw.VRows.indexOf(RowIndex)>=0) {return;}
		lvw.VRows.push(RowIndex);
		if(disAutosort!=true){ lvw.VRows.sort(function(a,b){return a>b?1:-1}); }//从小到大排序
	} else {
		var i = lvw.VRows.indexOf(RowIndex);
		if(i>=0) { lvw.VRows.splice(i,1);}
	}
}

//JSON模式编辑.输出列表单元格的值
function __sys_lvw_getItemCellHtml(lvw, header, rowindex, isztlr) {
	var value, source;
	var cellindex = header.i;
	var jvalue = (isztlr==1?"":lvw.rows[rowindex][cellindex]);
	if(isztlr) {rowindex=-1;}
	if(typeof(jvalue)=="object" && jvalue!=null) {
		value = jvalue.value;
		source = jvalue.source;
	} else {
		value = jvalue;
		source = null;
	}
	function jsConvert(strhtml){ return String(strhtml).replace(/\"/g,"&#34;"); }
	var h = header;
	var ui = h.uitype;
	var html = new Array();
	var attr = "";
	var uiid = " id='" + lvw.id + "_jec_" + rowindex + "_" + cellindex + "'"
	var cgJs = "'__lvw_je_updateCellValue(\"" + lvw.id + "\","+ rowindex +","+ cellindex +",this.value)'"
	var wattrv = "width:" + (h.boxwidth?h.boxwidth:(h.notnull==1?"60%":"80%")) + ";"
	var wattr = "style='" + wattrv + "'"
	var oread = h.oread;
	var srcScript = "";
	var editlock = __lvw_je_editlockIf(lvw, h.editlock, rowindex, cellindex);
	var editstate = (editlock==1? " disabled" : (editlock==3 || (h.srcScript && editlock!=1) ?" readonly onkeydown='return false'":""));
	if(editlock==2) {oread=1;}
	if(editlock=="#ERR!") {ui="text";oread=1;value="<span style='color:red'>#公式出错</span>"}
	if(h.srcScript && editlock!=1) { srcScript = "<img src='" + window.virpath + "images/11645.png' onclick=\"" + h.srcScript.replace(/\"/g,"&#34;") + "\" style='background:white;height:13px;cursor:pointer;margin-left:-17px'>"}
	switch(ui){
		case "indexcol11": return "<input " + uiid + " onclick=" + cgJs.replace("this.value","this.checked?1:0") + " type='checkbox' " + (value==1?"checked":"") + "> <span style='color:#dddddf'>|</span>&nbsp; " + (rowindex*1+1).toString();
		case "indexcol10": return (rowindex*1+1).toString();
		case "indexcol01": return "<input  " + uiid + " onclick=" + cgJs.replace("this.value","this.checked?1:0") + "  type='checkbox' " + (value==1?"checked":"") + ">";
		case "tree":
			if (typeof(jvalue)=="object")
			{
				var css = "";
				html.push("<div class='lvw_treenode'>")
				html.push(jvalue.deeps.replace(/1/g,"<div class='tvw_n_ln d1'>&nbsp;</div>").replace(/0/g,"<div class='tvw_n_ln d0'>&nbsp;</div>"));
				var ix = (jvalue.expand==1?1:0);
				if(!(jvalue.nxt==1)){
					if(jvalue.cot==0) { 
						css = "ty_1_e2";
						ix = 2;
					}else{
						css = "ty_1_e" + ix
					}
				}else {
					if(jvalue.cot==0) { 
						css = "ty_2_e2"
						ix = 2
					}else{
						css = "ty_2_e" + ix
					}
				}
				html.push("<div class='tvw_n_st " + css + "' onmousedown='return lvw_je_Expnode(\"" + lvw.id + "\"," + rowindex + "," + cellindex + ")'>&nbsp;</div>");
				if(jvalue.ico) {
					if(!jvalue.ico2||jvalue.ico2.length==0) { jvalue.ico2 = jvalue.ico; }
					var ico = jvalue.ico.replace("@img", window.sysskin +"/images");
					var ico2 = jvalue.ico2.replace("@img", window.sysskin +"/images");
					html.push("<div class='tvw_n_ico" + ((jvalue.cot==0||jvalue.expand!=1)?"":" lvw_tvwbline")+ "'><img id='" + lvw.id + "_ico' src='" + (jvalue.expand==1?ico:ico2) + "' ico1='" + ico + "' ico2='" + ico2 + "'></div>");
				}
				var fm = h.fmhtml;
				var resv=(fm.length==0)?jvalue.txt:__lvw_je_formattext(lvw, fm, rowindex, cellindex);
				html.push("<div class='lvw_treenodetxt'>" + resv+ "</div>");
				html.push("</div>")
				return html.join("");
			} else {
				return "";
			}
		case "select":
			var rows = source?source:__sys_je_filterSoruce(lvw, rowindex, h);
			if(oread==1) {
				if(rows) {
					for (var i = 0; i < rows.length ; i++ )
					{
						var cells = rows[i];
						if(value==cells[cells.length-1]) {return cells[0];}
					}
				}
			} else {
				var sv = 0;
				html.push("<select " + wattr + " onchange=" + cgJs + " " + uiid + editstate + ">");
				if(rows) {
					for (var i = 0; i < rows.length ; i++ )
					{
						var cells = rows[i];
						if(value==cells[cells.length-1]) {  sv=1 }	
						html.push("<option " + (value==cells[cells.length-1]?"selected ":"") + "value='" + cells[cells.length-1] + "'>" +  cells[0] + "</option>");
					}
					if(sv==0 && isztlr!=1) { 
						cells = rows[0];
						if(cells){ lvw.rows[rowindex][cellindex] = cells[cells.length-1]; } 
						else {lvw.rows[rowindex][cellindex]="";}
					}
				}
				html.push("</select>");
				return html.join("");
			}
			break;
		case "text":
			return (oread==0)?("<input" +editstate+" value=\"" + jsConvert(value) + "\" " + wattr + " onkeyup=" + cgJs + " onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ srcScript + (h.notnull==1?" <span class='red'>*</span>":"")) : jsConvert(value)
		case "money":
			var vstr, fieldDotNum, fieldDotType; 
			fieldDotNum = window.sysConfig.moneynumber;
			fieldDotType = "money";
			switch(h.dbtype){
				case "commprice":
					fieldDotNum = window.sysConfig.CommPriceDotNum;
					fieldDotType = "CommPrice";
					break;
				case "salesprice":
					fieldDotNum = window.sysConfig.SalesPriceDotNum;
					fieldDotType = "SalesPrice";
					break;
				case "storeprice":
					fieldDotNum = window.sysConfig.StorePriceDotNum;
					fieldDotType = "StorePrice";
					break;
				case "financeprice":
					fieldDotNum = window.sysConfig.FinancePriceDotNum;
					fieldDotType = "FinancePrice";
					break;
				default:
					fieldDotNum = window.sysConfig.moneynumber;
					fieldDotType = "money";
					break;
			}
			vstr= (isNaN(value)||value=="")?jsConvert(value + ""):parseFloat(value).toFixed(fieldDotNum);
			if(h.oread==0) {
				var cgJs2 = (",,,"+cgJs).replace(",,,'","");
				cgJs2 = "'checkDot(\"" + lvw.id + "_jec_" + rowindex + "_" + cellindex + "\","+fieldDotNum+");"+ cgJs2;
				return "<input" +editstate+" maxlength='32' style='text-align:right;" + wattrv + "' onpropertychange=\"formatData(this,'"+fieldDotType+"',2)\"; value=\"" + vstr + "\" onkeyup=" + cgJs2 + " onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ (h.notnull==1?" <span class='red'>*</span>":"")
			} else{
				return vstr;	
			}		
		case "number":
			var vstr = (isNaN(value)||value=="")?jsConvert(value + ""):parseFloat(value).toFixed(window.sysConfig.floatnumber);
			if(h.oread==0) {
				var cgJs2 = (",,,"+cgJs).replace(",,,'","");
				cgJs2 = "'checkDot(\"" + lvw.id + "_jec_" + rowindex + "_" + cellindex + "\","+window.sysConfig.floatnumber+");"+ cgJs2;
				return "<input" +editstate+" maxlength='32' onpropertychange=\"formatData(this,'number',2)\"; value=\"" + vstr + "\" " + wattr + " onkeyup=" + cgJs + " onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ (h.notnull==1?" <span class='red'>*</span>":"")
			} else{
				return vstr;	
			}
		case "hl":
			var vstr = (isNaN(value)||value=="")?jsConvert(value + ""):parseFloat(value).toFixed(window.sysConfig.hlnumber);
			if(h.oread==0) {
				return "<input maxlength='32' onpropertychange=\"formatData(this,'hl',2)\"; value=\"" + vstr + "\" " + wattr + " onkeyup=" + cgJs + " onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ (h.notnull==1?" <span class='red'>*</span>":"")
			} else{
				return vstr;	
			}
		case "zk":
			var vstr = (isNaN(value)||value=="")?jsConvert(value + ""):parseFloat(value).toFixed(window.sysConfig.zkmumber);
			if(h.oread==0) {
				return "<input maxlength='32' style='text-align:right;" + wattrv +"' onpropertychange=\"formatData(this,'zk',2)\"; value=\"" + vstr + "\" onkeyup=" + cgJs + " onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ (h.notnull==1?" <span class='red'>*</span>":"")
			} else{
				return vstr;	
			}
		case "datetime":
			return (oread==0)?("<input" +editstate+" onkeydown='return false' readonly onclick='datedlg.showDateTime()' value=\"" + jsConvert(value) + "\" style='cursor:default;" + wattrv + "' onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ "<img src='" + window.virpath + "images/datePicker.gif' onclick='datedlg.showDateTime()' style='cursor:pointer;margin-left:-17px'>" + (h.notnull==1?" <span class='red'>*</span>":"")) : jsConvert(value)
			break;
		case "time":
			return (oread==0)?("<input" +editstate+" onkeydown='return false' readonly onclick='datedlg.showTime()' value=\"" + jsConvert(value) + "\" style='cursor:default;" + wattrv + "' onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ "<img src='" + window.virpath + "images/datePicker.gif' onclick='datedlg.showTime()' style='cursor:pointer;margin-left:-17px'>" + (h.notnull==1?" <span class='red'>*</span>":"")) : jsConvert(value)
			break;
		case "date":
			return (oread==0)?("<input" +editstate+" onkeydown='return false' readonly onclick='datedlg.show()' value=\"" + jsConvert(value) + "\" style='cursor:default;" + wattrv + "' onchange=" + cgJs + " onblur=" + cgJs + " " + uiid + ">"
				+ "<img src='" + window.virpath + "images/datePicker.gif' onclick='datedlg.show()' style='cursor:pointer;margin-left:-17px'>" + (h.notnull==1?" <span class='red'>*</span>":"")) : jsConvert(value)
			break;
		case "checkbox":
			return (oread==0)?("<input" + editstate + ((value+"")=="1"?" checked":"") + " type='checkbox' onclick='__lvw_je_updateCellValue(\"" + lvw.id + "\","+ rowindex +","+ cellindex +",this.checked?1:0)'>"):((value+"")=="1"?"<img src='" + window.virpath + "images/ok.gif'>":"");
		case "radio":
			var rows = source?source:__sys_je_filterSoruce(lvw, rowindex, h);
			var html = "";
			for (var i = 0; i < rows.length ; i++ )
			{
				var cells = rows[i];
				html+= "<input value=\"" + jsConvert(cells[cells.length-1]) + "\" " + (h.oread==0?"":"disabled ")  
					+ ((value+"")==cells[cells.length-1]?"checked":"") + " type='radio' onclick='if(this.checked){__lvw_je_updateCellValue(\"" + lvw.id + "\","+ rowindex +","+ cellindex +",this.value)}' "
				    +" id='" + lvw.id + "_jec_" + rowindex + "_" + cellindex + "_" +i + "' name='" + lvw.id + "_jec_" + rowindex + "_" + cellindex + "'><label for='" + lvw.id + "_jec_" + rowindex + "_" + cellindex + "_" + i + "'>" + cells[0] + "</label>";
			}
			return html;
		case "editcol":
			if(lvw.edit.canadd==1) {html.push("<button onclick='__lvw_je_btnhandle(this,1)' title=插入增加 class='zb-btn fs'>增</button>");}
			if(lvw.edit.candel==1) {html.push("<button onclick='__lvw_je_btnhandle(this,2)' title=删除 class='zb-btn fs'>删</button>");}
			if(lvw.edit.rowmove) {
				html.push("<button onclick='__lvw_je_btnhandle(this,3)' title=行上移 class='zb-btn fs'>↑</button>");
				html.push("<button onclick='__lvw_je_btnhandle(this,4)' title=行下移 class='zb-btn fs'>↓</button>");
			}
			return html.join("");
		default:
			var resv;
			var fm = h.fmhtml;
			resv=(fm.length==0)?value:__lvw_je_formattext(lvw, fm, rowindex, cellindex);
			if (lvw.istreegrid == 1) { return "<div style='text-align:" + h.align + "' class='lvw_treecell' rowindex=" + rowindex + " cellindex=" + cellindex +">" + resv + "</div>"}
			else {return resv;}
	}
	return value;
}

//JSON模式编辑.控制单元格编辑状态0=可编辑，1=禁止编辑 2=只读状态, 3=编辑框锁定状态
function __lvw_je_editlockIf(lvw, lockExpress, rowindex, cellindex) {
	if(lockExpress=="") {return 0;}
	if(lockExpress=="false" || lockExpress=="False" || lockExpress=="0") {return 0;}
	if(lockExpress=="true" || lockExpress=="True" || lockExpress=="1") {return 1;}
	if(lockExpress=="read") {return 2;}
	if(lockExpress=="lock") {return 3;}
	if(lockExpress.indexOf("@")==-1) {return lockExpress;}
	var v = __lvw_je_formattext(lvw, lockExpress, rowindex, cellindex);
	if(v && ((v + "").indexOf("&")>0 || (v + "").indexOf("|")>0)) { try{v = eval(v);}catch(e){v=0;} }
	if(v==true) { return 1;}
	if(v==false) {return 0;}
	if((v+"")=="2") {return 2;}
	if(v=="#ERR!") {return v;}
	return 0;
}

//JSON模式编辑.处理单元格format
function __lvw_je_formattext(lvw, fm, rowindex, cellindex) {
	var boolcode = (fm.indexOf("code:")==0);
	var h = lvw.headers[cellindex];
	var v = (h.uitype=="tree"?lvw.rows[rowindex][cellindex].txt:lvw.rows[rowindex][cellindex]);
	fm = fm.replace(/\@value/g,v);
	var i1 = fm.indexOf("@cells[");
	var ix = 0;
	while(i1>=0 && ix<10) {
		ix ++;
		var fm2 = fm.substr(i1);
		var i2 = fm2.indexOf("]");
		if(i2>0) {
			var ins = fm.substr(i1+7, i2-7)
			var insv = ins.replace(/\"/g,"");
			var dbindex = insv;
			if(isNaN(ins)) {
				for (var ii=0; ii < lvw.headers.length; ii++ )
				{
					var h = lvw.headers[ii];
					if(insv==h.dbname) {dbindex = ii;break;}
				}
			}
			if(isNaN(dbindex)) {return fm}
			var px = eval("/\\@cells\\[" + ins.replace(/\"/g,"\\\"") + "\\]/g");
			var rpv = lvw.rows[rowindex][dbindex];
			if(isNaN(rpv) || rpv=="") { rpv = "\"" + rpv + "\"";}
			fm = fm.replace(px, rpv);
			i1 = fm.indexOf("@cells[");
		} else { i1=-1}
	}
	if(!boolcode) {return fm;} 
	else {fm = fm.replace(/\<\>/g,"!=");} 
	try { return eval(fm.replace("code:","")); }
	catch(e) {return "#ERR!";}
}


//JSON模式编辑.更新单元格的值
function __lvw_je_updateCellValue(id, rowi, cellindex, v) {
	var lvw = eval("window.lvw_JsonData_"+id);
	var rowindex, iii = 0, isztlr = 0
	if (app.isArray(rowi))
	{	
		rowindex = rowi;
		isztlr=1;
	}else if(rowi == -1){
		rowindex = new Array();
		for (var i = 0; i  < lvw.rows.length ; i++ )
		{
			rowindex[i] = i;
		}
		isztlr=1;
	}else{
		rowindex = [rowi];
	}
	var csi = new Array();
	csi[csi.length] = cellindex;
	for ( x = 0; x < rowindex.length ; x++)
	{
		var iii = 0;
		lvw.rows[rowindex[x]][cellindex] = v;
		if (window.onlvwUpdateCellValue) {
		    var CanExit = window.onlvwUpdateCellValue(id, rowindex[x], cellindex, v, isztlr, (x == rowindex.length - 1));
		    if (CanExit) return;
		}
		for (var i = 0; i < lvw.headers.length ; i ++ )
		{
			var h = lvw.headers[i];
			if(h.display!="none") {
				if(cellindex!=i){ //当前事件源单元格不触发重绘
					if(h.fmhtml.indexOf("@")>-1 || h.editlock.indexOf("@")>-1) { 
						if(isztlr==0){__lvw_je_redrawCell(lvw,h, rowindex[x],iii);}
						if( x==0 && ("," + csi.join(",") + ",").indexOf("," + h.i + ",")==-1) {
							csi[csi.length] = h.i;
						}
					}
					if(app.isString(h.source)) {
						if(isztlr==0){__lvw_je_redrawCell(lvw,h, rowindex[x],iii);}
						if( x==0 && ("," + csi.join(",") + ",").indexOf("," + h.i + ",")==-1) {
							csi[csi.length] = h.i;
						}
					}
				}
				iii ++;
			} else {}
		}
	}

	for (var i = 0; i< csi.length ; i++)
	{
		var ii = csi[i];
		var smv = 0, hs = 0;
		for (var iii=0; iii<lvw.rows.length ; iii++)
		{
			var v = lvw.rows[iii][ii];
			if(isNaN(v)==false) { smv = smv + v*1; hs=1;}
		}
		lvw.sums[ii] = ((hs==1) ? smv : "*");
	}
	if(isztlr==0) {
		__lvw_je_redrawCellSumRow(lvw);
	} else {
		___RefreshListViewByJson(lvw);
	}
}


function ___ReSumListViewByJsonData(lvw){
	for (var i = 0; i<lvw.headers.length ;  i++)
	{
		var smv = 0, hs = 0;
		for (var ii=0; ii<lvw.rows.length ; ii++)
		{
			var v = lvw.rows[ii][i];
			if(isNaN(v)==false) { smv = smv + v*1; hs=1;}
		}
		lvw.sums[i] = ((hs==1) ? smv : "*");
	}
}

//单独显示求和行
function __lvw_je_redrawCellSumRow(lvw){
	var tb = $ID("lvw_dbtable_" + lvw.id);
	var hcount = lvw.headers.length;
	var sumrow = tb.rows[tb.rows.length-1];
	var iii = 0;
	for (var ii = 0; ii< hcount; ii++ )
	{
		var h = lvw.headers[ii];
		if(h.display!="none"){
			var cel = sumrow.cells[iii];
			if(iii>0){
				cel.innerHTML = __RefreshLvwSumCell(lvw.sums[ii],h);
			} else {
				cel.innerHTML = "合计"
			}
			iii ++;
		}
	}
}

//全选或全取消选择
function __lvw_je_checkall(box, id) {
	var lvw = eval("window.lvw_JsonData_"+id);
	for (var i = 0 ; i < lvw.rows.length ; i++ )
	{
		lvw.rows[i][0] = box.checked?1:0;
	}
	___RefreshListViewByJson(lvw);
}

//JSON模式编辑.根据值重新刷新某个单元格
function __lvw_je_redrawCell(lvw, header, rowindex, cellindex) {
	var tb = $ID("lvw_dbtable_" + lvw.id);
	for (var i = 0; i < tb.rows.length ; i++ )
	{
		if(tb.rows[i].getAttribute("pos")==rowindex) {
			var cell = tb.rows[i].cells[cellindex];
			if (cell) cell.innerHTML = __sys_lvw_getItemCellHtml(lvw, header, rowindex)
		}
	}
}

//JSON模式编辑.每行功能按钮
function __lvw_je_btnhandle(btn, ht) {
	var tr = app.getParent(btn,2);
	var tb = app.getParent(tr,2);
	var id = tb.id.replace("lvw_dbtable_","");
	var lvw = eval("window.lvw_JsonData_"+id);
	var pos = tr.getAttribute("pos")*1;
	switch(ht) {
		case 1: //在当前行之前插入新纪录
			var headers = lvw.headers;
			for (var i = lvw.rows.length; i>pos ; i--) { lvw.rows[i] = lvw.rows[i-1]; }
			var newrow = new Array();
			for (var i = 0; i< headers.length ; i ++ ) { 
				//if(headers[i].display!="none") {  
					newrow[newrow.length] = headers[i].defval; 
				//}  
			}
			lvw.rows[pos] = newrow;
			lvw.recordcount++;
			lvw_je_RowVisible(lvw,lvw.rows.length-1, 1);
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw);
			break;
		case 2: //删除当前行
			lvw_je_RowVisible(lvw,lvw.rows.length-1, 0);
			lvw.rows.splice(pos,1);
			lvw.recordcount--;
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw);
			if(window.onlvwUpdateRows){
				window.onlvwUpdateRows(lvw);
			}
			break;
		case 3: 
			__lvw_je_rowmove(lvw, pos, -1); break;
		case 4:
			__lvw_je_rowmove(lvw, pos, 1); break;
	}
}

//JSON模式编辑.调整列表滚动
function __lvwJeScroll(tbdiv){
	var r = window.event.wheelDelta;
	var src = window.event.srcElement;
	if(src.tagName=="SELECT") {return true;}
	if($ID("lvw_row_dragdiv")) {return false;} //存在拽动，则屏蔽滚动事件
	var lvw = eval("window.lvw_JsonData_"+tbdiv.id.replace("lvw_tablebg_",""));
	var startpos = isNaN(lvw.startpos)?0:lvw.startpos;
	var newstartpos = (r > 0) ? startpos-1 : startpos*1+1;
	var endpos = newstartpos*1 + lvw.pagesize*1-1;
	var VCount = lvw.VRows.length;
	if(endpos>VCount-1) {
		endpos=VCount-1;
		newstartpos=endpos-lvw.pagesize+1;
	}
	if(newstartpos<0) {newstartpos=0;}
	if(startpos==newstartpos) {
		var r=(new Date()).getTime() - (lvw.lastscrollTime? lvw.lastscrollTime: (new Date("2010/1/1")).getTime())>1000*2;
		if(r==false) { lvw.lastscrollTime = (new Date()).getTime(); }
		return r;
	}
	lvw.startpos = newstartpos;
	___RefreshListViewByJson(lvw, "wheel");
	lvw.lastscrollTime = (new Date()).getTime();
	return false;
}

//JSON模式编辑.调整列表滚动条
function __lvw_handlescrolbar(div,id){
	var sbardiv = $ID("lvwjsnscrollbar_" + id);
	if(sbardiv) {
		var tb = $ID("lvw_dbtable_" + id);
		var tbbg = tb.parentNode;
		if(tb.offsetHeight==0) {return;} //表格被隐藏
		if(app.IeVer<=8) {
			var row = tb.rows[tb.rows.length-1];
			if(tb.offsetWidth>tbbg.offsetWidth ) {
				tbbg.style.paddingBottom = "17px";
				for (var i = 0; i<row.cells.length ; i++ )
				{
					row.cells[i].style.borderBottom = "1px solid #c0ccdd";
				}
			}else{
				tbbg.style.paddingBottom = "0px";
				for (var i = 0; i<row.cells.length ; i++ )
				{
					row.cells[i].style.borderBottom = "0px solid #c0ccdd";
				}
			}
		}
		sbardiv.style.marginTop ="-" + tbbg.offsetHeight + "px";
		if(app.IeVer==6){
			sbardiv.style.marginLeft =parseInt((tbbg.offsetWidth-sbardiv.offsetWidth)/2) + "px";
		} else{
			sbardiv.style.marginLeft =(tbbg.offsetWidth-sbardiv.offsetWidth) + "px";
		}
		sbardiv.style.height =(tb.offsetHeight-1) + "px";
	}
}

//JSON模式编辑.生成列表滚动条
function __lvw_handlescrolbar_init(id) {
	if(!$){
		setInterval(function(){
			__lvw_handlescrolbar($ID("lvw_tablebg_"+ id),id);
		},200);
		return;
	}
	$(document).ready(function() { 
		__lvw_handlescrolbar($ID("lvw_tablebg_"+ id),id)
	});
	$(window).bind("resize",function() { 
		__lvw_handlescrolbar($ID("lvw_tablebg_"+ id),id)
	}); 
}

//JSON模式编辑.生成列表底部工具栏
function __lvw_initbtmtooldiv(id) {
	var lvw = eval("window.lvw_JsonData_"+id);
	function _w(str){document.write(str);}
	//if (lvw.recordcount > 0)
	//{
		//lvw.selpos = 0;
	//}
	if (lvw.edit.canadd==1 || lvw.pagebar==1){
		_w("<div class='lvwbtmtooldiv' id='lvwbtmtooldiv_" + id + "'>");
		_w("<div class='lv_b_spli'>&nbsp;</div>");
		if(lvw.edit.canadd==1){_w("<div class='lv_b_add'><a onclick='__lvw_je_addNew(\"" + id + "\")' href='javascript:void(0)'>添加新行</a></div>");}
		if (lvw.pagebar==1){
			_w("<div class='lv_b_spl'>|</div>");
			_w("<div class='lv_b_fst' onmousedown='__lvw_posgoto(\"" + id + "\",0)' title='移到第一条记录'>&nbsp;</div>");
			_w("<div class='lv_b_pre' onmousedown='__lvw_posgoto(\"" + id + "\",1)' title='移到上一条记录'>&nbsp;</div>");
			_w("<div class='lv_b_spl'>|</div>");
			_w("<div class='lv_b_pos'><input title='当前位置' onkeydown='if(window.event.keyCode==13){__lvw_postdownkey(\"" + id + "\",this);}' onblur='this.style.borderColor=\"#c0ccDD\"' onfocus='this.style.borderColor=\"#909cbD\"' id='lvw_je_ecn_" + id + "' value='" + (isNaN(lvw.selpos)?1:(lvw.selpos + 1)) + "' class='lvw_je_ecn'>&nbsp;/&nbsp;<span id='lvw_je_enum_" + id + "'>" + lvw.recordcount + "</span></div>");
			_w("<div class='lv_b_spl'>|</div>");
			_w("<div class='lv_b_nxt' onmousedown='__lvw_posgoto(\"" + id + "\",2)' title='移到下一条记录'>&nbsp;</div>");
			_w("<div class='lv_b_lst' onmousedown='__lvw_posgoto(\"" + id + "\",3)' title='移到最后一条记录'>&nbsp;</div>");
			_w("<div class='lv_b_spl'>|</div>");
			_w("<div class='lv_b_pos'>每页显示<select style='font-size:12px' onchange='__lvw_chg_psiz(\"" + id + "\",this.value)'>");
			var pages = [10,15,20,30,50,100];
			for (var i = 0; i < pages.length ; i++ ) { _w("<option " + (pages[i]==lvw.pagesize?"selected":"") + " value='" + pages[i] + "'>" + pages[i] + "</option>"); }
			_w("</select>行</div>");
			_w("</div>");
		}
	}
}

function __sy_lv_sh_JSN(lvwid){
	var obj = eval("window.lvw_JsonData_" + lvwid);
	var w = window.open("about:blank");
	var html = JSON.stringify(obj, null, 4);
	w.document.write("<pre style='font-size:12px'>" + html.replace(/\</g,"&lt;").replace(/\>/g,"&gt;") + "</pre>");
}


function __lvw_je_inittoptooldiv(id) {
	function _w(str){document.write(str);}
	_w("<div class='lvwtoptooldiv' id='lvwtoptooldiv_" + id + "'>");
	_w("<div class='lv_b_spli'>&nbsp;</div>");
	//_w("<div class='lv_b_btn' title='查看json数据'></div>");
	_w("<div class='lv_b_pos' id='lvw_je_ctl_ztlr_tit_" + id + "'></div>");
	_w("<div class='lv_b_spl' id='lvw_je_ctl_ztlr_spl_" + id + "'>|</div>");
	_w("<div class='lv_b_posZtlr' title='整体录入整列数据' id='lvw_je_ctl_ztlr_val_" + id + "' style='width:140px'></div>");
	if(window.location.href.indexOf("127.0.0.6")>0) {
		_w("<div style='float:right' ><img title='查看JSON数据' onclick='__sy_lv_sh_JSN(\"" + id + "\")' style='margin-right:3px;margin-top:4px;cursor:pointer' src='" + window.virpath + "skin/default/images/ico16/help_f_i.gif'></div>")
	}
	_w("</div>");
}

//JSON模式编辑.跳转到列表的选中光标
function __lvw_posgoto(id, t) {
	var lvw = eval("window.lvw_JsonData_"+id);
	lvw.selpos = isNaN(lvw.selpos)?0:lvw.selpos;
	switch(t){
		case 0: lvw.selpos = 0; ___RefreshListViewselPos(lvw); break;
		case 1: lvw.selpos --; if(lvw.selpos<0){lvw.selpos=0};___RefreshListViewselPos(lvw); break;
		case 2: lvw.selpos ++; if(lvw.selpos>lvw.recordcount-1){lvw.selpos=(lvw.recordcount-1);};___RefreshListViewselPos(lvw); break;
		case 3: lvw.selpos = lvw.recordcount-1; ___RefreshListViewselPos(lvw); break;
	}
}

//JSON模式编辑.设置列表的选中光标
function __lvw_postdownkey(id,box){
	var lvw = eval("window.lvw_JsonData_"+id);
	var v = box.value;
	if(isNaN(v)) {
		box.value = lvw.selpos+1;
		return;
	}
	v = v*1;
	if(v<1) {v=1}
	if(v>lvw.recordcount) {v = lvw.recordcount;}
	lvw.selpos = v-1;
	___RefreshListViewselPos(lvw);
	box.value = (lvw.selpos*1+1)
}

//JSON模式编辑.设置列表的pagesize
function __lvw_chg_psiz(id,v) {
	var lvw = eval("window.lvw_JsonData_"+id);
	lvw.pagesize = v;
	___RefreshListViewByJson(lvw);
}



//JSON编辑模式.整体录入控制
function ___lvw_je_ztlrCHtml(lvw) {
	var spX = lvw.selposX?lvw.selposX:0;
	if(spX>0 && lvw.rows.length>0 && lvw.headers[spX].dbname!="@editcol" &&  lvw.headers[spX].canBatchInput!="1"){
		var h = lvw.headers[spX];
		var tit = (h.title?h.title:h.dbname).replace("_","");
		if(!$ID("lvw_je_ctl_ztlr_tit_" + lvw.id)) { return; } //没有整体录入，直接退出
		$ID("lvw_je_ctl_ztlr_tit_" + lvw.id).innerHTML =  "整体输入【" + tit + "】" //【" + (h.title?h.title:h.dbname).replace("_","") + "】" ;
		if(	h.uitype && h.uitype!=""
			&& !(h.editlock && (h.editlock.indexOf("@cell")>0||h.editlock.indexOf("@value")>0))
			&& !(h.source && app.isString(h.source) && (h.source.indexOf("@cell")>=0||h.source.indexOf("@value")>=0 || h.source.indexOf("treenode:")==0))
			&& ! h.filter
		) {
			var v = lvw.rows[0][h.i];
			$ID("lvw_je_ctl_ztlr_val_" + lvw.id).innerHTML =  __sys_lvw_getItemCellHtml(lvw, h, 0, 1).replace(">*<","><");
			$ID("lvw_je_ctl_ztlr_tit_" + lvw.id).style.display = "block";
			$ID("lvw_je_ctl_ztlr_val_" + lvw.id).style.display = "block";
			$ID("lvw_je_ctl_ztlr_spl_" + lvw.id).style.display = "block";
		} else {
			$ID("lvw_je_ctl_ztlr_tit_" + lvw.id).style.display = "block";
			$ID("lvw_je_ctl_ztlr_val_" + lvw.id).style.display = "none";
			$ID("lvw_je_ctl_ztlr_spl_" + lvw.id).style.display = "none";
			$ID("lvw_je_ctl_ztlr_tit_" + lvw.id).innerHTML =  "<span style='color:red'>列【" + tit + "】无法整体输入</span>"
		}
	}else{
		if ($ID("lvw_je_ctl_ztlr_tit_" + lvw.id))
		{
			$ID("lvw_je_ctl_ztlr_tit_" + lvw.id).style.display = "none";
		}
		if ($ID("lvw_je_ctl_ztlr_val_" + lvw.id))
		{
			$ID("lvw_je_ctl_ztlr_val_" + lvw.id).style.display = "none";
		}
		if ($ID("lvw_je_ctl_ztlr_spl_" + lvw.id))
		{
			$ID("lvw_je_ctl_ztlr_spl_" + lvw.id).style.display = "none";
		}
	}
}

//JSON模式编辑.刷新列表的选中行
function ___RefreshListViewselPos(lvw) {
	var sp = lvw.selpos?lvw.selpos:0;
	___lvw_je_ztlrCHtml(lvw);
	//输出选中行

	var tb = $ID("lvw_dbtable_" + lvw.id);
	var rows = tb.rows;
	var hs = false;
	for (var ii=0; ii< rows.length; ii++ )
	{
		var tr = rows[ii];
		if((tr.getAttribute("pos")+"")==(sp+"")) {
			tr.className = "lr_je_sel";
			hs = true;
		} else {
			if(tr.className=="lr_je_sel") {
				tr.className= "";
			}
		}
	}
	if(hs==false) {
		lvw.startpos = lvw.VRows.indexOf(sp);  //
		___RefreshListViewByJson(lvw);	
	}
	try{$ID("lvw_je_ecn_" + lvw.id).value = (lvw.selpos*1+1);}catch(e){}
}

//点击选中行设置选中焦点， 或者拖动选中行
function __lvw_jn_tbmd(tb) {
	var id = tb.id.replace("lvw_dbtable_","");
	var lvw = eval("window.lvw_JsonData_"+id);
	if(window.lvw_drag_ste==1) {return;}
	var srcobj = window.event.srcElement;
	if( (srcobj.tagName=="TH" || srcobj.tagName=="TD") && srcobj.getAttribute("dbname") && srcobj.getAttribute("pid") ) {
		//点击的是表头
		for (var i = 0; lvw.headers.length; i++ )
		{
			if(lvw.headers[i].dbname == srcobj.getAttribute("dbname")) {
				lvw.selposX = i;
				___lvw_je_ztlrCHtml(lvw);
				break;
			}
		}
		return;
	}
	if( (srcobj.tagName=="TH" || srcobj.tagName=="TD") && srcobj.className.indexOf("lvwheader")>=0 && srcobj.getAttribute("cindex") ) {
		//点击的是表头
		var td = srcobj.children[0].rows[0].cells[1];
		var dbname = td.getAttribute("dbname")
		//点击的是表头
		for (var i = 0; lvw.headers.length; i++ )
		{
			if(lvw.headers[i].dbname == dbname) {
				lvw.selposX = i;
				___lvw_je_ztlrCHtml(lvw);
				break;
			}
		}
		return;
	}
	var isCmd = (srcobj.tagName=="SELECT"||srcobj.tagName=="INPUT" || srcobj.tagName=="BUTTON" || srcobj.tagName=="IMG");
	while(srcobj && (srcobj.tagName!="TD" || (srcobj.className!="lvw_cell" && srcobj.className!="lvw_index") ) ) {
		srcobj = srcobj.parentNode;
	}
	if(!srcobj || srcobj.tagName!="TD"){return;}
	var td = srcobj; srcobj = srcobj.parentNode;
	var pos = srcobj.getAttribute("pos");
	if(isNaN(pos)==false && pos!=null) {
		var tb = srcobj.parentNode.parentNode;
		lvw.selpos = pos;
		var ii = 0;
		lvw.selposX = 0;
		for (var i = 0; i < lvw.headers.length ; i++ )
		{
			if(lvw.headers[i].display!="none") {
				if(ii==td.cellIndex) { lvw.selposX = i; break; }
				ii++;
			}
		}
		try{$ID("lvw_je_ecn_" + id).value = (pos*1+1);}catch(e){}
		___RefreshListViewselPos(lvw);
		if (isCmd || lvw.edit.rowmove==0) { return ;}

		//执行拖动行准备
		var pos =  GetObjectPos(srcobj);
		var lvw_drag_initYt = (window.event.clientY + document.body.scrollTop + document.documentElement.scrollTop)-pos.top;
		var rows = tb.rows;
		var headc = tb.getAttribute("maxheads")*1;
		var rowspos =  new Array();
		for (var i = headc*1+1 ; i < rows.length-1 ; i++ ) //+1是因爲存在无数据提示值行, -1是因爲存在合计行
		{
			rowspos[rowspos.length] =  GetObjectPos(tb.rows[i]);
		}
		var fpos = rowspos[0];
		var lpos = rowspos[rowspos.length-1];
		var inih = srcobj.offsetHeight;
		var inil = tb.parentNode.scrollLeft;
		var lastscell =  null;
		var lastscpos = -1;
		function setDragSCell(cell) {
			cell.style.backgroundImage = "url(" +  window.sysskin + "/images/lvwdrag.gif)";
			cell.style.backgroundRepeat = "repeat-x";
			cell.style.backgroundPosition = "left top";
		}
		app.beginMoveElement(srcobj, 
			function() { //moving
				window.lvw_drag_ste=1;
				var div = $ID("lvw_row_dragdiv");
				var cY = window.event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
				srcobj.style.cursor = "move";
				if(!div) {
					div = document.createElement("div");
					div.id = "lvw_row_dragdiv";
					document.body.appendChild(div);
					var cols = srcobj.parentNode.parentNode.getElementsByTagName("col");
					var htmls = new Array();
					for (var i = 0; i <cols.length ; i++ ) { htmls[i] = cols[i].outerHTML; }
					div.innerHTML = "<table class='lvwframe2' style='margin-left:-" + inil + "px'>" + htmls.join("") + srcobj.outerHTML.replace(id,"").replace(/onmousedown/g,"") + "</table>";
					div.style.width = srcobj.offsetWidth > tb.parentNode.offsetWidth?tb.parentNode.offsetWidth:srcobj.offsetWidth;
					div.style.height = inih;
				}
				div.style.left = parseInt(pos.left+1) + "px";
				var t = (cY-lvw_drag_initYt);
				var b = (t+inih);
				if(t<fpos.top) {t=fpos.top;}
				if(t>lpos.top) {t=lpos.top;}
				div.style.top = t + "px";
				var srow = -1;
				var ci = 0;
				for (var i = 0; i < rowspos.length ; i++)
				{
					var p = rowspos[i];
					var jiao = 0;
					var row = tb.rows[ headc*1+1+i];
					var cell = row.cells[0];
					if(srow==-1){	
						if(t>=p.top && t<(p.top+p.height)) {
							jiao = (p.top+p.height-t);
							if((jiao-(inih*0.5))>=0){ srow = i;setDragSCell(cell); lastscell = cell; continue; }
						}
						else if(b>=p.top && b<(p.top+p.height)) {
							jiao = (b-p.top);
							if((jiao-(inih*0.5))>0){ srow = i;setDragSCell(cell); lastscell = cell; continue;}
						}
					}
					cell.style.backgroundImage = "";
					cell.style.backgroundRepeat = "";
					cell.style.backgroundPosition = "3px center";
				}
				lastscpos = srow;
			},
			function () { //move end
				window.lvw_drag_ste=0;
				var div = $ID("lvw_row_dragdiv");
				srcobj.style.cursor = "";
				if(div){document.body.removeChild(div);} else{return;}
				if(lastscell) {
					lastscell.style.backgroundImage = "";
					lastscell.style.backgroundRepeat = "";
					lastscell.style.backgroundPosition = "3px center";
				}
				var PosRow =tb.rows[headc*1+1+lastscpos*1];
				var newpos = PosRow.getAttribute("pos");
				var oldpos = srcobj.getAttribute("pos");
				__lvw_je_rowmove(lvw,oldpos,newpos-oldpos);
			}
		);
	}
}

//JSON模式编辑.行位置移动
function __lvw_je_rowmove(lvw, pos, movev) {
	if(movev==0) {return;}
	var cell = lvw.rows[pos];
	var gopos = pos*1+movev*1;
	if(gopos<0 || gopos>lvw.rows.length-1) {return;}
	if(movev<0) { //上移
		for (var i=pos; i> gopos; i--){ lvw.rows[i] = lvw.rows[i-1]; }
	}else {
		for (var i=pos; i< gopos; i++) { lvw.rows[i] = lvw.rows[i*1+1]; }
	}
	lvw.rows[gopos]=cell;
	lvw.selpos = gopos;
	___RefreshListViewByJson(lvw);
}

//JSON模式编辑.插入新行
function __lvw_je_addNew(id) {
	var lvw = eval("window.lvw_JsonData_"+id);
	var newpos = lvw.rows.length;
	lvw.rows[newpos] = new Array();
	lvw.VRows.push(newpos);
	lvw.recordcount++;
	var headers = lvw.headers;
	var ii = 0;
	for (var i = 0; i< headers.length ; i ++ )
	{
		//if(headers[i].display!="none") {
			lvw.rows[newpos][ii] = headers[i].defval;
			ii++;
		//}
	}
	lvw.selpos = newpos;
	___ReSumListViewByJsonData(lvw);
	___RefreshListViewByJson(lvw);
	___RefreshListViewselPos(lvw);
}

//JSON模式编辑.弹出URL数据源选择框
function __lvw_je_sorceurlOpen(url, box) {
	var td = box.parentNode;
	var tb = app.getParent(td,3);
	var ids = td.children[0].id.split("_");
	var winn = tb.id + "_" + ids[ids.length-1];
	var fw = (screen.availWidth?screen.availWidth:screen.Width);
	var fh = (screen.availHeight?screen.availHeight:screen.Height);
	var w = parseInt(fw*0.8);
	var h = parseInt(fh*0.8);
	var l = 0, t = 0;
	if(url.indexOf("?")>0) {
		var urls = url.split("?")[1].split("&");
		for(var i = 0; i < urls.length; i++) {
			if(urls[i].indexOf("width=")==0) { w=urls[i].replace("width=",""); }
			if(urls[i].indexOf("height=")==0){ h=urls[i].replace("height=",""); }
			if(urls[i].indexOf("left=")==0) { l=urls[i].replace("left=",""); }
			if(urls[i].indexOf("top=")==0){ t=urls[i].replace("top=",""); }
		}
	}
	if(l==0) { l = parseInt((fw-w)*0.5);}
	if(t==0) { t = parseInt((fh-h)*0.5);}
	window.open(url, winn, "width=" + w + "px,height=" + h + "px,top=" + t + "px,left=" + l + "px,resizable=1,scrollbars=1,titlebar=0,status=0");
}

//数据操作函数.删除行集
function __lvw_je_deleteRows(id) {
	return function(startindex, length, refresh) {
		var lvw = eval("window.lvw_JsonData_"+id);
		for (var i = startindex*1+length*1-1; i>=startindex ; i-- ){ lvw.deleteRow(i,false);}
		if(refresh) {
			lvw.VRows.sort(function(a,b){return a>b?1:-1});
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw);
		}
		lvw = null;
	}
}
//数据操作函数.删除行
function __lvw_je_deleteRow(id) {
	return function(startindex, refresh) {
		var lvw = eval("window.lvw_JsonData_"+id);
		lvw.rows.splice(startindex,1);
		var deli = -1;
		for (var i = 0; i < lvw.VRows.length ; i++ )
		{
			if(lvw.VRows[i]>startindex) { lvw.VRows[i]--;}
			if(lvw.VRows[i]==startindex) { deli = i;}
		}
		if(deli>-1) {lvw.VRows.splice(deli,1);}
		if(refresh) {
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw); 
		} 
		lvw = null;
	}
}
//数据操作函数.插入行集
function __lvw_je_insertRows(id) {
	return function(newRows, startindex, refresh, visibleRows) {
		var lvw = eval("window.lvw_JsonData_"+id);
		var al = newRows.length;
		var nc = startindex*1+al;
		if(!visibleRows) {
			visibleRows = new Array();
			for (var i = 0; i<newRows.length ; i++ ){visibleRows[i] = i;}
		}
		for (var i=0; i < visibleRows.length ; i++ )
		{ visibleRows[i] = visibleRows[i]+startindex*1; }
		for (var i = 0; i < lvw.VRows.length ; i++ )
		{if(lvw.VRows[i]>=startindex) { lvw.VRows[i]=lvw.VRows[i]+al;}}
		for (var i = 0; i < newRows.length ; i++ )
		{ lvw.rows.splice(startindex+i,0,newRows[i]); }
		for (var i = 0; i<visibleRows.length ; i++ )
		{ lvw.VRows.push(visibleRows[i]); }
		if(refresh) {
			lvw.VRows.sort(function(a,b){return a>b?1:-1});
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw); 
		}
		lvw = null;
	}
}
//数据操作函数.插入插入行
function __lvw_je_insertRow(id) {
	return function(newRow, startindex, refresh) {
		var lvw = eval("window.lvw_JsonData_"+id);
		lvw.rows.splice(startindex,0, newRow);
		for (var i = 0; i < lvw.VRows.length ; i++ )
		{if(lvw.VRows[i]>=startindex) { lvw.VRows[i]++;}}
		lvw.VRows.push(startindex);
		if(refresh) {
			lvw_je_RowVisible(lvw, startindex, false); 
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw); 
		}
		lvw = null;
	}
}
function __lvw_je_addNewProx(id) {
	return function(){
		__lvw_je_addNew(id);
	}
}

function _lvw_je_RefreshListTreeNode(id, rowindex, isRefreshCurrNode, fun) {
	ajax.regEvent("sys_lvw_callback");
	ajax.addParam("cmd","refreshTreeNode");
	ajax.addParam("backdata",$ID("__viewstate_lvw_" + id).value);
	ajax.addParam("lvwid",id);
	rowindex = rowindex*1;
	if(fun) {fun();}
	var data = ajax.send();
	var json;
	try{
		json = eval("(" + data + ")");
	} catch(e) {
		app.Alert("节点更新失败：" + e.message + data);
		return;
	}
	var lvw = eval("window.lvw_JsonData_"+id);
	var deepl = "";
	var nodeindex = -1;
	var hsnxt = "0"; 
	for (var i = 0; i < lvw.headers.length ;i++ )
	{
		var h = lvw.headers[i];
		if(h.uitype=="tree") {
			nodeindex = i;
			hsnxt = lvw.rows[rowindex][i].nxt?"1":"0";
			deepl = lvw.rows[rowindex][i].deeps;
			break;
		}
	}
	if(nodeindex==-1) { app.Alert("当前要更新的列表没有树节点"); return;};
	if(isRefreshCurrNode) { //更新当前节点
		json.rows[0][nodeindex].deeps = lvw.rows[rowindex][nodeindex].deeps;
		if (hsnxt == "1")
		{
			json.rows[0][nodeindex].nxt = hsnxt;
		}
		lvw.rows[rowindex] = json.rows[0];
	}
	json.rows.splice(0,1);
	var c = 0;
	for (var i = rowindex*1+1; i<lvw.rows.length; i++ )
	{
		var jv = lvw.rows[i][nodeindex];
		if(jv.deeps.length>deepl.length){c++;}else{break;}
	}

	lvw.deleteRows(rowindex*1+1,c, true);
	var jsc = new Array();
	for(var i = 0; i<json.rows.length; i++) {
		var s = json.rows[i][nodeindex].deeps;
		if(s&&s.length>0) {s=s.substr(1);}else {s="";}
		json.rows[i][nodeindex].deeps = deepl+hsnxt+s;
	}
	lvw.insertRows(json.rows,rowindex*1+1,false);
	lvw.VRows.sort(function(a,b){return a>b?1:-1});
	lvw.recordcount = lvw.rows.length;
	lvw.Refresh();
}
