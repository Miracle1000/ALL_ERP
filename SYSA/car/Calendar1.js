//<input name="nowdate" size="9" readonly="true" id="daysOfMonthPos" onmouseup="toggleDatePicker('daysOfMonth','date.nowdate')"><DIV id=daysOfMonth style="POSITION: absolute;z-index:10"></DIV>
strFrame='<style type="text/css">'
strFrame+='<!--'
strFrame+='.Calendar_table{'
strFrame+='padding:3px;'
strFrame+='font-size:12px;}'
strFrame+='.Calendar_table td{'
strFrame+='padding:2px;'
strFrame+='color:#FFFFFF;}'
strFrame+='.Calendar_table a:link { text-decoration: none;'
strFrame+='color: blue;'
strFrame+='padding:2px;'
strFrame+='}'
strFrame+='.Calendar_table a:active { text-decoration:none;'
strFrame+='padding:2px;'
strFrame+='}'
strFrame+='.Calendar_table a:hover { text-decoration:none;'
strFrame+='background-color:#00FF00;'
strFrame+='padding:2px;'
strFrame+='}'
strFrame+='.Calendar_table a:visited { text-decoration: none;'
strFrame+='color: green;'
strFrame+='padding:2px;'
strFrame+='}'
strFrame+='-->'
strFrame+='</style>'
document.writeln(strFrame);
isIE = (document.all ? true : false);
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
 //return (isIE ? document.all[eltname].style : document.layers[eltname]);
 return document.getElementsByName(eltname)[0]
}

function hideElement(eltname) {try{getXBrowserRef(eltname).innerHTML=""}catch(e3){};
//getXBrowserRef(eltname).visibility = 'hidden'; 
}

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
  positioner = document.images[positionername];
  elt.left = positioner.x;
  elt.top = positioner.y;
 }
 if (isPlacedUnder) { moveBy(elt,0,positioner.height); }
}

isIE = (document.all ? true : false);

var months = new Array("01 月", "02 月", "03 月", "04 月", "05 月", "06 月", "07 月","08 月", "09 月", "10 月", "11 月", "12 月");
var daysInMonth = new Array(31, 28, 31, 30, 31, 30, 31, 31,30, 31, 30, 31);
var displayMonth = new Date().getMonth();
var displayYear = new Date().getFullYear();
var displayDivName;
var displayElement;

function getDays(month, year) {
if (1 == month)
   return ((0 == year % 4) && (0 != (year % 100))) ||
	  (0 == year % 400) ? 29 : 28;
else
   return daysInMonth[month];
}

function getToday() {
this.now = new Date();
this.year = this.now.getFullYear();
this.month = this.now.getMonth();
this.day = this.now.getDate();
}

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
	if ((today.year == newCal.getFullYear()) &&
		  (today.month == newCal.getMonth()))
{
	   day = today.day;
	}
	var intDaysInMonth =
	   getDays(newCal.getMonth(), newCal.getFullYear());
	var daysGrid = makeDaysGrid(startDayOfWeek,day,intDaysInMonth,newCal,eltName)
if (isIE) {
  // var elt = document.all[eltName];
  var elt = document.getElementsByName(eltName)[0]
   elt.innerHTML = daysGrid;
} else {
   var elt = document.layers[eltName].document;
   elt.open();
   elt.write(daysGrid);
   elt.close();
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
daysGrid = '<table border=0 cellspacing=1 cellpadding=0 bgcolor="#63A3E9" class="Calendar_table"><tr align="center">';
daysGrid += '<td nowrap><a href="javascript:hideElement(\'' + eltName + '\')">×</a></b></td>';
daysGrid += '<td colspan="3"><a href="javascript:incMonth(-1,\'' + eltName + '\')">&nbsp;<&nbsp;</a>';
if (isThisMonth) { daysGrid += '<font color=red>' + months[month] + '</font>'; }
else { daysGrid += months[month]; }
daysGrid += '<a href="javascript:incMonth(1,\'' + eltName + '\')">&nbsp;>&nbsp;</a></td>';
daysGrid += '<td  colspan="3"><a href="javascript:incYear(-1,\'' + eltName + '\')">&nbsp;<&nbsp;</a>';
if (isThisYear) { daysGrid += '<font color=red>' + year + '</font>'; }
else { daysGrid += ''+year; }
daysGrid += '<a href="javascript:incYear(1,\'' + eltName + '\')">&nbsp;>&nbsp;</a></td></tr>';
daysGrid += '<tr><td>Su&nbsp;</td><td>Mo</td><td>Tu</td><td>We</td><td>Th</td><td>Fr</td><td>Sa</td></tr>';
var dayOfMonthOfFirstSunday = (7 - startDay + 1);
for (var intWeek = 0; intWeek < 7; intWeek++)
{
	var dayOfMonth;
	for (var intDay = 0; intDay < 7; intDay++)
	{
		dayOfMonth = (intWeek * 7) + intDay + dayOfMonthOfFirstSunday - 7;
		if (dayOfMonth <= 0)
		{
		   daysGrid += "<td></td>";
		}
		else if (dayOfMonth <= intDaysInMonth)
		{
			var color = "white";
			if (day > 0 && day == dayOfMonth) color="red";
			daysGrid += '<td><a href="javascript:setDay(';
			daysGrid += dayOfMonth + ',\'' + eltName + '\')" '
			daysGrid += 'style="color:' + color + '">';
			var dayString = dayOfMonth + "</a> ";
			if (dayString.length == 6) dayString = '0' + dayString;
			daysGrid += dayString+"</td>";
		}
	}
   if (dayOfMonth < intDaysInMonth) daysGrid += "</tr> ";
}
return daysGrid + "</td></tr></table>";
}

function setDay(day,eltName) {
displayElement.value =displayYear+"-"+(displayMonth + 1)+ "-" +day;
hideElement(eltName);
}

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
  //newCalendar(eltName,document.forms[formName].elements[formEltName]);
  newCalendar(eltName,document.getElementsByName(formEltName)[0])
  toggleVisible(eltName);
}

function fixPositions()
{
 fixPosition('daysOfMonth');
 fixPosition('daysOfMonth2');
 fixPosition('daysOfMonth0');
}
