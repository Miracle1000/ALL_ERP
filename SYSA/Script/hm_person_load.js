
<!--
function getcount(uid)
{
var thisAll=0;
$("#row_"+uid+" input:text", document.forms[0]).each(function(){
if (this.id.indexOf("0_0_")<0)
{
var thisVal=$("#"+this.id+"").val();
var proVal=$("#"+this.id+"_pro").val();
var spVal=$("#"+this.id+"_sp").val();
 thisAll+=thisVal*proVal*spVal
}
}); 
$("#0_0_"+uid+"").val(thisAll);
}
var userBh="";
var MouseDown=0;
var bclick=false;
var lastId="";
var lastTR="";
$(document).ready(function(){

$("#demo input:text").mousemove(function()
{


	if(userBh=="")
	{
	userBh=$("#"+this.id+"").val();
	}
	else if(this.id.indexOf(lastTR)<0)
	{
	userBh=$("#"+this.id+"").val();
	}

	if(this.id!=""&&this.id!=null&&userBh!=""&&this.id&&event.ctrlKey)
	{
	
	if(lastId!=this.id&&event.shiftKey)
	{
	userBh++;
	
	}
	lastId=this.id;
	if($("#"+this.id+"").val()=="")
	{
	$("#"+this.id+"").val(userBh);
	}
	if(this.id!=""&&this.id!=null&&this.id.indexOf("_")>=0)
	{
	lastTR=this.id.split("_")[0]
	}
	
	}
	});

});
function openDiv(title,str)
{
	var leftWidth=document.body.scrollLeft+window.event.clientX;
	var topHeight=document.body.scrollTop+window.event.clientY;
	var scrollWhdth=document.body.scrollWidth;
	if((leftWidth-scrollWhdth)>=-250){leftWidth=leftWidth-250;}

	div_write=window.DivOpen("person_load" ,title, 250,0,topHeight,leftWidth,true,0);
	div_write.innerHTML = "整列赋值：<input name='rowValue' size='15' id='rowValue'  type='text'> <br>是否递增：<input type='checkbox' name='isAdd' id='isAdd' value='1'>&nbsp;&nbsp;<input type='button' value='确定' onClick=setValue(rowValue.value,'"+str+"',isAdd.checked);window.DivClose(this); class='page'/>";
}
String.prototype.Right = function (charcount) {
    return this.substr(this.length - charcount, charcount);
};
function setValue(val,checkStr,isAdd)
{
	var controls = document.getElementsByTagName('input');
	var m=0;
	var str="";
	var str0="";
	var str1="";
	var str2="";
	for(var i=0; i<controls.length; i++){
		if(controls[i].type=='text'&&controls[i].name.indexOf(""+checkStr+"")>=0){
			if(isAdd)
			{
				try
				{
					controls[i].value=val;
					if(RegTest(val,/^\d{4}\-[0|1]?[\d]\-[0|1|2|3]?[\d]$/))
					{
						var d1 = new Date(Date.parse(val.replace(/\-/g,"/")));
						val=getFormatDate(d1.dateAdd("d",1));
					}
					else
					{
						m=0;
						str="";
						for (var n=val.toString().length;n>0 ;n--)
						{
							if (!isNaN(val.toString().substring(n-1,n)))
							{
								str=val.toString().substring(n-1,n)+str;
								m++;
							}						
						}
						str0=val.toString().substring(0,val.toString().length-m);
						val=str;
						if (val.toString().length>15 && val.toString().length<25)
						{
							str1=val.toString().substring(0,12);
							str2=val.toString().substring(12,val.toString().length);
							val=parseInt(str2)+1;	
							if (val.toString().length>str2.length)
							{
								val=(parseInt(str1)+1).toString()+val.toString().substring(1,val.toString().length);
							}
							else if (val.toString().length<str2.length)
							{
								val=str1+str2.substring(0,str2.length-val.toString().length)+val.toString();
							}
							else
							{
								val=str1+val.toString();
							}
						}
						else if (val.toString().length>0 && val.toString().length<=15)
						{//BUG 7096 Sword 2015-2-13 员工档案列表批量导入时问题 递增为空 不计算
							if (!isNaN(val)){
							    var l1 = (val + "").length;
							    val = (parseInt(val) + 1);
							    var l2 = (val + "").length;
							    val = ("000000000000000" + val).Right(l1 > l2 ? l1 : l2);
							}
						}
						val=str0+val.toString();
					}
				}
				catch(e){alert(e);}
			}
			else
			{
				controls[i].value=val;
			}
		}
	}
}

function RegTest(s,patrn) 
{ 
	if (!patrn.exec(s)) return false ;
	return true ;
} 
/* 得到日期年月日等加数字后的日期 */
Date.prototype.dateAdd = function(interval,number)
{
var d = this;
var k={"y":"FullYear", "q":"Month", "m":"Month", "w":"Date", "d":"Date", "h":"Hours", "n":"Minutes", "s":"Seconds", "ms":"MilliSeconds"};
var n={"q":3, "w":7};
eval("d.set"+k[interval]+"(d.get"+k[interval]+"()+"+((n[interval]||1)*number)+")");
return d;
};

function getFormatDate(day) 
{ 
var Year = 0; 
var Month = 0; 
var Day = 0; 
var CurrentDate = ""; 
Year= day.getFullYear();//ie火狐下都可以 
Month= day.getMonth()+1; 
Day = day.getDate(); 
CurrentDate += Year + "-"; 
if (Month >= 10 ) 
{ 
CurrentDate += Month + "-"; 
} 
else 
{ 
CurrentDate += "0" + Month + "-"; 
} 
if (Day >= 10 ) 
{ 
CurrentDate += Day ; 
} 
else 
{ 
CurrentDate += "0" + Day ; 
} 
return CurrentDate; 
} 

-->
