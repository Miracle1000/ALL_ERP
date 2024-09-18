
isIE = (document.all ? true : false);
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
iPos = 0;
while (elt!=null) {
iPos += elt["offset" + which];
elt = elt.offsetParent;
}
return iPos;
}

function getXBrowserRef(eltname) {
return document.getElementById(eltname).style;
//return (isIE ? document.all[eltname].style : document.layers[eltname]);
}

function hideElement(eltname) { 
	getXBrowserRef(eltname).visibility = 'hidden';
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
obj = document.getElementById(positionername);
var rec = obj.getBoundingClientRect(); 
elt.left = (rec.left ) + "px";
elt.top = (rec.top + obj.offsetHeight +1) + "px";
if (isPlacedUnder) { moveBy(elt,0,obj.offsetHeight); }
}

isIE = (document.all ? true : false);
var months = new Array("一　月", "二　月", "三　月", "四　月", "五　月", "六　月", "七　月",
"八　月", "九　月", "十　月", "十一月", "十二月");
var daysInMonth = new Array(31, 28, 31, 30, 31, 30, 31, 31,
30, 31, 30, 31);
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
var daysGrid = makeDaysGrid(startDayOfWeek,day,intDaysInMonth,newCal,eltName);
document.getElementById(eltName).innerHTML = daysGrid;
/*
if (isIE) {
var elt = document.all[eltName];
elt.innerHTML = daysGrid;
} else {
var elt = document.layers[eltName].document;
elt.open();
elt.write(daysGrid);
elt.close();
}
*/
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
var isThisMonth = (day > -1);
daysGrid = '<table border=0 cellspacing=0 cellpadding=2 style="border:solid #888888 1px;"><tr><td bgcolor=#ffffff nowrap>';
daysGrid += '<font face="courier new, courier" size=2>';
daysGrid += '<a href="javascript:hideElement(\'' + eltName + '\')">x</a>';
daysGrid += '  ';
daysGrid += '<a href="javascript:incMonth(-1,\'' + eltName + '\')">&laquo; </a>';

daysGrid += '<b>';
if (isThisMonth) { daysGrid += '<font color=red>' + months[month] + '</font>'; }
else { daysGrid += months[month]; }
daysGrid += '</b>';

daysGrid += '<a href="javascript:incMonth(1,\'' + eltName + '\')"> &raquo;</a>';
daysGrid += '   ';
daysGrid += '<a href="javascript:incYear(-1,\'' + eltName + '\')">&laquo; </a>';

daysGrid += '<b>';
if (isThisYear) { daysGrid += '<font color=red>' + year + '</font>'; }
else { daysGrid += ''+year; }
daysGrid += '</b>';

daysGrid += '<a href="javascript:incYear(1,\'' + eltName + '\')"> &raquo;</a><br>';
daysGrid += ' Su Mo Tu We Th Fr Sa <br> ';
var dayOfMonthOfFirstSunday = (7 - startDay + 1);
for (var intWeek = 0; intWeek < 6; intWeek++) {
var dayOfMonth;
for (var intDay = 0; intDay < 7; intDay++) {
dayOfMonth = (intWeek * 7) + intDay + dayOfMonthOfFirstSunday - 7;
if (dayOfMonth <= 0) {
daysGrid += "<span style='color:white'>...</span>";
} else if (dayOfMonth <= intDaysInMonth) {
var color = "blue";
if (day > 0 && day == dayOfMonth) color="red";
daysGrid += '<a href="javascript:setDay(';
daysGrid += dayOfMonth + ',\'' + eltName + '\')" ';
daysGrid += 'style="color:' + color + '">';
var dayString = dayOfMonth + "</a> ";
if (dayString.length == 6) dayString = '0' + dayString;
daysGrid += dayString;
}
}
if (dayOfMonth < intDaysInMonth) daysGrid += "<br> ";
}
return daysGrid + "</td></tr></table>";
}

function fixPosition(eltname) {
elt = getXBrowserRef(eltname);
positionerImgName = eltname + 'Pos';
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

function fixPositions()
{
fixPosition('daysOfMonth');
fixPosition('daysOfMonth2');
}
