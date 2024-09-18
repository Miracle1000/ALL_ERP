
$.extend($.messager.defaults,{   
    ok:"确定",   
    cancel:"取消"  
}); 
String.prototype.replaceAll = function(s1,s2) { 

    return this.replace(new RegExp(s1,"gm"),s2); 

}
/* 得到日期年月日等加数字后的日期 */
Date.prototype.dateAdd = function(interval,number) 
{ 
    var d = this; 
    var k={'y':'FullYear', 'q':'Month', 'm':'Month', 'w':'Date', 'd':'Date', 'h':'Hours', 'n':'Minutes', 's':'Seconds', 'ms':'MilliSeconds'}; 
    var n={'q':3, 'w':7}; 
    eval('d.set'+k[interval]+'(d.get'+k[interval]+'()+'+((n[interval]||1)*number)+')'); 
    return d; 
} 
/* 计算两日期相差的日期年月日等 */
Date.prototype.dateDiff =function(interval,objDate2)
{
    var d=this, i={}, t=d.getTime(), t2=objDate2.getTime();
    i['y']=objDate2.getFullYear()-d.getFullYear();
    i['q']=i['y']*4+Math.floor(objDate2.getMonth()/4)-Math.floor(d.getMonth()/4);
    i['m']=i['y']*12+objDate2.getMonth()-d.getMonth();
    i['ms']=objDate2.getTime()-d.getTime();
    i['w']=Math.floor((t2+345600000)/(604800000))-Math.floor((t+345600000)/(604800000));
    i['d']=Math.floor(t2/86400000)-Math.floor(t/86400000);
    i['h']=Math.floor(t2/3600000)-Math.floor(t/3600000);
    i['n']=Math.floor(t2/60000)-Math.floor(t/60000);
    i['s']=Math.floor(t2/1000)-Math.floor(t/1000);
    return i[interval];
}

