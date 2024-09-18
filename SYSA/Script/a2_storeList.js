function frameResize()
{
    document.getElementById("cFF2").style.height = I2.document.documentElement.scrollHeight + 0 + "px";
    document.getElementById("allStore").style.height = (I2.document.documentElement.scrollHeight > 650 ? (I2.document.documentElement.scrollHeight - 110) : 550) + "px";
    if (parent.document.getElementById("cFF")){
        parent.document.getElementById("cFF").style.height = document.documentElement.scrollHeight + 0 + "px";
    }
}
function $(name){
	return document.getElementById(name);
}

var xmlHttp = GetIE10SafeXmlHttp();

function shDiv(divid,pdivid)
{
	document.getElementById(pdivid).className=document.getElementById(pdivid).className=="menu3"?"menu4":"menu3"
	document.getElementById(divid).style.display=document.getElementById(divid).style.display=='none'?'block':'none';
}

function showCK(sortid,tp)
{
	var p=tp?"ord="+sortid:"sort="+sortid;
	document.getElementById("cFF2").contentWindow.document.location="edit_ck.asp?"+p;
}

var expaned=true;
function ExpandAll(obj)
{
	obj.innerHTML=expaned?"全部展开":"全部收缩";
	var divobjs=document.getElementById("leftmenuall").getElementsByTagName("div");
	for(var i=0;i<divobjs.length;i++)
	{
		if(divobjs[i].onclick&&divobjs[i].onclick.toString().indexOf('shDiv')>0&&((expaned&&divobjs[i+1].style.display!='none')||(!expaned&&divobjs[i+1].style.display=='none')))
		{
			divobjs[i].click();
			//divobjs[i].fireEvent('onclick');
		}
	}
	expaned=!expaned;
}

function searchSort(kvalue)
{
	var url="search_store.asp?kv="+escape(kvalue)+"&s="+new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function()
  {
		if (xmlHttp.readyState == 4)
		{
			document.getElementById("allStore").innerHTML=xmlHttp.responseText;
		}
  };
  xmlHttp.send(null);  
}
