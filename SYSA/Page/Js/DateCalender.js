var gMonths=new Array("一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月");
var WeekDay=new Array("日","一","二","三","四","五","六");
var strToday="今天";
var strYear="年";
var strMonth="月";
var strDay="日";
var splitChar="-";
var startYear=1940;
var endYear=2050;
var dayTdHeight=12;
var dayTdTextSize=12;
var gcNotCurMonth="#E0E0E0";
var gcRestDay="#3333ff";
var gcWorkDay="#444444";
var gcMouseOver="#ffee00";
var gcMouseOut="#fcfcff";
var gcToday="#444444";
var gcTodayMouseOver="#FFcccc";
var gcTodayMouseOut="#aaaaFF";
var gdCtrl=new Object();
var goSelectTag=new Array();
var gdCurDate=new Date();
var giYear=gdCurDate.getFullYear();
var giMonth=gdCurDate.getMonth()+1;
var giDay=gdCurDate.getDate();
function $Date(){var elements=new Array();for(var i=0;i<arguments.length;i++) {var element=arguments[i];if(typeof(arguments[i])=='string'){element=document.getElementById(arguments[i]);}if(arguments.length==1){return element;}elements.Push(element);}return elements;}
Array.prototype.Push=function(){var startLength=this.length;for(var i=0;i<arguments.length;i++){this[startLength+i]=arguments[i];}return this.length;}
String.prototype.HexToDec=function(){return parseInt(this,16);}
String.prototype.cleanBlank=function(){return this.isEmpty()?"":this.replace(/\s/g,"");}
function checkColor(){var color_tmp=(arguments[0]+"").replace(/\s/g,"").toUpperCase();var model_tmp1=arguments[1].toUpperCase();var model_tmp2="rgb("+arguments[1].substring(1,3).HexToDec()+","+arguments[1].substring(1,3).HexToDec()+","+arguments[1].substring(5).HexToDec()+")";model_tmp2=model_tmp2.toUpperCase();if(color_tmp==model_tmp1 ||color_tmp==model_tmp2){return true;}return false;}
function $DateV(){return $Date(arguments[0]).value;}
function fPopCalendar(evt,popCtrl,dateCtrl,showtime)
{
	var d = null
	var hstimvalue = false
	evt.cancelBubble=true;
	gdCtrl=dateCtrl;
	
	fSetYearMon(giYear,giMonth);

	var point=fGetXY(popCtrl);

	document.getElementById("CalendarOnlyDate_tr").style.display = showtime ? "none" : ""
	document.getElementById("CalendarDateTime_tr").style.display = showtime ? "" : "none"
	with($Date("calendardiv").style)
	{
		left=point.x+"px";
		top=(point.y+popCtrl.offsetHeight+1)+"px";
		visibility='visible';
		zindex='99';
		position='absolute';
	}

	if(typeof(dateCtrl)=="object" && typeof(dateCtrl.value)=="string"){
		var hstimvalue = dateCtrl.value.toString().indexOf(":") >=0
		d = new Date(dateCtrl.value.toString().replace("-","/"))
		if(isNaN(d)){
			d = new Date();
		}
	}

	if(document.getElementById("tbSelYear").value!=d.getYear()){
		document.getElementById("tbSelYear").value = d.getYear();
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
	//$Date("calendardiv").focus();
}
function fSetDate(iYear,iMonth,iDay){
	var iMonthNew=new String(iMonth);
	var iDayNew=new String(iDay);
	if(iMonthNew.length<2){iMonthNew="0"+iMonthNew;}
	if(iDayNew.length<2){iDayNew="0"+iDayNew;}
	
	var d = iYear+splitChar+iMonthNew+splitChar+iDayNew;fHideCalendar();
	if(document.getElementById("CalendarOnlyDate_tr").style.display=="none"){
		d+= " " + document.getElementById("datedlg_hour").value + ":" + document.getElementById("datedlg_mill").value + ":" + document.getElementById("datedlg_secd").value
	}
	gdCtrl.value= d;
	if(gdCtrl.onchange){gdCtrl.onchange(gdCtrl)}
}
function fHideCalendar(){$Date("calendardiv").style.visibility="hidden";for(var i=0;i<goSelectTag.length;i++){goSelectTag[i].style.visibility="visible";}goSelectTag.length=0;}
function fSetSelected(){var iOffset=0;var iYear=parseInt($Date("tbSelYear").value);var iMonth=parseInt($Date("tbSelMonth").value);var aCell=$Date("cellText"+arguments[0]);aCell.bgColor=gcMouseOut;with(aCell){var iDay=parseInt(innerHTML);if(checkColor(style.color,gcNotCurMonth)){iOffset=(innerHTML>10)?-1:1;}iMonth+=iOffset;if(iMonth<1){iYear--;iMonth=12;}else if(iMonth>12){iYear++;iMonth=1;}}fSetDate(iYear,iMonth,iDay);}
function Point(iX,iY){this.x=iX;this.y=iY;}
function fBuildCal(iYear,iMonth){var aMonth=new Array();for(var i=1;i<7;i++){aMonth[i]=new Array(i);}var dCalDate=new Date(iYear,iMonth-1,1);var iDayOfFirst=dCalDate.getDay();var iDaysInMonth=new Date(iYear,iMonth,0).getDate();var iOffsetLast=new Date(iYear,iMonth-1,0).getDate()-iDayOfFirst+1;var iDate=1;var iNext=1;for(var d=0;d<7;d++){aMonth[1][d]=(d<iDayOfFirst)?(iOffsetLast+d)*(-1):iDate++;}for(var w=2;w<7;w++){for(var d=0;d<7;d++){aMonth[w][d]=(iDate<=iDaysInMonth)?iDate++:(iNext++)*(-1);}}return aMonth;}
function fDrawCal(iYear,iMonth,iCellHeight,iDateTextSize){var colorTD=" bgcolor='"+gcMouseOut+"' bordercolor='"+gcMouseOut+"'";var styleTD=" valign='middle' align='center' style='height:"+iCellHeight+"px;font-weight:bolder;font-size:"+iDateTextSize+"px;";var dateCal="";dateCal+="<tr>";for(var i=0;i<7;i++){dateCal+="<td"+colorTD+styleTD+"color:#990099'>"+WeekDay[i]+"</td>";}dateCal+="</tr>";for(var w=1;w<7;w++){dateCal+="<tr>";for(var d=0;d<7;d++){var tmpid=w+""+d;dateCal+="<td"+styleTD+"cursor:pointer;' onclick='fSetSelected("+tmpid+")'>";dateCal+="<span id='cellText"+tmpid+"'></span>";dateCal+="</td>";}dateCal+="</tr>";}return dateCal;}
function fUpdateCal(iYear,iMonth){var myMonth=fBuildCal(iYear,iMonth);var i=0;for(var w=1;w<7;w++){for(var d=0;d<7;d++){with($Date("cellText"+w+""+d)){parentNode.bgColor=gcMouseOut;parentNode.borderColor=gcMouseOut;parentNode.onmouseover=function(){this.bgColor=gcMouseOver;};parentNode.onmouseout=function(){this.bgColor=gcMouseOut;};if(myMonth[w][d]<0){style.color=gcNotCurMonth;innerHTML=Math.abs(myMonth[w][d]);}else{style.color=((d==0)||(d==6))?gcRestDay:gcWorkDay;innerHTML=myMonth[w][d];if(iYear==giYear && iMonth==giMonth && myMonth[w][d]==giDay){style.color=gcToday;parentNode.bgColor=gcTodayMouseOut;parentNode.onmouseover=function(){this.bgColor=gcTodayMouseOver;};parentNode.onmouseout=function(){this.bgColor=gcTodayMouseOut;};}}}}}}
function fSetYearMon(iYear,iMon){$Date("tbSelMonth").options[iMon-1].selected=true;for(var i=0;i<$Date("tbSelYear").length;i++){if($Date("tbSelYear").options[i].value==iYear){$Date("tbSelYear").options[i].selected=true;}}fUpdateCal(iYear,iMon);}
function fPrevMonth(){var iMon=$Date("tbSelMonth").value;var iYear=$Date("tbSelYear").value;if(--iMon<1){iMon=12;iYear--;}fSetYearMon(iYear,iMon);}
function fNextMonth(){var iMon=$Date("tbSelMonth").value;var iYear=$Date("tbSelYear").value;if(++iMon>12){iMon=1;iYear++;}fSetYearMon(iYear,iMon);}
function fGetXY(aTag){
	var pt=new Point(0,0)
	var w = 200 , h = 215
	var oTmp=aTag;
	while(oTmp)
	{
			pt.x = pt.x + oTmp.offsetLeft- oTmp.scrollLeft;
			pt.y = pt.y + oTmp.offsetTop - oTmp.scrollTop;
			oTmp=oTmp.offsetParent;
	}
	if (pt.x+w>document.body.offsetWidth){pt.x = document.body.offsetWidth -w;}
	if (pt.y+h>document.body.offsetHeight){
		pt.y = pt.y - h - aTag.offsetHeight;
		if (pt.y<0){pt.y = document.body.offsetHeight -h;}
	}
	pt.x = pt.x +  document.body.scrollLeft;
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
	dateDiv+="<div id='calendardiv' onclick='event.cancelBubble=true' "+noSelectForIE+" style='"+noSelectForFireFox+"position:absolute;z-index:990000;visibility:hidden;padding:3px;background-color:white;border:1px solid #ccccee;font-family:arial'>";dateDiv+="<table border='0'  cellpadding='2' style='' cellspacing='1' >";dateDiv+="<tr>";dateDiv+="<td><input type='button' style='border:1px solid #aaaaaa;height:18px;background-color:white;filter:wave(freq=1,strength=0,phase=0,lightstrength=10)' id='PrevMonth' value='<' style='height:20px;width:20px;font-weight:bolder;' onclick='fPrevMonth()'>";
	dateDiv+="</td><td><div style='width:60px;overflow:hidden;border:1px solid #aaaacc;height:16px;background-color:white'><select  id='tbSelYear' style='display:inline;width:65px;margin-top:-2px;margin-left:-2px;' onchange='fUpdateCal($DateV(\"tbSelYear\"),$DateV(\"tbSelMonth\"))'>";for(var i=startYear;i<endYear;i++){dateDiv+="<option value='"+i+"'>"+i+strYear+"</option>";}dateDiv+="</select></div></td><td>";
	dateDiv+="<div style='width:60px;overflow:hidden;border:1px solid #aaaacc;height:16px;background-color:white'><select id='tbSelMonth' style='display:inline;width:65px;margin-top:-2px;margin-left:-2px;' onchange='fUpdateCal($DateV(\"tbSelYear\"),$DateV(\"tbSelMonth\"))'>";
	for(var i=0;i<12;i++){
			dateDiv+="<option value='"+(i+1)+"'>"+gMonths[i]+"</option>";
	}
	dateDiv+="</select></div></td><td>";
	dateDiv+="<input type='button' id='NextMonth' value='>' style='width:20px;font-weight:bolder;border:1px solid #aaaaaa;height:18px;background-color:white;filter:wave(freq=1,strength=0,phase=0,lightstrength=10)' onclick='fNextMonth()'>";
	dateDiv+="</td>";
	dateDiv+="</tr><tr>";
	dateDiv+="<td align='center' colspan='4'>";
	dateDiv+="<div style='background-color:#cccccc;'><table width='100%' border='0' cellpadding='3' cellspacing='0' style='border-top:1px solid #ddddff;border-left:1px solid #ddddff;border-right:1px solid #aaaaee;border-bottom:1px solid #aaaaee'>";
	dateDiv+=fDrawCal(giYear,giMonth,dayTdHeight,dayTdTextSize);
	dateDiv+="</table></div>";
	dateDiv+="</td>";
	dateDiv+="</tr><tr><td align='center' colspan='4' nowrap id='CalendarOnlyDate_tr'>";
	dateDiv+="<span style='cursor:pointer;font-weight:bolder;' onclick='fSetDate(giYear,giMonth,giDay)' onmouseover='this.style.color=\""+gcMouseOver+"\"' onmouseout='this.style.color=\"#000000\"'>"+strToday+":"+giYear+strYear+giMonth+strMonth+giDay+strDay+"</span>";
	dateDiv+="</tr></tr>";
	dateDiv+="</tr><tr><td align='center' colspan='4' nowrap id='CalendarDateTime_tr'>";
	dateDiv+="<table><tr>";
	dateDiv+="<td><div style='width:36px;overflow:hidden;border:1px solid #aaaacc;height:16px;background-color:white'><select style='font-family:宋体;font-weight:bold;margin-top:-2px;margin-left:-2px;width:40px;isplay:inline;' id='datedlg_hour'>" + optionsText2 + "</select></div></td><td>时</td>"
	dateDiv+="<td><div style='width:36px;overflow:hidden;border:1px solid #aaaacc;height:16px;background-color:white'><select style='font-family:宋体;font-weight:bold;margin-top:-2px;margin-left:-2px;width:40px;isplay:inline;' id='datedlg_mill'>" + optionsText + "</select></div></td><td>分</td>"
	dateDiv+="<td><div style='width:36px;overflow:hidden;border:1px solid #aaaacc;height:16px;background-color:white'><select style='font-family:宋体;font-weight:bold;margin-top:-2px;margin-left:-2px;width:40px;isplay:inline;' id='datedlg_secd'>" + optionsText + "</select></div></td><td>秒</td>"
	dateDiv+="</tr></table>";
	dateDiv+="</tr></tr>";
	dateDiv+="</table></div>";
	return dateDiv;
}
with(document){onclick=fHideCalendar;write(getDateDiv());}
var datedlg = {
	show : function(){
		var button = window.event.srcElement;
		if(button.tagName=="BUTTON"){
			if(button.previousSibling && button.previousSibling.tagName=="INPUT"){
				button = button.previousSibling;
			}
			else
			{
				var td =  button.parentElement;
				button = td.previousSibling.all[0];
				if(!button){
					button =  td.previousSibling;
				}
			}
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
		if(button.tagName=="BUTTON"){
			if(button.previousSibling && button.previousSibling.tagName=="INPUT"){
				button = button.previousSibling;
			}
			else
			{
				var td =  button.parentElement;
				button = td.previousSibling.all[0];
				if(!button){
					button =  td.previousSibling;
				}
			}
		}
		
		var mH = 0 , mM=0 , mS = 0 
		
		var v = button.value.split(":")
		if(v.length==3){
			mH = isNaN(v[0]) ? 0 : v[0]
			mM = isNaN(v[1]) ? 0 : v[1]
			mS = isNaN(v[2]) ? 0 : v[2]
		}

		var div = document.getElementById("datedlg_time_panel")
		if(!div){
			var h = "" , m ="" , s = ""
			for (var i = 0; i< 24 ; i ++ ){h = h + "<option " + ((mH-i) == 0 ? "selected":"")  + " value='" + (i<10?"0":"") + i + "'>" + (i<10?"0":"") + i + "</option>"}
			for (var i = 0; i< 60 ; i ++ ){m = m + "<option " + ((mM-i) == 0 ? "selected":"")  + "  value='" + (i<10?"0":"") + i + "'>" + (i<10?"0":"") + i + "</option>"}
			for (var i = 0; i< 60 ; i ++ ){s = s + "<option " + ((mS-i) == 0 ? "selected":"")  + "  value='" + (i<10?"0":"") + i + "'>" + (i<10?"0":"") + i + "</option>"}
			div = document.createElement("div");
			div.id = "datedlg_time_panel";
			div.style.cssText = "background-repeat:repeat-x;background-image:url(../../images/m_table_top.jpg);overflow:hidden;position:absolute;z-index:100;width:226px;height:44px;background-color:white;display:none;border:1px solid #aaaabb;"
			div.innerHTML = "<table style='margin:5px;border-top:1px solid #fff;border-left:1px solid #fff;border-bottom:1px solid #aaaacc;;border-right:1px solid #aaaacc;background-color:#f0f0f0' cellSpacing=5><tr><td>时</td><td>"
							+ "<select style='font-family:arial;font-size:12px;font-weight:bold;color:#333388'>" + h 
							+ "</select></td><td>分</td><td><select style='font-family:arial;font-size:12px;font-weight:bold;color:#333388'>" + m + "</select></td><td>秒</td><td>" 
							+ "<select style='font-family:arial;font-size:12px;font-weight:bold;color:#333388'>" + s 
							+ "</select></td><td><button class=wavbutton onclick='datedlg.setTimeValue()'><img src='../../images/smico/ok.gif' title='确定'></button></td></tr></table>"
			document.body.appendChild(div);
			div.style.borderRight = "2px solid #666688"
			div.style.borderBottom = "2px solid #666688"
		}
		else{
			var s = div.getElementsByTagName("select")
			s[0].value = mH ; s[1].value = mM ; s[2].value = mS;
		}
		
		var xy = fGetXY(button);
		div.style.top = xy.y + button.offsetHeight + "px";
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
		var button = window.event.srcElement;
		if(button.tagName=="BUTTON"){
			if(button.previousSibling && button.previousSibling.tagName=="INPUT"){
				button = button.previousSibling;
			}
			else
			{
				var td =  button.parentElement;
				button = td.previousSibling.all[0];
				if(!button){
					button =  td.previousSibling;
				}
			}
		}
		fPopCalendar(window.event,button,button,true)
	}
}
