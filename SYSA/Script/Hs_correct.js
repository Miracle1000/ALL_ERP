$.ajaxSetup({async:false});
function getcount(uid){
	var CutAll = 0;
	var AddAll = 0;
	var thisAll = 0;
	var thisAll2 = 0;
	var moneyNzj = 0;
	var Tax=0;
	var TaxID=""; var TaxID2 = ""; var TaxID3 = "";
	var tr = document.getElementById("row_" + uid);
	var ord = $("#row_" + uid).find("td:first").find("input").val();
	var $tr = $('#row_' + uid);
	var taxv1 = 0;
	var taxv2 = 0;
	var boxs = $tr.find(":input[id^='Q_']")
	//var boxs = tr.getElementsByTagName("input");
	for (var i = 0 ; i < boxs.length ; i ++ )	{
		var item = boxs[i];
		if ((item.type=="text" || item.type=="hidden") && item.id.indexOf("intro_")<0)	{		
			if(item.id.indexOf("YesTax")<0 && item.id.indexOf("NzjTax")<0 && item.id.indexOf("NzjMoney")<0){
				var v1 = item.value;	
				var v2 = 0;
				var v5 = 0;
				if (document.getElementById("p_" + i)) { v2 = document.getElementById("p_" + i).value; v5 = $("#p_" + i).attr("deductible") }
				var v3 = v1*v2;				
				if (v5 == 1) {
				    CutAll += v3;
				} else {
				    AddAll += v3;
				}
				thisAll+= v3;
			}else{
			    if (item.id.indexOf("YesTax") > 0) {
			        taxv1= $("#p_" + i).attr("deductible")
					if(TaxID==""){
						TaxID=item.id; 
					}else{
						alert("个税不能同时出现在两个项目中!");
					}
				}	
			    if (item.id.indexOf("NzjTax") > 0) {
			        taxv2 = $("#p_" + i).attr("deductible")
					if(TaxID2==""){
						TaxID2=item.id; 
					}else{
						alert("年终奖所得税不能同时出现在两个项目中!");
					}
				}	
				if(item.id.indexOf("NzjMoney")>0){
					if(TaxID3==""){
						TaxID3=item.id;  moneyNzj = Number($(item).val());
					}else{
						alert("年终奖不能同时出现在两个项目中!");
					}
				}	
			}
		}
	}
	CutAll = Math.abs(CutAll);
	var qy = 0;
	if (jQuery("#qy").size() > 0) {
	    if (jQuery("#qy").attr("checked")) {
	        qy = 1
	    }
	}
	if (thisAll <= 0) {
	    qy = 0;
	}
	//计算个税	
	var thisTax=0.0; var thisTax2=0.0;
	if(TaxID!="" || TaxID2!=""){
		var arr_res = ""; 
		$.get("../hrm/GetTax.asp",
		{ action: "get", ToalMoney: thisAll, ord: $("#hr_salaryClass").attr("ord"), ismode: 1, qy: qy, ToalMoney2: moneyNzj, uid: ord, startDate: window.s_tdDay1, endDate: window.s_TdEndDay, num: Math.random(), ChildrenseDucation: $("#ChildrenseDucation" + ord).text(), ContinuingEducationxl: $("#ContinuingEducationxl" + ord).text(), ContinuingEducationjn: $("#ContinuingEducationjn" + ord).text(), medical: $("#medical" + ord).text(), Housingloans: $("#Housingloans" + ord).text(), payment: $("#payment" + ord).text(), SupportOldPeople: $("#SupportOldPeople" + ord).text() },
		function(data,html){ 
			arr_res = data.split("|");
			thisTax = parseFloat(parseFloat(arr_res[0]).toFixed(window.sysConfig.moneynumber));
			thisTax2 = parseFloat(parseFloat(arr_res[1]).toFixed(window.sysConfig.moneynumber));
			if(TaxID!=""){
			    $("#" + TaxID + "").val(thisTax.toFixed(window.sysConfig.moneynumber));
			}
			if(TaxID2!=""){
			    $("#" + TaxID2 + "").val(thisTax2.toFixed(window.sysConfig.moneynumber));
			}
			if (taxv1 == 1) CutAll = CutAll + thisTax;
			if (taxv2 == 1) CutAll = CutAll + thisTax2;
			AddAll = AddAll + moneyNzj;
			thisAll=thisAll+moneyNzj-thisTax-thisTax2;

			$("#yf_all_" + uid + "").html(AddAll.toFixed(window.sysConfig.moneynumber));
			$("#yk_all_" + uid + "").html(CutAll.toFixed(window.sysConfig.moneynumber));
			$("#sj_all_" + uid + "").html(thisAll.toFixed(window.sysConfig.moneynumber));
			hjAllWages();	//求合计
		});
	}else	{
	    $("#yf_all_" + uid + "").html(AddAll.toFixed(window.sysConfig.moneynumber));
	    $("#yk_all_" + uid + "").html(CutAll.toFixed(window.sysConfig.moneynumber));
	    $("#sj_all_" + uid + "").html(thisAll.toFixed(window.sysConfig.moneynumber));
		hjAllWages();	//求合计
	}

}

