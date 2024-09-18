
<!--
function Check()
{   
	var b2 = document.form1.sort1.value.toLowerCase();
	if (b2.length<=0)
	{
		window.alert("分类名不可为空");
		return false;
	}
 	return true;
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
	if(document.getElementById("sttp").checked)
	{
		var ckobj=document.getElementsByName("cksort");
		for(var i=0;i<ckobj.length;i++)
		{
			if(ckobj[i].disabled!=true&&ckobj[i].checked) return true;
		}
		alert("请选择上级分类");
		return false;
	}
	else
	{
		return true;
	}
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

function chgtp(flg)
{
	var objs=document.getElementById("leftmenuall").getElementsByTagName("input");
	for(var i=0;i<objs.length;i++)
	{
		if(objs[i].type=="radio"&&objs[i].cld=="123")
		{
			if(flg) objs[i].checked=false;
			objs[i].disabled=flg;
		}
	}
}
//-->
