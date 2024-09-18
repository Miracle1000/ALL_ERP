if(app.IeVer<8) 
{
	__tvwcolresize = function(div,id,isAutoresize){
		__lvw_tabonresize(div, id);
		return false;
	}
}
var ifHasObj=document.getElementById("hidebar");
if (ifHasObj){
	if(ifHasObj.value==0) {
		document.body.style.backgroundImage = "url(" + window.sysskin + "/images/topbar0004.gif)";
	}
	else{
		document.getElementById("comm_itembarbg").style.height = "32px";
	}
}else{
		document.getElementById("comm_itembarbg").style.height = "32px";
}

var em = document.getElementById("searchitemsbutton");
if(em)
{
	em.style.position = "static";
	em.style.display = "inline";
	var html = em.outerHTML;
	em.outerHTML = "";
	document.getElementById("asearchlink").innerHTML = html + "&nbsp;";
}
//禁止select内容超长
function xzSelectWidth()
{
	var boxs = document.getElementById("toparea").getElementsByTagName("select");
	for (var i = 0 ; i < boxs.length ; i ++ )
	{
		if(boxs[i].offsetWidth>140)
		{
			boxs[i].style.width = "140px";
		}
	}
}
xzSelectWidth();

//更新关联字段
function joinFieldUpdate(name, value)
{
	ajax.regEvent("ReportJoinField");
	ajax.addParam("name",name);
	ajax.addParam("value", value.length==0?'0':value);
	ajax.send(
		function(data)
		{
			var dat = data.split("\3\1");
			if(dat.length==1) {
				alert(data);
				return;
			}
			document.getElementById("sfields_" + dat[0]).innerHTML = dat[1];
			xzSelectWidth();
			if(window.onjoinFieldUpdate)
			{
				window.onjoinFieldUpdate(name, value);
			}
		}	
	);
}

window.onsearchpanlChange = function(t) {
	var div = $ID("commfieldsBox");
	if(div.getAttribute("onlyadSearchModel")=="1") {
		if(t==1) {
			div.setAttribute("connHTML", div.innerHTML);
			div.innerHTML = "";
			div.style.display = "none";
			$ID("asearchlinkBg").style.display = "none";
			$ID("fieldsBox").style.paddingTop = "0px";
			$ID("comm_itembarbg").style.height = "32px";
		}
		else {
			var html = div.getAttribute("connHTML");
			if(html==null || html=="null" || html=="" ||!html) {return;}
			div.innerHTML = html;
//			div.innerHTML = div.getAttribute("connHTML");
			div.setAttribute("connHTML", null);
			div.style.display = "block";
			$ID("asearchlinkBg").style.display = "block";
			$ID("fieldsBox").style.paddingTop = "13px";//高级检索，顶部padding
			$ID("comm_itembarbg").style.height = "33px";
		}
	}
}

