
function delStoreHC(cpmxid)
{
	var url="delStoreHC.asp?cpmxid="+escape(cpmxid)+"&stamp=" + (Math.random()*10).toString().replace(".","");
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
}

function saveHC(ckid,cpmxid,tindex,kuinlistid)
{
	var hcnum=document.getElementById("backnum_"+ckid).value;
	var kuinnum=document.getElementById("num"+tindex).value;
	if(hcnum==""||isNaN(hcnum))
	{
		alert("对冲数量不合法");
		return false;
	}
	if(kuinnum==""||isNaN(kuinnum))
	{
		alert("对冲数量不合法");
		return false;
	}
	var hcnumobj=document.getElementsByName("backnum");
	var sumhcnum=0;
	for(var i=0;i<hcnumobj.length;i++)
	{
		sumhcnum+=hcnumobj[i].value==""?0:parseFloat(hcnumobj[i].value);
	}
	if(parseFloat(sumhcnum)>parseFloat(kuinnum))
	{
		alert("对冲数量不能大于入库数量");
		return false;
	}
	var url="SaveStoreHC.asp?ckid="+ckid+"&cpmxid="+escape(cpmxid)+"&hcnum="+escape(hcnum)+"&kuinlist="+kuinlistid+"&stamp=" + (Math.random()*10).toString().replace(".","");
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState == 4)
	  {
	    var response = xmlHttp.responseText.split("</noscript>")[1];
	    if(response=="成功!")
	    {
	    	document.getElementById("backnum_"+ckid).style.bgcolor="green";
	    }
	    else
	    {
	    	alert(response);
	    }
			xmlHttp.abort();
	  }
	};
  xmlHttp.send(null);
}

function showStore(obj,tindex,kuinlistid)
{
	var x=obj.offsetLeft,y=obj.offsetTop;
	var obj2=obj;
	var offsetx=25;
	while(obj2=obj2.offsetParent)
	{
		x+=obj2.offsetLeft;
		y+=obj2.offsetTop;
	}
	var showobj=document.getElementById("showhc");
	var hcdivobj=document.getElementById("hcdiv");
	hcdivobj.style.display="block";
	showobj.innerHTML="";
	hcdivobj.style.left=offsetx+x+"px";
	hcdivobj.style.top=y-5+"px";

  var url = "getStoreHC.asp?ord="+escape(obj.id.replace("Minus_",""))+"&unit="+document.getElementById("unit"+tindex).value+"&tindex="+tindex+"&kuinlist="+kuinlistid+"&stamp=" + (Math.random()*10).toString().replace(".","");
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState < 4)
	  {
			showobj.innerHTML="loading...";
	  }
	  if (xmlHttp.readyState == 4)
	  {
	    var response = xmlHttp.responseText;
			showobj.innerHTML=response;
			xmlHttp.abort();
	  }
  };
  xmlHttp.send(null);

	addEvent(document.body,"mousedown",clickOther)
}

function addEvent(obj,eventType,func){
	if(obj.attachEvent){obj.attachEvent("on" + eventType,func);}
	else{obj.addEventListener(eventType,func,false)}
	}
function delEvent(obj,eventType,func){
	if(obj.detachEvent){obj.detachEvent("on" + eventType,func)}
	else{obj.removeEventListener(eventType,func,false)}
	}
function clickOther(el){
	thisObj = el.target?el.target:event.srcElement;
	do{
		if(thisObj.id == "hcdiv") return;
		if(thisObj.tagName == "BODY"){
			hidemenu();
			return;
			};
		thisObj = thisObj.parentNode;
	}while(thisObj.parentNode);
}

function hidemenu(){
 var obj=document.getElementById("hcdiv");
 delEvent(document.body,"mousedown",showStore);
 obj.style.display='none';
}
