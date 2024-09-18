window.bill_onLoad = function() {
	var sbox = Bill.getInputByDBName("CreateFrom");
	if(!sbox) {
		//只读模式下
		var td = $ID("M_Field_8_1");
		if(td.innerHTML.indexOf("手动添加")>0) {
			var tr = td.parentNode;
			tr.cells[2].style.visibility = "hidden";
			tr.cells[3].style.visibility = "hidden";
		}
		return;
	}
	window.bindEvent(sbox, "change", function(){
		updateBoxState(sbox);
	});
	updateBoxState(sbox, 1);
}

function updateBoxState(sbox, fst) {
	var tr = sbox.parentNode.parentNode;
	var db = Bill.getInputByDBName("FromID");
	if(fst!=1) {
		db.value = "";
		db.title = "0";
		$(db).trigger("change");
	} else {
		if(sbox.value==4) {
			if(db && db.title=="") {
				db.value = "";
				db.title = "0";
			}
		}
	}
	if(sbox.value==4) {
		tr.cells[2].style.visibility = "hidden";
		tr.cells[3].style.visibility = "hidden";
		if($ID("lvw_add_71_tb")){$ID("lvw_add_71_tb").style.display  =  "";}  //注意：lvw_add_71_tb是写死的，后期如果变动了UI还需要再调整
	} else {
		tr.cells[2].style.visibility = "visible";
		tr.cells[3].style.visibility = "visible";
		if( $ID("lvw_add_71_tb")){$ID("lvw_add_71_tb").style.display  =  "none";}
	}
}
//详情设置物料清单 和 关联设计单
window.currMenusSelectData = function(id , result , exid1, exid2 ){
	var ajaxHttp = Bill.ScriptHttp();
	if (id==17)
	{
		if (result.length>0){
			//if (confirm("确定选择该物料清单？")){
				var BOMID =  (""+result[0]).split(",")[1];
				ajaxHttp.regEvent("B3_SelectBOMID");
				ajaxHttp.addParam("id",id);
				ajaxHttp.addParam("mxid",exid1);
				ajaxHttp.addParam("BOMID",BOMID);
				var r = ajaxHttp.send();
				$("#71_psize").trigger("change");
			//}
		}
	}else{	
		var DesignIDs = "0";
		for (var i = 0; i<result.length ; i++ ){
			DesignIDs += "," + (""+result[i]).split(",")[1] ; 
		}
		ajaxHttp.regEvent("B3_SelectDesignID");
		ajaxHttp.addParam("id",id);
		ajaxHttp.addParam("oid",exid1);
		ajaxHttp.addParam("bid",exid2);
		ajaxHttp.addParam("DesignID",DesignIDs);
		var r = ajaxHttp.send();
		if (r=="1"){
			window.open('../../notice/add.asp?datatype='+ exid1 +'&fromid='+exid2,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
		}
		$("#design_psize").trigger("change");
	}
}

