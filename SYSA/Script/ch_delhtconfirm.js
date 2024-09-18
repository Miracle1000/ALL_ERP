
function checkselection()
{
	if(!(document.getElementById("delperson1").checked)&&!(document.getElementById("delperson2").checked))
	{
		alert("请选择是否删除收款单！");
		return false;
	}
	else return true;
}
