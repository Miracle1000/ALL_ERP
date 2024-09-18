var ListAction = {
	DoDel:function(id){
		var s = confirm("确认删除？");
		if (!s){
			return false;
		}
		ajax.regEvent("DoDel");
		ajax.addParam("id",id);
		var v = ajax.send();
		if (v == "true"){
			window.DoRefresh();
		}
	},
	DoDelClose:function(id){
		var s = confirm("确认删除？");
		if (!s){
			return false;
		}
		ajax.regEvent("DoDel");
		ajax.addParam("id",id);
		var v = ajax.send();
		if (v == "true"){
			window.close();
			if(opener){
				opener.window.DoRefresh();
			}
		}
	}
}