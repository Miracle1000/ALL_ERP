
function frameResize()
{
    var I2BodyScrollHeight = I2.document.documentElement.scrollHeight;
    if (I2BodyScrollHeight) { document.getElementById("cFF2").style.height = I2BodyScrollHeight + "px" } else { document.getElementById("cFF2").style.height = I2.document.body.scrollHeight + 0 + "px"; }
    document.getElementById("allStore").style.height = (I2BodyScrollHeight > 650 ? (I2BodyScrollHeight - 110) : 550) + "px";
    if (I2BodyScrollHeight) { parent.document.getElementById("cFF").style.height = document.documentElement.scrollHeight + 0 + "px"; }
}
function $(name){
	return document.getElementById(name);
}



function shDiv(divid,pdivid)
{
	document.getElementById(pdivid).className=document.getElementById(pdivid).className=="menu3"?"menu4":"menu3"
	document.getElementById(divid).style.display=document.getElementById(divid).style.display=='none'?'block':'none';
}

function showCK(sortid,tp)
{
	var p=tp?"ord="+sortid:"sort="+sortid;
	document.getElementById("cFF2").src="edit_ck.asp?"+p;
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
			divobjs[i].fireEvent('onclick');
		}
	}
	expaned=!expaned;
}

function searchSort(kvalue)
{
	var kbox = document.getElementById("allStore").contentWindow.document.getElementById("txtKeywords");
	kbox.value=kvalue;
	document.getElementById("allStore").contentWindow.doSearch();
	
}

window.refreshTree = function()
{
	document.getElementById("allStore").contentWindow.doSearch();
}
