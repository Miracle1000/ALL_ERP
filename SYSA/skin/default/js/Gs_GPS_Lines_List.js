var ListAction = {
	DoDel:function(id){
		var s = confirm("您确定要进行删除吗？");
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
		var s = confirm("您确定要进行删除吗？");
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
	},
	DoSave:function(input,num){
		document.getElementById('SubmitType').value = num;
		return bill.doSave(input);
	}
}