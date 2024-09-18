var xmlHttp=new XMLHttpRequest();
function car_img(val,currpage,car_code)
{
url="Car_Img.asp?sel_time="+val+"&currpage="+currpage+"&car_code="+car_code+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.onreadystatechange = null;
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var ajaxhtml=xmlHttp.responseText;
			document.getElementById('ajaxdiv').innerHTML=ajaxhtml;
		}
	}
	xmlHttp.send(null);	
}
function opentitle(Control,carid,times1,times2)
{
	var div=document.getElementById('title');
	div.style.display=""
	var ttop = Control.offsetTop;
    var tleft = Control.offsetLeft;
	div.style.top=ttop+90;
	div.style.left=tleft+5;
	url="Car_Sel.asp?carid="+carid+"&times1="+times1+"&times2="+times2+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.onreadystatechange = null;
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var selhtml=xmlHttp.responseText;
			document.getElementById('title').innerHTML=selhtml;
		}
	}
	xmlHttp.send(null);	
}
function closetitle()
{
	var div=document.getElementById('title');
	div.innerHTML="<img src='../images/smico/proc.gif' title='使用明细'>"
	div.style.display="none"
}
function add_tr(id,name,driver,ftime,ptime)
{
	var carid=document.getElementById("use_carid_"+id);
	if(carid==null)
	{
		addtr(id,name,driver);
	}
	var startime=document.getElementsByName("use_startime_"+id);
	for(i=0;i<startime.length;i++)
	{
		startime[i].value=ftime;
		startime[i].style.color="black";
	}
}
function del_TR(id)
{
	try{
	var tr=document.getElementById(id);
	tr.parentNode.removeChild(tr);
	}
	catch(e){}
	setSortList();
}
function setSortList()
{
	var sortlist=document.getElementsByName('sortlist');
	for (i=0;i<sortlist.length;i++)
	{
		sortlist[i].innerHTML=i+1;
	}
	a=a-1;
}
function Validate(carIdList,starTimeList,starEndList)
{
	px=0
	for(i=0;i<carIdList.length;i++)
	{
		if(starTimeList[i].value!="" && starEndList[i].value!="")
		{
			try
			{	
				var d1 = new Date(starTimeList[i].value.replace(/\-/g,"/"))
				var d2 = new Date(starEndList[i].value.replace(/\-/g,"/"))
				if (d1.getTime()-d2.getTime()<0)
				{}
				else
				{px=1;break;return px;}
			}
			catch(e)
			{px=2;break;return px;}
		}
		else
		{px=3;break;return px;}
	}
	
	for(i=0;i<carIdList.length;i++)
	{
		for(j=0;j<carIdList.length;j++)
		{
			if(carIdList[i].value==carIdList[j].value)
			{
				if(i!=j)
				{
					var d1 = new Date(starTimeList[i].value.replace(/\-/g,"/"))
					var d2 = new Date(starEndList[i].value.replace(/\-/g,"/"))
					var d3 = new Date(starTimeList[j].value.replace(/\-/g,"/"))
					var d4 = new Date(starEndList[j].value.replace(/\-/g,"/"))
					if(d1.getTime()-d4.getTime()>=0 || d2.getTime()-d3.getTime()<=0)
					{}
					else
					{px=4;break;return px;}
				}
			}
		}
	}
	
	for (i=0;i<carIdList.length;i++)
	{
		arrIdList=carIdList[i].value+","
		arrStarList=starTimeList[i].value+","
		arrEndList=starEndList[i].value+","
	}
	
	url="Car_Sel_time.asp?arrIdList="+arrIdList+"&arrStarList="+arrStarList+"&arrEndList="+arrEndList+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			a=xmlHttp.responseText;
			if (parseInt(a)==2)
			{px=3;return px;}
			else if (parseInt(a)==3)
			{px=5;return px;}
		}
	}
	xmlHttp.send(null);	
	
	return px;
}

function setAll(values,times)
{
	$("input[name='"+times+"']").val(values);
	$("input[name='"+times+"']").css("color","#000000");
}



