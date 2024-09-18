
$=function (id) { return (typeof (id)=='object')?id:document.getElementById(id); }
function ajaxSubmit_page(sort1,pagenum)
{
	//获取用户输入
	var B=document.forms[0].B.value;
	var C=(document.forms[0].C.value==$("txtKeywords").defaultValue?"":document.forms[0].C.value);
	var top=document.forms[0].top.value;
	var url = "../contract/search_cp.asp?P="+pagenum+"&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		updatePage_cp();
	};
	xmlHttp.send(null);  
}

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
function TxmAjaxSubmit(){
    //获取用户输入
    var TxmID=document.txmfrom.txm.value;
	if (TxmID.length ==0){return;}
	var top=document.txmfrom.top.value;
    var url = "../product/txmRK.asp?txm="+escape(TxmID)+"&top="+escape(top) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	updateTxm(top);
  };
  xmlHttp.send(null);  
}
function updateTxm(x1) {
  if (xmlHttp.readyState < 4) {
//	cp_search.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
	 var response = xmlHttp.responseText;
	// alert(response);
	response=response.split("</noscript>");
	//alert(response[1]);
	 if (response[1]!="")
	 {
		 callServer4(response[1],x1);
 		}
		else
		{
		alert("产品不存在");
		}
  }
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
