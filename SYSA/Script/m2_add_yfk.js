//'滕国辉 2010.8.11 显示账户的币种
function getbz(){
	var ck = document.getElementsByName('ck')[0]
	var id = 'bz_'+ck[ck.selectedIndex].value;
	var ye = ck[ck.selectedIndex].title;
	document.getElementById('bzdiv').innerHTML = document.getElementById(id).innerHTML
	document.getElementById('yefn').innerHTML = ye
}

function check_kh(ord) {
	var url = "../event/search_gys1.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage2();
	};
	xmlHttp.send(null);  
}

function updatePage2() {
	if (xmlHttp.readyState < 4) {
		khmc.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		khmc.innerHTML=response;
		xmlHttp.abort();
	}
}

function setInvoiceMode(Ttype){
	if (Ttype==1){
		document.getElementById("invoiceTr").style.display="none";
		$("#InvoiceType").attr("min","0");
	}else if ( Ttype==2){
		document.getElementById("invoiceTr").style.display="";
		$("#InvoiceType").attr("min","1");
	}
}

function doSave(ord){
	var fromobj=document.getElementById("demo");
	if(Validator.Validate(fromobj,2)){		
		var moneyobj=document.getElementById("money1");
		var bank = document.getElementById("ck").value
		var json = {};
		json.ord = ord;
		json.money1 = moneyobj.value;
		json.ck = bank
		var aj = $.ajax({
			type:'post',
			url:'checkbank.asp',
			cache:false,  
			dataType:'html', 
			data:json,
			success: function(data){
				if (data==""){
					spclient.GetNextSP('bankout', 0, moneyobj.value , 0, 0 ,"",fromobj);
				}else if (data.indexOf("err=")==0){
					alert(data.replace("err=",""));
				}
			},
			error:function(e){
				alert(e.responseText);
			}
		});
	}
}