window.currAjax = new xmlHttp();
window.currSendData = null;
function LoadSearchAttrs(ax) {
	ax.addParam("pagesize",$ID("PageSizeBox").value);
	ax.addParam("dbtxt", $ID("dbtxt").value);
	ax.addParam("groups", $ID("groups").value);
	ax.addParam("pbtnalign", $ID("pbtnalign").value);
	ax.addParam("IsIE8", $ID("IEModel").value.toLowerCase().indexOf("8") > 0 ? "1" : "0");
	ax.addParam("cancolset", $ID("cancolset").value);
	ax.addParam("BillListUIModel",$ID("BillListUIModel").value);
	ax.addParam("financeUIModel",$ID("financeUIModel").value);
	ax.addParam("excelextIntro",$ID("excelextIntro").value);
	ax.addParam("ckboxdbname",$ID("ckboxdbname").value);
	ax.addParam("batbuttons",$ID("batbuttons").value);
	ax.addParam("fixheader",$ID("fixheader").value);
	ax.addParam("openkzzdy",$ID("openkzzdy").value);
	ax.addParam("ServerLinkCols",$ID("ServerLinkCols").value);
	var box = $ID("commfieldsBox");
	for (var i = 0 ; i < box.children.length ; i ++ )
	{
		var ibox = box.children[i];
		if(ibox.tagName=="DIV" && ibox.className=="sfield" && ibox.getAttribute("ftype") && ibox.id.indexOf("sfields_")==0) 
		{
			var id =  ibox.id.replace("sfields_","");
			if(id.length > 0)
			{
				ax.addParam("rpt_f_" + id, getFieldValue(ibox));	
			}
		}
	}
	var adbox = $ID("searchitemspanel")
	var sbo = $ID("commfieldsBox").getAttribute("onlyadSearchModel")*1;
	if(adbox) //存在高级检索
	{	if(	sbo!=1 || window.__isadsearchmodel==1) 
		{
			var tds = adbox.getElementsByTagName("td")
			for (var i = 0 ; i < tds.length ; i ++ )
			{
				var ibox = tds[i];
				if(ibox.className=="asearchdatatd") 
				{
					var id =  ibox.id.replace("sfields_","");
					if(id.length > 0)
					{
						if(id.indexOf("A_dFx_")==0) {
							ax.addParam(id, getAFieldValue(ibox));
						} else {
							ax.addParam("rpt_f_" + id, getAFieldValue(ibox));
						}
					}
				}
			}
		}
	}
	var hdatas = document.getElementsByName("hiddedatas");
	for (var i = 0; i < hdatas.length ; i ++ )
	{
		var em = hdatas[i];
		ax.addParam("rpt_f_" + em.id, em.value);
	}
	//获取url参数传值
	/*当前页面URL，如：http://127.0.0.1/work/telhy2.asp?currpage=1&a=1&b=2&c=3*/ 
	var allurl=document.URL.split("?");
	var baseparam="";/*基础参数,比如：currpage=1&a=1&b=2&c=3*/
	if (allurl.length > 1){
		baseparam = allurl[1].replace(/\#/g, ""); 
		var arrvalue = baseparam.split("&");
		for(var i=0;i<arrvalue.length&&arrvalue!='';i++) 
		{ 
			var vnode=arrvalue[i].split("="); 
			ax.addParam(vnode[0], vnode[1]);
		}
	}	
}

function ReportCellClick(dbname , keyord){
	var ax = window.currAjax;
	ax.sendText ="__msgid=ReportServerLink&" + window.currSendData.split("pagesize="+$ID("PageSizeBox").value+"&")[1]+"&__coldbname="+escape(dbname)+"&__keyord="+escape(keyord) ;
	ax.Http.onreadystatechange = function(){};
	var r= ax.send()
	if(window.ReportServerLinkData){window.ReportServerLinkData(r , dbname, keyord );}else{app.Alert("window.ReportServerLinkData函数未定义");}
}
//是否开启页面扫描检索事件
window.__scanTime = 0;
window.__scanIntro = "";
document.onkeyup = function(){
	//判断开启页面扫描功能
	if(window.__canScanSearch ==1){
		//判断事件源不是在input select areatext上面
		var eobj = window.event.srcElement;
		if ( (eobj.tagName!="INPUT" || eobj.type=="button" || eobj.type=="submit" || eobj.type=="image") && eobj.tagName!="TEXTAREA"){
			//判断录入时间间隔
			var myDate = new Date();
			var mytime=myDate.getTime();     //获取当前时间
			if(window.event.keyCode==13) {
				//if(window.__scanIntro.length>=3){
					ReportSubmit(window.__scanIntro);
				//}
				window.__scanIntro = "";
				window.__scanTime=0;
				return;
			}

			if ( mytime-window.__scanTime<=200 && mytime-window.__scanTime>=0)
			{	
				window.__scanIntro = (window.__scanTime==0 ? "": window.__scanIntro) + String.fromCharCode(window.event.keyCode);
				
			}else{
				window.__scanIntro = String.fromCharCode(window.event.keyCode);
			}
			window.__scanTime = mytime ;

		}
	}
}

function ReportSubmit(scanfText)
{
	window.__Report_Fields_OK = true; 
	window.onReportSubmiting = 1;
	var lvwbody = $ID("lvwbody");
	if(lvwbody.getAttribute("jsonEditModel")==1) { return ; } //json编辑模式，不通过异步提交加载数据
	var ax = window.currAjax;
	__rpt_addBatResultClear();
	ax.regEvent("ReportSubmit");
	LoadSearchAttrs(ax);
	ax.addParam("sortkey",window.__ReportSortKey)
	ax.addParam("scantext",scanfText?scanfText:"");
	ax.addParam("asrcm", window.__isadsearchmodel)
	if (window.location.href.indexOf("?")>0)
	{
		ax.addParam("UrlAttrs", window.location.href.split("?")[1])
	}
	if(window.__isadsearchmodel==1) { 
		//保持高度，防止点击高级检索按钮晃动
		lvwbody.style.height = lvwbody.offsetHeight + "px";
	}
	if (window.__Report_Fields_OK == false){ return; }
	window.currSendData = ax.sendText;//记录当前提交
	showProcDiv();
	ax.send(function(r)
		{
			try{
				lvwbody.style.height = "auto";
				hideProcDiv();
				$ID("lvwbody").innerHTML = r;
				if (r.indexOf("showECharts")) {
					$ID("lvw_tablebg_mlistvw").style.overflow = "visible";
				}
				//UI调整 
				lvwbodyResize();
			}
			catch(e){
				app.Alert("Load Fail, " + e.message);
			}
			window.onReportSubmiting = 0;
		}
	);
	
}

function lvwbodyResize(){
	try{
		var w = document.getElementById("lvwbody").style.width;
		var w2 = document.getElementById("lvw_dbtable_mlistvw").offsetWidth;
		if(w2 > document.body.offsetWidth && w.length > 0) {
			if($ID("lvw_mlistvw").getAttribute("fixheight")!="1") {
				document.getElementById("lvwbody").style.width = w2 + "px";
			}
			else{
				document.getElementById("lvwbody").style.width = "100%";
				document.getElementById("lvwbody").style.overflow = "hidden";
			}
		}
		else{
			if($ID("lvw_mlistvw").getAttribute("fixheight")=="1") { 
				document.getElementById("lvwbody").style.width = "100%";
				document.getElementById("lvwbody").style.overflow = "hidden";
			}
		}
	}catch(e){}
	if(window.onReportRefresh)
	{
		window.onReportRefresh();
	}
	if (window.__ShowImgBigToSmall== true)
	{
		window.__ImgBigToSmall();
	}
	OnReportBodyResize();
	if(top.frameResizeNew) {top.frameResizeNew();} //E产品线 框架高度定时计算	
}

function showProcDiv() {
	var div = $ID("showProcDivDom");
	if(!div) {
		div = document.createElement("div");
		div.id = "showProcDivDom";
		document.body.appendChild(div);
		div.innerHTML = "<br><br><table class='resetHeadBg resetBorderColor' style='background-color:#f3f8ff;width:280px;border:1px solid #ccc' align='center' cellpadding=10><tr>"
					+ "<td style='padding-top:10px;padding-left:30px;width:20px'><img height='20' src='" + window.sysskin + "/images/proc.gif'></td>" 
					+ "<td style='width:160px;color:#000;background-color:white;text-align:left'>正在加载数据，请稍候...</td><td width='auto'>&nbsp;</td></tr></table>"
	}
	pos = fGetXY($ID("lvwbody"));
	var tb = $ID("lvw_dbtable_mlistvw");
	if(tb) {
		div.style.cssText = "display:block; position:fixed; _position:absolute;left:" + pos.x + "px;top:" + (pos.y+1) + "px; width:100%;_width:" + tb.offsetWidth + "px;height:" + (tb.offsetHeight-2) + "px;"
	}
	else{
		div.style.cssText = "display:block; position:absolute;left:" + pos.x + "px;top:" + (pos.y+1) + "px;width:100%;height:100px;"
	}
}

function hideProcDiv() {
	var div = $ID("showProcDivDom");
	if(div) {
		div.style.display = "none";
	}
}

//获取某个字段的值
function getFieldValue(ibox)
{
	var t = ibox.getAttribute("ftype");
	var d1 , d2, ttype;
	switch(t)
	{
		case "select": return ibox.getElementsByTagName("select")[0].value;
		case "text": return ibox.getElementsByTagName("input")[0].value;
		case "URLText": return ibox.getElementsByTagName("input")[0].value;
		case "months": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "date" : return ibox.getElementsByTagName("input")[0].value;
		case "radio" : return getRadioValue(ibox)
		case "dates":
			d1 = ibox.getElementsByTagName("input")[0].value;
			d2 = ibox.getElementsByTagName("input")[1].value;
			var d11 ,d22
			if (d1!=''){d11 = new Date(d1.replace(/\-/g,"/").replace(/\./g,"/"));}
			if (d2!=''){d22 = new Date(d2.replace(/\-/g,"/").replace(/\./g,"/"));}
			if(window.__Report_Fields_OK == true && d11 > d22 && d11 && d22) 
			{
				ttype = (d1.indexOf(":") > 0 ? "时间" : "日期");
				app.Alert("温馨提示：\n\n快速检索中不能存在【起始" + ttype + "】大于【截止" + ttype + "】的条件。\n");
				window.__Report_Fields_OK = false;
			}
			//日期时间其他控制
			if(window.__Report_Date_Check){window.__Report_Date_Check(d11 , d22 , 1);}
			return d1 + "\1" + d2;
		case "datetime": 
			d1 = ibox.getElementsByTagName("input")[0].value;
			d2 = ibox.getElementsByTagName("input")[1].value;
			var d11 ,d22
			if (d1!=''){d11 = new Date(d1.replace(/\-/g,"/").replace(/\./g,"/"));}
			if (d2!=''){d22 = new Date(d2.replace(/\-/g,"/").replace(/\./g,"/"));}
			if(window.__Report_Fields_OK == true && d11 > d22 && d11 && d22)
			{
				ttype = (d1.indexOf(":") > 0 ? "时间" : "日期");
				app.Alert("温馨提示：\n\n快速检索中不能存在【起始" + ttype + "】大于【截止" + ttype + "】的条件。\n");
				window.__Report_Fields_OK = false;
			}
			if(window.__Report_Date_Check){window.__Report_Date_Check(d11 , d22 , 1);}
			return d1 + "\1" + d2;
		case "gategroup": return ibox.getElementsByTagName("select")[0].value + "\1" + ibox.getElementsByTagName("select")[1].value ;
		case "gategroup2": return ibox.getElementsByTagName("select")[0].value + "\1" + ibox.getElementsByTagName("select")[1].value ;
		case "gategroup3": return ibox.getElementsByTagName("select")[0].value + "\1" + ibox.getElementsByTagName("select")[1].value ;
		case "gategroup4": return ibox.getElementsByTagName("select")[0].value + "\1" + ibox.getElementsByTagName("select")[1].value ;
		case "telcls": return ibox.getElementsByTagName("select")[0].value + "\1" + ibox.getElementsByTagName("select")[1].value ;
		case "rate": return ibox.getElementsByTagName("input")[0].value;
		case "hidden": return ibox.getElementsByTagName("input")[0].value;
		case "sortonehy": return ibox.getElementsByTagName("select")[0].value;
		case "stores" :  return ibox.getElementsByTagName("input")[0].value;
		default: return window.confirm("快速检索getFieldValue函数.未定义类型【" + t + "】");
	}
}

function getRadioValue(ibox) {
	var boxs = ibox.getElementsByTagName("input");
	for (var i = 0 ; i < boxs.length ; i++)
	{
		if(boxs[i].checked) { return boxs[i].value; }
	}
}

//获取高级检索字段的值
function getAFieldValue(ibox)
{
	var t = ibox.getAttribute("ftype");
	var d1 , d2, ttype;
	switch(t)
	{
		case "text": return ibox.getElementsByTagName("input")[0].value;
		case "moneys": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "numbers": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "ints": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "cpfl": return "@cpfl=" + getcpflList(ibox);
		case "radios" : return getRadioValue(ibox)
		case "checks": return getchecks(ibox);
		case "gateoption" : return getgates(ibox,"gateoption");
		case "gates": return getgates(ibox,"gates");
		case "gates2": return getgates(ibox,"gates2");
		case "gates3": return getgates(ibox,"gates3");
		case "gates4": return getgates(ibox,"gates4");
		case "gategroup": return getgates(ibox,"gategroup");
		case "gategroup2": return getgates(ibox,"gategroup2");
		case "gategroup3": return getgates(ibox,"gategroup3");
		case "gategroup4": return getgates(ibox,"gategroup4");
		case "months": return ibox.getElementsByTagName("input")[0].value + "\1" + ibox.getElementsByTagName("input")[1].value;
		case "date" : return ibox.getElementsByTagName("input")[0].value;
		case "datetimes":
		case "dates": 
			d1 = ibox.getElementsByTagName("input")[0].value;
			d2 = ibox.getElementsByTagName("input")[1].value;
			//BUG 6507  Sword 2014-12-15 财务，凭证列表检索时的日期选择问题 
			var d11 ,d22
			if (d1!=''){d11 = new Date(d1.replace(/\-/g,"/").replace(/\./g,"/"));}
			if (d2!=''){d22 = new Date(d2.replace(/\-/g,"/").replace(/\./g,"/"));}
			if(window.__Report_Fields_OK == true && d11 > d22 && d11 && d22) 
			{
				ttype = (d1.indexOf(":") > 0 ? "时间" : "日期");
				app.Alert("温馨提示：\n\n高级检索中不能存在【起始" + ttype + "】大于【截止" + ttype + "】的条件。\n");
				window.__Report_Fields_OK = false;
			}
			if(window.__Report_Date_Check){window.__Report_Date_Check(d11 , d22 , 2);}
			return d1 + "\1" + d2;
		case "selectys": return ibox.getElementsByTagName("select")[0].value + "\1" + ibox.getElementsByTagName("input")[0].value;
		case "datetime": 
			d1 = ibox.getElementsByTagName("input")[0].value;
			d2 = ibox.getElementsByTagName("input")[1].value;
			var d11 ,d22
			if (d1!=''){d11 = new Date(d1.replace(/\-/g,"/").replace(/\./g,"/"));}
			if (d2!=''){d22 = new Date(d2.replace(/\-/g,"/").replace(/\./g,"/"));}
			if(window.__Report_Fields_OK == true && d11 > d22 && d11 && d22) 
			{
				ttype = (d1.indexOf(":") > 0 ? "时间" : "日期");
				app.Alert("温馨提示：\n\n高级检索中不能存在【起始" + ttype + "】大于【截止" + ttype + "】的条件。\n");
				window.__Report_Fields_OK = false;
			}
			if(window.__Report_Date_Check){window.__Report_Date_Check(d11 , d22 , 2);}
			return d1 + "\1" + d2;
		case "select": return ibox.getElementsByTagName("select")[0].value;
		case "checkszt": return getchecks(ibox);
		case "treechecks": return getchecks(ibox);
		case "sortonehy": return getchecks(ibox);
		case "telcls": return gettelcls(ibox);
		case "wages": return getwages(ibox);
		case "khqy" : return "@area=" + getchecks(ibox); //BUG.2558.Binary.2013.10.12 区域数据特殊处理
		case "paycls": return getPaycls(ibox);
		case "ckcls": return "@ckcls=" + getCkcls(ibox);
		case "source": return "";
		default:
			 return window.confirm("高级检索getAFieldValue函数.未定义类型【" + t + "】");
	}
}

function ReportURLTo(url) {
	var frm = $ID("__ReportPostFrm");
	$ID("toparea").style.display = "none";
	$ID("lvwbody").style.display = "none";
	if(!frm) {
		frm = document.createElement("div");
		frm.innerHTML = "<iframe id='__ReportPostFrm_box' style='background-color:white' frameborder=0 src=\"" + url.replace("\"","%22") + "\"></iframe>"
		frm.id = "__ReportPostFrm";
		document.body.appendChild(frm);
	}
	else{
		$ID("__ReportPostFrm_box").contentWindow.location.href = url;
	}
	frm.style.display = "block";
}

function ReportURLBack() {
	$ID("__ReportPostFrm").style.display = "none";
	$ID("__ReportPostFrm_box").contentWindow.location.href = "about:blank";
	$ID("toparea").style.display = "block";
	$ID("lvwbody").style.display = "block";
	window.DoRefresh();
}


//人员选择清单
function getgates(ibox, gt) {
	var w1 = new Array();
	var w2 = new Array();
	var w3 = new Array();
	var wt = new Array();
	var boxs = ibox.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		var bx = boxs[i];
		if(bx.checked)
		{
			switch(bx.name.toLowerCase()) {
				case "w1": w1[w1.length] = bx.value; break;
 				case "w2": w2[w2.length] = bx.value; break;
				case "w3": w3[w3.length] = bx.value; break;
				case "wt" : wt[wt.length] = bx.value; break;
			}
		}
	}
	if (gt.indexOf("gategroup")==-1)	{
		if (gt.indexOf("gateoption")>-1){
			return wt.join(",")+ "\1" + w1.join(",") + "|" + w2.join(",") + "|" + w3.join(",");
		}else{
			return "@sysgt=" + gt + "|" + w1.join(",") + "|" + w2.join(",") + "|" + w3.join(",");
		}
	}else{
		return  w1.join(",") + "\1" + w2.join(",");
	}
}

