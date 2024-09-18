

function check_kh(ord,from) {
	from = from || '';
	var url = "../event/search_kh.asp?ord="+escape(ord) + "&from=" + from + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
		updatePage3();
	}
}

function updatePage3() {
	var company = document.getElementById("companyname").value;
	var sortObj = document.getElementById("sort");
	var u_name = document.getElementById("htid").value;
	var title = document.getElementById("title");
	var zt=company+u_name
	title.value=zt;
   
	var telOrd = document.form1.company.value;	
	if(window.__onAddressSelect){
		if (telOrd!=''){
			$.ajax({
				url:'../MicroMsg/Addresses.asp?__msgId=getDefAddress&company='+telOrd,
				success:function(r){
					var json = eval('(' + r.replace(/\r\n/g,'"+\r\n"') + ')');
					window.__onAddressSelect.apply(this,[null,json]);
				}
			});
		}else{
			window.__onAddressSelect.apply(this,[null,{}]);
		}
	}

	if(telOrd!=""){
		telOrd = Number(telOrd);
		if(telOrd>0){
			var url2 = "../event/tel_credit.asp?ty=1&company="+telOrd+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
					XMlHttp2.abort();
				}	
			};
			XMlHttp2.send(null);
		}
	}
	xmlHttp.abort();
}

function empty(v){ 
	switch (typeof v){ 
		case 'undefined' : return true; 
		case 'string' : if(trim(v).length == 0) return true; break; 
		case 'boolean' : if(!v) return true; break; 
		case 'number' : if(0 === v) return true; break; 
		case 'object' : 
		if(null === v) return true; 
		if(undefined !== v.length && v.length==0) return true; 
		for(var k in v){return false;} return true; 
		break; 
	} 
	return false; 
}
