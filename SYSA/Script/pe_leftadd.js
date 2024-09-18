
$=function (id) { return (typeof (id)=='object')?id:document.getElementById(id); }
var xmlHttpNode = false;
try 
{
  xmlHttpNode = new ActiveXObject("Msxml2.XMLHTTP");
} 
catch (e) 
{
  try 
  {
    xmlHttpNode = new ActiveXObject("Microsoft.XMLHTTP");
  } 
  catch (e2) 
  {
    xmlHttpNode = false;
  }
}
if (!xmlHttpNode && typeof XMLHttpRequest != 'undefined') 
{
  xmlHttpNode = new XMLHttpRequest();
}

function getChildNodes(pid,cname,px_1,topid,lt)
{
	if($("a"+pid)!=null)
	{
		if($("a"+pid).cells[0].innerHTML.length==0)
		{
		  var url = "../inc/getChildNodes.asp?pid="+pid+"&l="+cname+"&px_1="+px_1+"&top="+topid+"&lt="+lt+"&"+Math.round(Math.random()*100);
		  xmlHttpNode.open("GET", url, false);
		  xmlHttpNode.setRequestHeader("If-Modified-Since","0");
		  xmlHttpNode.onreadystatechange = function(){
			  if (xmlHttpNode.readyState == 4) 
			  {
			    var tmpstr=xmlHttpNode.responseText;
			    var outstr=tmpstr.substring(tmpstr.lastIndexOf("</noscript>")+11,tmpstr.length-1);
			    $("a"+pid).cells[0].innerHTML = outstr;
			    if(outstr.length>59)
			    {
			    	$("a"+pid).style.display="";
			    	$("b"+pid).className="menu2";
			  	}
					xmlHttpNode.abort();
			  }
			}
		  xmlHttpNode.send(null);  
		}
	}
	else
	{
	  var url = "../inc/getChildNodes.asp?pid="+pid+"&l="+cname+"&px_1="+px_1+"&top="+topid+"&lt="+lt+"&"+Math.round(Math.random()*100);
	  xmlHttpNode.open("GET", url, false);
	  xmlHttpNode.setRequestHeader("If-Modified-Since","0");
	  xmlHttpNode.onreadystatechange = function(){
		  if (xmlHttpNode.readyState == 4) 
		  {
		    var tmpstr=xmlHttpNode.responseText;
		    var outstr=tmpstr.substring(tmpstr.lastIndexOf("</noscript>")+11,tmpstr.length-1);
		    $("cp_search").innerHTML = outstr;
				xmlHttpNode.abort();
		  }
		}
	  xmlHttpNode.send(null);  
	}
}