//客户分类选择清单
function gettelcls(ibox) {
	var w1 = new Array();
	var w2 = new Array();
	var w3 = new Array();
	var boxs = ibox.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		var bx = boxs[i];
		if(bx.checked)
		{
			switch(bx.name.toLowerCase()) {
				case "e": w1[w1.length] = bx.value; break;
 				case "f": w2[w2.length] = bx.value; break;
			}
		}
	}
	return w1.join(",") + "\1" + w2.join(",");
}
//工资项目
function getwages(ibox) {
	var sortwages = 0;
	var wages = new Array();
	var boxs = $(ibox).find(":checkbox[name=wage]:checked");	
	boxs.each(function(i,bx){
		sortwages = bx.value;
		var wsort = "";
		var wsorts = "";
		var boxs1 = $("#wage"+sortwages).find(":checkbox[name=wsort]");
		boxs1.each(function(ii,bx1){
			if(bx1.checked==true)
			{
				if (wsort.length>0){wsort = wsort + ",";}
				wsort = wsort + bx1.value ;
			}
			else
			{
				if (wsorts.length>0){wsorts = wsorts + ",";}
				wsorts = wsorts + bx1.value ;
			}
		})
		if (wsort.length>0){
			wages[i] = sortwages + "|" + wsort ;
		}
		else if (wsorts.length>0)
		{
			wages[i] = sortwages + "|" + wsorts ;
		}
	})
	return wages.join("||");
}

