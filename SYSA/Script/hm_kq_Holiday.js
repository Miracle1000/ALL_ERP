
var sss=new Date().getFullYear();
function getHdYear(){
	var val=$("#DHdayType").val();
	var s = "";
	$.ajax({
       url:"getholidayJson.asp?v=getYear&HdType="+val+"&r="+ Math.random(),
       type:"post",
	   dataType:"json",
	   success:function(json){
	   	  for(var i=0;i<json.length;i++){
			 s = s + "<option value="+json[i].yValue+ ">"+json[i].yName+"</option>";
		  };
		  $("#DHYear").html(s);
	   },complete:function(){
	   	  getHdMonth();
	   }
   });
}
function getHdMonth(){
	var val=$("#DHdayType").val();
	var HdYear=$("#DHYear").val();
	if(HdYear==null||HdYear=="")
	{
	HdYear=1901;
	}
	var s = "";
    var t = "";
	$.ajax({
       url:"getholidayJson.asp?v=getMonth&HdType="+val+"&HdYear="+HdYear+"&r="+ Math.random(),
       type:"post",
	   dataType:"json",
	   success:function(json){
	   	  for(var i=0;i<json.length;i++){
			 s = s + "<option value="+json[i].mValue;
			 s = s + ">"+json[i].mName+"</option>";
		  };
		  $("#DHMonth").html(s);
	   },complete:function(){
	   	  getHdDay();
	   }

   });
}


function getHdDay(){
	var val=$("#DHdayType").val();
	var HdYear=$("#DHYear").val();
	var HdMonth=$("#DHMonth").val();
		if(HdYear==null||HdYear=="")
	{
	HdYear=1901;
	}
	var s = "";
	$.ajax({
       url:"getholidayJson.asp?v=getDay&HdType="+val+"&HdYear="+HdYear+"&HdMonth="+HdMonth+"&r="+ Math.random(),
       type:"post",
	   dataType:"json",
	   success:function(json){
		  var DHDay =  $("#DHDay").val();
	   	  for(var i=0;i<json.length;i++){
			 s = s + "<option value="+json[i].dValue;
			 if(DHDay == json[i].dValue) {s = s +" selected ";}
			 s = s + ">"+json[i].dName+"</option>";
		  };
		  $("#DHDay").html(s);
	   },complete:function(){
	   	  getHolidate(1);
	   }
   });
}
//生成日历
function getHolidate(ftype , val, HdYear , HdMonth , HdDay ,hidDate, hidDateW){
	var url = "";
	if (ftype==1){
		val=$("#DHdayType").val();
		HdYear=$("#DHYear").val();
		HdMonth=$("#DHMonth").val();
		HdDay=$("#DHDay").val();
		url = "date_holiday.asp?HdType="+val+"&HdYear="+HdYear+"&HdMonth="+HdMonth+"&HdDay="+HdDay+"&r="+ Math.random();
	}else{
		url = "date_holiday.asp?HdType="+val+"&HdYear="+HdYear+"&HdMonth="+HdMonth+"&HdDay="+HdDay+"&hidDate="+hidDate+"&hidDateW="+hidDateW+"&r="+ Math.random();
	}
	$.ajax({
       url:url,
       type:"post",
	   dataType:"html",
	   success:function(data){
			$("#holidayDate").html(data);
			initBindEvent();
		}
	});
}
function DateDiff(asStartDate,asEndDate){   
var miStart=Date.parse(asStartDate.replace(/\-/g,'/'));   
var miEnd=Date.parse(asEndDate.replace(/\-/g,'/'));   
return (miEnd-miStart)/(1000*24*3600);   
}
function getDiffDay(start,end,show)
{
var s1=$("#"+start+"").val();
var s2=$("#"+end+"").val();
var diffday=DateDiff(s1,s2)
if(diffday>=0)
{
$("#"+show+"").val(diffday);//调用方法如前，返回结果：1
}
else
{
alert("结束日期必须大于开始时间");
}
}


var publicWorkID,publicColor="#99cc00",publicColorstr,publicSetWIdStr;
function initBindEvent(){
	$("#topWorkBoor tr td").click(function(){
		publicWorkID=this.id;
		publicColor=$("#"+publicWorkID+"").attr("bgcolor").toLowerCase();
		publicColor = ColorToHEX(publicColor);
	});
	$("#Calendar table tr td").click(function(){
		if(this.id!=""&&this.id!=null){
			var style = $("#"+this.id+"").attr("style");
			if (!style){style = "";}
			style=getColorByStyle(style);
			if(style.toLowerCase().indexOf(publicColor)>=0){
				$("#"+this.id+"").css("background-color","#ffffff");
				$("#hidDate").val($("#hidDate").val().replace("|"+this.id,""));
				$("#hidDateW").val($("#hidDateW").val().replace("|"+this.id,""));
			}
			else{
				$("#"+this.id+"").css("background-color",publicColor);
				style = $("#"+this.id+"").attr("style");
				if (!style){style = "";}
				style=getColorByStyle(style);
				if(style.toLowerCase().indexOf("#99cc00")>=0){
					$("#hidDate").val($("#hidDate").val()+"|"+this.id);
					$("#hidDateW").val($("#hidDateW").val().replace("|"+this.id,""));
				}
				else if(style.toLowerCase().indexOf("#ffe888")>=0){
					$("#hidDateW").val($("#hidDateW").val()+"|"+this.id);
					$("#hidDate").val($("#hidDate").val().replace("|"+this.id,""));
				}
			}
		}
	});
}

function getColorByStyle(style){
	if (style.length==0){return "";}
	style = style.replace("background-color:","").replace(";","").replace(" ","")
	return ColorToHEX(style)
}

function hex(x) {
	return ("0" + parseInt(x).toString(16)).slice(-2);
}
function ColorToHEX(rgb){
	if(!$.browser.msie){
		rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
		rgb= "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
	}
	return rgb;
}
