function bill_onLoad(){
	var box = document.getElementsByName("MT4")[0]; //补料类型
	box.onpropertychange = function(){
		window.changeBoxValue(box);
	}
}

Bill.onRadioFieldClick = function(obj){
	var box = document.getElementsByName("MT4")[0]; //领料类型
	window.changeBoxValue(box);
}

window.changeBoxValue = function (box){	
	var td = document.getElementById("M_Field_5_1").previousSibling;
	if(box.value==1){
		td.innerHTML = "所属委外单："
	}
	else{
		td.innerHTML = "所属派工单："
	}
	if(event.propertyName=="value"){
		document.getElementsByName("MT5")[0].value = "";
		document.getElementsByName("MT6")[0].value = "";
		document.getElementsByName("MT7")[0].value = "";
		document.getElementsByName("MT8")[0].value = "";
		//document.getElementsByName("MT9")[0].value = "";
		//document.getElementsByName("MT10")[0].value = "";
		document.getElementsByName("MT11")[0].value = "";
		document.getElementsByName("MT12")[0].value = "";
		document.getElementById("M_Field_5_1").getElementsByTagName("button")[0].selid = box.value==1 ? 83 : 84
		Bill.RefreshDetail(true);
	}
	try {
	    document.getElementById("M_Field_5_1").getElementsByTagName("button")[0].selid = box.value == 1 ? 83 : 84
	} catch (e) { }
	return true
}