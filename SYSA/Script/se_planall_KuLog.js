
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
eval(targ+".location=\'"+selObj.options[selObj.selectedIndex].value+"\'");
if (restore) selObj.selectedIndex=0;
}

function close1()
{
	$('#dd').dialog('close');
}
//-->

function shDiv(divid,pdivid)
{
	document.getElementById(pdivid).className=document.getElementById(pdivid).className=="menu3"?"menu4":"menu3"
	document.getElementById(divid).style.display=document.getElementById(divid).style.display=='none'?'block':'none';
}

function checkScroll(obj)
{
	obj.doScroll(event.wheelDelta<0?"down":"up");
	event.cancelBubble=true;
	return false;
}

function checkMe(obj)
{
	var ckdiv=document.getElementById("scks");
	var dvpid="ckid_"+obj.value;
	var dvobj=ckdiv.getElementsByTagName("DIV");
	for(var i=0;i<dvobj.length;i++)
	{
		if(dvobj[i].pid==dvpid)
		{
			var tgobj=dvobj[i].getElementsByTagName("INPUT");
			for(var j=0;j<tgobj.length;j++)
			{
				tgobj[j].checked=obj.checked;
			}
			break;
		}
	}
	event.cancelBubble=true;
	return false;
}

function checkALL(obj)
{
	var dvobj=document.getElementById("scks");
	var chkobj=dvobj.getElementsByTagName("INPUT");
	for(var i=0;i<chkobj.length;i++)
	{
		if (chkobj[i].checked!=obj.checked)
		{
			chkobj[i].click();
		}
		chkobj[i].checked=obj.checked;
	}
}
