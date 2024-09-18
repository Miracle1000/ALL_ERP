function check_ck2(id,money2) {
	var money1 = document.getElementById("money1_"+id).value;
	if ( isNaN(money1) || (money1 == "") ) {
		document.getElementById("money1_"+id).value=money2
		return true;
	}
	if (Number(money1)>=0){  
		if (Number(money1) > Number(money2)) {
			alert("大于应收账款！")
			document.getElementById("money1_"+id).value=money2
			return true;
		}
	}
	return true;
}

function chtotal(id,num_dot_xs){
	var price= document.getElementById("money1_"+id);
	var moneyall= document.getElementById("moneyall_"+id);
	var money1 = document.getElementById("money1");

	var price1 = price.value;
	var money = money1.value;
	var moneyal = moneyall.value;
	len1 = money.toString().indexOf(".") == -1 ? 0 : money.toString().split(".")[1].length;
	len2 = price1.toString().indexOf(".") == -1 ? 0 : price1.toString().split(".")[1].length;

	m = Math.pow(10, Math.max(len1, len2));
	money3 = (money * m - moneyal * m) / m;
	money3 = (money3 * m + price1 * m) / m;
	moneyall.value = parseFloat(price.value);
	money3 = money3.toFixed(num_dot_xs);
	money1.value = money3
	add_hb(id)
	xmlHttp.abort();
}

function add_hb(id) {
	var money1 = document.getElementById("money1_"+id).value;
	var money2 =  document.getElementById("moneyall2_"+id).value;
	var url = "cu_hb.asp?money1=" + escape(money1)+"&money2="+escape(money2)+"&id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_hb(id);
	};
	xmlHttp.send(null);
}

function updatePage_hb(id) {
	var w="next_"+id
	w=document.all[w]
	if (xmlHttp.readyState < 4) {
		w.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		w.innerHTML=response;
		xmlHttp.abort();
	}
}
function del(str,id,num_dot_xs){
	var moneyall = 0;
	$("#"+str).html("");
	$("input[name^='money1_']").each(function(){
		var currMoney = parseFloat($(this).val().replace(",",""));
		moneyall += currMoney;
	});
	$("#money1").val(FormatNumber(moneyall,num_dot_xs));
	$("#money1").attr("max",FormatNumber(moneyall,num_dot_xs));
	$("#money1").attr("msg",($("#money1").attr("min")=="0"?"金额必须大于0且小于等于":"金额不能大于")+FormatNumber(moneyall,num_dot_xs));
}

function chtotalMoney(){
	var num_dot_xs = window.sysConfig.moneynumber;
	var newMoney1 = parseFloat($("#money1").val());
	var oldMoney1 = parseFloat($("#money1").attr("max"));
	var money = 0;
	var money1 = 0;
	if(newMoney1 > oldMoney1){
		$("#money1Tip").html(" 不能大于"+FormatNumber(oldMoney1,num_dot_xs));
		try{
			if($("#money1Tip").next().attr("id").indexOf("__ErrorMessagePanel")>-1){
				$("#money1Tip").next().html("");
			}
		}catch(e){}
		return;
	}else{
		$("#money1Tip").html("");
	}
	$("input[name^='money1_']").each(function(){
		var newplanmoney1 = parseFloat($(this).val().replace(",", ""));
		var id = $(this).attr("id").replace("ht_","");
		var oldmoney = parseFloat($(this).attr("oldMoney"));
		var newMoney = newplanmoney1;
		money1 += parseFloat(oldmoney);
		if (parseFloat(money1) >= parseFloat(newplanmoney1)) {
			money = parseFloat(parseFloat(oldmoney) - (parseFloat(money1) - parseFloat(newMoney1))).toFixed(num_dot_xs)
			if (money > 0) {
				if(money>=oldmoney){
					newMoney = FormatNumber(oldmoney, num_dot_xs);
				}else{
					newMoney = FormatNumber(money, num_dot_xs);
				}				
			} else {
				newMoney = FormatNumber(0, num_dot_xs);
			}
		} else {
			newMoney = FormatNumber(oldmoney, num_dot_xs);
		}
		$(this).val(FormatNumber(newMoney, num_dot_xs));
		chtotal2(id, 2);
		if (oldmoney > newMoney) {
			var date1 = $("#date1_"+id).html();
			$("#daysdate1_"+id+"Pos").val(date1);
		}
	});
}