function addItem(pId,intYear,dtFrom,dtTo){
	$.ajax({
		url:"period_add.asp?pId="+pId+"&intYear="+intYear+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			$("#period_add").html(msg);
			$.parser.parse($('#period_add'));
			$('#win').window({
				collapsible:false,
				minimizable:false,
				maximizable:false,
				top:200,
				left:(document.body.scrollWidth-500)/2
			});
			$('#win').window('open');
			
			$("#dtFromDate").val(dtFrom);

			var intRoleId=$("#intRoleId").val();
			if(intRoleId=="5"){
				var t1 = dtFrom.split(/[- :]/);
				var d1 = new Date(t1[0], t1[1]-1, t1[2]);
				var w1=d1.getDay();
				if(w1==0) w1=7;
				if(w1>1){
					var s=d1.dateAdd("d",8-w1);
					var dtFromStr=s.getYear()+"-"+(s.getMonth()+1)+"-"+s.getDate();
					$("#dtFromDate").val(dtFromStr);
				}
			}
			
			if(dtFrom==""){
				var defaultDateStr=intYear+"-1-1";
			}else{
				var defaultDateStr=dtFrom;
			}
			$("#dtFromDate").datepicker({
				dateFormat:"yy-m-d",
				showWeek: true,
				weekHeader: "周",
				changeYear: true,
				minDate: dtFrom,
				maxDate: dtTo,
				firstDay: 1,
				defaultDate:defaultDateStr,
				beforeShow: function(input, inst){
					var intRoleId=$("#intRoleId").val();
					if(intRoleId=="5"){
						var t1 = dtFrom.split(/[- :]/);
						var d1 = new Date(t1[0], t1[1]-1, t1[2]);
						var w1=d1.getDay();
						if(w1==0) w1=7;
						if(w1>1){
							var s=d1.dateAdd("d",8-w1);
							var dtFromStr=s.getYear()+"-"+(s.getMonth()+1)+"-"+s.getDate();
							$("#dtFromDate").datepicker( "option" , "minDate" , dtFromStr );
						}
						var t2 = dtTo.split(/[- :]/);
						var d2 = new Date(t2[0], t2[1]-1, t2[2]);
						var w2=d2.getDay();
						if(w2==0) w2=7;
						if(w2!=7){
							var s2=d2.dateAdd("d",7-w2);
							var dtToStr=s2.getYear()+"-"+(s2.getMonth()+1)+"-"+s2.getDate();
							$("#dtFromDate").datepicker( "option" , "maxDate" , dtToStr );
						}
					}else{
						$("#dtFromDate").datepicker( "option" , "minDate" , dtFrom );
						$("#dtFromDate").datepicker( "option" , "maxDate" , dtTo);
					}
				},
				onSelect: function(dateText, inst){
					var intRoleId=$("#intRoleId").val();
					if(intRoleId=="5"){
						var t1 = dateText.split(/[- :]/);
						var d1 = new Date(t1[0], t1[1]-1, t1[2]);
						if(d1.getDay()!=1){
							alert("请选择一周的开始时间");
							$(this).val("");
						}
					}else{
						if(dateText!=dtFrom&&dtFrom!=""){
							alert("开始日期必须为"+dtFrom);
							$(this).val(dtFrom);
						}
					}
				},
				dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
				monthNames: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
			});
			$("#dtToDate").datepicker({
				dateFormat:"yy-m-d",
				showWeek: true,
				weekHeader: "周",
				changeYear: true,
				minDate: dtFrom,
				maxDate: dtTo,
				firstDay: 1,
				defaultDate:defaultDateStr,
				beforeShow: function(input, inst){
					var intRoleId=$("#intRoleId").val();
					if(intRoleId=="5"){
						var t1 = dtFrom.split(/[- :]/);
						var d1 = new Date(t1[0], t1[1]-1, t1[2]);
						var w1=d1.getDay();
						if(w1==0) w1=7;
						if(w1>1){
							var s=d1.dateAdd("d",8-w1);
							var dtFromStr=s.getYear()+"-"+(s.getMonth()+1)+"-"+s.getDate();
							$("#dtToDate").datepicker( "option" , "minDate" , dtFromStr );
						}
						var t2 = dtTo.split(/[- :]/);
						var d2 = new Date(t2[0], t2[1]-1, t2[2]);
						var w2=d2.getDay();
						if(w2==0) w2=7;
						if(w2!=7){
							var s2=d2.dateAdd("d",7-w2);
							var dtToStr=s2.getYear()+"-"+(s2.getMonth()+1)+"-"+s2.getDate();
							$("#dtToDate").datepicker( "option" , "maxDate" , dtToStr );
						}
					}else{
						$("#dtToDate").datepicker( "option" , "minDate" , dtFrom );
						$("#dtToDate").datepicker( "option" , "maxDate" , dtTo);
					}
				},
				onSelect: function(dateText, inst){
					var intRoleId=$("#intRoleId").val();
					if(intRoleId=="5"){
						var t2 = dateText.split(/[- :]/);
						var d2 = new Date(t2[0], t2[1]-1, t2[2]);
						if(d2.getDay()!=0){
							alert("请选择一周的结束时间");
							$(this).val("");
						}
					}
				},
				dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
				monthNames: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
			});
		}
   });
}
function editItem(Id,dtFrom,dtTo,minDate,maxDate){
	$.ajax({
		url:"period_add.asp?Id="+Id+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			$("#period_add").html(msg);
			$.parser.parse($('#period_add'));
			$('#win').window({
				collapsible:false,
				minimizable:false,
				maximizable:false,
				top:200,
				left:(document.body.scrollWidth-500)/2
			});
			$('#win').window('open');
			var intRoleId=$("#intRoleId").val();
			$("#dtFromDate").datepicker({
				dateFormat:"yy-m-d",
				showWeek: true,
				weekHeader: "周",
				changeYear: true,
				minDate: dtFrom,
				maxDate: dtTo,
				firstDay: 1,
				defaultDate:dtFrom,
				onSelect: function(dateText, inst){
					if(minDate!=""){
						if(!compareDate(dateText,minDate,1)){
							alert("开始日期不能大于"+minDate);
							$(this).val(minDate);
							return;
						}
					}
					if(intRoleId=="5"){
						var t1 = dateText.split(/[- :]/);
						var d1 = new Date(t1[0], t1[1]-1, t1[2]);
						if(d1.getDay()!=1){
							alert("请选择一周的开始时间");
							$(this).val("");
						}
					}else{
						if(dateText!=dtFrom&&dtFrom!=""){
							alert("开始日期必须为"+dtFrom);
							$(this).val(dtFrom);
						}
					}
				},
				dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
				monthNames: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
			});
			$("#dtToDate").datepicker({
				dateFormat:"yy-m-d",
				showWeek: true,
				weekHeader: "周",
				changeYear: true,
				minDate: dtFrom,
				maxDate: dtTo,
				firstDay: 1,
				defaultDate:dtTo,
				onSelect: function(dateText, inst){
					if(maxDate!=""){
						if(!compareDate(dateText,maxDate,2)){
							alert("结束日期不能小于"+maxDate);
							$(this).val(maxDate);
							return;
						}
					}
					if(intRoleId=="5"){
						var t2 = dateText.split(/[- :]/);
						var d2 = new Date(t2[0], t2[1]-1, t2[2]);
						if(d2.getDay()!=0){
							alert("请选择一周的结束时间");
							$(this).val("");
						}
					}
				},
				dayNamesMin: ['日', '一', '二', '三', '四', '五', '六'],
				monthNames: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
			});

		}
   });
}
function formSubmit(){
	var dtFromDate=$("#dtFromDate").val();
	var dtToDate=$("#dtToDate").val();
	var flag2=compareDate(dtFromDate,dtToDate,1);
	if(!flag2){
		$("#msg").html('开始日期不能大于结束日期');
	}else{
		$("#msg").html('');
	}
	
	var intRoleId=$("#intRoleId").val();
	if(intRoleId=="5"){
		var t1 = dtFromDate.split(/[- :]/);
		var d1 = new Date(t1[0], t1[1]-1, t1[2]);
		if(d1.getDay()!=1){
			$("#msg").html('开始日期不是一周起始时间');
			return;
		}
		var t2 = dtToDate.split(/[- :]/);
		var d2 = new Date(t2[0], t2[1]-1, t2[2]);
		if(d2.getDay()!=0){
			$("#msg").html("结束日期不是一周结束时间");
			return;
		}
	}
	var flag=false;
	flag=Validator.Validate(document.forms['period_add'],2);
	if(flag&&flag2){
		$('#period_add').submit();
	}
}
//日期比较
function compareDate(date1,date2,tag) 
{ 
	try 
	{ 
		date1=date1.replaceAll("-","/");
		date2=date2.replaceAll("-","/");
		var strdt1=date1.replace(/- /g,"/"); 
		var strdt2=date2.replace(/- /g,"/"); 
		var dt1=Date.parse(strdt1); 
		var dt2=Date.parse(strdt2);
		if(tag==1){ 
			return dt1<=dt2; 
		}else if(tag==2){
			return dt1>=dt2; 
		}else if(tag==3){
			return dt1==dt2;
		}
	} 
	catch(e) 
	{ 
	} 
} 
function delItem(nId){
	window.location.href="period_del.asp?Id="+nId;
}