//费用分类选择清单
function getPaycls(ibox) {
	var w1 = new Array();
	var w2 = new Array();
	var boxs = ibox.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		var bx = boxs[i];
		if(bx.checked)
		{
			switch(bx.name.toLowerCase()) {
				case "paysort": w1[w1.length] = bx.value; break;
 				case "paytype": 
					if (bx.parentElement.parentElement.style.display != "none")
					{
						w2[w2.length] = bx.value;
					}	
					break;
			}
		}
	}
	return w1.join(",") + "\1" + w2.join(",");
}

//仓库分类选择清单
function getCkcls(ibox) {
	var s = new Array();
	var s1 = new Array();
	var boxs = ibox.getElementsByTagName("input");
	for (var i = 0; i<boxs.length ; i ++ )
	{
		var bx = boxs[i];
		if(bx.checked)
		{	
			var divid = bx.id.replace("_cb","");
			var div = document.getElementById(divid);
			var a =  div.getElementsByTagName("a")[0];
			if(a){
				if (a.getAttribute("canselect")!="0")
				{
					s[s.length] = a.getAttribute("value");
				}
				else{
					s1[s1.length] = a.getAttribute("value");
				}
			}
		}
	}
	return s1.join(",")+"|"+s.join(",");
}

//勾选框清单
function getchecks(ibox) {
	var s = new Array();
	var boxs = ibox.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		if(boxs[i].checked)
		{
			s[s.length] = boxs[i].value;
		}
	}
	return s.join(",");
}

