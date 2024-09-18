var ddlg_virpath = "../../"
if(window.sysCurrPath) {
	ddlg_virpath = window.sysCurrPath;
}
var gMonths=new Array("一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月");
var WeekDay=new Array("日","一","二","三","四","五","六");
var strToday="今天";
var strYear="年";
var strMonth="月";
var strDay="日";
var splitChar="-";
var startYear=1940;
var endYear=2031;
var dayTdHeight=12;
var dayTdTextSize=14;
var gcNotCurMonth="#E0E0E0";
var gcRestDay = "#2879FF";
var gcWorkDay="#444444";
var gcMouseOver = "#00BBFF";
var gcMouseOver1 = "#3758FF";//底部年月日鼠标悬浮颜色
var gcMouseOut="white";
var gcMouseOut2="white";
var gcgroundColor = "white";
var gcborderColor = "#ccc;";
var gcborderColor2 = "#ccc";
var gcToday="#444444";
var gcTodayMouseOver="#FFcccc";
var gcTodayMouseOut="#aaaaFF";
var gcClick = "e0f1ff";
var gdCtrl=new Object();
var goSelectTag=new Array();
var gdCurDate=new Date();
var giYear=gdCurDate.getFullYear();
var giMonth=gdCurDate.getMonth()+1;
var giDay = gdCurDate.getDate();
var giYear1, giMonth1, giDay1;
function $$(){var elements=new Array();for(var i=0;i<arguments.length;i++) {var element=arguments[i];if(typeof(arguments[i])=='string'){element=document.getElementById(arguments[i]);}if(arguments.length==1){return element;}elements.Push(element);}return elements;}
Array.prototype.Push=function(){var startLength=this.length;for(var i=0;i<arguments.length;i++){this[startLength+i]=arguments[i];}return this.length;}
String.prototype.HexToDec=function(){return parseInt(this,16);}
String.prototype.cleanBlank=function(){return this.isEmpty()?"":this.replace(/\s/g,"");}
function checkColor(){var color_tmp=(arguments[0]+"").replace(/\s/g,"").toUpperCase();var model_tmp1=arguments[1].toUpperCase();var model_tmp2="rgb("+arguments[1].substring(1,3).HexToDec()+","+arguments[1].substring(1,3).HexToDec()+","+arguments[1].substring(5).HexToDec()+")";model_tmp2=model_tmp2.toUpperCase();if(color_tmp==model_tmp1 ||color_tmp==model_tmp2){return true;}return false;}
function $$V(){return $$(arguments[0]).value;}
function $DateV(){return $$(arguments[0]).value;}
function clearSelDate(){
	if(window.event && dlgFireElement == window.event.srcElement) {
		return;
	}
	if (document.getElementById("calendardiv").style.visibility=="visible")
	{
		dlgFireElement = null;
		fHideCalendar();
	}
}

function positionXY() {
    var input = document.getElementById("tbSelYear");
    var l = input.getBoundingClientRect().left;
    var t = input.getBoundingClientRect().top + input.offsetHeight;
    $("#selectList").css({ "left": l + "px", "top": t + "px" })
}

function selectionBoxscroll() {
    if ($("#maskLayerTrp").css("display") == "none") {
        positionXY()
        $("#maskLayerTrp").css("display", "block");
        var n = $("#tbSelYear").val().replace("年", "") - startYear;
        var scrollTop1 = 14 * (n > 10 ? (n - 10) : 0)//14为li的高度；
        $($("#maskLayerTrp li")[n]).addClass("alSelected").siblings().removeClass("alSelected");
        $("#maskLayerTrp ul").scrollTop(scrollTop1);
        return;
    } else {
        $("#maskLayerTrp").css("display", "none");
    }
}

