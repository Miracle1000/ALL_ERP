function checkInputData($obj, dataType , minlimit , maxlimit ,title, initMessage){
	var isok = true , message = "";
	switch(dataType){
		case "varchar" : 
			var currval = $obj.val().replace(/^\s*/,'').replace(/\s*$/,'')
			if(minlimit>0 && currval.length==0){
				message = initMessage;
				isok=false;
			}else if(currval.length< minlimit ) {
				message ="最少输入"+minlimit+"字！";
				isok=false;
			}
			else if(maxlimit>0 && $obj.val().length>maxlimit){
				message = "最多输入"+maxlimit+"字！";
				isok = false;
			}
			break;
		case "selectid":
			var selectid =$obj.find("select:last").children(":selected").val();
			if(minlimit>0 && selectid == "请选择") {message = initMessage;isok = false;}
			break;
		case "fixedtel" :
			var re = /^(((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7}|10000|10086|10001|110|120|119|114|199|122|95588|95533|95599|95566)$/;
			if(minlimit>0 && $obj.val()==''){
				message = initMessage;
				isok=false;
			}
			else if(!re.test($obj.val())){
				message = "请输入正确的电话号码";
				isok=false;
			}
		case "postcode" :
			var re = /^\d{6}$/;
			if(minlimit>0 && obj.val().length==0){
				message = initMessage;
				isok=false;
			}else if($obj.val().length< minlimit){
				message = "最少输入"+minlimit+"字！";
				sok = false;
			}
			else if (maxlimit>0 && $obj.val().length> maxlimit){
				message = "最多输入"+maxlimit+"字！";
				isok = false;
			}
			else if($obj.val().length>0 && !re.test($obj.val())){
				message = "请输入正确的邮编";
				isok=false;
			}
	}
	if(isok){
		$obj.parent().next().hide();
	}else{
		$obj.parent().next().text(title + message);
		$obj.parent().next().show();
	}
	return isok;
}
function checkLong($obj,num){
	$obj.unbind().bind("keyup blur input",function(){
		if($(this).val().length>50){
			$(this).val($obj.attr("oldV"));
			return;
		}else{
		}
		$obj.attr("oldV",$(this).val());
	})
}

function checkName($this){
	if($this.val().replace(/^\s*/,'').replace(/\s*$/,'')!=''){
		$this.parent().next().hide();
	}else{
		$this.parent().next().show();
		return false;
	}
	if($this.val().length>50){
		alert("姓名最多输入50字！");
		return false;
	}
	return true;
}
//固定电话验证
function checkFixedTel($this){
	var re = /^(((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7}|10000|10086|10001|110|120|119|114|199|122|95588|95533|95599|95566)$/;
	if(re.test($this.val())||$this.val()==''){
		$this.parent().next().hide();
		return true;
	}else{
		$this.parent().next().show();
		return false;
	}
}

//手机号码验证
function checkTel($this){
    var re = /^1[3456789][0-9]{9}$/;
	if(re.test($this.val())&&$this.val() != ""){
		$this.parent().next().hide();
		return true;
	}else{
		$this.parent().next().show();
		return false;
	}
}
//手机号码2次不一致验证
function checkTel2($this){
	return true;
	var tel1 = $("#tel").val();
	var tel2 = $("#tel2").val();
	if(tel1===tel2){
		$("#tel2").parent().next().hide();
		return true;
	}else{
		$("#tel2").parent().next().show();
		return false;
	}
}
//地址验证
function checkAddress($this){
	var re =  /^\s*|\s*$/g;
	if($this.val().replace(/^\s*/,'').replace(/\s*$/,'')!=''){
		$this.parent().next().hide();
	}else{
		$this.parent().next().show();
		return false;
	}	
	if($this.val().length>200){
		alert("姓名最多输入200字！");
		return false;
	}
	return true;
}
//邮编验证
function checkPostcode($this){	
	var postcode = $("#postcode");
	if ((/^\d{6}$/).test(postcode)) { //邮政编码判断
        $this.parent().next().show();
		return false;
    }else{
    	$this.parent().next().hide();
		return true;   
    }
}

//邮箱验证
function emailCheck($this){	
	var email = $this.val();
	var re = /^(\w-*\.*)+@(\w-?)+(\.\w{2,})+$/;
	if (re.test(email)) { 
        $this.parent().next().hide();
		return true;   
    }else{
    	$this.parent().next().show();
		return false;
    }
}



$.fn.validate = function(){
	var $this = $(this);
	var notnull = $this.attr("notnull");
	if(notnull=='true' && $this.val().replace(/^\s*/,'').replace(/\s*$/,'').length == 0){
		$this.parent().find(".taxErro").show().text("该字段不能为空！");
		return false;
	}else{
		$this.parent().find(".taxErro").text("").hide();
	}
	if(!maxL($this)) return false;
	return true;
}


function maxL($this){
	var max = $this.attr("maxL");
	var len = $this.val().length;
	if(len <= max){
		$this.parent().find(".taxErro").hide().text("");
		return true;
	}else{
		$this.parent().find(".taxErro").show().text("最多输入"+max+"字！");
		return false;
	}
}
$.fn.dateCkeck = function(){
		var nowDate = new Date();
		var y = nowDate.getFullYear();
		var m = (nowDate.getMonth()+1)<10?("0"+(nowDate.getMonth()+1)):nowDate.getMonth()+1;
		var day = nowDate.getDate()<10?"0"+ nowDate.getDate():nowDate.getDate();
		var today = parseInt(y+m+day);
		var chooseDate= parseInt(($(this).val()).replace(/-/g,""));
		if(chooseDate<today){
			return {success:false,msg:'所选日期不能小于当前日期！'};
		}else{
			return {success:true,msg:''};
		}
	}