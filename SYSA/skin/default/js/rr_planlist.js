window.onReportExtraHandle = function(text , arrValue){
	if (text=="批量派工"){	
		var slord = "";
		$("input[name='slord']").each(function(){  
			slord+=$(this).val()+",";
		})
		var selectid = arrValue.join(",");
		if(selectid == ""){
			app.Alert("您没有选择任何维修受理单，请选择后再派工！");
		}else{		
			ajax.regEvent("chkPaigong");
			ajax.addParam("id", selectid);
			var r = ajax.send();
			if(r=="-1"){	//没有删除权限
				app.Alert("您没有派工权限，不允许派工！");
			}else if(r=="0"){
				app.Alert("您没有选择任何维修受理单，请选择后再派工！");
			}else if(r=="3"){
				app.Alert("您没有选择任何维修受理单已删除，请重新选择！");
			}else if(r=="1"){
				window.open('planlist2.asp?sys_lvw_ckbox='+selectid+"&slord="+slord,'newwin','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
			}
		}
	}
}

