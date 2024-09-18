window.bill_onLoad = function(){
	var v = Bill.getinputbyywname("本次派出量").value
	if(!isNaN(v) && v>0){
		Bill.RefreshDetail(true, "71"); //BUG.3336.binary.根据派工数量刷新用量
	}
}

//关联设计单
window.currMenusSelectData = function(id , result , exid1, exid2 ){
	var ajaxHttp = Bill.ScriptHttp();
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