
function dislabel(sid)
{
	var left=parseInt(event.clientX)-500;
	var top=event.clientY;
	document.getElementById(sid).style.top=top+"px";
	document.getElementById(sid).style.left=left+"px";
	document.getElementById(sid).style.display='';

}

function xmldata1(ord)
{
	var dhtml=document.getElementById('dhtml');
	var url="selgl2.asp?ord="+ord;
	xmlHttp.open("GET",url,false);
	//xmlHttp.onreadystatechange=updatepage;
	xmlHttp.send();
	updatepage()
}
function updatepage()
{
	if(xmlHttp.readyState==4)
	{

		var response = xmlHttp.responseText;
		var re1=response.indexOf('</noscript>');
		var re2=response.length;
		ajaxhtml=response.substring(re1+11,re2);
		document.getElementById('dhtml').style.display='none';
		document.getElementById('dhtml').innerHTML=ajaxhtml;
		var left=parseInt(event.clientX)-500;
		var top = event.clientY + document.documentElement.scrollTop - 20;  //鼠标的y坐标
		var htmlheight = document.documentElement.clientHeight || document.body.clientHeight; //所打开当前网页，办公区域的高度，网页的高度
		var scrollheight = window.screen.availHeight; //整个windows窗体的高度
		var height = $("#dhtml").height()+ 20;
		if (htmlheight - event.clientY < height)
		{
		    top = top - (height - (htmlheight - event.clientY));
		    top = top > 0 ? top : 0;
		}
		document.getElementById('dhtml').style.top=top+"px";
		document.getElementById('dhtml').style.left=left+"px";
		document.getElementById('dhtml').style.display='';
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
