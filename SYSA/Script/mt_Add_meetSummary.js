

function ask()
{
	var sum_metid=document.getElementById('sum_metid').value;
	if (sum_metid=="" || sum_metid=="0")
	{
		document.getElementById('test2').innerHTML="*必填"
		return false;
	}
	return true;
}
function rediobtn(parse1,parse2)
{
	if (parseInt(parse2)==1)
	{
		document.getElementById(parse1).style.display='none';
	}
	else
	{
		document.getElementById(parse1).style.display='';
	}
}
function checkboxbth(parse1,parse2)
{
	var Lists=document.getElementsByName(parse1);
	var test=document.getElementById(parse2);
	for(i=0;i<Lists.length;i++)
	{
		if (test.value=="全选")
		{
			Lists[i].checked=true;
		}
		else
		{
			Lists[i].checked=false;
		}
	}
	if (test.value=="全选")
	{
		test.value="取消";
	}
	else
	{
		test.value="全选";
	}
}
