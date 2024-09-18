
function ask() { 
document.all.date.action = "save.asp?bc=1"; 
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
	if (expaned)
	{
		$(".tree-folder-open").each(function(){this.click()});
	}
	else
	{
		$(".tree-folder-closed").each(function(){this.click()});
	}
	expaned=!expaned;
}