//产品分类清单
function getcpflList(box)
{
	var s = new Array();
	var boxs = box.getElementsByTagName("input")
	for (var i = 0; i<boxs.length ; i ++ )
	{
		if(boxs[i].checked)
		{
			s[s.length] = boxs[i].value;
		}
	}
	return s.join(",");
}

function searchClick(){
	window.__isadsearchmodel = 1;
	ReportSubmit();
}

function searchQuickClick(){
	window.__isadsearchmodel = 0;
	ReportSubmit();
}

function resetClick(){
	var inputs =  document.getElementsByTagName("input")
	for (var i = 0 ; i < inputs.length ; i ++ )
	{
		var b = inputs[i]
		if(b.type=="text") { b.value = b.defaultValue; }
		if(b.type=="checkbox") { b.checked = false; }
	}
}

function gategroup1change(gbox) {
	var id2 = (gbox.id + "\1\2").replace("_g1\1\2","_g2");
	var gbox2 = $ID(id2);
	var data = gbox.options[gbox.selectedIndex].getAttribute("gatelist");
	var html = "<select id='" + id2 + "'><option value=''>==不限==</option>";
	if(data) {
		var datar = data.split("|*|");
		for (var i = 0; i < datar.length ; i++ )
		{
			var item = datar[i].split("$#%");
			html = html + "<option value='" + item[0] + "'>" + item[1] + "</option>";
		}
	}
	html = html + "</select>";
	gbox2.parentNode.innerHTML = html;
}


