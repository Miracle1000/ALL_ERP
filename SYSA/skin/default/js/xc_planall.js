function selectall(box) {
	$("input:checkbox[name=sys_lvw_ckbox]").attr("checked",$(box).attr("checked"));
}

function batDel(tip) {	//批量删除
	var selectid = "";
	var noDelID = 0;
	$("input:checkbox[name=sys_lvw_ckbox][checked]").each(function(){
		if(selectid==""){
			selectid += $(this).val();
		}else{
			selectid += "," + $(this).val();
		}
    }); 

	if(selectid == ""){
		app.Alert("您没有选择任何产品，请选择后再"+ tip +"！");
	}else{		
		if(confirm("确定要"+ tip +"吗？")){
			ajax.regEvent("delCPTCSet");
			ajax.addParam("ord", selectid);
			var r = ajax.send();
			if(r=="0"){	
				app.Alert("您没有选择任何产品，请选择后再"+ tip +"！");
			}else if(r=="1"){				
				lvw_refresh("mlistvw");	//刷新列表
			}
		}
	}
}

//取消产品提成设置
function delCPTCSet(cpord,tip){
	if(cpord!=""){
		if(confirm("确定"+ tip +"?")){
			ajax.regEvent("delCPTCSet");
			ajax.addParam("ord", cpord);			
			var r = ajax.send();		
			if(r=="0"){
				app.Alert("您没有选择任何产品，请选择后再"+ tip +"！");
			}else if(r=="1"){
				lvw_refresh("mlistvw");	//刷新列表
			}
		}
	}
}



