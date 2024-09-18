
function frameResize1(){
	try{
		document.getElementById("hklist").style.height=P3.document.body.scrollHeight+0+"px";
		parent.frameResize();
	}catch(e1){
		//alert(e1.message);
	}
}

function checkhtForm(){
	var telOrd = document.form1.company.value;
	var sumMoney = document.getElementById("moneyall").value;
	var bizhong = document.getElementById("bizhong").value;
	var date3 = document.form1.htret3.value;
	if(telOrd!=""){
		telOrd = Number(telOrd);
		sumMoney = Number(sumMoney)
		if(telOrd>0 && sumMoney>=0 && bizhong!="" && date3!=""){			
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
					document.getElementById("credit_intro").innerHTML="高于信用额度无法保存";
					return false;
				}
				XMlHttp2.abort();
			}	
			
		}
	}
}