var bottomdivobj = null;
window.onscroll = function(){
	try
	{
		if(!bottomdivobj) { bottomdivobj = document.getElementById("bottomdiv");}
		var l =  document.body.scrollLeft + document.documentElement.scrollLeft;
		bottomdivobj.style.left = l + "px";
	}
	catch (e) { }
}

//刷新报表 IsAsyn = true 表示异步 false表示同步
window.DoRefresh = function(IsAsyn) {	
	if(IsAsyn==false) {
		//同步刷新
		lvw_refresh("mlistvw");	
	}
	else{
		//目前暂不支持异步刷新
		lvw_refresh("mlistvw");
	}
}

function rpt__allck(ckbox) {
	var boxs = document.getElementsByName("sys_lvw_ckbox");
	for (var i = 0 ; i < boxs.length ; i++ )
	{
		boxs[i].checked = ckbox.checked;
	}
}

function rpt_showsortdlg(link) {
	var div = $ID("rptsortlist");
	if(!div) {
		div = document.createElement("div");
		div.id = "rptsortlist";
		var html = new Array();
		for (var i = 0; i < window.reportSorts.length ; i ++ )
		{
			var item = window.reportSorts[i];
			if(item[0]=="__col__" && item[1]=="__col__") {
				var cols = $ID("lvw_dbtable_mlistvw").getElementsByTagName("COL");
				for (var ii = 0; ii< cols.length; ii++ )
				{
					var c = cols[ii];
					if(c.getAttribute("cansort")=="1") {
						item = (c.getAttribute("title") + "\1" + c.getAttribute("dbname")).split("\1");
						addItemSortHtml(html, item);
					}
				}
			}
			else{
				addItemSortHtml(html, item, 0);
			}
		}
		html[window.reportSorts.length] = '<span class="top-reverse-arrow"></span>';
		div.innerHTML = html.join("");
		div.className = 'resetTableBg'
		document.body.appendChild(div);
	}
	var pos = GetObjectPos(link);
	div.style.left = (pos.left - (div.offsetWidth/2 - pos.width/2) ) + "px";
	div.style.top = pos.top + 24 + "px";
	if (div.style.display == "block"){div.style.display = "none";}else{div.style.display = "block";}
}

