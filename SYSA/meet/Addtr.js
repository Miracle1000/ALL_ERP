var xmlHttp=false;
try
{
	xmlHttp=new ActiveXObject("Msxml2.XMLHTTP")
}
catch(e)
{
	try{xmlHttp=new ActiveXObject("Microsoft.XMLHTTP")}
	catch(e)
	{
	if (!xmlHttp && typeof XMLHttpRequest!='undefined')
	{
		xmlHttp=new XMLHttpRequest();
	}
	}
}

function Validate(met_id,cycle1,time1,time2,utime1,utime2,udate1,udate2)
{
	url="Car_Sel.asp?met_id="+met_id+"&cycle1="+cycle1+"&time1="+time1+"&time2="+time2+"&utime1="+utime1+"&utime2="+utime2+"&udate1="+udate1+"&udate2="+udate2+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			px=xmlHttp.responseText;
			return px;
		}
	}
	xmlHttp.send(null);	
	return px;
}
function deltr(parses)
{
	try{
	var tr=document.getElementById(parses);
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
		sortlist[i].innerHTML=i+2;
	}
	b=b-1;
}
function car_img(val,currpage,meet_name)
{
	url="Car_Img.asp?sel_time="+val+"&currpage="+currpage+"&meet_name="+meet_name+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function Fun_meet(parses)
{
	use_deviceid=document.getElementById('use_deviceid');
	use_device=document.getElementById('use_device');
	url="Ajax1.asp?met_id="+parses+"&timestamp="+new Date().getTime()+"&date1"+Math.round(Math.random()*100);
	xmlHttp.open("GET",url,false)
	xmlHttp.onreadystatechange=function()
	{
		if (xmlHttp.readyState==4)
		{
			var text=xmlHttp.responseText;
			var txtarr=text.split('_');
			use_deviceid.value=txtarr[1];
			use_device.value=txtarr[0];
			use_device.style.color="black";
		}
	}
	xmlHttp.send(null);
}
function rediobtn(parses)
{
	if (parseInt(parses)==1)
	{
		document.getElementById('cycle1').style.display="none";
		document.getElementById('cycle2').style.display="none";
		document.getElementById('cycle3').style.display="none";
		document.getElementById('cycle4').style.display="none";
		document.getElementById('cycle5').style.display="";
		document.getElementById('cycle6').style.display="";
		document.getElementById('cycle7').style.display="";
		document.getElementById('cycle8').style.display="";
		document.getElementById('addtr').style.display="none";
	}
	else
	{
		document.getElementById('cycle1').style.display="";
		document.getElementById('cycle2').style.display="";
		document.getElementById('cycle3').style.display="";
		document.getElementById('cycle4').style.display="";
		document.getElementById('cycle5').style.display="none";
		document.getElementById('cycle6').style.display="none";
		document.getElementById('cycle7').style.display="none";
		document.getElementById('cycle8').style.display="none";
		document.getElementById('addtr').style.display="";
	}
}




