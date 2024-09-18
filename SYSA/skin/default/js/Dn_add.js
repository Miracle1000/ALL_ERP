window.___RefreshListViewHeadByJson=true;
function setDesignType(obj){
	var designType = $(obj).val();
	if ($("#fromid").length==0)
	{
		$(obj).parent().append("&nbsp;<input type='hidden' id='fromid' name='fromid'>"+
			"<input type='text' readonly='true' size='22' id='fromname' onclick='getFromID()' name='fromname'> <input class='notnull' id='frombt' title='必填' type='button' value='*'>&nbsp;<span id='showbt' style='color:red;display:none;'>必填</span>");
	}
	var dataType = ""
	switch(designType){
		case "1" :
			dataType="chance";
			break;
		case "2" :
			dataType="contract";
			break;
		case "3" :
			dataType="price";
			break;
		case "4" :
			dataType="M_PredictOrders";
			break;
		case "5" :
			dataType="M_ManuPlans";
			break;
		case "52001" :
			dataType="M2_PrePlans";
			break;
		case "52002" :
			dataType="M2_ManuPlans";
			break;
		case "54002" :
			dataType="M2_WorkAssign";
			break;
		default :
			break;
	}
	setFromId(dataType , 0, "", 0);
	switch(designType){
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
	var designType = $("#designtype_0").val();
	if(designType=="0"){
		app.Alert("请选择任务来源");
		return;
	}
	var url = "";
	switch(designType){
		case "1" :
			url="../event/result2.asp?act=design";
			break;
		case "2" :
			url="../event/result2ht.asp?act=design"
			break;
		case "3" :
			url="../event/result2bj.asp?act=design"
			break;
		case "4" :
			url="../event/resultbill.asp?datatype=M_PredictOrders&act=notice";
			break;
		case "5" :
			url="../event/resultbill.asp?datatype=M_ManuPlans&act=notice";
			break;
		case "52001" :
			url="../../SYSN/view/produceV2/ManuPlansPre/ManuPlansPreList.ashx?__displayuitype=urlpage&__ac_ismulti=0&__ac_srcobjid=M2_PrePlans";
			break;
		case "52002" :
			url="../../SYSN/view/produceV2/ManuPlans/ManuPlansList.ashx?__displayuitype=urlpage&__ac_ismulti=0&__ac_srcobjid=M2_ManuPlans";
			break;		
		case "54002" :
			url="../../SYSN/view/produceV2/WorkAssign/WorkAssignList.ashx?__displayuitype=urlpage&__ac_ismulti=0&__ac_srcobjid=M2_WorkAssign";
			break;
		default :
			break;
	}
	if (url.length>0){window.open(url,'design','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=100');}
}

//============================================================
var Bill = new Object();
//鼠标点击以及回车返回数据过程
Bill.SendDataFromAutoTable = function (srcobjId, data) {
	switch(srcobjId){
		//预生产计划
		case "M2_PrePlans" : setFromId(srcobjId , data[0].ID, data[0].title, 0 ,"预生产计划"); break;
		//生产计划
		case "M2_ManuPlans" : setFromId(srcobjId , data[0].ID, data[0].title, 0 ,"生产计划"); break;
		case "M2_WorkAssign" : setFromId(srcobjId , data[0].ID, data[0].WAtitle, 0 ,"生产派工"); break;
	}
}
//============================================================

function setFromId(dataType , ord, name, user ,dataTypeName){
	$("#fromid").val(ord);
	$("#fromname").val(name);
	if (dataTypeName!="" && name!=""){
		$("#title_0").val("转自"+dataTypeName+"："+name);
	}else{
		$("#title_0").val("");
	}
	var json = {};
	json.__msgid = "getLvwJsonByOrder";
	json.dataType = dataType;
	json.ord = ord;
	var aj = $.ajax({
		type:'post',
		url:'../Design/add.asp',
		cache:false,  
		dataType:'html', 
		data:json,
		success: function(data){
			var oRows = window.lvw_JsonData_bllst_designlist.rows;
			//关联的产品 或空行 在明细汇中删除
			var listid = getFieldIndex("listid");
			for (var ii=oRows.length-1;ii>=0;ii--){
				var listidV = oRows[ii][listid];
				if ((listidV.length>0 && listidV>0) || listidV.length==0){	
					window.lvw_JsonData_bllst_designlist.deleteRow(ii,false);
				}
			}
			var lvw = eval("o="+data);
			window.lvw_JsonData_bllst_designlist=lvw;
			//将旧的手动选择明细填入新的明细中
			for (var ii=0;ii<oRows.length;ii++){
				lvw.insertRow(oRows[ii],lvw.rows.length,false);
			}
			lvw.VRows.sort(function(a,b){return a>b?1:-1});
			___ReSumListViewByJsonData(lvw);
			___RefreshListViewByJson(lvw , "" , true);
		},
		error:function(data){}
	});
}
//判断产品是否已通过关联单据选择出来了
window.checkProductByOrder = function(product){
	var lvw = window.lvw_JsonData_bllst_designlist;
	var KeyIndex = getFieldIndex("ProductID");
	var hasProduct = false;
	if (KeyIndex==0){return hasProduct;}
	var listid = getFieldIndex("listid");
	for (var i=0;i<lvw.rows.length;i++){
		var listidV = lvw.rows[i][listid];
		if (lvw.rows[i][KeyIndex]==product && listidV.length>0 && listidV>0){
			hasProduct = true;
			break;
		}		
	}
	return hasProduct;
}

//获取对应字段的下标/位置
function getFieldIndex(dbname){
	var lvw = window.lvw_JsonData_bllst_designlist;
	var index = 0;
	for (var i=0;i<lvw.headers.length;i++){
		if (lvw.headers[i].dbname==dbname){
			index = lvw.headers[i].i ;
			break;
		}		
	}
	return index;
}
//编辑明细保存  刷新列表数据
window.RefreshLvwRow = function(LvRows){
	var lvw = window.lvw_JsonData_bllst_designlist;
	var rows = lvw.rows;
	var KeyIndex = getFieldIndex("ProductID");
	if (KeyIndex==0){return;}
	var listid = getFieldIndex("listid");
	//新选择的产品在明细中新增
	for (var i=0;i<LvRows.length;i++){
		var addnew = true;
		var cells = LvRows[i];
		for (var ii=rows.length-1;ii>=0;ii--){
			if (rows[ii][KeyIndex]==cells[1] && rows[ii][listid]=="0"){
				addnew = false;
				break;
			}else if (rows[ii][listid].length==0){
				//删除空行
				lvw.deleteRow(ii,false);
			}
		}
		if (addnew==true){
			var r = [];
			r[0] = "";
			for (var ii=1;ii<lvw.headers.length;ii++){
				var v = "";
				switch (lvw.headers[ii].dbname)
				{
					case "ProductID": 
						v=cells[1];
						break;
					case "title": 
						v=cells[2];
						break;
					case "order1": 
						v=cells[3];
						break;
					case "type1": 
						v=cells[4];
						break;
					case "unit": 
						v=cells[5];
						break;
					case "unitall":
						v=cells[6];
						break;
					case "zdy1": 
						v=cells[7];
						break;
					case "zdy2": 
						v=cells[8];
						break;
					case "zdy3": 
						v=cells[9];
						break;
					case "zdy4": 
						v=cells[10];
						break;
					case "zdy5": 
						v=cells[11];
						break;
					case "zdy6": 
						v=cells[12];
						break;
					case "listid": 
						v=0;
						break;
					default:
						v="";
						break;
				}
				r[ii] = v;
			}
			lvw.insertRow(r, rows.length,false);
		}
	}
	//删除的产品在明细汇中删除
	for (var ii=rows.length-1;ii>=0;ii--){
		if (rows[ii][listid]=="0"){	
			var delOld = true ; 
			for (var i=0;i<LvRows.length;i++){
				if (rows[ii][KeyIndex]==LvRows[i][1]){
					delOld = false;
					break;
				}
			}
			if (delOld==true){lvw.deleteRow(ii,false);}
		}
	}
	lvw.VRows.sort(function(a,b){return a>b?1:-1});
	___RefreshListViewByJson(lvw ,"",true);
}