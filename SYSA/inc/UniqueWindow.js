var sessiontype;
window.onbeforeunload=function ClearUniqueWindowSession(event)
{
	var clickJs = false;
	var event = event = window.event || event;
	var targHref = window.document.activeElement.href;
	var ie = ! -[1, ];
	if(ie && targHref != null && targHref.indexOf("javascript:void(0)")>=0)
	{
		 clickJs = true;
	}
	
	if(!clickJs) 
	{
		ClearSession(sessiontype);
	}
}

var xmlHttpobj = false;
try 
{
  xmlHttpobj = new ActiveXObject("Msxml2.XMLHTTP");
} 
catch (e) 
{
  try 
  {
    xmlHttpobj = new ActiveXObject("Microsoft.XMLHTTP");
  } 
  catch (e2) 
  {
    xmlHttpobj = false;
  }
}
if (!xmlHttpobj && typeof XMLHttpRequest != 'undefined') 
{
  xmlHttpobj = new XMLHttpRequest();
}

//清除服务器端的Session变量中保存的窗口状态值
function ClearSession(tindex)
{
  var url = "../inc/ClearSession.asp?t="+tindex+"&"+Math.round(Math.random()*100);
  xmlHttpobj.open("GET", url, false);
  xmlHttpobj.setRequestHeader("If-Modified-Since","0");
  xmlHttpobj.onreadystatechange = function(){
	  if (xmlHttpobj.readyState == 4) 
	  {
			xmlHttpobj.abort();
	  }
	}
  xmlHttpobj.send(null);  
}
