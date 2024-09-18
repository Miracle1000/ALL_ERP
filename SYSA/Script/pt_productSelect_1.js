
$=function (id) { return (typeof (id)=='object')?id:document.getElementById(id); }
function LVSelectProduct(pid)
{
	url="../store/addlistadd_rk.asp?lv=1&ord="+escape(pid)+"&t="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);
	var jsonobj=eval(xmlHttp.responseText);
	xmlHttp.abort();
	var cells = parent.lv.Rows.Add().Cells;
	var values=jsonobj.cklist;
	for(var i=0;i<parent.lv.Headers.length;i++)
	{
		if(i==1) cells[i].value=values[i].value;
		if(i<=1) continue;
		var cell=cells.Add();
		cell.text=values[i].text;
		cell.value=values[i].value;
		cell.datatype=values[i].datatype;
	}
	parent.lv.startIdx=parent.lv.Rows.length>parent.lv.RowsPerPage?parent.lv.Rows.length-parent.lv.RowsPerPage:0;
	parent.lv.RefreshContent();
	parent.lv.EditRow=parent.lv.Container.rows.length-3;
	parent.lv.RefreshContent();
	var mp=parent.document.getElementById("productselect");
	var pfm=parent.parent.document.getElementById("cFF");
	if(parseInt(mp.style.top)+parseInt(mp.offsetHeight)>parseInt(pfm.style.height)) pfm.style.height=parseInt(mp.style.top)+parseInt(mp.offsetHeight);
}

function ajaxSubmit_page(sort1,pagenum,callback,isadsearch)
{
	//获取用户输入
	var B=document.forms[0].B.value;
	var C=(document.forms[0].C.value==$("txtKeywords").defaultValue?"":document.forms[0].C.value);
	var top=document.forms[0].top.value;
	var url = "../contract/search_cp.asp?lv=1&P="+pagenum+"&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	if(event==null|| (event.srcElement && event.srcElement.getAttribute("ads")) ||isadsearch==1){
	{
		//处理高级搜索
		var ifcobj=document.getElementById("adsDiv");
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
		sobj=document.getElementsByName("A2");
		var tmp="";
		for(var i=0;i<sobj.length;i++)
		{
			if(sobj[i].checked)
			{
				tmp+=(tmp==""?"":",")+escape(sobj[i].value);
			}
		}
		txValue+=(tmp==""?"":(txValue==""?"":"&")+"A2="+tmp)
		url="../contract/search_cp.asp?lv=1&ads=1"+(txValue==""?"":"&")+txValue+"&P="+pagenum+"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	}

	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_cp()};
	xmlHttp.send(null);  
}
function updatePage_cp()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		cp_search.innerHTML=response;
		xmlHttp.abort();
	}
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

function TxmAjaxSubmit()
{
	//获取用户输入
	var TxmID=document.txmfrom.txm.value;
	if (TxmID.length ==0){return;}
	var url = "../product/txmRKnew.asp?txm="+escape(TxmID)+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){updateTxm(top);};
  xmlHttp.send(null);
}

function updateTxm(x1)
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		if (response!="")
		{
			LVSelectProduct(response);
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
		  var url = "../inc/getChildNodes.asp?pid="+pid+"&lv=1&l="+cname+"&px_1="+px_1+"&top="+topid+"&lt="+lt+"&"+Math.round(Math.random()*100);
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
	  var url = "../inc/getChildNodes.asp?pid="+pid+"&lv=1&l="+cname+"&px_1="+px_1+"&top="+topid+"&lt="+lt+"&"+Math.round(Math.random()*100);
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
