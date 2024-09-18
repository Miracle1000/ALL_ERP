
function share_CancelPerson(divid,str_id2)
{
	if (!document.getElementById(divid).checked)
	{
		var divobj=document.getElementById(str_id2);
		var docObj=divobj.getElementsByTagName("input");
		//alert(docObj.length);
		for(var i=0;i<docObj.length;i++)
		{
			docObj[i].fireEvent("onClick");
		}
	}
}
function share_ShowPerson(str_id,str_name)
{
	if (document.getElementById(str_id).checked)
	{
		document.getElementById('sharer').innerHTML=document.getElementById('sharer').innerHTML+"&nbsp;&nbsp;"+str_name;
	}
	else
	{
		var str_rs=document.getElementById('sharer').innerHTML;
		document.getElementById('sharer').innerHTML=str_rs.replace("&nbsp;&nbsp;"+str_name,"");
	}
}
