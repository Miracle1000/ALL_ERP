var v_TM6_old = 0;
var v_L_type = 0;
var v_change_ed = 0;
function bill_onLoad(){
	var box = document.getElementsByName("MT4")[0]; //领料类型
	v_TM6_old = document.getElementsByName("MT6")[0].value;
	v_L_type = box.value;
	box.onpropertychange = function (){	 
		window.changeBoxValue(box);
	}
}

Bill.onRadioFieldClick = function(obj){
	var box = document.getElementsByName("MT4")[0]; //领料类型
	window.changeBoxValue(box);
}

window.changeBoxValue = function (box){	
	var td = document.getElementById("M_Field_5_1").previousSibling;
	if (box.value == 1) {
		td.innerHTML = "所属委外单："
	}
	else {
		td.innerHTML = "所属派工单："
	}
	if (event.propertyName == "value") {
		if(v_L_type==box.value) {
			if(v_TM6_old>0) {
				if(v_change_ed==1) {
					window.location.href = window.location.href;
				}
				return;
			}
		}
		else{
			v_change_ed = 1;
		}
		document.getElementsByName("MT5")[0].value = "";
		document.getElementsByName("MT6")[0].value = "";
		document.getElementsByName("MT7")[0].value = "";
		document.getElementsByName("MT8")[0].value = "";
		document.getElementsByName("MT11")[0].value = "";
		document.getElementsByName("MT12")[0].value = "";
		try {
			document.getElementById("M_Field_5_1").getElementsByTagName("button")[0].selid = box.value == 1 ? 82 : 33
		} catch (e) { }
		Bill.RefreshDetail(true);
	}
	return true
}