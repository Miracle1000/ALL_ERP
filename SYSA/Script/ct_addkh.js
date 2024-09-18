
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
