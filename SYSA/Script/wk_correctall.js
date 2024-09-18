
function callServer3(m,ord,strname) {
	var w2  = "ts_"+ord;
	w2=document.all[w2];
	if ((strname == null) || (strname == "")) return;
	var url = "cu.asp?name=" + escape(strname)+"&ord="+escape(m)+"&intupdate="+ord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage4(w2);
	};
	xmlHttp.send(null);  
}

function updatePage4(w) {
	var test6=w
	if (xmlHttp.readyState < 4) {
		test6.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test6.innerHTML=response;
	}
}

function callServer(ord,cateid) {
	var w="w";
	
	var url = "correctall_person.asp?cateid=" + cateid +"&ord="+ord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage(w);
	};
	xmlHttp.send(null);  
}

function updatePage(w) {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		document.getElementById(""+w+"").innerHTML=response;	
		var inttop=(55+document.documentElement.scrollTop+document.body.scrollTop)+"px";
		$('#'+w+'').window({top:inttop});
	}
}

function callServer2(ord,intype) {
	var w="w1";
	var url = "correctall_area.asp?intype=" + intype +"&ord="+ord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage2(w,ord);
	};
	xmlHttp.send(null);  
}

//任务：升级到31.70后 添加客户选择不了区域 xieyanhui20150415
function updatePage2(w,ord) {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		document.getElementById(""+w+"").innerHTML=response;
		ord = Number(ord);
		var $td = "";
		var arealist = $("#arealist").val(); 
		if(arealist!="" && arealist!="0" && arealist !="-1"){
			arealist = ","+arealist+",";
			$("#treeArea").find("td[id^='b']").each(function(){
				var trid = $(this).attr("id").replace("b","");
				if(arealist.indexOf(","+trid+",")<0){
					$(this).parent().hide();
					$("#a"+trid).hide();
				}else{
					if($("#a"+trid).size()>0){
						$("#a"+trid).find("td[id^='b']").each(function(){		
							$td =$(this);
							$td.find("a:first").attr("href","javascript:;").unbind().click(function(){
								select_area(ord,$(this).parent().attr("id").replace("b",""),$(this).text());
							});
						});
					}else{
							$td =$(this);
							$td.find("a:first").attr("href","javascript:;").unbind().click(function(){				
								select_area(ord,$(this).parent().attr("id").replace("b",""),$(this).text());
							});
					}
				}	
			});
		}else{
			$("#treeArea").find("td[id^='b']").each(function(){		
				$td =$(this);
				$td.find("a:first").attr("href","javascript:;").unbind().click(function(){
					select_area(ord,$(this).parent().attr("id").replace("b",""),$(this).text());
				});
			});
		}
		var inttop=(55+document.documentElement.scrollTop+document.body.scrollTop)+"px";
		$('#'+w+'').window({top:inttop});
	}
}

function saveone_kh(ord,center) {
	if (center==1)
	{
		if (document.getElementById("ts_"+ord).innerHTML!="")
		{
			return ;
		}
	}
	var khid=document.getElementById("khid"+ord).value;
	var ly=document.getElementById("ly"+ord).value;
	var jz=document.getElementById("jz"+ord).value;
	var trade=document.getElementById("trade"+ord).value;
	var area=document.getElementById("area"+ord).value;
	if (document.getElementById("hk_xz"+ord))
	{
		var hk_xz=document.getElementById("hk_xz"+ord).value;
	}
	else
	{
		var hk_xz=0;
	}
	var cateid="";
	if (document.getElementById("cateid"+ord))
	{
		cateid=document.getElementById("cateid"+ord).value;
	}
	var url = "updateone.asp?ord="+ord+"&khid="+khid+"&ly="+ly+"&jz="+jz+"&trade="+trade+"&area="+area+"&hk_xz="+hk_xz+"&cateid="+cateid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage3();
	};
	xmlHttp.send(null);  
}

function updatePage3() {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		alert(response);
	}
}

function select_person(khord,ord,strvalue)
{
	if (khord==0)
	{
		document.getElementById("cateidall").value=ord;
		document.getElementById("cateid_all").value=strvalue;
		var controls = document.getElementsByTagName('input');
		for(var i=0; i<controls.length; i++){
			if(controls[i].type=='text'&&controls[i].name.indexOf("cateid")>=0){
				controls[i].value=strvalue;
			}
			if(controls[i].type=='hidden'&&controls[i].name.indexOf("cateid")>=0){
				controls[i].value=ord;
			}
		}
	}
	else
	{
		if (document.getElementById("cateid"+khord))
		{
			document.getElementById("cateid"+khord).value=ord;
			document.getElementById("cateid_"+khord).value=strvalue;
		}
	}
	$('#w').window('close');
}

function select_area(khord,ord,strvalue)
{
	if (khord==0)
	{
		document.getElementById("areaall").value=ord;
		document.getElementById("area_all").value=strvalue;
		var controls = document.getElementsByTagName('input');
		for(var i=0; i<controls.length; i++){
			if(controls[i].type=='text'&&controls[i].name.indexOf("area")>=0){
				controls[i].value=strvalue;
			}
			if(controls[i].type=='hidden'&&controls[i].name.indexOf("area")>=0){
				controls[i].value=ord;
			}
		}
	}
	else
	{
		if (document.getElementById("area"+khord))
		{
			document.getElementById("area"+khord).value=ord;
			document.getElementById("area_"+khord).value=strvalue;
		}
	}
	$('#w1').window('close');
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
function setSelect(val,checkStr)
{
	var controls = document.getElementsByTagName('select');
	for(var i=0; i<controls.length; i++){
		if(controls[i].name.indexOf(""+checkStr+"")>=0){
			for(var j=0;j<controls[i].options.length;j++) 
			{ 
				if(controls[i].options[j].value==val) 
				{	controls[i].options[j].selected=true; 
					break;
				}
			} 	
		}
	}
}
function setValue(val,checkStr,isAdd)
{
	var controls = document.getElementsByTagName('input');
	//if (checkStr=="khid" &&val.replace(" ","")=="")
	//{
	//	return;
	//}
	val=val.replace(/(^\s*)|(\s*$)/g, "");  
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
							else
							{
								break;
							}
						}
						str0=val.toString().substring(0,val.toString().length-m);
						val=str;
						if (val!="")
						{							
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
							else if (val.toString().length<=15 && val.toString().length>0)
							{
								m=val.toString().length;
								val=val.replace(/\b(0+)/gi,"");
								if (val=="")
								{
									val=0;
								}
								val=parseInt(val)+1;
								if (m>val.toString().length)
								{
									val=str.substr(0,m-val.toString().length)+val.toString();
								}
							}
							val=str0+val.toString();
						}
						else 
						{
							val=str0;
						}
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

function setSince(obj)
{
	if(obj.checked){
		document.getElementById('select_all').onchange= function () {setValue(document.getElementById('select_all').value,'khid',true); }
		obj.title="取消递增";
		if (document.getElementById('select_all').value!="")
		{
			setValue(document.getElementById('select_all').value,'khid',true);
		}
	}
	else
	{
		document.getElementById('select_all').onchange= function () {setValue(document.getElementById('select_all').value,'khid',false); }
		obj.title="递增";
		if (document.getElementById('select_all').value!="")
		{
			setValue(document.getElementById('select_all').value,'khid',false);
		}
	}
}
