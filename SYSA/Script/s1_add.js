
function ask(bc)
{ 
	document.all.date.action = "save.asp?bc="+bc;
}

function shDiv(divid,pdivid)
{
	document.getElementById(pdivid).className=document.getElementById(pdivid).className=="menu3"?"menu4":"menu3"
	document.getElementById(divid).style.display=document.getElementById(divid).style.display=='none'?'block':'none';
}

function showCK(objid)
{
	if(!document.getElementById("ckr_"+objid).disabled) document.getElementById("ckr_"+objid).checked=true;
}

function CheckSort()
{
	var ckobj=document.getElementsByName("cksort");
	for(var i=0;i<ckobj.length;i++)
	{
		if(ckobj[i].checked) return true;
	}
	alert("请选择仓库分类");
	return false;
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
//-->
