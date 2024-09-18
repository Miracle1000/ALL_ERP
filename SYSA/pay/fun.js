// JavaScript Document

function getSumMoney()
{
	var moneyobj=document.getElementsByTagName("input");
	var moneyall=0;
	for(var i=0;i<=moneyobj.length;i++)
	{
		try
		{
			if(moneyobj[i].name.indexOf("money_")==0)
			{
				if(!isNaN(moneyobj[i].value)&&moneyobj[i].value!='')	moneyall=accAdd(parseFloat(moneyall),parseFloat(moneyobj[i].value));
			}
		}
		catch(e1)
		{}
	}
	return moneyall;
}
function getSumNum()
{
	var moneyobj=document.getElementsByTagName("input");
	var moneyall=0;
	for(var i=0;i<=moneyobj.length;i++)
	{
		try
		{
			if(moneyobj[i].name.indexOf("num_")==0)
			{
				if(!isNaN(moneyobj[i].value)&&moneyobj[i].value!='')	moneyall+=parseFloat(moneyobj[i].value);
			}
		}
		catch(e1)
		{}
	}
	return moneyall;
}
function changetype()
{
	var type=document.getElementById("jktype").value;
	if(type=="1")
	{
		var Tdbtarr=document.all("Tdbt");
		for(i=0;i<Tdbtarr.length;i++)
		{
			Tdbtarr[i].style.display='none';
		}
		var Tddjarr=document.all("Tddj");
		for(i=0;i<Tddjarr.length;i++)
		{
			Tddjarr[i].style.display='none';
		}
	}
	else if(type=="2")
	{
		var Tdbtarr=document.all("Tdbt");
		for(i=0;i<Tdbtarr.length;i++)
		{
			Tdbtarr[i].style.display='block';
		}
		var Tddjarr=document.all("Tddj");
		for(i=0;i<Tddjarr.length;i++)
		{
			Tddjarr[i].style.display='block';
		}
	}
}

//验证费用文本框不允许填非数字并且不允许小于0
function yanZheng(src) {
    isNaN(src.value) ? src.value = 0 : src.value;
    src.value.indexOf("-") > -1 ? src.value = 0 : src.value;
}
