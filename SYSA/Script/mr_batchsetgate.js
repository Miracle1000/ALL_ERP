
function setNum(obj,stype)
{
	var num4=obj.value;
	if (!isNaN(num4))
	{
		if ( num4.length>0){num4 = parseFloat(num4);}
		obj.value=num4;
		var strName="num4"
		if (stype==1){strName="numly"}
		$("input[name="+strName+"]").val(num4);
	}
}
function setAll(ord,stype)
{
	var ordlist = "";
	if (ord=="0")
	{
		$("input[name=gateord]").each(function()
			{
				if (ordlist.length>0){ordlist += ",";}
				ordlist +=$(this).val();
			}
		)
		if (ordlist.length==0)
		{
			alert("没有选择批量设置人员！")
			return false;
		}
	}
	var openUrl = "" ; 
	switch(stype)
	{
	case 0:
		openUrl = "../manager/set_telapply.asp?ord="+ord+"&ordlist="+ordlist+"&addact=close";
		break;
	default:
		openUrl = "../manager/set_sort5back.asp?ord="+ord+"&ordlist="+ordlist+"&sort="+stype+"&addact=close";
		break;
	}
	window.open(openUrl,'newbatch','width=' + 800 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=0,left=340,top=145');
}
