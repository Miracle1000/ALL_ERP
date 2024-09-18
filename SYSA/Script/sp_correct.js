
function resumeCheckbox()
{
	var obj= document.getElementsByTagName("input");
	for (i=0, count= obj.length; i< count; i++)
	{
		if(obj[i].type=='checkbox'&&obj[i].disabled)
		{
			obj[i].disabled=false;
		}
	}
	return true;
}
function setHid()
{
	try
	{
	document.getElementById('hidden1').style.display='none'
	document.getElementById('hidden2').style.display='none'
	document.getElementById('hidden3').style.display='none'
	}
	catch(e){}
}
function setHid1()
{
	try
	{
	document.getElementById('hidden1').style.display=''
	document.getElementById('hidden2').style.display=''
	document.getElementById('hidden3').style.display=''
	}catch(e){}
}
