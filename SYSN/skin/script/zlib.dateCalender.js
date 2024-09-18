var gMonths = new Array("一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月");
var WeekDay = new Array("日", "一", "二", "三", "四", "五", "六");
var strToday = "今天";
var strYear = "年";
var strMonth = "月";
var strDay = "日";
var splitChar = "-";
var startYear = 1910;
var endYear = 2201;
var dayTdHeight = 12;
var dayTdTextSize = 12;
var gcNotCurMonth = "#B0B0B0";
var gcRestDay = "#2879FF";//休息日字体颜色和默认选中颜色鼠标悬浮颜色;
//var gcDefaultSelect = "#54C8FF";//默认选中颜色是一致的；
var gcWorkDay = "#000";
var gcMouseOver = "#00BBFF";//鼠标悬浮；
var gcMouseOver1 = "#3758FF";//底部年月日鼠标悬浮颜色
var gcMouseOut = "white";
var gcToday = "#000";
var gcTodayMouseOver = "#FFcccc";
var gcTodayMouseOut = "#FFF";
var gcClick = "white";
var gdCtrl = new Object();
var goSelectTag = new Array();
var gdCurDate = new Date();
var giYear = gdCurDate.getFullYear();
var giMonth = gdCurDate.getMonth() + 1;
var giDay = gdCurDate.getDate();
var giYear1 , giMonth1 , giDay1 ;//当前文本框时间
var oldIsMonth = false;
if (!app) {
    var app = new Object();
    app.getIEVer = function () { //获取ie版本
        var browser = navigator.appName;
        var b_version = navigator.appVersion;
        var version = b_version.split(";");
        if (browser == "Microsoft Internet Explorer") {
            var trim_Version = version[1].replace(/[ ]/g, "");
            if (trim_Version == "MSIE7.0") { return 7; }
            if (trim_Version == "MSIE6.0") { return 6; }
            if (trim_Version == "MSIE5.0") { return 5; }
            else { return 8 }
        }
        else {
            return 100;
        }
    }
    app.IeVer = app.getIEVer(); // 获取ie版本
}
function ddlgGetElement() {

    var elements = new Array();
    for (var i = 0; i < arguments.length; i++) {
        var element = arguments[i];
        if (typeof (arguments[i]) == 'string') {
            element = document.getElementById(arguments[i]);
        }
        if (arguments.length == 1) {
            return element;
        }
        elements.Push(element);
    }
    return elements;
}
//Array.prototype.Push = function () { var startLength = this.length; for (var i = 0; i < arguments.length; i++) { this[startLength + i] = arguments[i]; } return this.length; }
String.prototype.HexToDec = function () { return parseInt(this, 16); }
String.prototype.cleanBlank = function () { return this.isEmpty() ? "" : this.replace(/\s/g, ""); }
function checkColor() {
    var color_tmp = (arguments[0] + "").replace(/\s/g, "").toUpperCase();
    var model_tmp1 = arguments[1].toUpperCase();
    var model_tmp2 = "rgb(" + arguments[1].substring(1, 3).HexToDec() + "," + arguments[1].substring(1, 3).HexToDec() + "," + arguments[1].substring(5).HexToDec() + ")";
    model_tmp2 = model_tmp2.toUpperCase();
    if (color_tmp == model_tmp1 || color_tmp == model_tmp2) { return true; }
    return false;
}

function ddlgGetElementV(date, isMonth) {
    if (isMonth) {
        var data_t = "";
        if (arguments[0] == "tbSelYear") {
            data_t = ddlgGetElement(arguments[0]).value
        }
        return data_t;
    }
    else {
        return ddlgGetElement(arguments[0]).value;
    }
}

var minDate = "";
var maxDate = "";
//更新面板位置和dom
function fPopCalendar(evt, popCtrl, dateCtrl, showtime, showMonth,box) {
    if (window.SysConfig && !window.virpath) {
        window.virpath = window.SysConfig.VirPath + "SYSA/"
    }
    var d = null
    oldIsMonth = showMonth;
    var hstimvalue = false;
    if (evt) { evt.cancelBubble = true; }
    gdCtrl = dateCtrl;
    minDate = "";
    maxDate = "";
    try {
        minDate = $(gdCtrl).attr("minDate");
        if (!minDate) { minDate = ""; }
        maxDate = $(gdCtrl).attr("maxDate");
        if (!maxDate) { maxDate = ""; }
    } catch (e) { }


    fSetYearMon(giYear1, giMonth1, showMonth);

    var point = window.dcGetObjectPos(popCtrl, 1);
    var oName = evt&&(evt.target || evt.srcElement)||box;
	var obj = null;
	
	if (oName&&oName.tagName != 'INPUT') {
		obj = $(oName).parents('td').first().find('input').first()[0];
		if (!obj) {
			obj = $(oName)[0].parentNode.getElementsByTagName("input")[0];
		}
	}else{ 
		obj = oName;
	};
	
	
    if (showMonth) {
        document.getElementById("CalendarMonth_tr").style.display = "";
        document.getElementById("CalendarOnlyDate_tr").style.display = "none";
        document.getElementById("CalendarDateTime_tr").style.display = "none";
    }
    else {
        document.getElementById("CalendarMonth_tr").style.display = "none";
        document.getElementById("CalendarOnlyDate_tr").style.display = showtime ? "none" : ""
        document.getElementById("CalendarDateTime_tr").style.display = showtime ? "" : "none"
    }
  	with (ddlgGetElement("calendardiv").style) {
            var clientWidth = (document.documentElement.clientWidth || document.body.clientWidth) + (window.scrollX || (document.body.scrollLeft + document.documentElement.scrollLeft));
	    if (showMonth) {
	        width = "180px";
	        point.left = ((point.left + 248 > clientWidth)?(clientWidth - 248)  : point.left)
	    }else {
	        point.left = (((point.left + 248) > clientWidth) ? (clientWidth - 248) : point.left)
	    };
		var _s = 0;
		if(app.IeVer == 7 && window["lvw_JsonData_MainList"]){ _s = document.documentElement.scrollTop || document.body.scrollTop; }
		
		var t = $(obj).offset().top;
		var l = $(obj).offset().left;
		
        left =  point.left + "px";
        top = t + _s + 28 + "px";
        visibility = 'visible';
        zindex = '99';
        position = 'absolute';
        display = '';
    }


    if (hstimvalue == false) {
        var d = new Date();
    }
    var v = d.getHours();
    v = v < 10 ? "0" + v.toString() : v;
    document.getElementById("datedlg_hour").value = v;
    v = d.getMinutes();
    v = v < 10 ? "0" + v.toString() : v;
    document.getElementById("datedlg_mill").value = v;
    v = d.getSeconds();
    v = v < 10 ? "0" + v.toString() : v;
    document.getElementById("datedlg_secd")? (document.getElementById("datedlg_secd").value = v):void 0;
    //ddlgGetElement("calendardiv").focus();
}