//body滚动下拉框消失
function isBodyScroll() {
    if ($("#maskLayerTrp").css("display") != "none") { $("#maskLayerTrp").css("display", "none"); }
}
function attachEvent1(obj, type, handle) {
    try {
        obj.addEventListener(type, handle, false);
    } catch (e) {
        try {
            obj.attachEvent('on' + type, handle);
        } catch (e) {
            obj['on' + type] = handle;
        }
    }
}
attachEvent1(window, "scroll", isBodyScroll)
var minDate = "";
var maxDate = "";
function fPopCalendar(evt,popCtrl,dateCtrl,showtime)
{
	minDate = "";
	maxDate = "";
	dlgFireElement = window.event.srcElement;
	try{
		if(dlgFireElement.minDate!="" && typeof(dlgFireElement.minDate)!="undefined"){
			minDate = dlgFireElement.minDate;
		}
		if(dlgFireElement.maxDate!="" && typeof(dlgFireElement.maxDate)!="undefined"){
			maxDate = dlgFireElement.maxDate;
		}
	}catch(e){}

	if(!document.getElementById("calendardiv"))
	{
		var dv = document.createElement("div");
		document.body.appendChild(dv);
		dv.outerHTML = getDateDiv();
		document.onclick=clearSelDate;
	}

	var d = null
	var hstimvalue = false
	evt.cancelBubble=true;
	gdCtrl=dateCtrl;
	minDate = "";
		try{
		if(gdCtrl.minDate!="" && typeof(gdCtrl.minDate)!="undefined"){
			minDate = gdCtrl.minDate;
		}
	}catch(e){}
	
	fSetYearMon(giYear,giMonth);

	var point=fGetXY(popCtrl);
	document.getElementById("CalendarOnlyDate_tr").style.display = showtime ? "none" : ""
	document.getElementById("CalendarDateTime_tr").style.display = showtime ? "" : "none"
	if(document.getElementById("CalendarDateTime_frame")) {
		document.getElementById("CalendarDateTime_frame").style.height = showtime ? "246px" : "216px";
	}
	var alw = $$("calendardiv").offsetWidth + point.x;
	if(alw > document.body.offsetWidth) {
		point.x = document.body.offsetWidth -  $$("calendardiv").offsetWidth;
	}
	with($$("calendardiv").style)
	{
		left=point.x+"px";
		top=(point.y+popCtrl.offsetHeight+1)+"px";
		visibility='visible';
		zindex='99';
		position='absolute';
	}

	if(typeof(dateCtrl)=="object" && typeof(dateCtrl.value)=="string"){
		var hstimvalue = dateCtrl.value.toString().indexOf(":") >=0
		d = new Date(dateCtrl.value.toString().replace(/\-/g,"\/"))
		if(isNaN(d)){
			d = new Date();
		}
	}
	if(d==null) {
		d = new Date();
	}

	if(document.getElementById("tbSelYear").value!=d.getFullYear()){
		document.getElementById("tbSelYear").value = d.getFullYear()+"年";
		document.getElementById("tbSelYear").fireEvent("onchange");
	}
	if(document.getElementById("tbSelMonth").value!=d.getMonth()+1){
		document.getElementById("tbSelMonth").value = d.getMonth()+1;
		document.getElementById("tbSelMonth").fireEvent("onchange");
	}
	if (hstimvalue==false)
	{
		var d = new Date();
	}
	var v = d.getHours();
	v = v<10 ? "0" + v.toString() : v ;
	document.getElementById("datedlg_hour").value = v;
	v = d.getMinutes();
	v = v<10 ? "0" + v.toString() : v ;
	document.getElementById("datedlg_mill").value = v;
	v = d.getSeconds();
	v = v<10 ? "0" + v.toString() : v ;
	document.getElementById("datedlg_secd").value = v;
	var ifrm = document.getElementById("CalendarDateTime_frame");
	var idiv = document.getElementById("calendardiv");
	if(ifrm) {
		ifrm.style.cssText = idiv.style.cssText;
		ifrm.style.zIndex = "90";
		ifrm.style.border = "0px";
		ifrm.style.width = (idiv.offsetWidth-6) + "px";
		ifrm.style.height= (idiv.offsetHeight-4) + "px";
	}

//$$("calendardiv").focus();
}

function fClearInputData(){
	fHideCalendar();
	gdCtrl.value= "";
	if(gdCtrl.onchange){gdCtrl.onchange(gdCtrl)};
}

