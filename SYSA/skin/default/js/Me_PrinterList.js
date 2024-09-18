//删除模板
function doDel(id){
	if(id!=""){
		if(confirm("确定删除?")){
			ajax.regEvent("doDel");
			ajax.addParam("id", id);			
			var r = ajax.send();		
			 if(r=="1"){
					lvw_refresh("mlistvw");	//刷新列表
			 }else{
				app.Alert("删除失败！");
			 }
		}
	}
}

//启用停用模板
function doSetUse(status, id){
	if(id!=""){
		var ztStr = "";
		if(status == 0){
			ztStr = "启用";
		}else if(status == 1){
			ztStr = "停用";
		}
		if(confirm("确定"+ztStr+"?")){
			ajax.regEvent("doSet");
			ajax.addParam("id", id);	
			ajax.addParam("status", status);		
			var r = ajax.send();		
			 if(r=="1"){
					lvw_refresh("mlistvw");	//刷新列表
			 }
		}
	}
}