function fSetDate(iYear, iMonth, iDay, isMonth, isCurBtn) {
    var iMonthNew = !isNaN(iMonth + "") && iMonth!="" ? new String(iMonth) : "";
    var iDayNew = !isNaN(iDay + "") && iDay !=""? new String(iDay) : "";
    if (iMonthNew && iMonthNew.length < 2) { iMonthNew = "0" + iMonthNew; }
    if (iDayNew && iDayNew.length < 2) { iDayNew = "0" + iDayNew; }
    var d = iDayNew?iYear + splitChar + iMonthNew + splitChar + iDayNew:"";
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
    if (isMonth) {
        iMonthNew?d = iYear + splitChar + iMonthNew:d="";
    }else {
        if (document.getElementById("CalendarOnlyDate_tr").style.display == "none" && iDayNew && d) {
            if(window.DateTimeNotShowSecond){
                d += " " + document.getElementById("datedlg_hour").value + ":" + document.getElementById("datedlg_mill").value
            }else{
                d += " " + document.getElementById("datedlg_hour").value + ":" + document.getElementById("datedlg_mill").value + ":" +  document.getElementById("datedlg_secd").value;
            }
        }
    }
    gdCtrl.value = d;
    if (gdCtrl.onchange) { gdCtrl.onchange(gdCtrl) }
}

function fHideCalendar() {
	var CDiv = ddlgGetElement("calendardiv");
	document.getElementById('Calendar-Month-Clear-Btn').style.display = "none";
	document.getElementById('Calendar-Month-Close-Btn').style.display = "none";
	document.getElementById('Calendar-Normal-Clear-Btn').style.display = "none";
	document.getElementById('Calendar-Normal-Close-Btn').style.display = "none";
	document.getElementById('Calendar-Datetime-Confirm-Btn').style.display = "none";
	document.getElementById('Calendar-Datetime-Clear-Btn').style.display = "none";
	ddlgGetElement("calendardiv") ? ddlgGetElement("calendardiv").style.visibility = "hidden" : void 0;
    if(!window.DateTimeShowHMSArea){
    	var tds = CDiv.getElementsByTagName("TD");
	    for(var i=0;i<tds.length;i++){
	    	$(tds[i]).attr("Cho",0);
	    }
	    for (var i = 0; i < goSelectTag.length; i++) {
	        goSelectTag[i].style.visibility = "visible";
	    }
    }
    goSelectTag.length = 0;
    $(document).unbind("keydown", datedlg.dateLayerShortKey);
    $("body").unbind("click", datedlg.dateeventproc)
    if (Bill.EnterTabKeyHandle) {
        var box = datedlg.activedIntBox;
        $(document).unbind("keydown", Bill.EnterTabKeyHandle).bind("keydown", Bill.EnterTabKeyHandle);
        datedlg.activedIntBox = 0;
    }
}

