
function saveCPRemind(ord,input){
	if(ord!=""){
		var inpName = input.name;
		var inpValue = input.value;
		if(inpName != 'RemindPerson'){
			if(inpValue.length>15){
				app.Alert("请输入15位以内的数字");
				return;
			}else if(isNaN(inpValue)){
				app.Alert("请输入有效的数字");
				return;
			}
		}
		ajax.regEvent("saveCPRemind");
		$ap("ord",ord);
		$ap("actName",inpName);
		$ap(inpName,inpValue)
		var r = ajax.send();
		if(r != ""){
			if(r=="0"){
				app.Alert("请选择产品");
			}else if(r == "1"){
			}else{
				app.Alert("保存失败，请重试");
			}
		}
	}
}

function doCPSearch(){
	var searchKey = $ID("searchKey").value;
	var searchType = $ID("searchType").value;
	ajax.regEvent("showCPView");
	$ap("searchKey",searchKey)
	$ap("searchType",searchType)
	var r = ajax.send();
	if(r != ""){
		$ID("txcpView").innerHTML = r;
		parent.frameResize();
	}
}

window.onlistviewRefresh = function(){
	parent.frameResize();
}

