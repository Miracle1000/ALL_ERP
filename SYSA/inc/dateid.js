Validator =
{
	Require : /.+/,
	Email : /^$|^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/,
	EmailList : /^([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?((\;([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?)*[\;]?)+$/,
	EmailNull :/^(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*)?$/,
	Phone : /^(((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7}|10000|10086|10001|110|120|119|114|199|122|95588|95533|95599|95566)$/,
	PhoneNull : /^((((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7})|10000|10086|10001|110|120|119|114|199|122|95588|95533|95599|95566)?$/,
	Mobile : /^(13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8}$/,
	MobileNull : /^((13[0-9]|14[0-9]|15[^4]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\d{8})?$/,
	DateTime : /^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)(\ ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9])?$/,
	Url : /^(http|https):\/\/[A-Za-z0-9\-_]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*|http:\/\/$/,
	Money : /^\-?[0-9]+[\.]?[0-9]{0,4}$/,
	IdCard : /^\d{15}(\d{2}[A-Za-z0-9])?$/,
	Currency : /^\d+(\.\d+)?$/, Number : /^\d+$/,
	Zip : /^$|^[0-9A-Za-z ]+$/,
	QQ : /^$|^[1-9]\d{4,9}$/,
	Integer : /^[-\+]?\d+$/,
	Double : /^[-\+]?\d+(\.\d+)?$/,
	English : /^[A-Za-z]+$/,
	Chinese :  /^[\u0391-\uFFE5]+$/,
	FloatNum :  /^([0-1](\.[\d]+)?)?$/,
	UnSafe : /^(([A-Z]*|[a-z]*|\d*|[-_\~!@#\$%\^&\*\.\(\)\[\]\{\}<>\?\\\/\'\"]*)|.{0,5})$|\s/,
	IsSafe : function(str){return !this.UnSafe.test(str);},
	SafeString : "this.IsSafe(value)",
	Limit: "this.limit(table_str_len, getAttribute('min'), getAttribute('max'))",
	LimitB : "this.limit(this.LenB(value.replace(/^\\s*/,'').replace(/\\s*$/,'')), getAttribute('min'), getAttribute('max'))",
	Date : "this.IsDate(value, getAttribute('min'), getAttribute('format'),getAttribute('required'))",
	Repeat : "value == document.getElementsByName(getAttribute('to'))[0].value",
	Range : "(!getAttribute('min') || getAttribute('min') <= Number(value.replace(/\,/g,''))) && (!getAttribute('max') || Number(value.replace(/\,/g,'')) <= Number(String(getAttribute('max')).replace(/\,/g,'')))",
	Compare : "this.compare(value,getAttribute('operator'),getAttribute('to'))",
	Custom : "this.Exec(value, getAttribute('regexp'))",
	Group : "this.MustChecked(getAttribute('name'), getAttribute('min'), getAttribute('max'))",
	number:  /.+/,
	ErrorItem : [document.forms[0]],
	ErrorMessage : ["以下原因导致提交失败：\t\t\t\t"],
	Validate : function(date, mode)
	{
		try{
			if(window.onBeforeValidate) { if(window.onBeforeValidate()==false) { return false; } }
		} catch(exx){}
		var objVar = date || event.srcElement;
		var count =objVar && objVar.elements && objVar.elements.length?objVar.elements.length:0;
		this.ErrorMessage.length = 1;
		this.ErrorItem.length = 1;
		this.ErrorItem[0] = objVar;
		try{
			if(jQuery){
				jQuery(objVar).find("iframe[src*='ewebeditor.asp']").each(function(){
					this.contentWindow.syncText(); 
				});
			}
			if (document.getElementById("eWebEditor1") && document.getElementById("eWebEditor1").contentWindow.syncText) { document.getElementById("eWebEditor1").contentWindow.syncText() }
		}
		catch(e){}

		for(var i=0;i<count;i++)
		{
			with(objVar.elements[i])
			{
				var _dataType = getAttribute("dataType");
				if(typeof(_dataType) == "object" || typeof(this[_dataType]) == "undefined")  continue;
				this.ClearState(objVar.elements[i]);
				if(getAttribute("require") == "false" && value == "") continue;
				switch(_dataType)
				{
					case "Date" :
					case "Repeat" :
					case "Range" :
					case "Compare" :
					case "Custom" :
					case "Group" :
					case "Limit" :
					case "LimitB" :
				    case "SafeString":
				        var table_str_len = value.replace(/\n/g, 'xx').length;
						if(!eval(this[_dataType])){this.AddError(i, getAttribute("msg"));}
						break;
					case "DateTime":
						if(value=="" && getAttribute("min")==0) {break;}
					default :
						if(_dataType.toLowerCase()!='number'&&!this[_dataType].test(value)){this.AddError(i, getAttribute("msg"));}//
						break;
				}
				if(_dataType.toLowerCase()=="number"){
					if(!(getAttribute("cannull")=="1" && value.toString().length==0)) {
						if (isNaN(value)==true || value.toString().length==0){
							setAttribute("msg","请输入正确数字");
							this.AddError(i, getAttribute("msg"));
						}
						else{
							var limit = getAttribute("limit");
							if(limit!=null && !isNaN(limit) && (value-limit<=0)){
							    setAttribute("msg",limit==0.000001 ?"必须大于0" :"必须大于" + limit); 
								this.AddError(i, getAttribute("msg")); 
								break;
							}
							var max = getAttribute("max");
							max = (max ==null || isNaN(max) || max=="") ? null : max.toString().replace(/\,/g,'');
							//此处isNaN(空)=false foxfire下 tpyeOf(max)=string
							if (max != null && !isNaN(max) && max.toString().length > 0 && (value - max * 1 > 0)) { setAttribute("msg", "不能大于" + max); this.AddError(i, getAttribute("msg")); break; }
							var min = getAttribute("min");
							min = (min ==null || isNaN(min) || min=="") ? null : min.toString().replace(/\,/g,'');
							if (min != null && !isNaN(min) && min.toString().length > 0 && (value - min * 1 < 0)) { setAttribute("msg", "不能小于" + min); this.AddError(i, getAttribute("msg")); break; }
						}
					}
					//break;
				}
				if(_dataType.toLowerCase()=="limit"){
					if(value.indexOf("'")>=0){
						this.AddError(i,"含特殊字符");
					}
				}
			}
		}

		if(this.ErrorMessage.length > 1){
			mode = mode || 1;
			var errCount = this.ErrorItem.length;
			var $topErrorItem = jQuery(this.ErrorItem[1]);
			if ($topErrorItem.size()>0){
				var msgWhenHide = $topErrorItem.attr('msgWhenHide');
				if ($topErrorItem.height()==0 || 
						$topErrorItem.width()==0 || 
						$topErrorItem.css('display')=='none' || 
						$topErrorItem.css('visiblity')=='hidden'){
					if (msgWhenHide){
						alert(msgWhenHide);
					}
				}
			}

			switch(mode){
				case 2 :
					for(var i=1;i<errCount;i++)	this.ErrorItem[i].style.color = "red";
			    case 1:
			        try { $("#__ErrorMessagePanel").remove(); } catch (e) { }
					for(var i=1;i<errCount;i++){
						try{
							var span = document.createElement("SPAN");
							span.id = "__ErrorMessagePanel";
							span.style.color = "red";
							this.ErrorItem[i].parentNode.appendChild(span);
							span.innerHTML = this.ErrorMessage[i].replace(/\d+:/,"");
						}
						catch(e){
							alert(e.description);
						}
					}
					try{
						this.ErrorItem[1].focus();
					}
					catch(e){}
					break;
				case 3 :
					for(var i=1;i<errCount;i++){
						try{
							var span = document.createElement("SPAN");
							span.id = "__ErrorMessagePanel";
							span.style.color = "red";
							this.ErrorItem[i].parentNode.appendChild(span);
							span.innerHTML = this.ErrorMessage[i].replace(/\d+:/,"");
						}catch(e){
							alert(e.description);
						}
					}
					try{
						this.ErrorItem[1].focus();
					}
					catch(e){}
					break;
				default :
					alert(this.ErrorMessage.join("\n"));
					break;
			}
			return false;
		}
		if(window.onAfterValidate) {
			if(window.onAfterValidate()==false) {
				return false;
			}
		}
		return true;
	},
	limit : function(len,min, max){
		min = min || 0;
		max = max || Number.MAX_VALUE;
		return min <= len && len <= max;
	},
	LenB : function(str){
		return str.replace(/[^\x00-\xff]/g,"**").length;
	},
	ClearState : function(elem){
		with(elem){
			if(style.color == "red") style.color = "";
			var childs = parentNode.childNodes;
			for (var i = childs.length-1;i>=0 ; i-- )
			{
				if(childs[i].id == "__ErrorMessagePanel") {
					parentNode.removeChild(childs[i])
					return;
				}
			}
		}
	},
	AddError : function(index, str){
		if (str==null){str="*";}
		this.ErrorItem[this.ErrorItem.length] = this.ErrorItem[0].elements[index];
		this.ErrorMessage[this.ErrorMessage.length] = this.ErrorMessage.length + ":" + str;
	},
	Exec : function(op, reg){
		return new RegExp(reg,"g").test(op);
	},
	compare : function(op1,operator,op2){
		switch (operator){
			case "NotEqual":
				return (op1 != op2);
			case "GreaterThan":
				return (op1 > op2);
			case "GreaterThanEqual":
				return (op1 >= op2);
			case "LessThan":
				return (op1 < op2);
			case "LessThanEqual":
				return (op1 <= op2);
			default:
				return (op1 == op2);
		}
	},
	MustChecked : function(name, min, max){
		var groups = document.getElementsByName(name);
		var hasChecked = 0;
		min = min || 1;
		max = max || groups.length;
		for(var i=groups.length-1;i>=0;i--)	if(groups[i].checked) hasChecked++;
		return min <= hasChecked && hasChecked <= max;
	},
	IsDate : function(op, min,formatString,required){
		if (required != undefined && ((op == null) || (op == ""))) return false;
		if (((op == null ) || (op =="") ) && ( (min == null ) || (min =="") ) ) return true;
		formatString = formatString || "ymd";
		var m, year, month, day;
		switch(formatString){
			case "ymd" :
				m = op.match(new RegExp("^((\\d{4})|(\\d{2}))([-./])(\\d{1,2})\\4(\\d{1,2})$"));
				if (m == null ) return false;
				day = m[6];
				month = m[5]--;
				year =  (m[2].length == 4) ? m[2] : GetFullYear(parseInt(m[3], 10));
				break;
			case "dmy" :
				m = op.match(new RegExp("^(\\d{1,2})([-./])(\\d{1,2})\\2((\\d{4})|(\\d{2}))$"));
				if(m == null ) return false;
				day = m[1];
				month = m[3]--;
				year = (m[5].length == 4) ? m[5] : GetFullYear(parseInt(m[6], 10));
				break;
			default :
				break;
		}
		if(!parseInt(month)) return false;
		month --;
		var date = new Date(year, month, day);
		return (typeof(date) == "object" && year == date.getFullYear() && month == date.getMonth() && day == date.getDate());
		function GetFullYear(y){
			return ((y<30 ? "20" : "19") + y)|0;
		}
	}
}

var CurrentDateID;
isIE = (document.all ? true : false);
function getIEPosX(elt){return getIEPos(elt,"Left");}
function getIEPosY(elt){return getIEPos(elt,"Top");}
function getIEPos(elt,which){
	iPos = 0;
	while(elt!=null){
		iPos += elt["offset" + which];
		elt = elt.offsetParent;
	}
	return iPos;
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
function getXBrowserRef(eltname){
	var obj = document.getElementsByName(eltname);
	return obj.length > 0 ? obj[0] : document.getElementById(eltname);
}
function hideElement(eltname){
	try{
		getXBrowserRef(eltname).innerHTML=""
	}catch(e3){};
}
function moveBy(elt,deltaX,deltaY){
	if (isIE){
		elt.left = elt.pixelLeft + deltaX;
		elt.top = elt.pixelTop + deltaY;
	}else{
		elt.left += deltaX;
		elt.top += deltaY;
	}
}
function toggleVisible(eltname){
	elt = getXBrowserRef(eltname);
	if (elt.style.visibility == 'visible' || elt.style.visibility == 'show')
	{
		elt.style.visibility = 'hidden';
	}
	else
	{
		fixPosition(eltname);
		elt.style.visibility = 'visible';
	}
}
function setPosition(elt,positionername,isPlacedUnder){
	positioner = null;
	if (isIE){
		positioner = document.all[positionername];
		if(!positioner) {return }
		elt.left = getIEPosX(positioner);
		elt.top = getIEPosY(positioner);
	}else{
		positioner = document.images[positionername];
		if(!positioner) {return }
		elt.left = positioner.x;
		elt.top = positioner.y;
	}
	if(isPlacedUnder){
		moveBy(elt,0,positioner.height);
	}
}
isIE = (document.all ? true : false);
var months = new Array("一　月", "二　月", "三　月", "四　月", "五　月", "六　月", "七　月", "八　月", "九　月", "十　月", "十一月", "十二月");
var daysInMonth = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
var displayMonth = new Date().getMonth();
var displayYear = new Date().getFullYear();
var displayDivName;   var displayElement;
function getDays(month, year){
	if (1 == month)
		return ((0 == year % 4) && (0 != (year % 100))) || (0 == year % 400) ? 29 : 28;
	else
		return daysInMonth[month];
}
function getToday(){
	this.now = new Date();
	this.year = this.now.getFullYear();
	this.month = this.now.getMonth();
	this.day = this.now.getDate();
}
today = new getToday();
function newCalendar(eltName,attachedElement){
	if (attachedElement){
		if (displayDivName && displayDivName != eltName) hideElement(displayDivName);
		displayElement = attachedElement;
	}
	displayDivName = eltName;
	today = new getToday();
	var parseYear = parseInt(displayYear + '');
	var newCal = new Date(parseYear,displayMonth,1);
	var day = -1;
	var startDayOfWeek = newCal.getDay();
	if ((today.year == newCal.getFullYear()) && (today.month == newCal.getMonth())){
		day = today.day;
	}
	var intDaysInMonth = getDays(newCal.getMonth(), newCal.getFullYear());
	var daysGrid = makeDaysGrid(startDayOfWeek,day,intDaysInMonth,newCal,eltName);
	if (isIE){
		var elt = document.getElementsByName(eltName);
		elt = elt.length > 0 ? elt[0] : document.getElementById(eltName);
		elt.innerHTML = daysGrid;
	}else{
		var elt = document.layers[eltName].document;
		elt.open();
		elt.write(daysGrid);
		elt.close();
	}
}
function incMonth(delta,eltName){
	displayMonth += delta;
	if (displayMonth >= 12){
		displayMonth = 0;
		incYear(1,eltName);
	}else if (displayMonth <= -1){
		displayMonth = 11;
		incYear(-1,eltName);
	}else{
		newCalendar(eltName);
	}
}
function incYear(delta,eltName){
	displayYear = parseInt(displayYear + '') + delta;
	newCalendar(eltName);
}
function makeDaysGrid(startDay,day,intDaysInMonth,newCal,eltName){
	var daysGrid;
	var month = newCal.getMonth();
	var year = newCal.getFullYear();
	var isThisYear = (year == new Date().getFullYear());
	var isThisMonth = (day > -1);
	daysGrid = '<table border=1 cellspacing=0 cellpadding=2><tr><td bgcolor=#ffffff nowrap>';
	daysGrid += '<font face="courier new, courier" size=2>';
	daysGrid += '<a href="javascript:hideElement(\'' + eltName + '\')">x</a>';
	daysGrid += '  ';
	daysGrid += '<a href="javascript:incMonth(-1,\'' + eltName + '\')">&laquo; </a>';
	daysGrid += '<b>';
	if (isThisMonth){
		daysGrid += '<font color=red>' + months[month] + '</font>';
	}else{
		daysGrid += months[month];
	}
	daysGrid += '</b>';
	daysGrid += '<a href="javascript:incMonth(1,\'' + eltName + '\')"> &raquo;</a>';
	daysGrid += '   ';
	daysGrid += '<a href="javascript:incYear(-1,\'' + eltName + '\')">&laquo; </a>';
	daysGrid += '<b>';
	if (isThisYear){
		daysGrid += '<font color=red>' + year + '</font>';
	}else{
		daysGrid += ''+year;
	}
	daysGrid += '</b>';
	daysGrid += '<a href="javascript:incYear(1,\'' + eltName + '\')"> &raquo;</a><br>';
	daysGrid += ' Su Mo Tu We Th Fr Sa <br> ';
	var dayOfMonthOfFirstSunday = (7 - startDay + 1);
	for (var intWeek = 0; intWeek < 6; intWeek++){
		var dayOfMonth;
		for (var intDay = 0; intDay < 7; intDay++){
			dayOfMonth = (intWeek * 7) + intDay + dayOfMonthOfFirstSunday - 7;
			if (dayOfMonth <= 0){
				daysGrid += "&nbsp;&nbsp;&nbsp;";
			}else if (dayOfMonth <= intDaysInMonth){
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
	return daysGrid + "<iframe src='javascript:false' style='position:absolute; visibility:inherit; top:0px; left:0px; width:expression(this.parentNode.offsetWidth);   height:expression(this.parentNode.offsetHeight);   z-index:-1; filter='progid:DXImageTransform.Microsoft.Alpha(style=0,opacity=0)';'></iframe></td></tr></table>";
}
function setDay(day,eltName){
	displayElement.value =displayYear+"-"+(displayMonth + 1)+ "-" +day;
	hideElement(eltName);
}
function fixPosition(eltname){
	elt = getXBrowserRef(eltname);
	positionerImgName = eltname + 'Pos';
	isPlacedUnder = false;
	if (isPlacedUnder){
		setPosition(elt,positionerImgName,true);
	}else{
		setPosition(elt,positionerImgName);
	}
}
function toggleDatePicker(eltName,formElt){	
		var x = formElt.indexOf('.');
		var formEltName = formElt.substring(x+1);
		//datedlg.cdiv();
		isIE = (document.all ? true : false);
		if (isIE){
			var elt = document.getElementsByName(eltName);
			elt = elt.length > 0 ? elt[0] : document.getElementById(eltName);
		}else{
			//var elt = document.layers[eltName].document;
		}
		var button = document.getElementsByName(formEltName)[0] ? document.getElementsByName(formEltName)[0] : window.event.srcElement;
		datedlg.show(button)
		return false;
		//document.getElementsByName(formEltName)[0]
}


function fixPositions(){
	fixPosition('daysOfMonth');
	fixPosition('daysOfMonth2');
	fixPosition('daysOfMonth0');
}
//以下是日历 by:snihaps time:2012-02-05
var gMonths=new Array("一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月");
var WeekDay=new Array("日","一","二","三","四","五","六");
var strToday="今天";
var strYear="年";
var strMonth="月";
var strDay="日";
var splitChar="-";
var startYear=1901;
var endYear=2099;
var dayTdHeight=12;
var dayTdTextSize=12;
var gcNotCurMonth="#E0E0E0";
var gcRestDay = "#2879FF";//休息日字体颜色;默认选中颜色；
var gcWorkDay="#444444";
var gcMouseOver = "#FFF";//鼠标悬浮；
var gcMouseOver1 = "#3758FF";//底部年月日鼠标悬浮颜色
var gcMouseOut="white";
var gcMouseOut2="white url(" + (window.sysCurrPath?window.sysCurrPath:"../") + "images/m_table_top.jpg) repeat-x";
var gcgroundColor = "white url(" + (window.sysCurrPath?window.sysCurrPath:"../") + "images/m_table_top.jpg) repeat-x";
var gcborderColor = "#9c9cbe;";
var gcborderColor2 = "#c6d3e1";
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
var dlgFireElement = null;
function $Date(){var elements=new Array();for(var i=0;i<arguments.length;i++) {var element=arguments[i];if(typeof(arguments[i])=='string'){element=document.getElementById(arguments[i]);}if(arguments.length==1){return element;}elements.Push(element);}return elements;}
Array.prototype.Push=function(){var startLength=this.length;for(var i=0;i<arguments.length;i++){this[startLength+i]=arguments[i];}return this.length;}
String.prototype.HexToDec=function(){return parseInt(this,16);}
String.prototype.cleanBlank=function(){return this.isEmpty()?"":this.replace(/\s/g,"");}
function checkColor(){var color_tmp=(arguments[0]+"").replace(/\s/g,"").toUpperCase();var model_tmp1=arguments[1].toUpperCase();var model_tmp2="rgb("+arguments[1].substring(1,3).HexToDec()+","+arguments[1].substring(1,3).HexToDec()+","+arguments[1].substring(5).HexToDec()+")";model_tmp2=model_tmp2.toUpperCase();if(color_tmp==model_tmp1 ||color_tmp==model_tmp2){return true;}return false;}
function $DateV(){return $Date(arguments[0]).value;}
function clearSelDate(){
	if(dlgFireElement == window.event.srcElement) {
		return;
	}
	if ($Date("calendardiv").style.visibility=="visible"){
		fHideCalendar();
	}
}

function positionXY() {
    var input = document.getElementById("tbSelYear");
    var l = input.getBoundingClientRect().left;
    var t=input.getBoundingClientRect().top+input.offsetHeight;
    $("#selectList").css({ "left": l + "px", "top": t  + "px" })
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
function isBodyScroll() {
    try{    if ($("#maskLayerTrp").css("display") != "none") { $("#maskLayerTrp").css("display", "none"); }
    }catch(e){}
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
function fPopCalendar(evt,popCtrl,dateCtrl,showtime, showMonth){
	var d = null
	var hstimvalue = false
	evt.cancelBubble=true;
	gdCtrl=dateCtrl;
	minDate = "";
    maxDate = "";
	var event = evt || window.event;
	dlgFireElement = event.srcElement || event.target;
	try{
		minDate = jQuery(dlgFireElement).attr("minDate");
		if (!minDate){minDate = "";}
        maxDate = jQuery(gdCtrl).attr("maxDate");
        if (!maxDate) { maxDate = ""; }
	}catch(e){}

	if(!document.getElementById("calendardiv")){
		var dv = document.createElement("div");
		document.body.appendChild(dv);
		dv.outerHTML = getDateDiv();
		document.onclick=clearSelDate;
	}

	fSetYearMon(giYear,giMonth,showMonth);

	document.getElementById("CalendarOnlyDate_tr").style.display = showtime ? "none" : "";
	document.getElementById("CalendarDateTime_tr").style.display = showtime ? "" : "none";
	var parentDisplay;
	if (showtime) {
		parentDisplay = '';
	} else {
		parentDisplay = 'none';
	}
	document.getElementById("CalendarDateTime_tr").parentNode.style.display = parentDisplay;
	if(document.getElementById("CalendarDateTime_frame")) {
		document.getElementById("CalendarDateTime_frame").style.height = showtime ? "246px" : "216px";
	};

	var point=fGetXY(popCtrl);	
	with($Date("calendardiv").style){
		left=point.x+"px";
		top=(point.y+popCtrl.offsetHeight+1)+"px";
		visibility='visible';
		zindex='99';
		position='absolute';
	}

	if(typeof(dateCtrl)=="object" && typeof(dateCtrl.value)=="string"){
		var hstimvalue = dateCtrl.value.toString().indexOf(":") >=0
		d = new Date(dateCtrl.value.toString().replace(/\-/g,"/"))
		if(isNaN(d)){
			d = new Date();
		}
		if (document.getElementById("tbSelYear").value.replace(strYear, "")!= d.getFullYear()) {
			document.getElementById("tbSelYear").value = d.getFullYear()+"年";
		    //document.getElementById("tbSelYear").fireEvent("onchange");
			jQuery("#tbSelYear").change()
		}
		if(document.getElementById("tbSelMonth").value!=d.getMonth()+1){
			document.getElementById("tbSelMonth").value = d.getMonth()+1;
		    //document.getElementById("tbSelMonth").fireEvent("onchange");
			jQuery("#tbSelMonth").change()
		}
	}
	if (!showMonth) {
        if (document.getElementById("tbSelMonth").value != d.getMonth() + 1) {
            document.getElementById("tbSelMonth").value = d.getMonth() + 1;
            jQuery("#tbSelMonth").change();
        }
    }
	if (hstimvalue==false){
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
function fClearInputData(){
	fHideCalendar();
	gdCtrl.value= "";
	if(gdCtrl.onchange){gdCtrl.onchange(gdCtrl)};
}
function fHideCalendar(){
	var CDiv = $Date("calendardiv");
	CDiv.style.visibility="hidden";
	if(!window.DateTimeNotShowSecond){
    	var tds = CDiv.getElementsByTagName("TD");
	    for(var i=0;i<tds.length;i++){
	    	jQuery(tds[i]).attr("Cho",0);
	    }
	    for (var i = 0; i < goSelectTag.length; i++) {
	        goSelectTag[i].style.visibility = "visible";
	    }
    }
	goSelectTag.length=0;
}
function fSetSelected(){
	var unclick = null;
    try { unclick = jQuery("#tday" + arguments[0]).attr("unclick"); } catch (e) { }
	try { 
    	if(isMonth){
    		unclick = jQuery("#tmon" + arguments[0]).attr("unclick");
    	}else{
    		unclick = jQuery("#tday" + arguments[0]).attr("unclick");
    	}
    } catch (e) { }
	if (!unclick){unclick = "0";}
	if (unclick=="1"){return;}
	var iOffset=0;
	var iYear = parseInt($Date("tbSelYear").value.replace(strYear, ""));
	var iMonth=parseInt($Date("tbSelMonth").value);
	var aCell=$Date("cellText"+arguments[0]);
	aCell.bgColor=gcMouseOut;
	with(aCell){
		var iDay=parseInt(innerHTML);
		if(checkColor(style.color,gcNotCurMonth)){
			iOffset=(innerHTML>14)?-1:1;
		}
		iMonth+=iOffset;
		if(iMonth<1){
			iYear--;iMonth=12;
		}else if(iMonth>12){
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
		    if (tds[i].bgColor.toLowerCase() != gcTodayMouseOut.toLowerCase()) {//ie下16进制颜色区分大小写
		        tds[i].bgColor = gcMouseOut;
			}
			jQuery(tds[i]).attr("Cho",0);
		}
		$(td).addClass("defaultSelected").siblings().removeClass("defaultSelected").removeClass("currTDate")
		$(td).parent().siblings().find("td").removeClass("defaultSelected").removeClass("currTDate")
		jQuery(td).attr("Cho",1);
    	var txt = td.getAttribute("id");
    	var num = txt.replace("tday","");
		jQuery('#Calendar-Datetime-Confirm-Btn').attr("val",num);
	}else{
		fSetDate(iYear, iMonth, iDay);
	}
}
function Point(iX,iY){this.x=iX;this.y=iY;}
function fBuildCal(iYear,iMonth){
	var aMonth=new Array();
	for(var i=1;i<7;i++){
		aMonth[i]=new Array(i);
	}
	var dCalDate=new Date(iYear,iMonth-1,1);
	var iDayOfFirst=dCalDate.getDay();
	var iDaysInMonth=new Date(iYear,iMonth,0).getDate();
	var iOffsetLast=new Date(iYear,iMonth-1,0).getDate()-iDayOfFirst+1;
	var iDate=1;var iNext=1;
	for(var d=0;d<7;d++){
		aMonth[1][d]=(d<iDayOfFirst)?(iOffsetLast+d)*(-1):iDate++;
	}
	for(var w=2;w<7;w++){
		for(var d=0;d<7;d++){
			aMonth[w][d]=(iDate<=iDaysInMonth)?iDate++:(iNext++)*(-1);
		}
	}
	return aMonth;
}

function fDrawCal(iYear,iMonth,iCellHeight,iDateTextSize){
	var colorTD=" bgcolor='"+gcMouseOut+"' bordercolor='"+gcMouseOut+"'";
	var styleTD=" valign='middle' align='center' style='height:"+iCellHeight+"px;er;font-size:"+iDateTextSize+"px;";
	var dateCal = ""; dateCal += "<tr><td class='dlg_top' " + styleTD + "color:#000;height:25px;border-bottom:1px solid " + gcborderColor2 + ";width:6px'>&nbsp;</td>";
	for(var i=0;i<7;i++){
	    dateCal += "<td class='dlg_top' " + styleTD + "color:#000;height:25px;border-bottom:1px solid " + gcborderColor2 + "'>" + WeekDay[i] + "</td>";
	}
	dateCal += "<td class='dlg_top' " + styleTD + "color:#000;height:25px;width:6px;border-bottom:1px solid " + gcborderColor2 + "'>&nbsp;</td></tr>";
	for(var w=1;w<7;w++){
		dateCal+="<tr><td>&nbsp;</td>";
		for(var d=0;d<7;d++){
			var tmpid=w+""+d;
			dateCal +="<td class='tdayNum' "+styleTD+"cursor:pointer;padding:3px!important' id='tday"+tmpid+"' onclick='fSetSelected("+tmpid+")'>";
			dateCal+="<span id='cellText"+tmpid+"'>fadfasfdsa</span>";
			dateCal+="</td>";
		}
		dateCal+="<td>&nbsp;</td></tr>";
	}
	return dateCal;
}

function fUpdateCal(iYear, iMonth, showMonth) {
    var iYear;
    if (isNaN(iYear)) { iYear = iYear.replace("年", ""); }
	var myMonth=fBuildCal(iYear,iMonth);
	var i=0, oday = -1,  currMonth = iMonth, currYear = iYear;
	if(Math.abs(myMonth[1][0]) >1) {
		currMonth --;
		if(currMonth==0) {currYear --;currMonth = 12;}
	}
	var theday="";
	if (showMonth) {
        for (var w = 1; w < 4; w++) {
            for (var d = 0; d < 4; d++) {
                with (ddlgGetElement("cellText" + w + "" + d)) {
					$(parentNode).removeClass("defaultSelected").removeClass("currTDate");
                    parentNode.bgColor = gcMouseOut;
                    parentNode.borderColor = gcMouseOut;
                    //parentNode.onmouseover = function () {
                    //    this.bgColor = gcMouseOver;
                    //    $(this).children("span").addClass("spanColor")
                    //};
                    //parentNode.onmouseout = function () {
                    //    this.bgColor = gcMouseOut;
                    //    $(this).children("span").removeClass("spanColor")
                    //};
                    if (myMonth[w][d] < 0) {
                        style.color = gcNotCurMonth;
                        innerHTML = Math.abs(myMonth[w][d]);
                    }
                    else {
						style.color = '';
						className = ((d == 0) || (d == 6)) ? "RestDay" : "gcWorkDay";
                        innerHTML = myMonth[w][d];
                        if (iYear == giYear && myMonth[w][d] == giMonth) {
                            //style.color = "#ffffff";
							//parentNode.bgColor = gcTodayMouseOut;
							$(parentNode).addClass("currTDate");
                            //parentNode.onmouseover = function () {
                            //    this.bgColor = gcTodayMouseOver;
                            //};
                            //parentNode.onmouseout = function () {
                            //    this.bgColor = gcTodayMouseOut;
                            //};
                        }
                        if (iYear == giYear1 && myMonth[w][d] == giMonth1) {
                            $(parentNode).addClass("defaultSelected")
                        }
                    }
                }
                if (minDate != "" || maxDate != "") {
                    currMonth = Math.abs(myMonth[w][d]);
                    var d2 = new Date(currYear + '/' + currMonth + '/1');
                    var td = ddlgGetElement("tmon" + w + "" + d);
                    if (minDate != "") {
                        var d1 = new Date(minDate.replace(/\-/g, "/") + '/1');
                        if (d1 > d2) {
                            jQuery(td).attr("unclick", "1");
                            ddlgGetElement("cellText" + w + "" + d).style.color = "#E0E0E0";
                            td.disabled = true; td.style.cursor = "auto";
                            td.getElementsByTagName("span")[0].style.color="#E0E0E0";
                        }
                        else if (maxDate != "") {
                            var d3 = new Date(maxDate.replace(/\-/g, "/") + '/1');
                            if (d2 > d3) {
                                jQuery(td).attr("unclick", "1");
                                ddlgGetElement("cellText" + w + "" + d).style.color = "#E0E0E0";
                                td.disabled = true; td.style.cursor = "auto";
                            } else {
                                jQuery(td).attr("unclick", "0");
                                td.style.cursor = "pointer"; td.disabled = false;
                            }
                        }
                        else {
                            jQuery(td).attr("unclick", "0");
                            td.style.cursor = "pointer"; td.disabled = false;
                        }
                    }
                    else if (maxDate != "") {
                        var d3 = new Date(maxDate.replace(/\-/g, "/") + '/1');
                        if (d2 > d3) {
                            jQuery(td).attr("unclick", "1");
                            ddlgGetElement("cellText" + w + "" + d).style.color = "#E0E0E0";
                            td.disabled = true; td.style.cursor = "auto";
                        } else {
                            jQuery(td).attr("unclick", "0");
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
    }else{
		for(var w=1;w<7;w++){
			for(var d=0;d<7;d++){
			    with ($Date("cellText" + w + "" + d)) {
					$(parentNode).removeClass("defaultSelected").removeClass("currTDate");
					parentNode.bgColor=gcMouseOut;
					parentNode.borderColor=gcMouseOut;
					//parentNode.onmouseover=function(){
					//    this.bgColor = gcMouseOver;
					//    $(this).children("span").addClass("spanColor")
					//};
					//parentNode.onmouseout=function(){
					//	if(this.getAttribute("Cho") && this.getAttribute("Cho") == 1){
					//		this.bgColor = gcClick;
					//	}else{
					//	    this.bgColor = gcMouseOut;
					//	}
					//	$(this).children("span").removeClass("spanColor")
					//};
					if(myMonth[w][d]<0){
						style.color=gcNotCurMonth;
						innerHTML=Math.abs(myMonth[w][d]);
					}else{
						style.color = '';
						className = ((d == 0) || (d == 6)) ? "RestDay" : "gcWorkDay";
						innerHTML=myMonth[w][d];
						if(iYear==giYear && iMonth==giMonth && myMonth[w][d]==giDay){
							//style.color="#ffffff";
							//parentNode.bgColor=gcTodayMouseOut;
							$(parentNode).addClass("currTDate");
							if(jQuery('#Calendar-Datetime-Confirm-Btn')){
								var txt = parentNode.getAttribute("id");
								var num = txt.replace("tday","");
								jQuery('#Calendar-Datetime-Confirm-Btn').attr("val",num);
							}
							//parentNode.onmouseover=function(){
							//	this.bgColor=gcTodayMouseOver;
							//};
							//parentNode.onmouseout=function(){
							//	this.bgColor=gcTodayMouseOut;
							//};
						}
						if (iYear == giYear1 && iMonth == giMonth1 && myMonth[w][d] == giDay1) {
						    $(parentNode).addClass("defaultSelected")
						}
					}
				}
				if(minDate != "" || maxDate != ""){		
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
							jQuery(td).attr("unclick", "1");
							td.getElementsByTagName("span")[0].style.color="#E0E0E0";
							td.disabled = true; td.style.cursor = "auto";
						}
						else if (maxDate != "") {
							var d3 = new Date(maxDate.replace(/\-/g, "/"));
							if (d2 > d3) {
								jQuery(td).attr("unclick", "1");
								td.getElementsByTagName("span")[0].style.color="#E0E0E0";
								td.disabled = true; td.style.cursor = "auto";
							} else {
								jQuery(td).attr("unclick", "0");
								td.style.cursor = "pointer"; td.disabled = false;
							}
						}
						else {
							jQuery(td).attr("unclick", "0");
							td.style.cursor = "pointer"; td.disabled = false;
						}
					}
					else if (maxDate != "") {
						var d3 = new Date(maxDate.replace(/\-/g, "/"));
						if (d2 > d3) {
							jQuery(td).attr("unclick", "1");
							td.disabled = true; td.style.cursor = "auto";
							td.getElementsByTagName("span")[0].style.color="#E0E0E0";
						} else {
							jQuery(td).attr("unclick", "0");
							td.style.cursor = "pointer"; td.disabled = false;
						}
					}
				}else{
					var td = $Date("tday"+w+""+d);
					td.style.cursor="pointer";td.disabled = false;
				}
			}
		}
	}
}
function fConfirmData(s){
	var tmp = jQuery(s).attr('val');
	window.DateTimeNotShowSecond = null;
	fSetSelected(tmp);
}

function fSetYearMon(iYear,iMon, showMonth){
    if (showMonth) {
        var selYearLen = $("#selectList li")
        for (var i = 0; i < selYearLen.length; i++) {
            if (selYearLen[i].getAttribute("value") == iYear) {
                $("#tbSelYear").val(selYearLen[i].innerHTML)
                break;
            }
        }
    }
	else {
	    var selYearLen=$("#selectList li")
        $Date("tbSelMonth").options[iMon-1].selected=true;
        for (var i = 0; i < selYearLen.length; i++) {
            if (selYearLen [i].getAttribute("value")== iYear) {
                $("#tbSelYear").val(selYearLen[i].innerHTML)
                break;
			}
		}
    }
    fUpdateCal(iYear, iMon, showMonth);
}
function fPrevMonth() { var iMon = $Date("tbSelMonth").value; var iYear = $Date("tbSelYear").value.replace(strYear, ""); if (--iMon < 1) { iMon = 12; iYear--; } fSetYearMon(iYear, iMon); }
function fNextMonth() { var iMon = $Date("tbSelMonth").value; var iYear = $Date("tbSelYear").value.replace(strYear,""); if (++iMon > 12) { iMon = 1; iYear++; } fSetYearMon(iYear, iMon); }
function fGetXY(aTag,boxWidth,boxHeight){
	var box = document.getElementById("calendardiv");
	var boxWidth = null, boxHeight = null;
	if(box){
		boxWidth = box.offsetWidth;
		boxHeight = box.offsetHeight;
	};
	var pt=new Point(0,0)
	var w = boxWidth || 200 , h = boxHeight || 215
	var oTmp=aTag;
	if(!oTmp.getBoundingClientRect) {
		while(oTmp)
		{
				pt.x = pt.x + oTmp.offsetLeft- oTmp.scrollLeft;
				pt.y = pt.y + oTmp.offsetTop - oTmp.scrollTop;
				oTmp=oTmp.offsetParent;
		}
	} else {
		var pos = oTmp.getBoundingClientRect();
		pt.x = pos.left;
		pt.y = pos.top;
	}



	var bodyw = document.body.offsetWidth;
	if(bodyw==0) {bodyw = document.documentElement.offsetWidth;}
	if (pt.x+w>bodyw){pt.x = bodyw -w;}

	var offHeight = document.documentElement.offsetHeight;
	var cliHeight = document.documentElement.clientHeight;
	var bodyH = offHeight > 0 ? offHeight : cliHeight;
	if(cliHeight > offHeight) { bodyH = cliHeight };
	if (bodyH==0){bodyH = document.documentElement.offsetHeight;} //offHeight = 0  cliHeight = 0时
	if (pt.y+h>bodyH){
		pt.y = pt.y - h - aTag.offsetHeight;
		if (pt.y<0){pt.y = bodyH -h;}
	}
	pt.x = pt.x + document.body.scrollLeft;
	pt.y = pt.y + document.body.scrollTop;
	try
	{
		pt.x = pt.x + document.documentElement.scrollLeft;
		//if(window.location.href.indexOf("telhy_view.asp")==-1) {
			pt.y = pt.y + document.documentElement.scrollTop;
		//}
	}
	catch (e){}
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
	dateDiv+="<div id='calendardiv' onclick='event.cancelBubble=true' "+noSelectForIE+" style='"+noSelectForFireFox+";position:absolute;left:-1000px;top:-1000px;z-index:990000;visibility:hidden;padding:5px 0px;width:250px;background:" + gcgroundColor + ";border:1px solid " + gcborderColor + ";font-family:宋体;'>";
	if(navigator.userAgent.indexOf("MSIE 6.0") > 0){
		dateDiv+="<iframe src='about:blank' id='CalendarDateTime_frame' frameborder=0 style='position:absolute;visibility:hidden!important;_visibility:inherit;top:0px; left:0px; width:226px; height:216px; z-index:-1;'></iframe>"
		dateDiv+="<div frameborder=0 style='background:" + gcgroundColor + ";position:absolute;visibility:hidden!important;_visibility:inherit;top:0px; left:0px; width:226px; height:32px; z-index:-1;'></div>"
	}
	dateDiv+="<table border='0' cellpadding='2' style='' cellspacing='0' width='100%'>";dateDiv+="<tr>";dateDiv+="<td  style='padding-left:10px;'><input type='button' style='border:1px solid #aaaaaa;height:18px;line-height:18px;background-color:white;' id='PrevMonth' value='<' style='height:20px;width:20px;er;' onclick='fPrevMonth()'>";
	dateDiv += "</td><td><div style='overflow:hidden;'><input type='button' id='tbSelYear' style='background:#fff;display:inline;width:70px;' onclick='selectionBoxscroll()'   onchange='fUpdateCal($DateV(\"tbSelYear\"),$DateV(\"tbSelMonth\"))'><div id='maskLayerTrp' style='position:fixed;left:0;top:0;bottom:0;right:0;display:none;' onclick='this.style.display=\"none\"'><ul id='selectList' onclick='window.event.cancelBubble = true'>";
	for (var i = startYear; i < endYear; i++) { dateDiv += "<li onmouseover='$(this).addClass(\"alSelected1\");' onmouseout='$(this).removeClass(\"alSelected1\")'  onclick='window.event.cancelBubble = true;document.getElementById(\"tbSelYear\").value=this.innerHTML;$(\"div#maskLayerTrp\").css(\"display\",\"none\");$(\"#tbSelYear\").change();$(this).addClass(\"alSelected\").siblings().removeClass(\"alSelected\")' value='" + i + "'>" + i + strYear + "</li>"; }
	dateDiv += "</ul></div></div></td><td>";
	dateDiv+="<div style='overflow:hidden;'><select id='tbSelMonth' style='display:inline;width:70px;' onchange='fUpdateCal($DateV(\"tbSelYear\"),$DateV(\"tbSelMonth\"))'>";
	for(var i=0;i<12;i++){
			dateDiv+="<option value='"+(i+1)+"'>"+gMonths[i]+"</option>";
	}
	dateDiv+="</select></div></td><td style='padding-right:10px;'>";
	dateDiv+="<input type='button' id='NextMonth' value='>' style='width:20px;er;border:1px solid #aaaaaa;height:18px;background-color:white;' onclick='fNextMonth()'>";
	dateDiv+="</td>";
	dateDiv+="</tr><tr>";
	dateDiv+="<td align='center' colspan='4' style='padding-bottom:0px' style='padding-left:0px;padding-right:0px'>";
	dateDiv+="<div>";
	dateDiv += "<table class='datedlgbodytable' width='100%' border='0' cellpadding='3' cellspacing='0' style='font-weight:bold;background:" + gcMouseOut2 + ";border-top:1px solid " + gcborderColor2 + ";border-bottom:1px solid " + gcborderColor2 + ";'>";
	dateDiv+=fDrawCal(giYear,giMonth,dayTdHeight,dayTdTextSize);
	dateDiv+="</table>";
	dateDiv+="</div>";
	dateDiv+="</td>";
	dateDiv+="</tr>";
	dateDiv+="<tr>";
	dateDiv+="<td align='center' colspan='4' style='padding:0px'' nowrap id='CalendarOnlyDate_tr'><div style='padding-top:4px'>&nbsp;";
	dateDiv += "<INPUT class='dateClearBtn' style='width:49px;height:22px;' onclick='fClearInputData();' value='清空' type=button>";
	dateDiv += "<span class='todayDate' style='padding-left:5px;padding-right:5px;cursor:pointer;' onclick='fSetDate(giYear,giMonth,giDay)'>" + strToday + ":" + giYear + strYear + giMonth + strMonth + giDay + strDay + "</span>";
	dateDiv+="<INPUT class='dateCloseBtn ' style='background:#FFF;width:49px;height:22px;'  onclick='fHideCalendar();' value='关闭' type=button>&nbsp;";
	dateDiv+="</div></td>";
	dateDiv+="</tr>";
	dateDiv+="<tr>";
	dateDiv+="<td align='center' colspan='4' nowrap id='CalendarDateTime_tr' style='padding:0px'>";
	dateDiv+="<table style='width:100%'>";
	dateDiv+="<tr>";
	dateDiv+="<td><div style='width:10px;overflow:hidden;height:2px'>&nbsp;</div></td>"
	dateDiv+="<td><div style='background-color:white;padding:6px 0;'><select style='width:43px;' id='datedlg_hour'>" + optionsText2 + "</select></div></td><td>时</td>"
	dateDiv+="<td><div style='background-color:white;padding:6px 0;'><select style='width:43px;' id='datedlg_mill'>" + optionsText + "</select></div></td><td>分</td>"
	dateDiv+="<td><div style='background-color:white;padding:6px 0;'><select style='width:43px;' id='datedlg_secd'>" + optionsText + "</select></div></td><td>秒</td>"
	dateDiv+="<td><div style='width:10px;overflow:hidden;height:2px'>&nbsp;</div></td>"
	dateDiv+="</tr>";
	dateDiv+="<tr>";
	dateDiv+="<td colspan='12' style='text-align:center;padding-top:0px'><div style='padding-top:4px;text-align:left;height:28px;'>&nbsp;";
	dateDiv += "<INPUT class='dateClearBtn' style='zoom:0.96;width:49px;height:22px;' onclick='fClearInputData();' id='Calendar-Datetime-Clear-Btn' value='清空' type=button>";
	dateDiv += "<span class='todayDate' style='padding-left:5px;padding-right:5px;cursor:pointer;' onclick='fSetDate(giYear,giMonth,giDay)'>" + strToday + ":" + giYear + strYear + giMonth + strMonth + giDay + strDay + "</span>";
	dateDiv += "<INPUT class='dateCloseBtn ' style='zoom:0.96;background:#FFF;width:49px;height:22px;'  onclick='fConfirmData(this);' id='Calendar-Datetime-Confirm-Btn' value='确定' type=button>&nbsp;";
	dateDiv+="</div></td>";
	dateDiv+="</tr>";
	dateDiv+="</table>";
	dateDiv+="</td>";
	dateDiv+="</tr>";
	dateDiv+="</table></div>";
	return dateDiv;
}

var datedlg = {
	show : function(srcbutton,event){
		event = event || window.event;		
		var button = srcbutton ? srcbutton : (event.srcElement || event.target);
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
		fPopCalendar(event,button,button)
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
			div.style.cssText = "background-repeat:repeat-x;background-image:url(" + (window.sysCurrPath?window.sysCurrPath:"../") + "images/m_table_top.jpg);overflow:hidden;position:absolute;z-index:100;width:226px;height:44px;background-color:white;display:none;border:1px solid #aaaabb;"
			div.innerHTML = "<table style='margin:5px;border-top:1px solid #fff;border-left:1px solid #fff;border-bottom:1px solid #aaaacc;;border-right:1px solid #aaaacc;background-color:#f0f0f0' cellSpacing=5><tr><td>时</td><td>"
							+ "<select style='font-family:宋体;font-size:12px;;color:#333388'>" + h 
							+ "</select></td><td>分</td><td><select style='font-family:宋体;font-size:12px;;color:#333388'>" + m + "</select></td><td>秒</td><td>" 
							+ "<select style='font-family:宋体;font-size:12px;;color:#333388'>" + s 
							+ "</select></td><td><button class=wavbutton onclick='datedlg.setTimeValue()'><img src='" + (window.sysCurrPath?window.sysCurrPath:"../") + "images/smico/ok.gif' title='确定'></button></td></tr></table>"
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
		window.DateTimeNotShowSecond=false;
		var button = window.event.srcElement;
		CurrentDateID=button;
        if(button.disabled) { return; }
		if(button.tagName=="BUTTON" || button.tagName == "IMG" || button.className.indexOf("fieldDateBtn")>-1 ){
			if(button.previousSibling && button.previousSibling.tagName=="INPUT"){
				button = button.previousSibling;
				document.getElementById('Calendar-Datetime-Confirm-Btn').style.display = "inline-block";
				document.getElementById('Calendar-Datetime-Clear-Btn').style.display = "inline-block";
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
		fPopCalendar(event,button,button,true,false)
	}
}
function trim(val){
	var str = val+""; if (str.length == 0) return str;
	return str.replace(/^\s*/,'').replace(/\s*$/,'');
}
function Ajax(){
	var xH,xA="",fun=arguments[1];
	for (i=2;i<arguments.length;i++) xA+=",'"+arguments[i]+"'";
	this.Ajax_sced=function(){ if(xH.readyState==4||xH.readyState=="complete") eval("fun(xH.responseText"+xA+");");}
	this.Ajax_gxho=function(handler){ var oXH=false;
		if(window.XMLHttpRequest) { oXH = new XMLHttpRequest(); if(oXH.overrideMimeType) oXH.overrideMimeType('text/xml');
		}else if(window.ActiveXObject) {
			var versions=['Microsoft.XMLHTTP','MSXML.XMLHTTP','Microsoft.XMLHTTP','Msxml2.XMLHTTP.7.0','Msxml2.XMLHTTP.6.0','Msxml2.XMLHTTP.5.0','Msxml2.XMLHTTP.4.0','MSXML2.XMLHTTP.3.0','MSXML2.XMLHTTP'];	for(var i=0;i<versions.length;i++) {try {oXH=new ActiveXObject(versions[i]);if(oXH) break;	} catch(e) {}};
		} try{oXH.onreadystatechange=handler; return oXH;} catch(e){ alert("AJAX环境错误"); return ;} 
	}
	if (arguments[0].length>0){ xH=this.Ajax_gxho(this.Ajax_sced); xH.open("POST",arguments[0],true); xH.send(" ");}else{ eval("fun(''"+xA+");");}
}
