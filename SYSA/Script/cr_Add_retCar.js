
function ask()
{
	var mxid=document.getElementsByName('mxid');
	var use_rettime=document.getElementsByName('use_rettime');
	var use_retcateid=document.getElementsByName('use_retcateid');
	if(mxid.length==0)
	{
		alert('没有明细，不能返还');
		return false;
	}
	for (i=0;i<use_rettime.length;i++)
	{
		if(use_rettime[i].value=="" || use_rettime[i].value=="点击选择时间")
		{
			alert('返还时间不能为空');
			return false;
		}else{
			var use_time = $(use_rettime[i]).parentsUntil('tr').last().prev().prev().text().substring(0,19);
			var ret_time = use_rettime[i].value;
			var date_use = new Date(Date.parse(use_time.replace(/-/g, "/")));
			var date_ret = new Date(Date.parse(ret_time.replace(/-/g, "/")));
			if (date_ret.getTime() < date_use.getTime()){
				alert('返还时间必须大于申请开始时间');
				return false;
			}
		}
	}
	for (i=0;i<use_retcateid.length;i++)
	{
		if(use_retcateid[i].value=="")
		{
			alert('返还人员不能为空');
			return false;
		}
	}
	var arrlist=document.getElementsByTagName("input");
	for(i=0;i<arrlist.length;i++)
	{
		if (arrlist[i].type=="text" || arrlist[i].type=="hidden")
		{
			if(arrlist[i].value=="" && (!arrlist[i].onpropertychange))
			{ 
				arrlist[i].value="$^&1&*$";
			}
			if(arrlist[i].value.indexOf(", ")>=0 && (!arrlist[i].onpropertychange))
			{ 
				arrlist[i].value=arrlist[i].value.replace(/,\s/g,"^#$6a");
			}
		}
	}
	
	return true;
}
function del_TR(id)
{
	try{
	var tr=document.getElementById(id);
	tr.parentNode.removeChild(tr);
	}
	catch(e){}
}
