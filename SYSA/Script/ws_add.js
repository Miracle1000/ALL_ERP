
function getcount(uid)
{
	var CutAll = 0;
	var AddAll = 0;
	var thisAll = 0;
	var tr = document.getElementById("row_" + uid);
	var boxs = tr.getElementsByTagName("input");
	for (var i = 0 ; i < boxs.length ; i ++ )
	{
		var item = boxs[i];
		if ((item.type=="text" || item.type=="hidden") && item.id.indexOf("intro_")<0)
		{
		    var v5 = 0;
			var v1 = item.value;
			if(document.getElementById("p_"+(i-1)))
			{
			    var v2 = document.getElementById("p_" + (i - 1)).value;
			    v5 = $("#p_" + (i-1)).attr("deductible")
			}
			else
			{
				var v2 = 0
			}
			var v3 = v1*v2;
			if (v5==1)
			{
				CutAll +=v3;
			}
			else{
				AddAll +=v3;
			}
			thisAll+= v3;
		}
	}
	var box = document.getElementById("money2_"+uid+"");
	if (box)
	{
		thisAll+=box.value*1;
		AddAll+=box.value*1;
	}
	var box = null;
	CutAll=Math.abs(CutAll);

	$("#yf_all_"+uid+"").html(FormatNumber(AddAll,window.sysConfig.moneynumber));
	$("#yk_all_"+uid+"").html(FormatNumber(CutAll,window.sysConfig.moneynumber));
	$("#sj_all_"+uid+"").html(FormatNumber(thisAll,window.sysConfig.moneynumber));
}


// 一个简单的测试是否IE浏览器的表达式
isIE = (document.all ? true : false);

// 得到IE中各元素真正的位移量，即使这个元素在一个表格中
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
 iPos = 0
 while (elt!=null) {
  iPos += elt["offset" + which]
  elt = elt.offsetParent
 }
 return iPos
}

function getXBrowserRef(eltname) {
 return (isIE ? document.all[eltname].style : document.getElementById(eltname).style);
}

function hideElement(eltname) { 
	getXBrowserRef(eltname).visibility = 'hidden';
}

// 按不同的浏览器进行处理元件的位置
function moveBy(elt,deltaX,deltaY) {
 if (isIE) {
  elt.left = elt.pixelLeft + deltaX;
  elt.top = elt.pixelTop + deltaY;
 } else {
  elt.left += deltaX;
  elt.top += deltaY;
 }
}

function toggleVisible(eltname) {
 elt = getXBrowserRef(eltname);
 if (elt.visibility == 'visible' || elt.visibility == 'show') {
   elt.visibility = 'hidden';
 } else {
   fixPosition(eltname);
   elt.visibility = 'visible';
 }
}

function setPosition(elt,positionername,isPlacedUnder) {
	positioner = null;
	if (isIE) {
		positioner = document.all[positionername];
		elt.left = getIEPosX(positioner);
		elt.top = getIEPosY(positioner);
	} else {
		positioner = document.getElementById(positionername);
		elt.left = positioner.x;
		elt.top = positioner.y;
	}
	if (isPlacedUnder) { moveBy(elt,0,positioner.height); }
}



//——————————————————————————————————————

// 判断浏览器
isIE = (document.all ? true : false);

// 初始月份及各月份天数数组
var months = new Array("一　月", "二　月", "三　月", "四　月", "五　月", "六　月", "七　月",
"八　月", "九　月", "十　月", "十一月", "十二月");
var daysInMonth = new Array(31, 28, 31, 30, 31, 30, 31, 31,
30, 31, 30, 31);
var displayMonth = new Date().getMonth();
var displayYear = new Date().getFullYear();
var displayDivName;
var displayElement;

function getDays(month, year) {
	//测试选择的年份是否是润年？
	if (1 == month)
	   return ((0 == year % 4) && (0 != (year % 100))) ||
		  (0 == year % 400) ? 29 : 28;
	else
	   return daysInMonth[month];
}

 function getToday() {
	// 得到今天的日期
	this.now = new Date();
	this.year = this.now.getFullYear();
	this.month = this.now.getMonth();
	this.day = this.now.getDate();
 }

