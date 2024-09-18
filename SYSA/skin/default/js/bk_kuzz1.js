var ListAction = {
	DoHF:function(id){
		var s = confirm("确认恢复？");
		if (!s){
			return false;
		}
		ajax.regEvent("DoHF");
		ajax.addParam("id",id);
		var v = ajax.send();
		if (v == "true"){
			window.DoRefresh();
		}
	},
	DoDel:function(id){
		var s = confirm("您选择的是彻底删除，删除后不能再恢复，确认删除？");
		if (!s){
			return false;
		}
		ajax.regEvent("DoDel");
		ajax.addParam("id",id);
		var v = ajax.send();
		if (v == "true"){
			window.DoRefresh();
		}
	}
	,
	DoDelAll:function(id){
		var s = confirm("确认清空本回收站里的所有内容？");
		if (!s){
			return false;
		}
		ajax.regEvent("DoDelAll");
		var v = ajax.send();
		if (v == "true"){
			window.DoRefresh();
		}
	}
}