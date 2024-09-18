window.loadnextnodes = function(goType) {
	var ems = document.getElementsByName("nextnodes");
	var nodes = new Array();
	for (var i = 0; i < ems.length ; i++) {
		if (ems[i].checked) {
			nodes[nodes.length] = ems[i].value;
		}
	}
	window.GetlogNextNodes(__currwin.zsml.body.bill.ord, nodes.join(","), goType);
	autoSetTime();
}

window.GetlogNextNodes = function(logid, nextnodes, goType) {
	goType = (goType == -1 ? -1 : 1); // -1表示往回推进, 1表示往下推进 
	ajax.regEvent("GetlogNextNodes", "ProcInit.asp");
	ajax.addParam("logid", logid);
	ajax.addParam("nextnodes", nextnodes);
	ajax.addParam("goType", goType);
	//保存当前编辑值
	var inputs = document.getElementsByName("N_ID");
	var vars = new Array();
	for (var i = 0; i < inputs.length; i++) {
		var id = inputs[i].id;
		vars[vars.length] = [inputs[i].value, $ID(id.replace("i", 1)).value, $ID(id.replace("i", 2)).value, $ID(id.replace("i", 3)).value, $ID(id.replace("i", 4)).value, $ID(id.replace("i", 5)).value];
	}
	//更新下级阶段
	document.getElementById("ProcNodeData").innerHTML = ajax.send();
	//回写编辑的值
	var inputs = document.getElementsByName("N_ID");
	for (var i = 0; i < inputs.length; i++) {
		var id = inputs[i].id;
		for (var ii = 0; ii < vars.length; ii++) {
			if (vars[ii][0] == inputs[i].value) {
				$ID(id.replace("i", 1)).value = vars[ii][1];
				$ID(id.replace("i", 2)).value = vars[ii][2];
				$ID(id.replace("i", 3)).value = vars[ii][3];
				$ID(id.replace("i", 4)).value = vars[ii][4];
				$ID(id.replace("i", 5)).value = vars[ii][5];
			}
		}
	}
}

window.autoSetTime = function () {
	var autoTime = "";	
	var i;
	var execStatus = 0;
	try{
		if($ID("status2").checked || $ID("status7").checked){execStatus = 1;}
	}catch(e){}
	if(execStatus == 1){
		var ptime = $("#EndTime_0").val();
		var arr_nextnodes = $("input[name=nextnodes][checked]");
		var gq, beginTime, endTime;
		for(i = 1; i<=arr_nextnodes.length; i++){
			if($("#st_"+i).attr("disabled")==false){
				autoTime = $("#st_"+i).val();
				if(autoTime=="1"){
					gq = Number($("#v_1_"+i).val());
					beginTime = $("#v_4_"+i).val();
					endTime = $("#v_5_"+i).val();
					if(ptime!=""){
						beginTime = ptime;
						$("#v_4_"+i).attr("value",beginTime);

						if(gq>0){
							endTime = addDate(beginTime, gq);
							$("#v_5_"+i).attr("value",endTime);
						}
					}		
				}
			}
		}
	}
}