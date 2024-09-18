
function checkw3()
{
	var fw=$("input[name=allcansee][checked]").val();
	var w1=$("input[name=W1][checked]").val();
	var w2=$("input[name=W2][checked]").val();
	var w3=$("input[name=W3][checked]").val();
	if(fw==undefined||((fw==0&&w1==undefined)&&(fw==0&&w3==undefined)))
	{
		alert("请选择被考核人员！");
		return false;
	}
	return true;
}
