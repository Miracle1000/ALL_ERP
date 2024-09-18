
function check_kh(ord) {	//查看关联客户信息
	var resTxt, arr_res
	ajax.regEvent("getTelInfo");
	$ap("ord",ord)
	var r = ajax.send();
	if(r != ""){
		resTxt = r
		arr_res = resTxt.split("{|}");
		if(arr_res[0]=="0"){
			app.Alert("没有关联的客户，请重新选择");
			return;
		}else if(arr_res[0]=="1"){
			$ID("companyOrd").value = ord
			$ID("khmc").value = arr_res[1];
			$ID("address").value = arr_res[2];
		}else{
			app.Alert("未知错误，请重试");
			return;
		}
		
	}
}

function check_person(ord){	//查看关联联系信息
	var resTxt, arr_res
	ajax.regEvent("getPersonInfo");
	$ap("ord",ord)
	var r = ajax.send();
	if(r != ""){
		resTxt = r
		arr_res = resTxt.split("{|}");
		if(arr_res[0]=="0"){
			app.Alert("没有关联的联系人，请重新选择");
			return;
		}else if(arr_res[0]=="1"){
			$ID("personOrd").value = ord
			$ID("telmc").value = arr_res[1];
			$ID("phone").value = arr_res[2];
			$ID("mobile").value = arr_res[3];
		}else{
			app.Alert("未知错误，请重试");
			return;
		}
		
	}
}

function chkSLForm(){		//选择受理人员窗口
	var SLUser = document.getElementById("SLUser");
	$('#w2').window('open');
	document.getElementById("w2").style.display = "block";
	SLUser.innerHTML="loading...";
	ajax.regEvent("slUserList");
	var r = ajax.send();
	if(r != ""){
		SLUser.innerHTML = r;
	}
}

function setSLUser(){		//设置受理人
	var frm = document.secuser;
	var member2 = "";
	var userid = "";
	member2 = frm.member2.getAttribute("text");
	userid =  frm.member2.value || "";
	if(userid == ""){
		app.Alert("请选择受理人员");
		return false;
	}else{		
		$ID("cateName").value = member2;
		$ID("cateid").value = userid;
		$('#w2').window('close');
	}
	
	
}

function chkPaigong(){		//是否派工
	var isPai = 0;	
	try{
		if($ID("paigong1").checked==true){
			isPai = 1;
		}
		if(isPai == 1){
			$ID("pgPlan").style.display="block";
			$ID("pgPlan2").style.display="block";
			$ID("pgCate").style.display="block";
			$ID("pgCate2").style.display="block";
			$ID("ProcessID").setAttribute("dataType", "Limit");
			$ID("DealPerson").setAttribute("dataType", "Limit");
			$ID("ProcessID").disabled = false;
			$ID("DealPerson").disabled = false;
		}else{
			$ID("pgPlan").style.display="none";
			$ID("pgPlan2").style.display="none";
			$ID("pgCate").style.display="none";
			$ID("pgCate2").style.display="none";
			$ID("ProcessID").disabled = true;
			$ID("DealPerson").disabled = true;
			$ID("ProcessID").setAttribute("dataType", "");
			$ID("DealPerson").setAttribute("dataType", "");
		}
	}catch(e){}
}

$(function(){	
	//选维修流程关联 处理人员
	try{
	$("#ProcessID").live("change",function(){
		var pID = $(this).val();
		$.post("commonAjax.asp",{action:"changePerson",ProcessID:pID},function(data){
			$("#DealPerson option").remove();
			var obj = jQuery.parseJSON(data);	
			$.each(obj,function(key,val){
				$("<option value='"+ key +"'>"+ val +"</option>").appendTo($("#DealPerson"));
			});
		});
	})
	}catch(e){}	
});


function frameResize(){
	document.getElementById("mxlist").style.height=(I3.document.getElementById("mxPos").offsetTop+26)+"px";
}

function getMxCompany1(ord){
	ajax.regEvent("getMxCompany1","../repair/topadd.asp");
	$ap("ord",ord)
	var r = ajax.send();
	if(r != ""){
		if(!isNaN(r)){
			return r;
		}else{
			app.Alert("未知错误");
			return 0;
		}
	}else{
		app.Alert("未知错误");
		return 0;
	}
}

function checkSLForm(){
	ajax.regEvent("checkMxCount");
	$ap("slord",window.repairSLrd);
	var r = ajax.send();
	var mxCount = 0;
	if(r == "0"){
			app.Alert("请添加产品明细、或者请检查是否重复打开了同一页面");
			return false;
	}
	
	try{
		var paigong = 0;
		if ($ID("paigong1").checked == true){
			paigong = 1;
		}
		if (paigong == 1){
			if($ID("ProcessID").options[$ID("ProcessID").selectedIndex].value == ""){
				app.Alert("请选择处理流程");
				$ID("ProcessID").focus();
				return false;
			}
			if($ID("DealPerson").options[$ID("DealPerson").selectedIndex].value == ""){
				app.Alert("请选择处理人员");
				$ID("DealPerson").focus();
				return false;
			}
		}
	}catch(e){}

	var slid = $ID("slid").value;
	if(slid!=""){
		ajax.regEvent("checkSLid");
		$ap("slid",slid);
		var r2 = ajax.send();
		if(r2 == "0"){
		}else{
			if(r2 == "2"){
				app.Alert("受理单编号【"+slid+"】已存在");
			}else{
				app.Alert("未知错误");
			}
			return false;
		}		
	}

	var currTel = $ID("companyOrd").value;
	var dataTel = getMxCompany1(window.repairSLrd);
	if(currTel!=""){
		currTel = Number(currTel);
	}
	if(dataTel!=""){
		dataTel = Number(dataTel);
	}
	if(dataTel>0 && currTel != dataTel){
		return confirm('维修产品不是该客户购买的,确定要继续吗？');
	}

}

function setPerspon(ord, strvalue, mobile, phone) {
    document.getElementById("personOrd").value = ord;
    document.getElementById("telmc").value = strvalue;
    document.getElementById("mobile").value = mobile;
    document.getElementById("phone").value = phone;
}