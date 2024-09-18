
function selectperson(typeid)
{
	if(document.getElementById("jx").checked==true)
	{
		if(document.getElementById("nextoperator").value=="0")
		{
			document.getElementById("ts").innerHTML="请选择处理人员";
			return false;
		}
	}
	else
	{
		if (typeid=="2")
		{
			if(document.getElementById("result").value=="0")
			{
				document.getElementById("ts1").innerHTML="请选择处理结论";
				return false;
			}
		}
	}
	return true;
}

function checkResult(resultID,typeID){
	if (resultID==1)
	{
		document.getElementById('nextoperator').style.display='';document.getElementById('bt').style.display='';document.getElementById('ts').style.display='';
		if (typeID=="2")
		{
			document.getElementById('result').style.display='none';document.getElementById('bt1').style.display='none';document.getElementById('ts1').style.display='none';	
		}
	}
	else if (resultID==2)
	{
		document.getElementById('nextoperator').style.display='none';document.getElementById('bt').style.display='none';document.getElementById('ts').style.display='none';
		if (typeID=="2")
		{
			document.getElementById('result').style.display='';document.getElementById('bt1').style.display='';document.getElementById('ts1').style.display='';	
		}
	}
}