function addItemSortHtml(html, itemarr) {
	if(window.SortUiType==0) {
		html[html.length] = "<div class='rptsortitem'><a class='reseetTextColor' href='javascript:void(0)' onclick='doReportSort(this,\"-" + itemarr[1] + "\")'>按" + itemarr[0] + "排序(降)</a></div>";
		html[html.length] = "<div class='rptsortitem'><a class='reseetTextColor' href='javascript:void(0)' onclick='doReportSort(this,\"" + itemarr[1] + "\")'>按" + itemarr[0] + "排序(升)</a></div>";
	}
	else{
		html[html.length] = "<div class='rptsortitem' style='text-align:right'>按" + itemarr[0] + "排序： "
							+ "<a href='javascript:void(0)' onclick='doReportSort(this,\"-" + itemarr[1] + "\")'>【↓】</a>"
							+ "<a href='javascript:void(0)' onclick='doReportSort(this,\"" + itemarr[1] + "\")'>【↑】</a></div>";
	}
}

function doReportSort(lnk, key) {
	if(window.pre_SortLink) { window.pre_SortLink.style.color = ""; }
	lnk.style.color = "blue";
	window.pre_SortLink = lnk;
	$ID("rptsortlist").style.display = "none";
	window.__ReportSortKey = key;
	ReportSubmit();
}

function rpt_batbtnClick(button) {
	var btnText = button.innerText || button.textContent;
	var boxs = document.getElementsByName("sys_lvw_ckbox");
	var values = new Array();
	for (var i = 0 ; i < boxs.length ; i++ )
	{
		if(boxs[i].checked) {
			values[values.length] = boxs[i].value;
		}
	}
	if(values.length==0) {
		app.Alert("请先选择数据，然后再执行批量处理操作。");
		return;
	}

	if(window.onReportExtraHandle) {
		window.onReportExtraHandle(btnText , values);
	}else{
		if (window.confirm("您确定要进行" + btnText + "吗？")==false) { return; }
		ajax.regEvent("__doBatHandle")
		ajax.addParam("command", btnText);
		ajax.addParam("checkvalues", values.join(","));
		ajax.exec();
	}
}

window.__isadsearchmodel = 0
if(window.onReportPageLoad) {
	//2014-8-6 20:30 该函数在库存变动汇总表中调用 (页面该函数存在则初始化不在执行 ReportSubmit ,建议本函数中包含提交事件) (Binary,Sword)
	window.onReportPageLoad();
}
else{
	ReportSubmit();
}

window.batResults = new Array();
//批量处理刷新函数
function __rpt_addBatResultClear() {
	window.batResults = new Array();
}
function __rpt_addBatResult(msg, color, ids) {
	window.batResults[window.batResults.length] = [msg, color, ids];
}
function __rpt_BatResultRefreshList() {
	lvw_refresh("mlistvw");
}

function __rpt_batResult_show() {
	for (var i = 0; i < window.batResults.length; i++)
	{
		var msg = window.batResults[i][0];
		var color = window.batResults[i][1];
		var ids = window.batResults[i][2].split(",");
		color = (color=="" ? "red" : color);
		for (var ii=0; ii< ids.length; ii++ )
		{
			var id = ids[ii];
			var box = $ID("mlistvw_ckv_" + id);
			if(box) {
				var td = box.parentNode;
				while(td && td.tagName!="BODY" && td.className.indexOf("lvw_")==-1) {
					td = td.parentNode;
				}
				
				if(!td || td.className.indexOf("lvw_")==-1) {
					 td = box.parentNode;
				}
				else{
					td = td.nextSibling;
					while(td && td.style.display=="none") {
						td = td.nextSibling;
					}
					if(!td) { 
						td = box.parentNode; 
					}
					else {
						var row = td.getElementsByTagName("TABLE")[0].rows[0];
						td = row.cells[row.cells.length-1];
					}
				}
			
				td.innerHTML = td.innerHTML + "<span style='color:" + color + "'>" + msg  + "</span>"

			}
		}
	}
}

window.onlistviewRefresh = function() {
	__rpt_batResult_show();
	if(window.onReportListRefresh) {
		window.onReportListRefresh();
	}
	if (window.__ShowImgBigToSmall== true)
	{
		window.__ImgBigToSmall();
	}
}


window.__lvwsaveselBoxDefEx = function(an,av, box) {
	ajax.addParam("sortkey", window.__ReportSortKey);
}

