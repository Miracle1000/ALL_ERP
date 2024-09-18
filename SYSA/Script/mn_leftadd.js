
$=function (id) { return (typeof (id)=='object')?id:document.getElementById(id); }
function ajaxSubmit_page(sort1,pagenum,callback,isadsearch)
{
	//获取用户输入
	var B=document.forms[0].B.value;
	var C=(document.forms[0].C.value==$("txtKeywords").defaultValue?"":document.forms[0].C.value);
	var top=document.forms[0].top.value;
	var url = "search_cp.asp?P="+pagenum+"&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	if(event==null|| (event.srcElement && event.srcElement.getAttribute("ads")) ||isadsearch==1){
	{
		//处理高级搜索
		var ifcobj=document.getElementById("adsIF").contentWindow.document;
		var sobj=ifcobj.getElementsByTagName("input");
		var txValue="";
		for(var i=0;i<sobj.length;i++)
		{
			if(sobj[i].getAttribute("sk")&&sobj[i].type=='text'&&sobj[i].value!='')
			{
				txValue+=(txValue==""?"":"&")+sobj[i].getAttribute("sk")+"="+escape(sobj[i].value);
			}
		}
		sobj=ifcobj.getElementsByTagName("select");
		for(var i=0;i<sobj.length;i++)
		{
			if(sobj[i].getAttribute("sk")&&sobj[i].value!='')
			{
				txValue+=(txValue==""?"":"&")+sobj[i].getAttribute("sk")+"="+escape(sobj[i].value);
			}
		}
		sobj=ifcobj.getElementsByName("A2");
		var tmp="";
		for(var i=0;i<sobj.length;i++)
		{
			if(sobj[i].checked)
			{
				tmp+=(tmp==""?"":",")+escape(sobj[i].value);
			}
		}
		txValue+=(tmp==""?"":(txValue==""?"":"&")+"A2="+tmp)
		url="search_cp.asp?ads=1"+(txValue==""?"":"&")+txValue+"&P="+pagenum+"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	}
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		updatePage_cp();
	};
	xmlHttp.send(null);  
}

var xmlHttpNode = GetIE10SafeXmlHttp();
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
		  var url = "getChildNodes.asp?pid="+pid+"&l="+cname+"&px_1="+px_1+"&top="+topid+"&lt="+lt+"&"+Math.round(Math.random()*100);
		  xmlHttpNode.open("GET", url, false);
		  xmlHttpNode.setRequestHeader("If-Modified-Since","0");
		  xmlHttpNode.onreadystatechange = function(){
			  if (xmlHttpNode.readyState == 4) 
			  {
			    var tmpstr=xmlHttpNode.responseText;
			    var outstr=tmpstr;
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
	  var url = "getChildNodes.asp?pid="+pid+"&l="+cname+"&px_1="+px_1+"&top="+topid+"&lt="+lt+"&"+Math.round(Math.random()*100);
	  xmlHttpNode.open("GET", url, false);
	  xmlHttpNode.setRequestHeader("If-Modified-Since","0");
	  xmlHttpNode.onreadystatechange = function(){
		  if (xmlHttpNode.readyState == 4) 
		  {
		    var tmpstr=xmlHttpNode.responseText;
		    var outstr=tmpstr;
		    $("cp_search").innerHTML = outstr;
				xmlHttpNode.abort();
		  }
		}
	  xmlHttpNode.send(null);  
	}
}

function Left_adSearch(obj)
{
	var sdivobj=document.getElementById("adsDiv");
	if(sdivobj.style.display!="none")
	{
		Left_adClose();
	}
	else
	{
		var x=obj.offsetLeft,y=obj.offsetTop;
		var obj2=obj;
		var offsetx=0;
		while(obj2=obj2.offsetParent)
		{
			x+=obj2.offsetLeft;
			y+=obj2.offsetTop;
		}
		sdivobj.style.left=x+33+"px";
		sdivobj.style.top=y+"px";
		sdivobj.style.display="inline";
	}
	document.getElementById('adsIF').style.height=document.getElementById('adsIF').contentWindow.document.getElementsByTagName('table')[1].offsetHeight+30+'px';
}

function Left_adClose()
{
	document.getElementById('adsDiv').style.display="none";
}
