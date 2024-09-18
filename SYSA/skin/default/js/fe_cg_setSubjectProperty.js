function correctSubject(){
	var sort2 = $('#sfields_sortkm').find('input:first').val();
	$('#sfields_sortcz').find('input:first').val(1);
	ReportSubmit();
	$("#actbtn").html("<button class='oldbutton' onclick='saveForm()'>保存</button>&nbsp;<button class='oldbutton' onclick=\"$('#propForm')[0].reset();\">重填</button>");
	$("#comm_itembarText span").html("会计科目属性设置（修改）");
	//window.location.href='?sort1=1&sort2='+sort2
}

function secSubject(typ){
	$('#sfields_sortkm').find('input:first').val(typ);
}

function ckConvertBz(ord){
	var convert = Number($("#convertBz_"+ord).val());
	if(convert == 0){
		$("#bz_"+ord).css("display","none");
		$("#exchange_"+ord).css("display","none");
	}else if(convert == 1){
		$("#bz_"+ord).css("display","");
		$("#exchange_"+ord).css("display","");
	}
}

function saveForm(){
	var saveForm = true;
	var ord = "";
	$("select[id^='thisYearProfit_']").each(function(){
		if($(this).val() == "1"){
			ord = $(this).attr("id").replace("thisYearProfit_","");
			if($("#amountDirection_"+ord).val() != "3"){
				saveForm = false;
				app.Alert("选择了本年利润科目项的科目的发生额方向必须是“借贷方”");
				$("#amountDirection_"+ord).focus();
				return false;
			}
		}
	});
	if(saveForm == false){return;}
	$("select[id^='exchangeLoss_']").each(function(){
		if($(this).val() == "1"){			
			ord = $(this).attr("id").replace("exchangeLoss_","");
			if($("#amountDirection_"+ord).val() != "3"){
				saveForm = false;
				app.Alert("选择了汇兑损益项的科目的发生额方向必须是“借贷方”");
				$("#amountDirection_"+ord).focus();
				return false;
			}
		}
	});
	if(saveForm == false){return;}
	if(saveForm == true){
		$('#propForm').find("select:disabled").attr("disabled",false);
		$('#propForm').submit();
	}
}

function checkExLoss(ord){
	if($("#exchangeLoss_"+ord).val()=="1"){
		$("select[name='exchangeLoss']").val(0);
		$("#exchangeLoss_"+ord).val(1);
		setAmountDirection(true,ord);
	}
}

function checkProfit(ord){
	if($("#thisYearProfit_"+ord).val()=="1"){
		$("select[name='thisYearProfit']").val(0);
		$("#thisYearProfit_"+ord).val(1);
		setAmountDirection(true,ord);
	}
}


function setAmountDirection(checked,ord){
	if(checked == true){
		$("#amountDirection_"+ord).val(3);
	}
}	

