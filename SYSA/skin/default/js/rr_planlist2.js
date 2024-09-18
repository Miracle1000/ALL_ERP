function selectall(box) {
	var ck = box.checked;
	var boxs = document.getElementsByName("sys_lvw_ckbox");
	for (var i = 0 ; i < boxs.length; i++ )
	{
		boxs[i].checked = ck;
	}
}

$(function(){	
	//选维修流程关联 处理人员
	$("select[name='ProcessID']").live("change",function(){
		var ProcessID = $(this).attr("id");
		var arr_ProcessID = ProcessID.split("_");
		var mxid = arr_ProcessID[1];
		var pID = $(this).val();
		$.post("commonAjax.asp",{action:"changePerson",ProcessID:pID},function(data){
			$("#DealPerson_"+mxid+" option").remove();
			var obj = jQuery.parseJSON(data);	
			$.each(obj,function(key,val){
				$("<option value='"+ key +"'>"+ val +"</option>").appendTo($("#DealPerson_"+mxid+""));
			});
		});
	})
	
	$("input[name='num1']").live("keyup",function(){
		var arr_num1 = $("input[name='num1']");
		var i = 0;
		var num1 = 0;
		var sumNum = 0;
		var dot_num = $("#num1_dot").val();
		for(i = 0; i < arr_num1.length; i++){
			num1 = Number($(arr_num1[i]).val());
			sumNum += num1
		}
		$("#sumNum1").html(""+MRound(sumNum,dot_num)+"");
	})

	$("input[name='money1']").live("keyup",function(){
		var arr_money1 = $("input[name='money1']");
		var i = 0;
		var money1 = 0;
		var sumMoney = 0;
		var num_dot_xs = $("#num_dot_xs").val();
		for(i = 0; i < arr_money1.length; i++){
			money1 = Number($(arr_money1[i]).val());
			sumMoney += money1
		}
		$("#sumMoney1").html(""+MRound(sumMoney,num_dot_xs)+"");
	})

	//批量录入
	$("#wxTitle_pi").live("keyup",function(){
		var wxTitle = $("#wxTitle_pi").val();
		$("input[name='wxTitle']").attr("value",wxTitle);
	})

	$("#SerialNumber_pi").live("keyup",function(){
		var SerialNumber = $("#SerialNumber_pi").val();
		$("input[name='SerialNumber']").attr("value",SerialNumber);
	})

	$("#ProcessID_pi").live("change",function(){
		var pID = $(this).val();
		$("select[name='ProcessID']").attr("value",pID);
		$.post("commonAjax.asp",{action:"changePerson",ProcessID:pID},function(data){
			$("#DealPerson_pi option").remove();
			$("select[name='DealPerson'] option").remove();
			var obj = jQuery.parseJSON(data);	
			$.each(obj,function(key,val){
				$("<option value='"+ key +"'>"+ val +"</option>").appendTo($("#DealPerson_pi"));
				$("<option value='"+ key +"'>"+ val +"</option>").appendTo($("select[name='DealPerson']"));
			});
		});
	})

	$("#DealPerson_pi").live("change",function(){
		var pID = $(this).val();
		$("select[name='DealPerson']").attr("value",pID);
	})
	
	$("#num1_pi").live("keyup",function(){
		var num1 = $("#num1_pi").val();
		$("input[name='num1']").attr("value",num1);
		refresStatDiv()
	})

	$("#money1_pi").live("keyup",function(){
		var money1 = $("#money1_pi").val();
		$("input[name='money1']").attr("value",money1);
		refresStatDiv()
	})

});

function resetForm(){
	var arr_DealPerson = $("select[name='DealPerson']");
	arr_DealPerson.empty();
	$("<option value=''>请选择处理人员</option>").appendTo(arr_DealPerson);
	var DealPerson_pi = $("#DealPerson_pi")
	DealPerson_pi.empty();
	$("<option value=''>请选择处理人员</option>").appendTo(DealPerson_pi);
}

function MRound(Num,dot_num){
	var fNum2 = 1;
	var Num2 = "";
	var str0 = "";
	var m = 0;
	for(m=0;m<dot_num;m++){
		fNum2 = fNum2 * 10
	}
	Num2 = Math.round(Num * fNum2)/fNum2;
	if(dot_num>0){
		Num2 = Num2.toString();
		if(Num2.indexOf(".")==-1){
			for(m=1; m<=dot_num; m++){
				str0 += "0";
			}
			Num2 = Num2 + "." + str0;
		}else{
			var arr_num2 = Num2.split(".");
			var dot2 = arr_num2[1];
			for(m=dot2.length; m<dot_num; m++){
				str0 += "0";
			}
			Num2 = Num2 + str0;
		}
	}
	return Num2;
}