function fSetDate(iYear,iMonth,iDay,isMonth,isCurBtn){
	var iMonthNew=new String(iMonth);
	var iDayNew=new String(iDay);
	if(iMonthNew.length<2){iMonthNew="0"+iMonthNew;}
	if(iDayNew.length<2){iDayNew="0"+iDayNew;}
	
	var d = iYear+splitChar+iMonthNew+splitChar+iDayNew;
	if(isCurBtn == 1){
    	var canSel = false;
	    var _d = new Date(d.replace(/\-/g, "/"));
	    if(isMonth){
	    	if (minDate != "") {
	            var d1 = new Date(minDate.replace(/\-/g, "/") + '/1');
	            if (_d < d1) { canSel = true; }
	       	}
	       	if (maxDate != "") {
	            var d3 = new Date(maxDate.replace(/\-/g, "/") + '/1');
	            if (_d > d3) { canSel = true; }
	        }
	    }else{
	    	if (minDate != "") {
	            var d1 = new Date(minDate.replace(/\-/g, "/"));
	            if (_d < d1) { canSel = true; }
	       	}
	       	if (maxDate != "") {
	            var d3 = new Date(maxDate.replace(/\-/g, "/"));
	            if (_d > d3) { canSel = true; }
	        }
	    }
	    if(canSel){ return; }
    }
	fHideCalendar();
	if(document.getElementById("CalendarOnlyDate_tr").style.display=="none"){
		d+= " " + document.getElementById("datedlg_hour").value + ":" + document.getElementById("datedlg_mill").value + ":" + document.getElementById("datedlg_secd").value
	}
	gdCtrl.value= d;
	if($){$(gdCtrl).change(); return;}
	if(gdCtrl.onchange){gdCtrl.onchange(gdCtrl)}
}
//BUG.2556.binary.2013.10.09 生产栏目下的js日期文件缺少ddlgGetElement函数，补上。
function ddlgGetElement(){var elements=new Array();for(var i=0;i<arguments.length;i++) {var element=arguments[i];if(typeof(arguments[i])=='string'){element=document.getElementById(arguments[i]);}if(arguments.length==1){return element;}elements.Push(element);}return elements;}
function fHideCalendar(){
	var CDiv = $("#calendardiv")[0];
	CDiv.style.visibility="hidden";
	if(document.getElementById("CalendarDateTime_frame")) { 
		document.getElementById("CalendarDateTime_frame").style.visibility="hidden"; 
	}
	if(!window.DateTimeNotShowSecond){
    	var tds = CDiv.getElementsByTagName("TD");
	    for(var i=0;i<tds.length;i++){
	    	$(tds[i]).attr("Cho",0);
	    }
	    for (var i = 0; i < goSelectTag.length; i++) {
	        goSelectTag[i].style.visibility = "visible";
	    }
    }
	goSelectTag.length=0;
}
function fSetSelected(){
	var iOffset=0;
	var iYear = parseInt($$("tbSelYear").value.replace(strYear, ""));
	var iMonth=parseInt($$("tbSelMonth").value);
	var aCell=$$("cellText"+arguments[0]);
	aCell.bgColor=gcMouseOut;
	with(aCell){
		var iDay=parseInt(innerHTML);
		if(checkColor(style.color,gcNotCurMonth)){
			iOffset=(innerHTML>14)?-1:1;
		}
		iMonth+=iOffset;
		if(iMonth<1){iYear--;iMonth=12;}
		else if(iMonth>12){
			iYear++;iMonth=1;
		}
	}
	if(window.DateTimeNotShowSecond == false){
		var et = window.event;
		var td = et.target || et.srcElement;
		if(td.tagName == "SPAN"){ td = td.parentNode; }
		var tb = td.parentNode.parentNode;
		var tds = tb.getElementsByTagName("TD");
		for(var i=0;i<tds.length;i++){
		    if (tds[i].bgColor.toLowerCase() != gcTodayMouseOut.toLowerCase()) {
				tds[i].bgColor = gcMouseOut;
			}
			$(tds[i]).attr("Cho",0);
		}
		$(td).addClass("defaultSelected").siblings().removeClass("defaultSelected")
		$(td).parent().siblings().find("td").removeClass("defaultSelected")
		$(td).attr("Cho",1);
    	var txt = td.getAttribute("id");
    	var num = txt.replace("tday","");
		$('#Calendar-Datetime-Confirm-Btn').attr("val",num);
	}else{
		fSetDate(iYear,iMonth,iDay);
	}
}
function Point(iX,iY){this.x=iX;this.y=iY;}
function fBuildCal(iYear,iMonth){var aMonth=new Array();for(var i=1;i<7;i++){aMonth[i]=new Array(i);}var dCalDate=new Date(iYear,iMonth-1,1);var iDayOfFirst=dCalDate.getDay();var iDaysInMonth=new Date(iYear,iMonth,0).getDate();var iOffsetLast=new Date(iYear,iMonth-1,0).getDate()-iDayOfFirst+1;var iDate=1;var iNext=1;for(var d=0;d<7;d++){aMonth[1][d]=(d<iDayOfFirst)?(iOffsetLast+d)*(-1):iDate++;}for(var w=2;w<7;w++){for(var d=0;d<7;d++){aMonth[w][d]=(iDate<=iDaysInMonth)?iDate++:(iNext++)*(-1);}}return aMonth;}
function fDrawCal(iYear, iMonth, iCellHeight, iDateTextSize) { var colorTD = " bgcolor='" + gcMouseOut + "' bordercolor='" + gcMouseOut + "'"; var styleTD = " valign='middle' align='center' style='height:" + iCellHeight + "px;er;font-size:" + iDateTextSize + "px;"; var dateCal = ""; dateCal += "<tr><td class='dlg_top' " + styleTD + "color:#000;height:25px;border-bottom:1px solid " + gcborderColor2 + ";width:6px'>&nbsp;</td>"; for (var i = 0; i < 7; i++) { dateCal += "<td class='dlg_top' " + styleTD + "color:#000;height:25px;border-bottom:1px solid " + gcborderColor2 + "'>" + WeekDay[i] + "</td>"; } dateCal += "<td class='dlg_top' " + styleTD + "color:#000;height:25px;width:6px;border-bottom:1px solid " + gcborderColor2 + "'>&nbsp;</td></tr>"; for (var w = 1; w < 7; w++) { dateCal += "<tr><td>&nbsp;</td>"; for (var d = 0; d < 7; d++) { var tmpid = w + "" + d; dateCal += "<td" + styleTD +"cursor:pointer;' class='tdayNum' id='tday"+tmpid+"' onclick='fSetSelected("+tmpid+")'>";dateCal+="<span id='cellText"+tmpid+"'></span>";dateCal+="</td>";}dateCal+="<td>&nbsp;</td></tr>";}return dateCal;}
function fUpdateCal(iYear, iMonth) {
    var iYear;
    if (isNaN(iYear)) { iYear = iYear.replace("年", ""); }
	var myMonth=fBuildCal(iYear,iMonth);
	var i=0, 
		oday = -1,  
		currMonth = iMonth, 
		currYear = iYear;
	if(Math.abs(myMonth[1][0]) >1) {
		currMonth --;
		if(currMonth==0) {currYear --;currMonth = 12;}
	}
	var theday="";
	for(var w=1;w<7;w++){
		for(var d=0;d<7;d++){
		    with ($$("cellText" + w + "" + d)) {
		        $(parentNode).removeClass("defaultSelected");
				parentNode.bgColor=gcMouseOut;
				parentNode.borderColor=gcMouseOut;
				parentNode.onmouseover=function(){
				    //this.bgColor = gcMouseOver;
				    //$(this).children("span").addClass("spanColor")
				};
				parentNode.onmouseout=function(){
					this.bgColor=gcMouseOut;
					if(this.getAttribute("Cho") && this.getAttribute("Cho") == 1){
                        this.bgColor = gcClick;
					}else{
						this.bgColor = gcMouseOut;
					}
					/*$(this).children("span").removeClass("spanColor")*/
				};
				if(myMonth[w][d]<0){
					style.color=gcNotCurMonth;innerHTML=Math.abs(myMonth[w][d]);
				}else{
					style.color=((d==0)||(d==6))?gcRestDay:gcWorkDay;innerHTML=myMonth[w][d];
					if(iYear==giYear && iMonth==giMonth && myMonth[w][d]==giDay){
						style.color="#ffffff";
						//parentNode.bgColor=gcTodayMouseOut;
						$(parentNode).addClass("currTDate");
						if($('#Calendar-Datetime-Confirm-Btn')){
							var txt = parentNode.getAttribute("id");
							var num = txt.replace("tday","");
							$('#Calendar-Datetime-Confirm-Btn').attr("val",num);
						}
						parentNode.onmouseover = function () {
							//this.bgColor=gcTodayMouseOver;
						}
						parentNode.onmouseout = function () {
							//this.bgColor=gcTodayMouseOut;
						}
					}
					if (iYear == giYear1 && iMonth == giMonth1 && myMonth[w][d] == giDay1) {
					    $(parentNode).addClass("defaultSelected")
					}
				}
			}
			if(minDate!=""){				
				if (oday!=-1){
					if(oday >  Math.abs(myMonth[w][d])) {
						currMonth ++;
						if(currMonth==13) {	currYear ++;currMonth = 1;}
					}
				}
				oday = Math.abs(myMonth[w][d]);
				var d1 = new Date(minDate.replace(/\-/g,"/"));
				var d2 = new Date(currYear + '/' + currMonth + '/' +  oday);
				var td = ddlgGetElement("tday"+w+""+d);
				if(d1>d2){
					td.disabled = true;td.style.cursor="auto";
				}else{
					td.style.cursor="pointer";td.disabled = false;
				}
			}else{
				var td = ddlgGetElement("tday"+w+""+d);
				td.style.cursor="pointer";td.disabled = false;
			}
		}
	}
}
function fSetYearMon(iYear, iMon) {
    $$("tbSelMonth").options[iMon - 1].selected = true;
    var selYearLen = $("#selectList li")
    for (var i = 0; i < selYearLen.length; i++) {
        if (selYearLen[i].getAttribute("value") == iYear) {
            $("#tbSelYear").val(selYearLen[i].innerHTML)
            break;
        }
    }
        fUpdateCal(iYear, iMon);
}
function fPrevMonth() { var iMon = $$("tbSelMonth").value; var iYear = $$("tbSelYear").value.replace(strYear, ""); if (--iMon < 1) { iMon = 12; iYear--; } fSetYearMon(iYear, iMon); }
function fNextMonth() { var iMon = $$("tbSelMonth").value; var iYear = $$("tbSelYear").value.replace(strYear, ""); if (++iMon > 12) { iMon = 1; iYear++; } fSetYearMon(iYear, iMon); }
function fGetXY(aTag){
	var pt=new Point(0,0)
	var w = 200 , h = 215
	if(aTag.getBoundingClientRect) {
		var pos = aTag.getBoundingClientRect();
		pt.x = pos.left;
		pt.y = pos.top;
	}else {
		var oTmp=aTag;
		while(oTmp)
		{
			pt.x = pt.x + oTmp.offsetLeft- oTmp.scrollLeft;
			pt.y = pt.y + oTmp.offsetTop - oTmp.scrollTop;
			oTmp=oTmp.offsetParent;
		}
	}
	var bodyw = document.body.offsetWidth;
	if(bodyw==0) {bodyw = document.documentElement.offsetWidth;}
	if (pt.x+w>bodyw){pt.x = bodyw -w;}
	if (pt.y+h>document.body.offsetHeight){
		pt.y = pt.y - h - aTag.offsetHeight;
		if (pt.y<0){pt.y = document.body.offsetHeight -h;}
	}
	pt.x = pt.x + document.body.scrollLeft;
	pt.y = pt.y + document.body.scrollTop;
	if(!isNaN(document.documentElement.scrollLeft))
	{
		pt.x = pt.x + document.documentElement.scrollLeft;
		pt.y = pt.y + document.documentElement.scrollTop;	
	}
	return pt;

}
function getDateDiv(){
	var optionsText = ""
	var optionsText2 = ""
	var noSelectForIE="";
	var noSelectForFireFox="";
	for (var i=0;i<60 ; i ++)
	{
		var v = i < 10 ? "0" + i.toString() : i;
		optionsText += "<option value=" + v +">" + v + "</option>"
		if (i<24)
		{optionsText2 += "<option value=" + v +">" + v + "</option>"}
	}
	if(document.all){noSelectForIE="onselectstart='return false;'";}else{noSelectForFireFox="-moz-user-select:none;";}
	var dateDiv="";
	dateDiv+="<div  id='calendardiv' onclick='event.cancelBubble=true' "+noSelectForIE+" style='overflow:hidden;"+noSelectForFireFox+";position:absolute;left:-1000px;top:-1000px;z-index:990000;visibility:hidden;padding:10px 0px;width:250px;background:" + gcgroundColor + ";border:1px solid " + gcborderColor + ";'>";
	if(navigator.userAgent.indexOf("MSIE 6.0") > 0){
		dateDiv+="<iframe src='about:blank' id='CalendarDateTime_frame' frameborder=0 style='position:absolute;visibility:hidden!important;_visibility:inherit;top:0px; left:0px; width:226px; height:216px; z-index:-1;'></iframe>"
		dateDiv+="<div frameborder=0 style='background:" + gcgroundColor + ";position:absolute;visibility:hidden!important;_visibility:inherit;top:0px; left:0px; width:226px; height:32px; z-index:-1;'></div>"
	}
	dateDiv += "<table border='0' cellpadding='2' style='width:100%;' cellspacing='0'>"; dateDiv += "<tr>"; dateDiv +="<td  style='padding-left:10px;'><input type='button' style='border:0px solid #aaaaaa;height:18px;line-height:18px;background-color:white;' id='PrevMonth' value='<' style='height:20px;width:20px;er;' onclick='fPrevMonth()'>";
	dateDiv += "</td><td><div style='overflow:hidden;'><input type='button' id='tbSelYear' style='display:inline-block;box-sizing:border-box;width:70px;height:24px;line-height: 24px;background-postion:55px center;' onclick='selectionBoxscroll()'   onchange='fUpdateCal($DateV(\"tbSelYear\"),$DateV(\"tbSelMonth\"))'><div id='maskLayerTrp' style='position:fixed;left:0;top:0;bottom:0;right:0;display:none;' onclick='this.style.display=\"none\"'><ul id='selectList' onclick='window.event.cancelBubble = true'>";
	for (var i = startYear; i < endYear; i++) { dateDiv += "<li onmouseover='$(this).addClass(\"alSelected1\");' onmouseout='$(this).removeClass(\"alSelected1\")'  onclick='window.event.cancelBubble = true;document.getElementById(\"tbSelYear\").value=this.innerHTML;$(\"div#maskLayerTrp\").css(\"display\",\"none\");$(\"#tbSelYear\").change();$(this).addClass(\"alSelected\").siblings().removeClass(\"alSelected\")' value='" + i + "'>" + i + strYear + "</li>"; }
	dateDiv += "</ul></div></div></td><td>";
	dateDiv += "<div style='overflow:hidden;'><select id='tbSelMonth' style='display:inline;width:65px;' onchange='fUpdateCal($DateV(\"tbSelYear\"),$DateV(\"tbSelMonth\"))'>";
	for(var i=0;i<12;i++){
			dateDiv+="<option value='"+(i+1)+"'>"+gMonths[i]+"</option>";
	}
	dateDiv+="</select></div></td><td style='padding-right:10px;'>";
	dateDiv +="<input type='button' id='NextMonth' value='>' style='width:20px;er;border:0px solid #aaaaaa;height:18px;background-color:white;' onclick='fNextMonth()'>";
	dateDiv+="</td>";
	dateDiv+="</tr><tr>";
	dateDiv+="<td align='center' colspan='4' style='padding-bottom:0px' style='padding-left:0px;padding-right:0px;'>";
	dateDiv+="<div style='padding:0px;overflow:hidden;'>";
	dateDiv += "<table border='0' class='datedlgbodytable' cellpadding='3' cellspacing='0' style='width:100%;table-layout:fixed;font-weight:bold;background:" + gcMouseOut2 + ";border-top:0px solid " + gcborderColor2 + ";border-bottom:0px solid " + gcborderColor2 + ";'>";
	dateDiv+=fDrawCal(giYear,giMonth,dayTdHeight,dayTdTextSize);
	dateDiv+="</table>";
	dateDiv+="</div>";
	dateDiv+="</td>";
	dateDiv+="</tr>";
	dateDiv+="<tr>";
	dateDiv+="<td align='center' colspan='4' style='padding:0px' nowrap id='CalendarOnlyDate_tr'><div style='padding-top:4px'>&nbsp;";
	dateDiv += "<INPUT class='dateClearBtn' style='width:49px;height:22px;' onclick='fClearInputData();' value='清空' type=button>";
	dateDiv += "<span class='todayDate' style='padding-left:5px;padding-right:5px;cursor:pointer;' onclick='fSetDate(giYear,giMonth,giDay,null,1)'>" + strToday + ":" + giYear + strYear + giMonth + strMonth + giDay + strDay + "</span>";
	dateDiv += "<INPUT class='dateCloseBtn' style='width:49px;height:22px;border:0px'  onclick='fHideCalendar();' value='关闭' type=button>&nbsp;";
	dateDiv+="</div></td>";


	dateDiv+="</tr>";
	dateDiv+="<tr>";
	dateDiv+="<td align='center' colspan='4' nowrap id='CalendarDateTime_tr' style='padding:0px'>";
	dateDiv+="<table style='width:100%'>";
	dateDiv+="<tr>";
	dateDiv+="<td><div style='width:10px;overflow:hidden;height:2px'>&nbsp;</div></td>"
	dateDiv+="<td><div style='background-color:white'><select style='font-family:宋体;;width:40px;' id='datedlg_hour'>" + optionsText2 + "</select></div></td><td>时</td>"
	dateDiv+="<td><div style='background-color:white'><select style='font-family:宋体;;width:40px;' id='datedlg_mill'>" + optionsText + "</select></div></td><td>分</td>"
	dateDiv+="<td><div style='background-color:white'><select style='font-family:宋体;;width:40px;' id='datedlg_secd'>" + optionsText + "</select></div></td><td>秒</td>"
	dateDiv+="<td><div style='width:10px;overflow:hidden;height:2px'>&nbsp;</div></td>"
	dateDiv+="</tr>";
	dateDiv+="<tr>";
	dateDiv+="<td colspan='8' style='text-align:center;padding-top:4px'>";
	dateDiv += "<INPUT class='dateClearBtn' style='width:49px;height:22px;' onclick='fClearInputData();' value='清空' type=button>";
	dateDiv += "<span class='todayDate' style='padding-left:5px;padding-right:5px;cursor:pointer;' onclick='fSetDate(giYear,giMonth,giDay,null,1)'>" + strToday + ":" + giYear + strYear + giMonth + strMonth + giDay + strDay + "</span>";
	dateDiv += "<INPUT class='dateCloseBtn' style='width:49px;height:22px;border:0px' onclick='fConfirmData(this);' id='Calendar-Datetime-Confirm-Btn' value='确定' type=button>";


	dateDiv+="</td>";
	dateDiv+="</tr>";
	dateDiv+="</table>";
	dateDiv+="</td>";
	dateDiv+="</tr>";
	dateDiv+="</table></div>";
	return dateDiv;
}

