
function ask1(a)
{
	var cont = 0
	var tel1=$('#car_phone').val(); //固定电话
	var tel2=$('#car_mobile').val(); //移动电话
	var tel3=$('#car_mobile2').val(); //移动电话
	
	if(tel1 !="")
	{
		if(tel1==tel2)
			cont = cont + 1;
					
		if(tel1==tel3)
			cont = cont + 1;
	}
	if(tel2 !="")
	{
		if(tel3==tel2)
			cont = cont + 1;
	}
	
	if(cont>0)
	{
		alert('手机号码不能重复出现');
		return false;
	}
	if(a=="1")
		$('#tp').val("1");
	else
		$('#tp').val("2");
}
