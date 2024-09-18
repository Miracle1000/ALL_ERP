
function xmldata1(ord)
{
	var dhtml=document.getElementById('dhtml');
	var url="selgl1.asp?dd=1&ord="+ord+"&timeStamp="+escape(window.nowTime);
	xmlHttp.open("GET",url,false);
	//xmlHttp.onreadystatechange=updatepage;
	xmlHttp.send();	
	updatepage();
}
function xmldata2(ord)
{
	var dhtml=document.getElementById('dhtml1');
	var url="selgl4.asp?ord="+ord;
	xmlHttp.open("GET",url,false);
	//xmlHttp.onreadystatechange=updatepage1;
	xmlHttp.send();	
	updatepage1();
}
function updatepage1()
{
	if(xmlHttp.readyState==4)
	{
		
		var response = xmlHttp.responseText;
		var re1=response.indexOf('</noscript>');
		var re2=response.length;
		ajaxhtml=response.substring(re1+11,re2);
		document.getElementById('dhtml').innerHTML=ajaxhtml;
		var left=parseInt(event.clientX)-500;
		var top=event.clientY+document.body.scrollTop;
		var htmlheight=document.body.offsetHeight;
		var scrollheight=window.screen.availHeight;
		if(htmlheight-event.clientY<300)
		{
			top=htmlheight-300+document.body.scrollTop;
		}
		document.getElementById('dhtml').style.top=top+"px";
		document.getElementById('dhtml').style.left=left+"px";
		document.getElementById('dhtml').style.display='block';
		updatePage3();
	}
}

function updatepage()
{
	if(xmlHttp.readyState<4)
	{
			
	}
	if(xmlHttp.readyState==4)
	{
		
		var response = xmlHttp.responseText;
		var re1=response.indexOf('</noscript>');
		var re2=response.length;
		ajaxhtml=response.substring(re1+11,re2);
		document.getElementById('dhtml').innerHTML=ajaxhtml;
		var left=parseInt(event.clientX)-500;
		var top=event.clientY+document.body.scrollTop;
		var htmlheight=document.body.offsetHeight;
		var scrollheight=window.screen.availHeight;
		if(htmlheight-event.clientY<500)
		{
			top=htmlheight-500+document.body.scrollTop;
		}
		document.getElementById('dhtml').style.top=top+"px";
		document.getElementById('dhtml').style.left=left+"px";
		document.getElementById('dhtml').style.display='block';
		updatePage3();
	}
}
function updatePage3()
{
	xmlHttp.abort();
}
function hidelabel()
{	
	document.getElementById('dhtml').style.display='none';
}
function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=20;
}
function test()
{
  if(!confirm('确认删除吗？')) return false;
}
 
function mm()
{
   var a = document.getElementsByTagName("input");
   var b=document.getElementById("chkall");
   if(b.checked==true)
	{
   		for (var i=0; i<a.length; i++)
		{
      		if (a[i].type == "checkbox")
			{ a[i].checked = true;}
		}
   }
   else
   {
   		for (var i=0; i<a.length; i++)
		{
      		if (a[i].type == "checkbox")
			{a[i].checked = false;}
		}
   }
}
