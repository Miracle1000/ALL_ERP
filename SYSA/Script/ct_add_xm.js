﻿
function checkhtForm(){
	var telOrd = document.date.company.value;
	var sumMoney = document.getElementById("moneyall").value;
	var bizhong = document.getElementById("bizhong").value;
	var date3 = document.date.ret3.value;
	var htSort = document.date.sort.value;
	if(telOrd!=""){
		telOrd = Number(telOrd);
		sumMoney = Number(sumMoney)
		if(telOrd>0 && sumMoney>=0 && bizhong!="" && date3!=""){
			document.getElementById("needSP").value="0";
			var url2 = "../event/tel_credit.asp?ty=2&company="+telOrd+"&sumMoney="+sumMoney+"&bz="+bizhong+"&date3="+date3+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			var XMlHttp2 =  GetIE10SafeXmlHttp();
			XMlHttp2.open("GET", url2, false);
			XMlHttp2.send(null);
			if (XMlHttp2.readyState == 4) {
				var restr = XMlHttp2.responseText;				
				if(restr=="0"){
					return true;
				}else if(restr=="1"){
					document.getElementById("credit_intro").innerHTML="高于信用额度无法保存";
					return false;
				}else if(restr=="2"){
					var url3 = "../event/tel_credit.asp?ty=4&sort="+htSort+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
					var XMlHttp3 =  GetIE10SafeXmlHttp();
					XMlHttp3.open("GET", url3, false);
					XMlHttp3.send(null);
					if (XMlHttp3.readyState == 4) {
						var restr3 = XMlHttp3.responseText;	
						if(restr3=="1"){
							document.getElementById("needSP").value="1";
							return true;
						}else if(restr3=="0"){
							document.getElementById("credit_intro").innerHTML="高于信用额度无法保存";
							return false;
						}
						XMlHttp3.abort();
					}
				}
				XMlHttp2.abort();
			}	
			
		}
	}
}

function chancetel(ord){
	var s = "<option value=''>选择收款账号</option>";
	$.ajax({
		url:"../contract/add_xm.asp?mode=chtel&tord="+ord+"&r="+ Math.random(),
		type:"post",
		dataType:"json",
		async:false,
		success:function(json){
			jQuery('#mxlist').get(0).contentWindow.location.reload();
			if(window.__onAddressSelect){
				if (ord!=''){
					$.ajax({
						url:'../MicroMsg/Addresses.asp?__msgId=getDefAddress&company='+ord,
						success:function(r){
							var json = eval('(' + r.replace(/\r\n/g,'"+\r\n"') + ')');
							window.__onAddressSelect.apply(this,[null,json]);
						}
					});
				}else{
					window.__onAddressSelect.apply(this,[null,{}]);
				}
			}
			return true;
		}
	});
	
	if(ord!=""){
		ord = Number(ord);
		if(ord>0){
			var url2 = "../event/tel_credit.asp?ty=1&company="+ord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			var XMlHttp2 =  GetIE10SafeXmlHttp();
			XMlHttp2.open("GET", url2, false);
			XMlHttp2.onreadystatechange = function(){
				if (XMlHttp2.readyState == 4) {
					var restr = XMlHttp2.responseText;
					var arr_restr=restr.split("|");
					if(arr_restr[0]=="0"){
						document.getElementById("tip_credit").style.display="none";
						document.getElementById("tel_credit").innerHTML="";
					}else if(arr_restr[0]=="1"){
						document.getElementById("tip_credit").style.display="block";
						document.getElementById("tel_credit").innerHTML=arr_restr[1];
					}
					try{
						setCateid(arr_restr[2],arr_restr[3]);
					}catch(e){}
					XMlHttp2.abort();
				}	
			};
			XMlHttp2.send(null);
		}
	}else{
		document.getElementById("tel_credit").innerHTML="";
	}
}