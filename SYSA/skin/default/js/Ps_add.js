bill.onPageLoad = function(){
	var needQA = $("#needQA_0").val();
	setTR_needQA(needQA);
	document.getElementsByName("txm")[0].focus();
}
//选择派工单
function checkPgd(id , fid, title ){
	$ID(fid+"_0").value=id;
	$ID(fid+"_nv_0").value=title;	
	$ID("Procedure_0").value="";
	$ID("Procedure_nv_0").value="";
	$ID("title_0").value="";
	$("#workcenter_div").html("");
	$("#prenum_div").html("");
	$("#num1_0").value = 1 ;
	bill.easyui.closeWindow("setAutoComplete");
}
//选择工序
function checkGx(id , fid,title ,wcname , prenum ,cnum , needQA){
	$ID(fid+"_0").value=id;
	$ID(fid+"_nv_0").value=title;
	$ID("title_0").value=title;
	$("#workcenter_div").html(wcname);
	$("#prenum_div").html(prenum);
	$("#num1_0").val(cnum);
	setTR_needQA(needQA);
	bill.easyui.closeWindow("setAutoComplete");
}

function setTR_needQA(needQA){
	var tr= $("#result_0").parent().parent().parent();
	if (needQA=="1"){
		tr.find("td").show();
		tr.show();
	}else{
		tr.find("td").hide();
		tr.hide();
	}
}

bill.onScanComplete = function(data){
	var rows = data.split("\r\n");
	if (rows.length>1){
		for(var i=0 ; i<rows.length;i++){
			if (rows[i].indexOf("流水号：")==0){
				data = "YGDA:" + rows[i].replace("流水号：","");
				break;
			}
		}
	}else if (data.indexOf("view.asp?V")>0){
		data = "YGDA:QrUrl="+ data.split("view.asp?")[1];
	}
	var cid = $ID("M_WorkAssigns_0").value;
	ajax.regEvent("onScanComplete")
	ajax.addParam("data", data);
	ajax.addParam("cid", cid);
	var r = ajax.send();
	var result = eval("o=" + r + "");
	if (result.msg == 'true'){
		switch (result.datatype)
		{
		case "SCPG": //生产派工
			checkPgd(result.id , result.fid, result.title );
			break;
		case "SCGX": //生产工序
			if (result.errmessage.length>0){
				if (result.errmessage!="ERR"){
					app.Alert(result.errmessage);
				}
			}else{
				checkGx(result.id , result.fid,result.title ,result.wcname , result.prenum ,result.cnum , result.needQA);
			}
			break;
		case "YGDA"://员工档案
			if (result.errmessage.length>0){
				if (result.errmessage!="ERR"){
					app.Alert(result.errmessage);
				}
			}else{
				checkPerson(result.id , result.name);
			}
			break;	
		case "YGTX" ://员工通讯录
			if (result.errmessage.length>0){
				if (result.errmessage!="ERR"){
					app.Alert(result.errmessage);
				}
			}else{
				checkPerson(result.id , result.name);
			}
			break;
		case "ZJJG": //质检结果
			$("input:radio[value='"+result.r+"']").attr('checked','true');	
			//扫码质检结果后执行提交事件
			bill.doSaveAdd();
			break;
		}
	}else{
		$("#codeProduct_0").val(data);
	}
}

function checkPerson(id , name){
	$("#cateid_nv_0").val(name);
	$("#cateid_0").val(id);
}
