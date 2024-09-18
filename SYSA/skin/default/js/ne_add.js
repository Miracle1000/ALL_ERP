function setDataType(obj){
	var dataType = $(obj).val();
	if ($("#fromid").length==0)
	{
		$(obj).parent().append("&nbsp;<input type='hidden' id='fromid' name='fromid'>"+
			"<input type='text' readonly='true' size='22' id='fromname' onclick='getFromID()' name='fromname'> <input class='notnull' id='frombt' title='必填' type='button' value='*'>&nbsp;<span id='showbt' style='color:red;display:none;'>必填</span>");
	}
	setFromId(dataType , 0, "", 0);
	switch(dataType){
		case "0" :
			$("#fromname").hide();
			$("#frombt").hide();
			break;
		default :
			$("#fromname").show();
			$("#frombt").show();
			break;
	}
}

function getFromID(){
	var dataType = $("#datatype_0").val();
	if(dataType=="0"){
		app.Alert("请选择消息来源");
		return;
	}
	var url = "";
	switch(dataType){
		case "-1" :
			url="../event/result2ht.asp?act=notice";
			break;
		case "-8" :
			url="../event/result2.asp?act=notice";
			break;
		case "-11":
			url="../event/resultbill.asp?datatype=M_ProcedureProgres&act=notice";
			break;
		case "-31":
			url="../event/resultbill.asp?datatype=design&act=notice";
			break;
		case "1":
			url="../event/resultbill.asp?datatype=M_PredictOrders&act=notice";
			break;
		case "2":
			url="../event/resultbill.asp?datatype=M_ManuOrders&act=notice";
			break;
		case "3":
			url="../event/resultbill.asp?datatype=M_ManuPlans&act=notice";
			break;
		case "4":
			url="../event/resultbill.asp?datatype=M_ManuOrderIssueds&act=notice";
			break;
		case "8":
			url="../event/resultbill.asp?datatype=M_WorkAssigns&act=notice";
			break;
		case "5":
			url="../event/resultbill.asp?datatype=M_BOM&act=notice";
			break;
		case "10":
			url="../event/resultbill.asp?datatype=M_WorkingFlows&act=notice";
			break;
		case "11":
			url="../event/resultbill.asp?datatype=M_MaterialProgres_11&act=notice";
			break;
		case "12":
			url="../event/resultbill.asp?datatype=M_MaterialOrders_12&act=notice";
			break;
		case "13":
			url="../event/resultbill.asp?datatype=M_MaterialOrders_13&act=notice";
			break;
		case "14":
			url="../event/resultbill.asp?datatype=M_MaterialOrders_14&act=notice";
			break;
		case "15":
			url="../event/resultbill.asp?datatype=M_MaterialOrders_15&act=notice";
			break;
		case "16":
			url="../event/resultbill.asp?datatype=M_PieceRateMain&act=notice";
			break;
		case "17":
			url="../event/resultbill.asp?datatype=M_QualityTestings_17&act=notice";
			break;
		case "18":
			url="../event/resultbill.asp?datatype=M_MaterialProgresRaws&act=notice";
			break;
		case "19":
			url="../event/resultbill.asp?datatype=M_MaterialProgres_19&act=notice";
			break;
		case "20":
			url="../event/resultbill.asp?datatype=M_ProgresReturns&act=notice";
			break;
		case "25":
			url="../event/resultbill.asp?datatype=M_OutOrder&act=notice";
			break;
		case "27":
			url="../event/resultbill.asp?datatype=M_QualityTestings_27&act=notice";
			break;
		case "28":
			url="../event/resultbill.asp?datatype=M_MaterialMove&act=notice";
			break;
		default :
			url="../event/resultbill.asp?datatype=";
			break;
	}
	if (url.length>0){window.open(url,'notice','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');}
}

function setFromId(dataType , ord, name, user ,dataTypeName){
	$("#fromid").val(ord);
	$("#fromname").val(name);
	if (dataTypeName!="" && name!=""){
		$("#title_0").val("来自"+dataTypeName+"："+name);
	}else{
		$("#title_0").val("");
	}
	var json = {};
	json.__msgid = "getTvwJsonByOrder";
	json.dataType = dataType;
	json.ord = ord;
	var aj = $.ajax({
		type:'post',
		url:'../notice/add.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			var lvw = eval("o="+data);
			window.lvw_JsonData_bllst_noticelist=lvw;
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw , "" , true);
		},
		error:function(data){}
	});
}