function fSetSelected(tmpid, isMonth) {
    var unclick = null
    try { 
    	if(isMonth){
    		unclick = $("#tmon" + arguments[0]).attr("unclick");
    	}else{
    		unclick = $("#tday" + arguments[0]).attr("unclick");
    	}
    } catch (e) { }
    if (!unclick) { unclick = "0"; }
    if (unclick == "1") { return; }
    var iOffset = 0;
    var iYear = parseInt(ddlgGetElement("tbSelYear").value.replace(strYear, ""));
    if (isMonth) {
        var aCell = ddlgGetElement("cellText" + arguments[0]);
        if (aCell) {
            aCell.bgColor = gcMouseOut;
            with (aCell) {
                var iMonth = parseInt(innerHTML);
            }
            iDay = 1;
        }
    }
    else {
        var iMonth = parseInt(ddlgGetElement("tbSelMonth").value);
        var aCell = ddlgGetElement("cellText" + arguments[0]);
        if (aCell) {
            with (aCell) {
                var iDay = parseInt(innerHTML);
                if (checkColor(style.color, gcNotCurMonth)) {
                    iOffset = (innerHTML > 14) ? -1 : 1;
                }
                iMonth += iOffset;
                if (iMonth < 1) {
                    iYear--; iMonth = 12;
                }
                else if (iMonth > 12) {
                    iYear++; iMonth = 1;
                }
            }
            aCell.bgColor = gcMouseOut;
        } else { iYear = ""; iMonth = "";iDay=""; }
    }
	if(window.DateTimeShowHMSArea){
		var et = window.event;
		var td = et.target || et.srcElement;
		if(td.tagName == "SPAN"){ td = td.parentNode; }
		var tb = td.parentNode.parentNode;
		var tds = tb.getElementsByTagName("TD");
		for(var i=0;i<tds.length;i++){
		    if (tds[i].bgColor.toLowerCase() != gcTodayMouseOut.toLowerCase()) {//ie下16进制颜色区分大小写
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
		fSetDate(iYear, iMonth, iDay, isMonth);
	}
}
function Point(iX, iY) { this.x = iX; this.y = iY;  }

function fBuildCal(iYear, iMonth, showMonth) {
     
    var aMonth = new Array();
    for (var i = 1; i < 7; i++) {
        aMonth[i] = new Array();
    }
    if (showMonth) {
        var imon = 1;
        for (var w = 1; w < 4; w++) {
            for (var d = 0; d < 4; d++) {
                aMonth[w][d] = imon++;
            }
        }
    }
    else {
        var dCalDate = new Date(iYear, iMonth - 1, 1);
        var iDayOfFirst = dCalDate.getDay();
        var iDaysInMonth = new Date(iYear, iMonth, 0).getDate();
        var iOffsetLast = new Date(iYear, iMonth - 1, 0).getDate() - iDayOfFirst + 1;
        var iDate = 1;
        var iNext = 1;
        for (var d = 0; d < 7; d++) {
            aMonth[1][d] = (d < iDayOfFirst) ? (iOffsetLast + d) * (-1) : iDate++;
        }
        for (var w = 2; w < 7; w++) {
            for (var d = 0; d < 7; d++) {
                aMonth[w][d] = (iDate <= iDaysInMonth) ? iDate++ : (iNext++) * (-1);
            }
        }
    }
    return aMonth;
}
function fDrawCal(iYear, iMonth, iCellHeight, iDateTextSize, isMonth) {
    var colorTD = " bgcolor='" + gcMouseOut + "' bordercolor='" + gcMouseOut + "'";
    var dateCal = "";
    dateCal += "<tr>";
    if (isMonth) {
        //dateCal+="<td class='dlg_top' "+styleTD+"color:#000;height:25px;border-bottom:1px solid #c6d3e1'>&nbsp;</td></tr>";
        for (var w = 1; w < 4; w++) {
            dateCal += "<tr>";
            for (var d = 0; d < 4; d++) {
                var tmpid = w + "" + d;
                dateCal += "<td style='cursor:pointer;' id='tmon" + tmpid + "' onclick='fSetSelected(" + tmpid + "," + isMonth + ")'>";
                dateCal += "<span id='cellText" + tmpid + "'></span>";
                dateCal += "</td>";
            }
            dateCal += "</tr>";
        }
    }
    else {
        dateCal += "<td class='dlg_top' style='width:6px'>&nbsp;</td>";
        for (var i = 0; i < 7; i++) {
            dateCal += "<td class='dlg_top'>" + WeekDay[i] + "</td>";
        }
        dateCal += "<td class='dlg_top' style='width:6px'>&nbsp;</td></tr>";
        for (var w = 1; w < 7; w++) {
            dateCal += "<tr><td>&nbsp;</td>";
            for (var d = 0; d < 7; d++) {
                var tmpid = w + "" + d;
                dateCal += "<td style='cursor:pointer;' class='tdayNum' id='tday" + tmpid + "' onclick='fSetSelected(" + tmpid + ")'>";
                dateCal += "<span id='cellText" + tmpid + "'></span>";
                dateCal += "</td>";
            }
            dateCal += "<td>&nbsp;</td></tr>";
        }
    }
    return dateCal;
}
function fUpdateCal(iYear, iMonth, showMonth) {
    var iYear; 
    if (isNaN(iYear)) { iYear=iYear.replace("年", ""); }
    var myMonth = fBuildCal(iYear, iMonth, showMonth);
    datedlg.dateRows = myMonth;
    var i = 0, oday = -1, currMonth = iMonth, currYear = iYear;
    if (Math.abs(myMonth[1][0]) > 1) {
        currMonth--;
        if (currMonth == 0) { currYear--; currMonth = 12; }
    }
    var theday = "",spanEle;
    if (showMonth) {  //月份面板更新
        for (var w = 1; w < 4; w++) {
            for (var d = 0; d < 4; d++) {
                spanEle = document.getElementById("cellText" + w + "" + d);
                updateDomUiHover(spanEle, iYear, iMonth, myMonth[w][d], showMonth);
                if (minDate != "" || maxDate != "") {
                    currMonth = Math.abs(myMonth[w][d]);
                    var d2 = new Date(currYear + '/' + currMonth + '/1');
                    var td = ddlgGetElement("tmon" + w + "" + d);
                    if (minDate != "") {
                        var d1 = new Date(minDate.replace(/\-/g, "/") + '/1');
                        if (d1 > d2) {
                            $(td).attr("unclick", "1");
                            ddlgGetElement("cellText" + w + "" + d).style.color = "#E0E0E0";
                            td.disabled = true; td.style.cursor = "auto";
                            td.getElementsByTagName("span")[0].style.color="#E0E0E0";
                        }
                        else if (maxDate != "") {
                            var d3 = new Date(maxDate.replace(/\-/g, "/") + '/1');
                            if (d2 > d3) {
                                $(td).attr("unclick", "1");
                                ddlgGetElement("cellText" + w + "" + d).style.color = "#E0E0E0";
                                td.disabled = true; td.style.cursor = "auto";
                            } else {
                                $(td).attr("unclick", "0");
                                td.style.cursor = "pointer"; td.disabled = false;
                            }
                        }
                        else {
                            $(td).attr("unclick", "0");
                            td.style.cursor = "pointer"; td.disabled = false;
                        }
                    }
                    else if (maxDate != "") {
                        var d3 = new Date(maxDate.replace(/\-/g, "/") + '/1');
                        if (d2 > d3) {
                            $(td).attr("unclick", "1");
                            ddlgGetElement("cellText" + w + "" + d).style.color = "#E0E0E0";
                            td.disabled = true; td.style.cursor = "auto";
                        } else {
                            $(td).attr("unclick", "0");
                            td.style.cursor = "pointer"; td.disabled = false;
                        }
                    }
                }
                else {
                    var td = ddlgGetElement("tmon" + w + "" + d);
                    td.style.cursor = "pointer"; td.disabled = false;
                }
            }
        }
    }
    else {//年份面板更新
        for (var w = 1; w < 7; w++) {
            for (var d = 0; d < 7; d++) {
                spanEle = document.getElementById("cellText" + w + "" + d);
                updateDomUiHover(spanEle, iYear, iMonth, myMonth[w][d], showMonth,d);
                if (minDate != "" || maxDate != "") {
                    if (oday != -1) {
                        if (oday > Math.abs(myMonth[w][d])) {
                            currMonth++;
                            if (currMonth == 13) { currYear++; currMonth = 1; }
                        }
                    }
                    oday = Math.abs(myMonth[w][d]);
                    var d2 = new Date(currYear + '/' + currMonth + '/' + oday);
                    var td = ddlgGetElement("tday" + w + "" + d);
                    if (minDate != "") {
                        var d1 = new Date(minDate.replace(/\-/g, "/"));
                        if (d1 > d2) {
                            $(td).attr("unclick", "1");
                            td.getElementsByTagName("span")[0].style.color="#E0E0E0";
                            td.disabled = true; td.style.cursor = "auto";
                        }
                        else if (maxDate != "") {
                            var d3 = new Date(maxDate.replace(/\-/g, "/"));
                            if (d2 > d3) {
                                $(td).attr("unclick", "1");
                                td.getElementsByTagName("span")[0].style.color="#E0E0E0";
                                td.disabled = true; td.style.cursor = "auto";
                            } else {
                                $(td).attr("unclick", "0");
                                td.style.cursor = "pointer"; td.disabled = false;
                            }
                        }
                        else {
                            $(td).attr("unclick", "0");
                            td.style.cursor = "pointer"; td.disabled = false;
                        }
                    }
                    else if (maxDate != "") {
                        var d3 = new Date(maxDate.replace(/\-/g, "/"));
                        if (d2 > d3) {
                            $(td).attr("unclick", "1");
                            td.disabled = true; td.style.cursor = "auto";
                            td.getElementsByTagName("span")[0].style.color="#E0E0E0";
                        } else {
                            $(td).attr("unclick", "0");
                            td.style.cursor = "pointer"; td.disabled = false;
                        }
                    }
                }
                else {
                    var td = ddlgGetElement("tday" + w + "" + d);
                    $(td).attr("unclick", "0");
                    td.style.cursor = "pointer"; td.disabled = false;
                }
            }
        }
    }
}

//更新dom的悬浮和选中效果
function updateDomUiHover(element, iYear, iMonth, myCurrMonth, showMonth,d) {
    if (!element) { return; }
    var cell = element.parentNode;
    if (!cell) { return; }
    $(cell).removeClass("defaultSelected").removeClass("currTDate");
    cell.bgColor = gcMouseOut;
    cell.borderColor = gcMouseOut;
    cell.onmouseover = function () {
        /*this.bgColor = gcMouseOver;*/
        /*$(this).children("span").addClass("spanColor")*/
        $(this).addClass("hovBorder");
    };
    var flag = showMonth ? false : true;
    cell.onmouseout = function (flag) {
        if (flag && this.getAttribute("Cho") && this.getAttribute("Cho") == 1) {
            this.bgColor = gcClick;
        } else {
            this.bgColor = gcMouseOut;
        }
        //$(this).children("span").removeClass("spanColor")
        $(this).removeClass("hovBorder");
    };
    if (myCurrMonth < 0) {
        element.style.color = gcNotCurMonth;
        element.innerHTML = Math.abs(myCurrMonth);
    }
    else {
        element.style.color = '';
        element.className = d != undefined && (d == 0) || (d == 6) ? "RestDay" : "gcWorkDay";
        element.innerHTML = myCurrMonth;
        if (iYear == giYear && myCurrMonth == (showMonth ? giMonth : giDay) && (showMonth ? true : iMonth == giMonth)) {
            cell.bgColor = gcTodayMouseOut;
            $(cell).addClass("currTDate")
            if (!showMonth && $('#Calendar-Datetime-Confirm-Btn')[0]) {
                var txt = cell.getAttribute("id");
                var num = txt.replace("tday", "");
                $('#Calendar-Datetime-Confirm-Btn').attr("val", num);
            }
            cell.onmouseover = function () {
                //this.bgColor = gcTodayMouseOver;
                $(this).addClass("hovBorder");
            };
            cell.onmouseout = function () {
                //this.bgColor = gcTodayMouseOut;
                $(this).removeClass("hovBorder");
            };
        }
        if (iYear == giYear1 && myCurrMonth == (showMonth ? giMonth1 : giDay1) && (showMonth ? true : iMonth == giMonth1)) {
            $(cell).addClass("defaultSelected")
        }
    }
}

//日期界限处理
function dateLimitHandle() {

}

//日期面板赋值并更新颜色背景
function fSetYearMon(iYear, iMon, isMonthPanel) {//isMonthPanel=true 年月数据面板
    var iYear = iYear || giYear, iMon = iMon || giMonth;
    if (isMonthPanel) {//年月面板
        var selYearLen = $("#selectList li")
        for (var i = 0; i < selYearLen.length; i++) {
            if (selYearLen[i].getAttribute("value") == iYear) {
                $("#tbSelYear").val(selYearLen[i].innerHTML)
                break;
            }
        }
    }
    else {//年月日面板
        ddlgGetElement("tbSelMonth").options[iMon - 1].selected = true;
        var selYearLen = $("#selectList li")
        for (var i = 0; i < selYearLen.length; i++) {
            if (selYearLen[i].getAttribute("value") == iYear) {
                $("#tbSelYear").val(selYearLen[i].innerHTML)
                break;
            }
        }
    }
    fUpdateCal(iYear, iMon, isMonthPanel);//更新日期面板
}

function fPrevMonth(isMonth) {
    var iYear = ddlgGetElement("tbSelYear").value.replace(strYear, "");
    if (isMonth) {
        iYear--;
    }
    else {
        var iMon = ddlgGetElement("tbSelMonth").value;
        if (--iMon < 1) { iMon = 12; iYear--; }
    }

    fSetYearMon(iYear, iMon, isMonth);
}

function fNextMonth(isMonth) {
    var iYear = ddlgGetElement("tbSelYear").value.replace(strYear, "");
    if (isMonth) {
        iYear++;
    }
    else {
        var iMon = ddlgGetElement("tbSelMonth").value;
        if (++iMon > 12) {
            iMon = 1;
            iYear++;
        }
    }
    fSetYearMon(iYear, iMon, isMonth);
}

window.dcGetObjectPos = function (element, model) {
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
        if (model != 1) {

            if (elmt.style.position == 'absolute' || elmt.style.position == 'relative'
				|| (elmt.style.overflow != 'visible' && elmt.style.overflow != '')) {
                //break;  Binry.2014.2.13.暂时注释, 如别的div
            }
        }
        offsetTop += elmt.offsetTop - elmt.scrollTop;
        offsetLeft += elmt.offsetLeft - elmt.scrollLeft;
        elmt = elmt.offsetParent;
    }
    return { top: offsetTop, left: offsetLeft, width: offsetWidth, height: offsetHeight };
}
var GetObjectPos = window.dcGetObjectPos;

function fClearInputData() {
    fHideCalendar();
    gdCtrl.value = "";
    if (gdCtrl.onchange) { gdCtrl.onchange(gdCtrl) };
}

function getDateDiv(isMonth,a) {
    var optionsText = ""
    var optionsText2 = ""
    var noSelectForIE = "";
    var noSelectForFireFox = "";
    for (var i = 0; i < 60 ; i++) {
        var v = i < 10 ? "0" + i.toString() : i;
        optionsText += "<option value=" + v + ">" + v + "</option>"
        if (i < 24)
        { optionsText2 += "<option value=" + v + ">" + v + "</option>" }
    }
    var dateDiv = "";
    dateDiv += "<table border='0' cellpadding='2' style='width:100%' cellspacing='0'>";
    dateDiv += isMonth ? "<col style='width:25%'><col style='width:50%'><col style='width:25%'>" : "<col style='width:20%'><col style='width:30%'><col style='width:30%'><col style='width:20%'>";
    dateDiv += "<tr>";
    dateDiv += "<td align='center'><span class='leftarrow img'  src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/dateleft.gif' id='PrevMonth'  onclick='fPrevMonth(" + isMonth + ")'/><</span>";
    dateDiv += "</td><td align=center><div style='overflow:hidden; '><input id='tbSelYear' type='button' style='display:inline;box-sizing:border-box;width:80px;height:24px;line-height: 24px;' onclick='selectionBoxscroll()' onchange='fUpdateCal(ddlgGetElementV(\"tbSelYear\"," + isMonth + "),ddlgGetElementV(\"tbSelMonth\"," + isMonth + ")," + isMonth + ")'>"
            + "<div id='maskLayerTrp' style='position:fixed;left:0;top:0;bottom:0;right:0;display:none;' onclick='this.style.display=\"none\"'><ul id='selectList' onclick='window.event.cancelBubble = true'>";/*用input模拟select，当下拉年份时选中的年份位于选项的中间位置*/
    for (var i = startYear; i < endYear; i++) {
        dateDiv += "<li onmouseover='$(this).addClass(\"alSelected1\");' onmouseout='$(this).removeClass(\"alSelected1\")'  onclick='document.getElementById(\"tbSelYear\").value=this.innerHTML;$(\"div#maskLayerTrp\").css(\"display\",\"none\");$(\"#tbSelYear\").change();$(this).addClass(\"alSelected\").siblings().removeClass(\"alSelected\")' value='" + i + "'>" + i + strYear + "</li>";
    }
    dateDiv += "</ul></div></td>";
    if (isMonth) {
        dateDiv += "";
    }
    else {
        dateDiv += "<td><div><select id='tbSelMonth' style='display:inline;width:80px;height:24px;line-height: 24px;' onchange='fUpdateCal(ddlgGetElementV(\"tbSelYear\"),ddlgGetElementV(\"tbSelMonth\"))'>";
        for (var i = 0; i < 12; i++) {
            dateDiv += "<option value='" + (i + 1) + "'>" + gMonths[i] + "</option>";
        }
        dateDiv += "</select></div></td>";
    }
    dateDiv += "<td align='center'>";
    dateDiv += "<span class='rightarrow img' id='NextMonth' src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/dateright.gif'  onclick='fNextMonth(" + isMonth + ")'/>></span>";
    dateDiv += "</td>";
    dateDiv += "</tr><tr>";
    dateDiv += "<td align='center' colspan='4' style='padding:0'>";
    dateDiv += "<div style='background-color:#FFF;padding-top:10px;'>"
    dateDiv += "<table width='100%' style='table-layout:fixed' border='0' cellpadding='0' cellspacing='0' class='datedlgbodytable'>";
    dateDiv += fDrawCal(giYear, giMonth, dayTdHeight, dayTdTextSize, isMonth);
    dateDiv += "</table>";
    dateDiv += "</div>";
    dateDiv += "</td>";
    dateDiv += "</tr>";
    dateDiv += "<tr>";

    dateDiv += "<td align='center' colspan='4' style='padding:0px' nowrap id='CalendarMonth_tr'><div style='padding:10px 0;box-sizing:border-box;text-align:center'>";
    if(!a) {
        dateDiv += "<INPUT class='zb-button dateClearBtn' onclick='fClearInputData();' id='Calendar-Month-Clear-Btn' value='清空' type=button>";
    }
    dateDiv += "<span class='todayDate' style='padding-left:5px;padding-right:5px;cursor:pointer;' onclick='fSetDate(giYear,giMonth,giDay," + isMonth + ",1)'>" + giYear + strYear + giMonth + strMonth + "</span>";
    if(!a) {
        dateDiv += "<INPUT class='zb-button dateCloseBtn' onclick='fHideCalendar();' id='Calendar-Month-Close-Btn' value='关闭' type=button>";
    }

    dateDiv += "</div></td>";

    dateDiv += "<td align='center' colspan='4' style='padding:0px' nowrap id='CalendarOnlyDate_tr'><div style='padding:10px 0;box-sizing:border-box;text-align:center'>";
    if(!a) {
        dateDiv += "<INPUT class='zb-button dateClearBtn' onclick='fClearInputData();' id='Calendar-Normal-Clear-Btn' value='清空' type=button>";
    }

    dateDiv += "<span class='todayDate' style='padding-left:5px;padding-right:5px;cursor:pointer;' onclick='fSetDate(giYear,giMonth,giDay,null,1)'>" + strToday + ":" + giYear + strYear + giMonth + strMonth + giDay + strDay + "</span>";
    if(!a) {
        dateDiv += "<INPUT class='zb-button dateCloseBtn' onclick='fHideCalendar();' id='Calendar-Normal-Close-Btn' value='关闭' type=button>";
    }


    dateDiv += "</div></td>";

    dateDiv += "</tr>";
    dateDiv += "<tr>";
    dateDiv += "<td align='center' colspan='4' nowrap id='CalendarDateTime_tr' style='padding:0px;padding-top:2px;'>";
    dateDiv += "<table style='width:100%' cellspacing='0'>";
    dateDiv += "<tr style='background-color: #FFF;border:0'>";
    if(window.DateTimeNotShowSecond){
        dateDiv += "<td style='background-color: #FFF;border-color:#FFF'><div style='width:5px;overflow:hidden;height:18px'>&nbsp;</div></td>";
        dateDiv += "<td style='background-color: #FFF;border-color:#FFF' align='center'><span style=' '>&nbsp;&nbsp;&nbsp;<select style='font-family:宋体;min-width: 30px;vertical-align: middle' id='datedlg_hour'>" + optionsText2 + "</select></span><span style=''>&nbsp;时</span></td>";
        dateDiv += "<td  style='background-color: #FFF;border-color:#FFF' align='center'><span style=''><select style='font-family:宋体;min-width: 30px;vertical-align: middle' id='datedlg_mill'>" + optionsText + "</select></span><span style=''>&nbsp;分</span>&nbsp;</td>";
        dateDiv += "<td  style='background-color: #FFF;border-color:#FFF'><div style='width:10px;overflow:hidden;height:2px'>&nbsp;</div></td>" ;
    }else{
        dateDiv += "<td><div style='width:10px;overflow:hidden;height:2px'>&nbsp;</div></td>";
        dateDiv += "<td><div style='background-color:white;float: right'><select style='width:40px;' id='datedlg_hour'>" + optionsText2 + "</select></div></td><td>时</td>";
        dateDiv += "<td><div style='background-color:white;float: right'><select style='width:40px;' id='datedlg_mill'>" + optionsText + "</select></div></td><td>分</td>";
        dateDiv += "<td><div style='background-color:white;float: right'><select style='width:40px;' id='datedlg_secd'>" + optionsText + "</select></div></td><td>秒</td>";
        dateDiv += "<td><div style='width:10px;overflow:hidden;height:2px'>&nbsp;</div></td>";
    }
    dateDiv += "</tr>";
    dateDiv += "<tr>";
    dateDiv += "<td colspan='8' style='text-align:center;padding:10px 0;'>";
    if(!a){
        dateDiv += "<INPUT class='zb-button  dateClearBtn' style='width:45px' onclick='fClearInputData();' id='Calendar-Datetime-Clear-Btn' value='清空' type=button>";
        dateDiv += "<span class='todayDate' style='padding-left:5px;padding-right:5px;cursor:pointer;' onclick='fSetDate(giYear,giMonth,giDay,null,1)'>" + strToday + ":" + giYear + strYear + giMonth + strMonth + giDay + strDay + "</span>";
        dateDiv += "<INPUT class='zb-button dateCloseBtn HighLight' style='width:45px' onclick='fConfirmData(this);' id='Calendar-Datetime-Confirm-Btn' value='确定' type=button>";
    }


    dateDiv += "</td>";
    dateDiv += "</tr>";
    dateDiv += "</table>";
    dateDiv += "</td>";
    dateDiv += "</tr>";
    dateDiv += "</table></div>";
    return dateDiv;
}
var dlgFireElement = null;
function clearSelDate() {
	if(!window.event){ return; }
    if (dlgFireElement == window.event.srcElement) {
        return;
    }
    if ($ID("calendardiv")&&$ID("calendardiv").style&&$ID("calendardiv").style.visibility == "visible") {
        datedlg.activedIntBox = dlgFireElement;
        dlgFireElement = null;
        fHideCalendar();
    }
}

function fChooseToday(){
	var iDate = new Date();
	var iYear = iDate.getFullYear();
	var iMonth = iDate.getMonth()*1+1;
	var iDay = iDate.getDate();  
	fSetDate(iYear, iMonth, iDay, "");
}

function fConfirmData(s){
	var tmp = $(s).attr('val');
	window.DateTimeShowHMSArea = null;
	fSetSelected(tmp);
}

function BindPageScrollVisible() {
	$('body').on("scroll", function () {//因为在鼠标滚动的时候，日历框不会跟着动，但是又不能在body上加“position：relative”，所以滚动的时候隐藏；
        clearSelDate();
    })
	if($("#rptframebody")){
		$("#rptframebody").on("scroll",function(){
			clearSelDate();
		})
	}
}

//解决模拟日期下拉框相对于input位置问题
function positionXY() {
    var input = document.getElementById("tbSelYear");
    var l = input.getBoundingClientRect().left;
    var t = input.getBoundingClientRect().top + input.offsetHeight;
    $("#selectList").css({ "left": l + "px", "top": t + "px" })
}

//选择项的滚动
function selectionBoxscroll() {
    if ($("#maskLayerTrp").css("display") == "none") {
        positionXY()
        $("#maskLayerTrp").css("display", "block");
        var n = $("#tbSelYear").val().replace("年", "") - startYear;
        var scrollTop1 = 18 * (n > 10 ? (n - 10) : 0)//18为li的高度；
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
attachEvent1(window, "scroll", isBodyScroll)
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

var datedlg = {
    cdiv: function (isMonth,a) {
        var d = document.getElementById("calendardiv");
        if (!d || oldIsMonth != isMonth) {
            //月份模式 切换 日期 和时间模式
            if (d) { document.body.removeChild(d); }
            d = document.createElement("div");
            d.id = "calendardiv";
            d.style.display = "none";
            d.onclick = function () {
                event.cancelBubble = true;
            };
            d.innerHTML = getDateDiv(isMonth,a);
            document.body.appendChild(d);
            if (app && app.IeVer && app.IeVer < 100) {
                $(document).on("focus", "textarea", function () {
                    datedlg.activedIntBox = null;//规避ie上日期框前面是多行文本框时不触发body上的点击事件
                })
            }
            BindPageScrollVisible();
        }
    }
	,
    show: function () {
        datedlg.ismonthpanel = false;
        dlgFireElement = window.event.srcElement;
        datedlg.cdiv(false);
        $("body").unbind("click", datedlg.dateeventproc).bind("click", datedlg.dateeventproc);
        var button = window.event.srcElement;
        if (button.disabled) { return; }
        if (button.tagName == "BUTTON" || button.tagName == "IMG" || button.className .indexOf("fieldDateBtn")>-1 ) {
            if (button.previousSibling && button.previousSibling.tagName == "INPUT") {
                button = button.previousSibling;
            }
            else {
                var td = button.parentElement;
                button = td.previousSibling.all[0];
                if (!button) {
                    button = td.previousSibling;
                }
            }
        }
        document.getElementById('Calendar-Month-Clear-Btn').style.display = "inline-block";
        document.getElementById('Calendar-Month-Close-Btn').style.display = "inline-block";
        document.getElementById('Calendar-Normal-Clear-Btn').style.display = "inline-block";
        document.getElementById('Calendar-Normal-Close-Btn').style.display = "inline-block";
        if (button.value.replace(/[ ]/g, "")) {//获取文本框内年月日
            var yyR;
            if (button.value.indexOf("-") > 0) { yyR = button.value.split("-"); } else { yyR = button.value.split("/"); }
            var isyearvalid = yyR[0] * 1 < 1910 || yyR[0] * 1 > 3999 ? false : true
            giYear1 = !isyearvalid ? giYear : yyR[0];
            giMonth1 = yyR[1] ? (yyR[1] > 0 ? yyR[1] : (!isyearvalid ? giMonth : 1)) : (!isyearvalid?giMonth:1);
            giDay1 = yyR[2] ? (yyR[2] > 0 ? yyR[2] : (!isyearvalid ? giMonth : 1)) : (!isyearvalid?giDay:1);
        } else {
            giYear1 = "";
            giMonth1 = "";
            giDay1 = "";
        }
        fPopCalendar(window.event, button, button, false, false)
        $(document).unbind("keydown", Bill.EnterTabKeyHandle);
        $(document).unbind("keydown", datedlg.dateLayerShortKey).bind("keydown", datedlg.dateLayerShortKey);
    }
	,
    setTimeValue: function () {
        var div = document.getElementById("datedlg_time_panel");
        var s = div.getElementsByTagName("select");
        var bid = div.getAttribute("buttonId");
        var button = document.getElementById(bid);
        if (RecordTimeBox) { button = RecordTimeBox}
        button.value = s[0].value + ":" + s[1].value + ":" + s[2].value;
        $(button).trigger('change');
        div.style.display = "none";
        RecordTimeBox = null;
        try {
            var lvwdiv = window.getParent(div.button, 9);
            if (lvwdiv.className == "ctl_listview") {
                lvw.updateRowByInput(div.button);//更新listview数组
            }
        } catch (e) { }
    }
	,
    showTime: function () { //显示时间选择框
        if (window.SysConfig && !window.virpath) {
            window.virpath = window.SysConfig.VirPath + "SYSA/"
        }
        var button = window.event.srcElement;
        var input = button.previousSibling;
        if(input && $(input).attr("islvw")==1){
        	var lvwcellinfo = ListView.GetListViewCellInfoDomId(input.id);
        	var lvw = lvwcellinfo.lvwobj;
        	var rowindex = lvwcellinfo.rowindex;
		    if (lvw && rowindex!=-1 && lvw.rows[rowindex][0] == "\1\1\1NewRowSign\1\1\1") {
		    	__lvw_je_addNew(lvw.id);
		    	return;
		    }
        }
        if (button.tagName == "BUTTON" || button.tagName == "IMG" || button.className.indexOf("fieldDateBtn")>-1 ) {
            if (button.previousSibling && button.previousSibling.tagName == "INPUT") {
                button = button.previousSibling;
            }
            else {
                var td = button.parentElement;
                button = td.previousSibling.all[0];
                if (!button) {
                    button = td.previousSibling;
                }
            }
        }
        window.RecordTimeBox = input;//声明一个window变量，记录操作的dom元素；
        var vs = (input.value).split(":")
        var mH = (vs[0]||0)*1,  mM = (vs[1]||0)*1,  mS =(vs[2]||0)*1;

        var div = document.getElementById("datedlg_time_panel");
        if (!div) {
            var h = "", m = "", s = ""
            for (var i = 0; i < 24 ; i++) { h = h + "<option " + ((mH - i) == 0 ? "selected" : "") + " value='" + (i < 10 ? "0" : "") + i + "'>" + (i < 10 ? "0" : "") + i + "</option>" }
            for (var i = 0; i < 60 ; i++) { m = m + "<option " + ((mM - i) == 0 ? "selected" : "") + "  value='" + (i < 10 ? "0" : "") + i + "'>" + (i < 10 ? "0" : "") + i + "</option>" }
            for (var i = 0; i < 60 ; i++) { s = s + "<option " + ((mS - i) == 0 ? "selected" : "") + "  value='" + (i < 10 ? "0" : "") + i + "'>" + (i < 10 ? "0" : "") + i + "</option>" }
            div = document.createElement("div");
            div.id = "datedlg_time_panel";
            div.style.cssText = "border:1px solid #ccc;box-shadow: 0px 2px 6px 0px rgba(43, 43, 43, 0.42);background:#FFF;overflow:hidden;position:absolute;z-index:990000;background-color:white;display:none;"
            div.innerHTML = "<table style='margin:5px;background-color:#fff' cellSpacing=5><tr><td>"
							+ "<select class='time'>" + (h?h:0)
                            + "</select></td><td>时</td><td><select class='time'>" + (m ? m : 0) + "</select></td><td>分</td><td>"
                            + "<select class='time'>" + (s?s:0)
                            + "</select><td>秒</td></td><td><button class='wavbutton HighLight' onclick='datedlg.setTimeValue()'>确定</button></td></tr></table>"
            document.body.appendChild(div);
        }
        else {
            var s = div.getElementsByTagName("select");
            s[0].selectedIndex = mH; s[1].selectedIndex = mM; s[2].selectedIndex = mS;
        }
		
		var l = $(button).offset().left;
		var t = $(button).offset().top;
		
        var xy = window.dcGetObjectPos(button, 1);
        div.style.position = "absolute";
        div.style.top = t + 20 + "px";
        div.style.left = l + "px";
        div.style.display = "block";
        div.button = button;
        div.setAttribute("buttonId", button.id);
        $("body").on("click",function (e) {
            var ele=e.target;
            if(ele.className.indexOf("fieldDateBtn")>-1){return;}
            var par=ele.parentNode;
            while(par&&par.id!="datedlg_time_panel"){
               par=par.parentNode;
            }
            if(!par){
                div.style.display="none"
            }
        });
    }
	,
    showYearMonth: function (a) {//setmonth
        datedlg.ismonthpanel = true;
        dlgFireElement = window.event.srcElement;
        datedlg.cdiv(true);
        $("body").unbind("click", datedlg.dateeventproc).bind("click", datedlg.dateeventproc);
        var button = window.event.srcElement;
        if (button.disabled) { return; }
        if (button.tagName == "BUTTON" || button.tagName == "IMG" || button.className .indexOf("fieldDateBtn")>-1 ) {
            if (button.previousSibling && button.previousSibling.tagName == "INPUT") {
                button = button.previousSibling;
            }
            else {
                var td = button.parentElement;
                button = td.previousSibling.all[0];
                if (!button) {
                    button = td.previousSibling;
                }
            }
        }
        document.getElementById('Calendar-Month-Clear-Btn').style.display = "inline-block";
        document.getElementById('Calendar-Month-Close-Btn').style.display = "inline-block";
        $(document).unbind("keydown", Bill.EnterTabKeyHandle);
        $(document).unbind("keydown", datedlg.dateLayerShortKey).bind("keydown", datedlg.dateLayerShortKey);
        if (button.value) {//有年月的文本框获取其年月日
            var yyR = button.value;
            if (yyR.indexOf("-") > 0) { yyR = yyR.split("-"); } else { yyR = yyR.split("/"); }
            var isyearvalid = yyR[0] * 1 < 1910 || yyR[0] * 1 > 3999 ? false : true;
            giYear1 = !isyearvalid ? giYear : yyR[0];
            giMonth1 = yyR[1] ? (yyR[1] > 0 ? yyR[1] : (!isyearvalid ? giMonth : 1)) : (!isyearvalid ? giMonth : 1);
        } else {
            giYear1 = "";
            giMonth1 = "";
        }
        fPopCalendar(window.event, button, button, true, true)
    }
	,
    showtime: function () {
        return datedlg.showTime();
    }
	,
    ShowTime: function () {
        return datedlg.showTime();
    }
	,

    showyearmonth: function () {
        return datedlg.showYearMonth();
    }
	,
    ShowYearMonth: function () {
        return datedlg.showYearMonth();
    }
	,
    showDateTime: function (a,b,box) {//a:显示确定和关闭按钮；b:显示秒
        if(b){window.DateTimeNotShowSecond=true;}
        else{window.DateTimeNotShowSecond=false;}
        window.DateTimeShowHMSArea = true;
        dlgFireElement = window.event&&window.event.srcElement||null;
        datedlg.cdiv(false,a);
        $("body").unbind("click", datedlg.dateeventproc).bind("click", datedlg.dateeventproc);
        var button = window.event && window.event.srcElement || box;
        if (button&&button.disabled) { return; }
        if (button&&(button.tagName == "BUTTON" || button.tagName == "IMG" || button.className.indexOf("fieldDateBtn") > -1)) {
            if (button.previousSibling && button.previousSibling.tagName == "INPUT") {
                button = button.previousSibling;
            }
            else {
                var td = button.parentElement;
                button = td.previousSibling.all[0];
                if (!button) {
                    button = td.previousSibling;
                }
            }
        }
        document.getElementById('Calendar-Datetime-Confirm-Btn').style.display = "inline-block";
        document.getElementById('Calendar-Datetime-Clear-Btn').style.display = "inline-block";
        if (button.value) {//有时分秒的文本框获取其年月日
            var yyR = button.value.split(" ")[0];
            if (yyR.indexOf("-") > 0) { yyR = yyR.split("-"); } else { yyR = yyR.split("/"); }
            var isyearvalid = yyR[0] * 1 < 1910 || yyR[0] * 1 > 3999 ? false : true;
            giYear1 = !isyearvalid ? giYear : yyR[0];
            giMonth1 = yyR[1] ? (yyR[1] > 0 ? yyR[1] : (!isyearvalid ? giMonth : 1)) : (!isyearvalid ? giMonth : 1);
            giDay1 = yyR[2] ? (yyR[2] ? yyR[2] : (!isyearvalid ? giMonth : 1)) : (!isyearvalid ? giDay : 1);
        } else {
            giYear1 = "";
            giMonth1 = "";
            giDay1 = "";
        }
        fPopCalendar(window.event, button, button, true, false,box)
        $(document).unbind("keydown", Bill.EnterTabKeyHandle);
        $(document).unbind("keydown", datedlg.dateLayerShortKey).bind("keydown", datedlg.dateLayerShortKey);
    }
	,
    autohide: function () {
        var p = document.getElementById("calendardiv");
        var o = window.event.srcElement;
        if (!p) { return true; }
        while (o) {
            o = o.parentNode;
            if (o == p) { return true; }
        }
        fHideCalendar();
    }
	,
    setRange: function (id1, id2, n, typ) {//'BUG 6578 Sword 2014-12-10 凭证字相关bug 
        switch (typ) {
            case "months":
                if (n == 1) {
                    if (!$('#' + id2).attr('oldminDate')) {
                        $('#' + id2).attr('oldminDate', $('#' + id2).attr('minDate'));
                    }
                    var minDate = $('#' + id1).val();
                    if (minDate.length > 0) {
                        $('#' + id2).attr('minDate', minDate + '-01');
                    }
                    else {
                        $('#' + id2).attr('minDate', $('#' + id2).attr('oldminDate'));
                    }
                }
                else {
                    if (!$('#' + id1).attr('oldmaxDate')) {
                        $('#' + id1).attr('oldmaxDate', $('#' + id1).attr('maxDate'));
                    }
                    var maxDate = $('#' + id2).val();
                    if (maxDate.length > 0) {
                        $('#' + id1).attr('maxDate', maxDate + '-01');
                    }
                    else {
                        $('#' + id1).attr('maxDate', $('#' + id1).attr('oldmaxDate'));
                    }
                }
                break;
        }
    },
    dateeventproc: function () {
        var funbodyclick = document.onclick;
        clearSelDate();
        datedlg.activedIntBox = null;
        if (funbodyclick) { funbodyclick(); }
    },
    activedIntBox: null,
    ismonthpanel: false
}
function toggleDatePicker(id1, id2) {
    datedlg.show();
}
function hideDiv() {
    document.getElementById("calendardiv").style.visibility="hidden";
}

//日期弹层快捷键
datedlg.dateLayerShortKey = function (e) {
    if (!e.target) { return }
    datedlg.activedIntBox = e.target;
    if (e && e.preventDefault) { e.preventDefault() } else { window.event.returnValue = false; };
    var keycode = e.keyCode || e.which;
    var selectDefCell = $("td.defaultSelected")[0];
    var curDayCell = $("td.currTDate")[0];
    if (!selectDefCell) {
        if (!curDayCell) {
            if (keycode == 13) {
                window.DateTimeShowHMSArea = false;
                fSetSelected("", datedlg.ismonthpanel);
            }
            return Bill && Bill.shortCutKeyGoLeft ? Bill.shortCutKeyGoLeft(e.target) : "";
        }
        selectDefCell = curDayCell;
        giYear1 = giYear1 || giYear; giMonth1 = giMonth1 || giMonth;
        giDay1 = giDay1 || giDay;
    };
    var arrRC = selectDefCell.id.replace("tday", "").replace("tmon", "").split("");
    var rowidx = arrRC[0];
    var colidx = arrRC[1];
    switch (keycode) {
        case 37:
            if (datedlg.ismonthpanel) { $(selectDefCell).removeClass("defaultSelected"); window.showMonthCutKey(rowidx, colidx,37); return }
            if (datedlg.dateRows[rowidx][colidx] > 1) {
                if (colidx * 1 >= 1) {
                    colidx = colidx * 1 - 1
                } else {
                    colidx = 6;
                    rowidx = rowidx * 1 - 1
                }
                $(selectDefCell).removeClass("defaultSelected");
                $("td#tday" + rowidx + colidx).addClass("defaultSelected");
            } else {
                giMonth1 = giMonth1 - 1;
                if (giMonth1 < 1) { giMonth1 = 12; giYear1--; }
                datedlg.dateRows = fBuildCal(giYear1, giMonth1, false)
                var dateArr;
                for (var i = datedlg.dateRows.length - 1; i > 0; i--) {
                    dateArr = datedlg.dateRows[i].join(",").split(",").sort(function (a, b) { return b - a });
                    if (dateArr[0] * 1 > 0) { giDay1 = dateArr[0]; break }
                }
                fSetYearMon(giYear1, giMonth1, false)
            }
            break
        case 39:
            if (datedlg.ismonthpanel) { $(selectDefCell).removeClass("defaultSelected"); window.showMonthCutKey(rowidx, colidx, 39); return }
            var rowdatas = datedlg.dateRows[rowidx];
            var max = getMaxDay(datedlg.dateRows)
            if (rowdatas[colidx] > 0 && rowdatas[colidx] < max) {
                if (colidx < 6) {
                    colidx = colidx * 1 + 1
                } else {
                    colidx = 0;
                    rowidx = rowidx * 1 + 1
                }
                $(selectDefCell).removeClass("defaultSelected")
                $("td#tday" + rowidx + colidx).addClass("defaultSelected");
                $("td#tmon" + rowidx + colidx).addClass("defaultSelected");
            } else {
                giMonth1 = giMonth1 * 1 + 1;
                if (giMonth1 > 12) { giMonth1 = 1; giYear1++; }
                giDay1 = 1;
                fSetYearMon(giYear1, giMonth1, false)
            }
            break
        case 38:
            if (datedlg.ismonthpanel) { $(selectDefCell).removeClass("defaultSelected"); window.showMonthCutKey(rowidx, colidx, 38); return }
            if (rowidx > 1) {
                if (datedlg.dateRows[rowidx - 1][colidx] > 0) {
                    $(selectDefCell).removeClass("defaultSelected")
                    $("td#tday" + (rowidx - 1) + colidx).addClass("defaultSelected");
                    return;
                }
                giMonth1 = giMonth1 - 1;
                if (giMonth1 < 1) { giMonth1 = 12; giYear1--; }
                giDay1 = Math.abs(datedlg.dateRows[rowidx - 1][colidx]);
                fSetYearMon(giYear1, giMonth1, false);
            } else {
                giMonth1 = giMonth1 - 1;
                if (giMonth1 < 1) { giMonth1 = 12; giYear1--; }
                var restarr = datedlg.dateRows[rowidx].slice(0, colidx + 1);
                var currRowMin = getMinDay(restarr);
                if (restarr[0] < 0) {
                    var minIdx = currRowMin.idx;
                    giDay1 = Math.abs(currRowMin.num) - (7 - colidx + minIdx);
                } else {
                    datedlg.dateRows = fBuildCal(giYear1, giMonth1, false);
                    giDay1 = getMaxDay(datedlg.dateRows) - (7 - colidx) + 1;
                }
                fSetYearMon(giYear1, giMonth1, false);
            }
            break
        case 40:
            if (datedlg.ismonthpanel) { $(selectDefCell).removeClass("defaultSelected"); window.showMonthCutKey(rowidx, colidx, 40); return }
            var max = getMaxDay(datedlg.dateRows);
            var rows = datedlg.dateRows;
            if (rowidx < 6) {
                if (rows[rowidx * 1 + 1][colidx] > 0) {
                    $(selectDefCell).removeClass("defaultSelected")
                    $("td#tday" + (rowidx * 1 + 1) + colidx).addClass("defaultSelected");
                } else {
                    giMonth1 = giMonth1 * 1 + 1;
                    if (giMonth1 > 12) { giMonth1 = 1; giYear1++; }
                    giDay1 = Math.abs(rows[rowidx * 1 + 1][colidx]);
                    fSetYearMon(giYear1, giMonth1, false)
                }
            } else {
                if (!datedlg.dateRows) { return }
                giMonth1 = giMonth1 * 1 + 1;
                if (giMonth1 > 12) { giMonth1 = 1; giYear1++; }
                var restarr = datedlg.dateRows[rowidx].slice(colidx * 1 + 1, 7);
                var currRowMin = getMinDay(restarr);
                giDay1 = Math.abs(currRowMin.num) + colidx * 1 + 1;
                fSetYearMon(giYear1, giMonth1, false)
            }
            break
        case 8:
            giYear1 = ""; giMonth1 = "";
            datedlg.ismonthpanel ? $("td#tmon" + rowidx + colidx).removeClass("defaultSelected") : $("td#tday" + rowidx + colidx).removeClass("defaultSelected");
            $("td.currTDate").removeClass("currTDate");
            break
        case 13:
            var dateid = $("td.defaultSelected")[0] && $("td.defaultSelected")[0].id.replace("tday", "").replace("tmon", "") || $("td.currTDate")[0] && $("td.currTDate")[0].id.replace("tday", "");
            window.DateTimeShowHMSArea = false;//带时间的enter选中
            fSetSelected(dateid , datedlg.ismonthpanel);
            return Bill && Bill.shortCutKeyGoLeft ? Bill.shortCutKeyGoLeft(e.target) : "";
            break
    }
}

window.showMonthCutKey = function (rowidx,colidx,key) {
    switch (key) {
        case 37:
            if (datedlg.dateRows[rowidx][colidx] > 1) {
                if (colidx > 0) {
                    colidx = colidx * 1 - 1
                } else {
                    colidx = 3;
                    rowidx = rowidx-1
                }
                $("td#tmon" + rowidx + colidx).addClass("defaultSelected");
            } else {
                giMonth1 = 12;
                giYear1--;
                fSetYearMon(giYear1, giMonth1, true)
            }
            break
        case 39:
            if (datedlg.dateRows[rowidx][colidx] < 12) {
                if (colidx < 3) {
                    colidx = colidx * 1 + 1
                } else {
                    colidx = 0;
                    rowidx = rowidx*1 + 1
                }
                $("td#tmon" + rowidx + colidx).addClass("defaultSelected");
            } else {
                giMonth1 = 1;
                giYear1 = giYear1*1+1;
                fSetYearMon(giYear1, giMonth1, true)
            }
            break
        case 38:
            if (rowidx > 1) {
                giMonth1 = datedlg.dateRows[rowidx-1][colidx];
                fSetYearMon(giYear1, giMonth1, true);
                $("td#tmon" + (rowidx - 1) + colidx).addClass("defaultSelected");
            } else {
                giMonth1 = datedlg.dateRows[3][colidx];
                giYear1--;
                fSetYearMon(giYear1, giMonth1, true)
            }
            break
        case 40:
            if (rowidx < 3) {
                giMonth1 = datedlg.dateRows[rowidx*1 + 1][colidx];
                $("td#tmon" + (rowidx*1+1) + colidx).addClass("defaultSelected");
            } else {
                giMonth1 = datedlg.dateRows[1][colidx];
                giYear1++;
                fSetYearMon(giYear1, giMonth1, true)
            }
            break
    }
}

//二维数组求最大；
function getMaxDay(arr) {
    var results = [];
    var largestNumber = 0;
    for (var n = 1; n < arr.length; n++) {
        largestNumber = Math.max.apply(null, arr[n])
        results[n] = largestNumber;
    }
    results.sort(function (a, b) { return b - a });
    return results[0];
}

//一维数组求最小
function getMinDay(arr) {
    var num = Math.min.apply(null, arr), idx;
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] == num) { idx = i; break }
    }
    return { num: num, idx: idx }
}
