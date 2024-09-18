
function ask1(parse1)
{
	var iss_type=document.getElementsByName('iss_type');
	var iss_company=document.getElementsByName('iss_company');
	var iss_startime=document.getElementsByName('iss_startime');
	var iss_endtime=document.getElementsByName('iss_endtime');
	if(iss_type.length==0)
	{
		alert('保险明细不能为空！');
		return false;
	}
	for(i=0;i<iss_type.length;i++)
	{
		if (iss_type[i].value=="")
		{
			alert('保险险种不能为空！');
			return false;
		}
	}
	for(i=0;i<iss_company.length;i++)
	{
		if (iss_company[i].value=="")
		{
			alert('保险公司不能为空！');
			return false;
		}
	}
	for(i=0;i<iss_startime.length;i++)
	{
		if (iss_startime[i].value=="" || iss_startime[i].value=='点击选择时间')
		{
			alert('投保时间不能为空！');
			return false;
		}
	}
	for(i=0;i<iss_endtime.length;i++)
	{
		if (iss_endtime[i].value=="" || iss_endtime[i].value=='点击选择时间')
		{
			alert('结束时间不能为空！');
			return false;
		}
	}
	for(i=0;i<iss_startime.length;i++)
	{
		var d1 = new Date(iss_startime[i].value.replace(/\-/g,"/"))
		var d2 = new Date(iss_endtime[i].value.replace(/\-/g,"/"))
		if (d1.getTime()-d2.getTime()>=0)
		{
			alert('开始时间不能大于结束时间！');
			return false;
		}
	}
	document.demo.action='Save_insure.asp?parse1='+parse1;
	return true;
}
function setcarid(id,name)
{
	document.getElementById('iss_carname').value=name;
	document.getElementById('iss_carname').style.color="black";
	document.getElementById('iss_carid').value=id;
	
}
function batch(parse1)
{
	var pvalue=document.getElementById(parse1).value;
	if (parse1=='isscompany')
	{parse1='iss_company';}
	else if (parse1=='issmoney')
	{parse1='iss_money';}
	else if (parse1=='isswarn')
	{parse1='iss_warn';}
	
	var plist=document.getElementsByName(parse1);
	for (i=0;i<plist.length;i++)
	{
		plist[i].value=pvalue;
	}
}