//合计行
function hjAllWages(){
	var hj_yf_all=0.0; var hj_yk_all=0.0; var hj_sj_all=0.0
	var yf_all=0.0; var yk_all=0.0; var sj_all=0.0;
	var trIndex = -1;
	$("div[id^='yf_all_']").each(function(){
		trIndex = $(this).attr("id").replace('yf_all_','');
		yf_all = Number($(this).html().replace(",",""));
		yk_all = Number($("#yk_all_"+trIndex).html().replace(",",""));
		sj_all = Number($("#sj_all_"+trIndex).html().replace(",",""));
		hj_yf_all += yf_all;
		hj_yk_all += yk_all;
		hj_sj_all += sj_all;
	});
	$("#hj_yf_all").html(hj_yf_all.toFixed(window.sysConfig.moneynumber));
	$("#hj_yk_all").html(hj_yk_all.toFixed(window.sysConfig.moneynumber));
	$("#hj_sj_all").html(hj_sj_all.toFixed(window.sysConfig.moneynumber));
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
 return (isIE ? document.all[eltname].style : document.layers[eltname]);
}

function hideElement(eltname) { getXBrowserRef(eltname).visibility = 'hidden'; }

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
  positioner = document.images[positionername];
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
            if ((today.year == newCal.getFullYear()) &&
                  (today.month == newCal.getMonth()))
        {
               day = today.day;
            }
            var intDaysInMonth =
               getDays(newCal.getMonth(), newCal.getFullYear());
            var daysGrid = makeDaysGrid(startDayOfWeek,day,intDaysInMonth,newCal,eltName);
        if (isIE) {
           var elt = document.all[eltName];
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




function openImportDiv(){
	var salaryClass = $("#hr_salaryClass").val();
	$("#importNzj").html("<iframe name='drFrame' id='drFrame' src='../load/newload/nzjdr.asp?salaryClass="+salaryClass+"&s_TdEndDay="+window.s_TdEndDay+"' FRAMEBORDER='0' SCROLLING='auto' width='100%' HEIGHT='100%' style='margin:0; padding:0;'></iframe>");
	$('#w2').css('display','block'); $('#w2').window('open');
}

//获取导入年终奖数据
function setCateBonus(){
	$.ajax({
		url:"../hrwages/add.asp?msgid=getImportBonus",
		success:function(r){
			if(r != ""){
				var arr_res = r.split("|");
				var arr_res2 = ""; var i = 0; var moneynzjId = "";
				for(i=0; i<arr_res.length;i++){
					if(arr_res[i] != ""){
						arr_res2 = arr_res[i].split(":");
						moneynzjId = $("#catenzj_"+arr_res2[0]).val();
						$("#"+moneynzjId).val(arr_res2[1]);
					}
				}
				//$('#w2').window('close');
			}else{
				//alert("请导入有效的年终奖信息");
			}	
		}
	});
}

function choose(obj) {
    if ($(obj).val() == -1) {

            $("#may4").show();
            $("#span4").show();
            $("#may4").attr("checked", true);
        
    }
    else {

        $("#may4").css("display", "none");
        $("#span4").css("display", "none");
        $("#may4").attr("checked", false);
    }

}