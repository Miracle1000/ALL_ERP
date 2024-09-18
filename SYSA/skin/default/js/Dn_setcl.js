function setChecks(obj){
	if($(obj).val()=="0"){
		$("input[name='designstatus']").attr("checked" , $(obj).attr("checked"));
	}else{
		if ($(obj).attr("checked")==false){
			$("input[value='0']").attr("checked",false);
		}
	}
}