function fConfirmData(s){
	var tmp = $(s).attr('val');
	window.DateTimeNotShowSecond = null;
	fSetSelected(tmp);
}

var datedlg = {
	show : function(){
		var button = window.event.srcElement;
		if(button.tagName=="IMG" && button.parentNode.tagName=="BUTTON") { button = button.parentNode;}
		if(button.tagName=="BUTTON"){
			if(button.previousSibling && button.previousSibling.tagName=="INPUT"){
				button = button.previousSibling;
			}
			else
			{
				var td =  button.parentElement;
				button = td.previousSibling.children[0];
				if(!button){
					button =  td.previousSibling;
				}
			}
		}
		if (button.value.replace(/[ ]/g, "")) {
		    var yyR;
		    if (button.value.indexOf("-") > 0) { yyR = button.value.split("-"); } else { yyR = button.value.split("/"); }
		    giYear1 = yyR[0];
		    giMonth1 = yyR[1] ? (yyR[1][0] > 0 ? yyR[1] : yyR[1][1]) : giMonth;
		    giDay1 = yyR[2] ? (yyR[2][0] ? yyR[2] : yyR[2][1]) : giDay;
		} else {
		    giYear1 = "";
		    giMonth1 = "";
		    giDay1 = "";
		}
		fPopCalendar(window.event,button,button)
	}
	,
	setTimeValue : function(){
		var div = document.getElementById("datedlg_time_panel")
		var s = div.getElementsByTagName("select")
		div.button.value = s[0].value + ":" + s[1].value + ":" + s[2].value;
		div.style.display = "none";
		
		try{
			var lvwdiv = window.getParent(div.button,9)			
			if(lvwdiv.className=="ctl_listview"){
				lvw.updateRowByInput(div.button)  //更新listview数组
			}
		}catch(e){}
	}
	,
	showTime : function(){ //显示时间选择框
		var button = window.event.srcElement;
		if(button.tagName=="IMG" && button.parentNode.tagName=="BUTTON") {
			button = button.parentNode;
		}
		if(button.tagName=="BUTTON"){
			if(button.previousSibling && button.previousSibling.tagName=="INPUT"){
				button = button.previousSibling;
			}
			else
			{
				var td =  button.parentElement;
				button = td.previousSibling.children[0];
				if(!button){
					button =  td.previousSibling;
				}
			}
		}
		
		var mH = 0 , mM=0 , mS = 0 
		var v = button.value.split(":");
		if(v.length==3){
			mH = isNaN(v[0]) ? 0 : v[0]*1
			mM = isNaN(v[1]) ? 0 : v[1]*1
			mS = isNaN(v[2]) ? 0 : v[2]*1
		}

		var div = document.getElementById("datedlg_time_panel")
		if(!div){
			var h = "" , m ="" , s = ""
			for (var i = 0; i< 24 ; i ++ ){h = h + "<option " + ((mH-i) == 0 ? "selected":"")  + " value='" + (i<10?"0":"") + i + "'>" + (i<10?"0":"") + i + "</option>"}
			for (var i = 0; i< 60 ; i ++ ){m = m + "<option " + ((mM-i) == 0 ? "selected":"")  + "  value='" + (i<10?"0":"") + i + "'>" + (i<10?"0":"") + i + "</option>"}
			for (var i = 0; i< 60 ; i ++ ){s = s + "<option " + ((mS-i) == 0 ? "selected":"")  + "  value='" + (i<10?"0":"") + i + "'>" + (i<10?"0":"") + i + "</option>"}
			div = document.createElement("div");
			div.id = "datedlg_time_panel";
			div.style.cssText = ";overflow:hidden;position:absolute;z-index:100;width:226px;height:44px;background-color:white;display:none;border:1px solid #aaaabb;"
			div.innerHTML = "<table style='margin:5px;border-top:1px solid #fff;border-left:1px solid #fff;border-bottom:1px solid #aaaacc;;border-right:1px solid #aaaacc;background-color:#f0f0f0;width:96%;height:80%' cellSpacing=5><tr><td>时</td><td>"
							+ "<select style='font-family:arial;font-size:12px;font-weight:bold;color:#333388'>" + h 
							+ "</select></td><td>分</td><td><select style='font-family:arial;font-size:12px;font-weight:bold;color:#333388'>" + m + "</select></td><td>秒</td><td>" 
							+ "<select style='font-family:arial;font-size:12px;font-weight:bold;color:#333388'>" + s 
							+ "</select></td><td><button class=wavbutton onclick='datedlg.setTimeValue()'><img src='" + ddlg_virpath + "images/smico/ok.gif' title='确定'></button></td></tr></table>"
			document.body.appendChild(div);
			div.style.borderRight = "2px solid #666688";
			div.style.borderBottom = "2px solid #666688";
		}
		else{
			var s = div.getElementsByTagName("select");
			if(mH*1<10) {mH="0" + mH;}
			if(mM*1<10) {mM="0" + mM;}
			if(mS*1<10) {mS="0" + mS;}
			s[0].value = mH ; s[1].value = mM ; s[2].value = mS;
		}
		
		var xy = fGetXY(button);
		div.style.top = $(button).offset().top + button.offsetHeight +10+ "px";
		div.style.left = xy.x + "px";
		div.style.display = "block";
		div.button = button;

	}
	,
	showtime : function(){
		return datedlg.showTime();
	}
	,
	ShowTime : function(){
		return datedlg.showTime();
	}
	,
	showDateTime : function(){
		window.DateTimeNotShowSecond=false;
		var button = window.event.srcElement;
		if(button.tagName=="IMG" && button.parentNode.tagName=="BUTTON") { button = button.parentNode;}
		if(button.tagName=="BUTTON"){
			if(button.previousSibling && button.previousSibling.tagName=="INPUT"){
				button = button.previousSibling;
			}
			else
			{
				var td =  button.parentElement;
				button = td.previousSibling.children[0];
				if(!button){
					button =  td.previousSibling;
				}
			}
		}
		if (button.value) {
		    var yyR = button.value.split(" ")[0];
		    if (yyR.indexOf("-") > 0) { yyR = yyR.split("-"); } else { yyR = yyR.split("/"); }
		    giYear1 = yyR[0];
		    giMonth1 = yyR[1] ? (yyR[1][0] > 0 ? yyR[1] : yyR[1][1]) : giMonth;
		    giDay1 = yyR[2] ? (yyR[2][0] ? yyR[2] : yyR[2][1]) : giDay;
		} else {
		    giYear1 = "";
		    giMonth1 = "";
		    giDay1 = "";
		}
		fPopCalendar(window.event,button,button,true)
	}
}
