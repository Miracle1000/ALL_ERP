function checkselection(){
    if (document.getElementById("delperson1") && document.getElementById("delperson2")) {
        if (!document.getElementById("delperson1").disabled) {
            if (!(document.getElementById("delperson1").checked) && !(document.getElementById("delperson2").checked)) {
                alert("请选择是否删除付款单！");
                return false;
            }
        }
    }
    if (document.getElementById("delinvoice1") && document.getElementById("delinvoice2"))
    {
        if (!document.getElementById("delinvoice1").disabled) {
            if(!(document.getElementById("delinvoice1").checked)&&!(document.getElementById("delinvoice2").checked))
            {
                alert("请选择是否删除收票单！");
                return false;
            }
        }
    }
    if (document.getElementById("delkuin1") && document.getElementById("delkuin2")) {
        if (!document.getElementById("delkuin1").disabled) {
            if (!(document.getElementById("delkuin1").checked) && !(document.getElementById("delkuin2").checked)) {
                alert("请选择是否删除入库单！");
                return false;
            }
        }

    }
	return true;
}