function selectCK(imgobj,event)
{	
	var div = document.getElementById("div_ckidstate")
	if(!div){
		div = document.createElement("div")
		div.id = "div_ckidstate";
		div.style.cssText = "border:1px solid #000;width:200px;height:490px;position:absolute;display:none;background-color:white"
		document.body.appendChild(div)
	}
	var divX = event.clientX+document.body.scrollLeft;
	var divY = event.clientY+document.body.scrollTop;
	div.style.left = divX + "px";
	div.style.top = divY + "px";
	var mi=imgobj.getAttribute("mi");
	div.innerHTML = "<iframe src='../store/storeDlg.asp' frameborder='0' scrolling='no' style='width:100%;height:100%'></iframe>"
	div.style.display = "block";
	window.currStore =
	{
		text : "" , value : "" , change : function()
		{
			var cktext = window.currStore.text;
			var ckvalue = window.currStore.value;
			$ID(mi + "_txt").innerHTML=cktext;
			$ID(mi + "_v").value = ckvalue;
			$ID("div_ckidstate").style.display = "none";
		}
	}
}

function adClose()
{
	$ID("div_ckidstate").style.display = "none";
}


jQuery(function(){
	jQuery('#cplx').find(':checkbox').bind('click',function(){
		var $o = jQuery(this);
		if(!this.checked){
			$o.next('div').find(':input:checked').removeAttr('checked');
		}
	});
});

function OnReportBodyResize() {
	var list = $ID("lvw_mlistvw");
	if(!list) {
		list = $ID("lvwbody").children[0];
	}
	if(list) {
		var id = list.id.replace("lvw_","");
		var tb = $ID("lvw_dbtable_mlistvw");
		if(tb==null) {return;}
		if(tb.style.width=="100%") {
			tb.parentNode.style.overflowX = "hidden"
		}
		var fixheight = list.getAttribute("fixheight");
		if(fixheight==1) {
			var h1 = document.body.offsetHeight;
			var h2 = document.documentElement.offsetHeight;
			var h = h2==0 ? h1 : h2;
			var pbar = $ID("lvw_pagebar_" + id);
			var alink = $ID("lvw_alink_" + id);
			var nopage = $ID("lvw_nopagebar_" + id);
			if(nopage && alink && alink.innerText.replace(/\s/g,"")=="") {
				pbar.style.display = "none";
			}
			var oh = (pbar.style.display == "none" ? 0 : pbar.offsetHeight)
			var hv = ( h  - $ID("lvwbody").offsetTop);
			if(hv > 0) {
				list.style.height = hv + "px";
				if(oh>0 && app.IeVer>6) { pbar.style.borderTop = "1px solid #c0ccdd";}
				try{
					$ID("lvw_tablebg_" + id ).style.height = (hv - oh) + "px";
					$ID("lvw_tbodybg_" + id ).style.height = (hv - oh) + "px";
				}catch(e){}
			}
			document.documentElement.style.overflow = "hidden";
		}
	}
}

document.onkeydown = function()  {
	if(window.event.keyCode==27){
		window.event.keyCode= 0;
		return false;
	}
}


function __rpt_showsettingPanel() {
	app.easyui.CAjaxWindow("showReportSettings",function(){
		ajax.addParam2("stateview",$ID("__viewstate_lvw_mlistvw").value);
	});
}

function __Report_cfg_Save(htype) {
	if(htype!=1 && Validator.Validate($ID("rpt_config_frm"),1)==false) {
		app.Alert(123)
		return false;
	}
	if(htype==1 && confirm("您确定要清除【" + $ID("comm_itembarText").innerText + "】的配置信息并还原到初始化状态吗？")==false) { return; }
	ajax.regEvent("sys_ReportConfig");
	ajax.addParam("HCKey", $ID("lvw_dbtable_mlistvw").getAttribute("hckey"))
	var boxs = $ID("rsetting").getElementsByTagName("input");
	for(var i = 0 ; i < boxs.length; i++) {
		var box = boxs[i];
		if(box.id!="") { ajax.addParam(box.id, (box.type=="checkbox" || box.type=="radio") ? (box.checked?"1":"0") : box.value); }
	}
	boxs = $ID("rsetting").getElementsByTagName("select");
	for(var i = 0 ; i < boxs.length; i++) {
		var box = boxs[i];
		if(box.id!="") { ajax.addParam(box.id, (box.type=="checkbox" || box.type=="radio") ? (box.checked?"1":"0") : box.value); }
	}
	ajax.addParam("backdata",$ID("__viewstate_lvw_mlistvw").value);
	ajax.addParam("htype",htype);
	app.easyui.closeWindow("showReportSettings");
	$ID("lvw_mlistvw").innerHTML = ajax.send();
	lvwbodyResize();
	return true;
}

// 快速检索支持回车
$(function(){
	$("div[id^=sfields_]").find("input[type=text]").focus(function() {
		$(this).keydown(function (event) {
			if(event.keyCode == 13){
				if(window.onReportSubmiting==1) { return; }
				searchQuickClick();
			};
		});
	});
});