function selectAll(chkinp) {
	if($(chkinp).prop("checked")){
		$("input[name='chkall']").prop("checked",true);
		$("input[name='selectid']").prop("checked",true);
	}else{
		$("input[name='chkall']").prop("checked",false);
		$("input[name='selectid']").prop("checked",false);
	}
}

function setXUse(mxid,xjmxid){
	var yuse=$("#toUse_"+mxid+"_"+xjmxid).val();
	if(yuse!=1){		
		$("#toUse_"+mxid+"_"+xjmxid).val(1);
		$("#tr_"+mxid+"_"+xjmxid).css("background-color","#ffeeee");
		$("#xy_"+mxid+"_"+xjmxid).prop("checked",true);
		$("#by_"+mxid+"_"+xjmxid).prop("checked",false);
	}else{
		$("#toUse_"+mxid+"_"+xjmxid).val(0);
		$("#tr_"+mxid+"_"+xjmxid).css("background-color","");
		$("#xy_"+mxid+"_"+xjmxid).prop("checked",false);
	}
}


function setBUse(mxid, xjmxid){
	var yuse=$("#toUse_"+mxid+"_"+xjmxid).val();
	if(yuse!=2){
		$("#toUse_"+mxid+"_"+xjmxid).val(2);
		$("#tr_"+mxid+"_"+xjmxid).css("background-color","");
		$("#xy_"+mxid+"_"+xjmxid).prop("checked",false);
	}else{
		$("#toUse_"+mxid+"_"+xjmxid).val(0);
		$("#tr_"+mxid+"_"+xjmxid).css("background-color","");
		$("#by_"+mxid+"_"+xjmxid).prop("checked",false);
	}
}

function batSetUse(toUse){
	$("input[name='selectid']").each(function(){
		if($(this).prop("checked")){
			var secid = $(this).attr("id");
			var arr_sec = secid.replace("sec_","").split("_");
			var mxid = arr_sec[0];
			var xjmxid = arr_sec[1];		
			if(toUse == 1){	//批量选用
				var yuse=$("#toUse_"+mxid+"_"+xjmxid).val();
				if(yuse!="1"){
					$("#toUse_"+mxid+"_"+xjmxid).val(1);
					$("#tr_"+mxid+"_"+xjmxid).css("background-color","#ffeeee");
					$("#xy_"+mxid+"_"+xjmxid).prop("checked",true);
					$("#by_"+mxid+"_"+xjmxid).prop("checked",false);
				}
			}else if(toUse == 2){	//批量备用
				var yuse=$("#toUse_"+mxid+"_"+xjmxid).val();
				if(yuse!="2"){
					$("#toUse_"+mxid+"_"+xjmxid).val(2);
					$("#tr_"+mxid+"_"+xjmxid).css("background-color","");
					$("#xy_"+mxid+"_"+xjmxid).prop("checked",false);
					$("#by_"+mxid+"_"+xjmxid).prop("checked",true);
				}
			}else if(toUse == 0){	//批量取消，选用、备用 都会取消
					$("#toUse_"+mxid+"_"+xjmxid).val(0);
					$("#tr_"+mxid+"_"+xjmxid).css("background-color","");
					$("#xy_"+mxid+"_"+xjmxid).prop("checked",false);
					$("#by_"+mxid+"_"+xjmxid).prop("checked",false);
			}
		}
	});	
}

//定价的选用、备用保存
function saveXjToUse(act){
	var xjmxidStr="";
	var toUseStr="";
	var secIds = "";
	var ymxid = "";
	var ymxid2 = "";
	var mxidStr = "";
	var toUse, arr_mxid, mxid, xjmxid ;
	$("input[name='toUse']").each(function(){
		toUse = Number($(this).val());
		mxid = $(this).attr("id").replace("toUse_","");
		arr_mxid = mxid.split("_");
		mxid = arr_mxid[0];
		xjmxid = arr_mxid[1];
		xjmxidStr += (xjmxidStr==""?"":",")+xjmxid;
		toUseStr += (toUseStr==""?"":",")+toUse;
		if(ymxid+""!=mxid+""){
			mxidStr += (mxidStr==""?"":",")+mxid;
			ymxid = mxid;
		}
		if(ymxid2+""!=mxid+"" && toUse>0){
			secIds += (secIds==""?"":",")+mxid;
			ymxid2 = mxid;
		}
	});
	if((secIds=="" || (mxidStr!=secIds && secIds!="")) && act=="save"){
		alert("请给所有询价记录选择上 选用 或 备用 后再保存！");
		return;
	}
	if(xjmxidStr==""){
		alert("请给所有询价记录选择上 选用 或 备用 后再保存！");
		return;
	}
	if(xjmxidStr!=""){
		jQuery.ajax({
			url:'../xunjia/ajax_save.asp',
			data:{				
				msgid:"saveXjToUse",
				act:act,
				mxid:xjmxidStr,
				toUse:toUseStr
			},
			type:'post',
			success:function(r){
				if(r=="1"){
					if(window.opener)window.opener.location.reload();
					window.opener=null;window.open('','_self');window.close();
				}else{
					alert("保存失败！\n"+r);
				}
			},error:function(XMLHttpRequest, textStatus, errorThrown){
				alert(errorThrown);
			}
		});
	}
}