//刷新合计行的数据统计
function refresStatDiv(){
	var arr_num1 = document.getElementsByName("num1");
	var arr_slNum = document.getElementsByName("slNum");
	var arr_ypNum = document.getElementsByName("ypNum");
	var arr_wxMoney = document.getElementsByName("money1");
	var dot_num = $ID("num1_dot").value;
	var num_dot_xs = $ID("num_dot_xs").value;
	var num1 = 0;
	var slNum = 0;
	var ypNum = 0;
	var wxMoney = 0;
	var sumNum1 = 0;
	var sumSlNum = 0;
	var sumYpNum = 0;
	var sumWxMoney = 0;
	for(var i=0; i<arr_num1.length; i++){
		num1 = Number(arr_num1[i].value);
		slNum = Number(arr_slNum[i].value);
		ypNum = Number(arr_ypNum[i].value);
		wxMoney = Number(arr_wxMoney[i].value);
		sumNum1 += num1;
		sumSlNum += slNum;
		sumYpNum += ypNum;
		sumWxMoney += wxMoney;
	}
	$ID("sumNum1").innerHTML = MRound(sumNum1,dot_num);	
	$ID("sumSlNum").innerHTML = MRound(sumSlNum,dot_num);
	$ID("sumYpNum").innerHTML = MRound(sumYpNum,dot_num);
	$ID("sumMoney1").innerHTML = MRound(sumWxMoney,num_dot_xs);
}
function delPGmx(wxid){
	if(wxid==""){
		app.Alert("您没有选择产品，请选择后再删除！");
		return false;
	}else{
		if(confirm("确定要删除吗？")){
			ajax.regEvent("delPGmx");
			ajax.addParam("wxid", wxid);
			var r = ajax.send();
			if(r=="0"){
				app.Alert("您没有选择产品，请选择后再删除！");
			}else if(r=="1"){
				var mxTable = $ID("lvw_dbtable_mlistvw");
				var mxidInput = $ID("wxid_"+wxid);	
				var delTR = mxidInput.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;	//获取需删除的行
				var cols = delTR.cells.length; 
				var delindex = delTR.rowIndex;
				mxTable.deleteRow(delindex);
				var mxCount = document.getElementsByName("sys_lvw_ckbox").length;
				if(mxCount==0){
					delTR = $ID("sumNum1").parentElement.parentElement;	//获取合计行
					mxTable.deleteRow(delTR.rowIndex);
					var newtr = mxTable.insertRow(1);
					var cell = newtr.insertCell(0);
					cell.colSpan = cols;
					cell.innerHTML="<div class='lvw_nulldata'></div>";
				}else{
					var arr_index = $(".lvw_index");
					for(var i = 0; i< arr_index.length; i++){
						arr_index[i].innerHTML = i + 1;
					}
					refresStatDiv();
					mxTable.rows.item(1).style.height = (mxTable.rows.item(1).offsetHeight +1) +'px';
					mxTable.rows.item(1).style.height = (mxTable.rows.item(1).offsetHeight -1) +'px';
				}
				//lvw_refresh("mlistvw");	
			}
		}
	}
}

function batDelPaigong(){
	var selectid = "";		
	for(i=0;i<document.getElementsByName("sys_lvw_ckbox").length;i++){
		if(document.getElementsByName("sys_lvw_ckbox")[i].checked==true){
			selectid += document.getElementsByName("sys_lvw_ckbox")[i].value+",";
		}
	}
	
	if(selectid == ""){
		app.Alert("您没有选择产品，请选择后再删除！");
	}else{		
		if(confirm("确定要删除吗？")){
			ajax.regEvent("delPGmx");
			ajax.addParam("wxid", selectid);
			var r = ajax.send();
			if(r=="0"){
				app.Alert("您没有选择任何维修受理单，请重新选择！");
			}else if(r=="1"){
				var mxTable = $ID("lvw_dbtable_mlistvw");
				var arr_mxid = selectid.split(",");
				var mxidInput = "";
				var delTR = ""
				var cols = 0;
				var i = 0; 
				var delindex =1;
				for(i=0; i<arr_mxid.length-1; i++){
					mxid = arr_mxid[i];
					mxidInput = $ID("wxid_"+mxid);							
					delTR = mxidInput.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;	//获取需删除的行
					cols = delTR.cells.length; 
					delindex = delTR.rowIndex;
					mxTable.deleteRow(delindex);					
				}
				var mxCount = document.getElementsByName("sys_lvw_ckbox").length;
				if(mxCount==0){
					delTR = $ID("sumNum1").parentElement.parentElement;	//获取合计行
					mxTable.deleteRow(delTR.rowIndex);
					var newtr = mxTable.insertRow(1);
					var cell = newtr.insertCell(0);
					cell.colSpan = cols;
					cell.innerHTML="<div class='lvw_nulldata'></div>";
				}else{
					var arr_index = $(".lvw_index");
					for(i = 0; i< arr_index.length; i++){
						arr_index[i].innerHTML = i + 1;
					}
					refresStatDiv();
					//使删除行后可以正常显示红字提示语
					mxTable.rows.item(1).style.height = (mxTable.rows.item(1).offsetHeight +1) +'px';
					mxTable.rows.item(1).style.height = (mxTable.rows.item(1).offsetHeight -1) +'px';
				}
				$ID("btnBatDel").blur();
				$ID("checkAll").checked = false;				
				//lvw_refresh("mlistvw");	
			}
		}
	}
}

