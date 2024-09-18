
function Check()
{
	var b2 = document.form1.sort1.value.toLowerCase();
	var b9 = document.form1.gate1.value.toLowerCase();
	if (b2.length<=0)
    {
		window.alert("修改后不可为空");
		return false;
	}
 	return true;
}
function checkSLForm() {
    var minv = $("#ChargeMin").val() == "" ? 0 : $("#ChargeMin").val();
    var maxv = $("#ChargeMax").val() == "" ? 0 : $("#ChargeMax").val();
    flag = true;
    if ($("#IsOpenCharge2").is(":checked"))//开启手续费
    {
        if (parseFloat(minv) > parseFloat(maxv)) {
            $("#information").css("display", "");
            flag = false;
        } else {
            $("#information").css("display", "none");
        }
    }
    return flag;
}