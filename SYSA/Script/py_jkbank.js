
function ask()
{
try{
	var val=document.getElementById('ck').value;
	var bt=document.getElementById('bt');
	if (val=="")
	{
		document.getElementById('bt').innerHTML="必填"
		return false;
	}
	else
	{
		return true;
	}
	}
	catch(e1)
	{}
}
function getbz()
{
try{
var ck = document.getElementsByName('ck')[0]
var id = 'bz_'+ck[ck.selectedIndex].value;
var ye = ck[ck.selectedIndex].title;
document.getElementById('bzdiv').innerHTML = document.getElementById(id).innerHTML
document.getElementById('yefn').innerHTML = ye
}
catch(e1){}
}
window.onload= function()
{
getbz()
}
if(window.opener)window.opener.location.reload();