function savePaigong(){	//
	var pgForm = $ID("pgForm");
	if (Validator.Validate(pgForm,2)){
			var wxid = "";		
			var wxTitle = "";
			var SerialNumber = "";
			var ProcessID = "";
			var DealPerson = "";
			var num1 = "";
			var money1 = "";
			var pg_plan = "";
			var pg_cate = "";
			for(i=0;i<document.getElementsByName("sys_lvw_ckbox").length;i++){
					wxid += document.getElementsByName("sys_lvw_ckbox")[i].value+",";
					wxTitle += document.getElementsByName("wxTitle")[i].value+"\2\1\3";
					SerialNumber += document.getElementsByName("SerialNumber")[i].value+"\2\1\3";
					pg_plan =  document.getElementsByName("ProcessID")[i];
					ProcessID += pg_plan.options[pg_plan.options.selectedIndex].value+",";
					pg_cate =  document.getElementsByName("DealPerson")[i];
					DealPerson += pg_cate.options[pg_cate.options.selectedIndex].value+",";
					num1 += document.getElementsByName("num1")[i].value+",";
					money1 += document.getElementsByName("money1")[i].value+",";
			}
			if (wxid==""){
				app.Alert("您没有选择任何产品，请重新选择！");
				return false;
			}
			ajax.regEvent("SavePaigong","saveRepairOrder2.asp");
			ajax.addParam("wxid", wxid);
			ajax.addParam("wxTitle", wxTitle);
			ajax.addParam("SerialNumber", SerialNumber);
			ajax.addParam("ProcessID", ProcessID);
			ajax.addParam("DealPerson", DealPerson);
			ajax.addParam("num1", num1);
			ajax.addParam("money1", money1);
			var r = ajax.send();
			if(r!=""){
				var arr_res = r.split("|");
				if(arr_res[0]=="0"){
					app.Alert("您没有选择任何产品，请重新选择！");
					return false;
				}else if(arr_res[0]=="-1"){
					app.Alert("您没有派工权限，不可以派工");
					return false;
				}else if(arr_res[0]=="-2"){
					app.Alert("数据错误，请重试");
					return false;
				}else if(arr_res[0]=="-3"){
					app.Alert("未知错误");
					return false;
				}else if(arr_res[0]=="1"){
					if(window.opener){
						window.opener.lvw_refresh("mlistvw");	//刷新列表
					}	
					window.opener=null;window.open('','_self');window.close();
				}else if(arr_res[0]=="2"){
					if(window.opener){
						window.opener.lvw_refresh("mlistvw");	//刷新列表
					}					
					lvw_refresh("mlistvw");	//刷新列表
					var noPG = arr_res[1];
					var noPGID = "";
					var arr_noPG = "";
					if(noPG!=""){
						arr_noPG = noPG.split(",");
						for(var i=0;i<arr_noPG.length; i++){
							noPGID = Number(arr_noPG[i]);
							if(noPGID>0){
								$ID("tip_"+noPGID).innerHTML = "&nbsp;已派工,不允许再派工！"
							}else if(noPGID<0){
								$ID("tip_"+Math.abs(noPGID)).innerHTML = "&nbsp;不允许派工！"
							}
						}
					}
				}else if(arr_res[0]=="3"){					
					var reNumber = "";					
					var arr_reNumber = arr_res[1].split(",");
					for(var i=0;i<arr_reNumber.length; i++){
						reNumber = Number(arr_reNumber[i]);
						if(reNumber>0){
							$ID("serial_tip_"+reNumber).innerHTML = "* 维修单编号重复"
						}
					}
					return false;
				}
			}
	}
}