// 并显示今天这个月份的日历
today = new getToday();

 function newCalendar(eltName,attachedElement) {
	if (attachedElement) {
	   if (displayDivName && displayDivName != eltName) hideElement(displayDivName);
	   displayElement = attachedElement;
	}
	displayDivName = eltName;
	today = new getToday();
	var parseYear = parseInt(displayYear + '');
	var newCal = new Date(parseYear,displayMonth,1);
	var day = -1;
	var startDayOfWeek = newCal.getDay();
	if ((today.year == newCal.getFullYear()) &&(today.month == newCal.getMonth()))
	{
		day = today.day;
	}
	var intDaysInMonth =
	getDays(newCal.getMonth(), newCal.getFullYear());
	var daysGrid = makeDaysGrid(startDayOfWeek,day,intDaysInMonth,newCal,eltName)
	if (isIE) {
		var elt = document.all[eltName];
		elt.innerHTML = daysGrid;
		elt.style.zIndex = 1000;
	} else {
		var elt = document.getElementById(eltName);
		elt.innerHTML = daysGrid;
		elt.style.zIndex = 1000;
	}
}

     function incMonth(delta,eltName) {
       displayMonth += delta;
       if (displayMonth >= 12) {
         displayMonth = 0;
         incYear(1,eltName);
       } else if (displayMonth <= -1) {
         displayMonth = 11;
         incYear(-1,eltName);
       } else {
         newCalendar(eltName);
       }
     }

     function incYear(delta,eltName) {
       displayYear = parseInt(displayYear + '') + delta;
       newCalendar(eltName);
     }

     function makeDaysGrid(startDay,day,intDaysInMonth,newCal,eltName) {
        var daysGrid;
        var month = newCal.getMonth();
        var year = newCal.getFullYear();
        var isThisYear = (year == new Date().getFullYear());
        var isThisMonth = (day > -1)
        daysGrid = '<table border=1 cellspacing=0 cellpadding=2><tr><td bgcolor=#ffffff nowrap>';
        daysGrid += '<font face="courier new, courier" size=2>';
        daysGrid += '<a href="javascript:hideElement(\'' + eltName + '\')">x</a>';
        daysGrid += '  ';
        daysGrid += '<a href="javascript:incMonth(-1,\'' + eltName + '\')">&laquo; </a>';

        daysGrid += '<b>';
        if (isThisMonth) { daysGrid += '<a href="javascript:setDay(';
           daysGrid += dayOfMonth + ',\'' + eltName + '\')"> <font color=red>' + months[month] + '</font></a>'; }
        else { daysGrid += '<a href="javascript:setDay(';
           daysGrid += dayOfMonth + ',\'' + eltName + '\')"> ' +months[month]+ '</a>'; }
        daysGrid += '</b>';



        daysGrid += '<a href="javascript:incMonth(1,\'' + eltName + '\')"> &raquo;</a>';
        daysGrid += '   ';
        daysGrid += '<a href="javascript:incYear(-1,\'' + eltName + '\')">&laquo; </a>';

        daysGrid += '<b>';
        if (isThisYear) { daysGrid += '<font color=red>' + year + '</font>'; }
        else { daysGrid += ''+year; }
        daysGrid += '</b>';

        daysGrid += '<a href="javascript:incYear(1,\'' + eltName + '\')"> &raquo;</a>';

        var dayOfMonthOfFirstSunday = (7 - startDay + 1);
        for (var intWeek = 0; intWeek < 6; intWeek++) {
           var dayOfMonth;
           for (var intDay = 0; intDay < 7; intDay++) {
             dayOfMonth = (intWeek * 7) + intDay + dayOfMonthOfFirstSunday - 7;
         if (dayOfMonth <= 0) {
         } else if (dayOfMonth <= intDaysInMonth) {
          var color = "blue";
           if (day > 0 && day == dayOfMonth) color="red";
           daysGrid += '<a href="javascript:setDay(';
           daysGrid += dayOfMonth + ',\'' + eltName + '\')" '
           daysGrid += 'style="color:' + color + '">';
           var dayString = dayOfMonth + "</a> ";
           if (dayString.length == 6) dayString = '0' + dayString;
         }
           }

        }
        return daysGrid + "</td></tr></table>";
     }


//——————————————————————————————————————

// fixPosition() 这个函数和前面所讲的那个函数一样
//
function fixPosition(eltname) {
 elt = getXBrowserRef(eltname);
 positionerImgName = eltname + 'Pos';
 // hint: try setting isPlacedUnder to false
 isPlacedUnder = false;
 if (isPlacedUnder) {
	setPosition(elt,positionerImgName,true);
 } else {
	setPosition(elt,positionerImgName)
 }
}

function toggleDatePicker(eltName,formElt) {
  var x = formElt.indexOf('.');
  var formName = formElt.substring(0,x);
  var formEltName = formElt.substring(x+1);
  newCalendar(eltName,document.forms[formName].elements[formEltName]);
  toggleVisible(eltName);
}

// fixPositions() 这个函数前面也讲过
function fixPositions()
{
 fixPosition('daysOfMonth');
 fixPosition('daysOfMonth2');
}


function showCover(){
		$("#progress").show();
		$("#progress").height(document.body.scrollHeight);
		$("#progress").width(document.body.scrollWidth);
		$("#imgs").css("top",document.body.scrollHeight/2+document.body.scrollTop/2-50);
		$("#imgs").css("left",document.body.scrollWidth/2+document.body.scrollLeft/2-50);
}

function ask2() {
	var frm = document.getElementById("demo"); 
	var gztitle = document.getElementsByName('title')[0].value;
	if(gztitle.length==0){ 
		alert('请输入工资单主题,长度必须在1至50个字之间!');
		document.getElementsByName('title')[0].focus();
		return false;
	}

	$("#gzact").val("zancun");
	showCover();
	frm.action = "save.asp";
	frm.submit();
}

