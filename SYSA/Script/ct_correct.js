

function check_kh(ord,from) {
	from = from || '';
  var url = "../event/search_kh.asp?ord="+escape(ord) + "&from=" + from +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2();
  };
  xmlHttp.send(null);  
}

function checkQualifications(){
	var telOrd = document.getElementById('company').value;
	var oldOrd = document.getElementById("company_old").value;
	if (telOrd.length==0) return false;
	if (telOrd == oldOrd) return true;
	var checkResult = false;

	$.ajax({
		url:'../store/CommonReturn.asp?act=checkQualifications&company=' + telOrd ,
		async:false,
		success:function(r){
			try{
				var json = eval('('+r+')');
				checkResult = json.success;
				if (!checkResult){
					alert(json.msg);
				}
			}catch(e){
				checkResult = false;
				alert(r);
			}
		}
	});
	return checkResult;
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
var u_name = document.getElementById("htid").value;
var title = document.getElementById("title");
var zt=company+u_name
	title.value=zt;
var telOrd = document.date.company.value;	
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

function checkhtForm(){
	var telOrd = document.date.company.value;
	var htOrd = document.date.htOrd.value;
	var bizhong = document.getElementById("bizhong").value;
	var ybizhong = document.getElementById("ybizhong").value;
	var ycompany = document.getElementById("ycompany").value;
	var date3 = document.date.ret3.value;
	var result = true;
	if(telOrd!="" && htOrd!="" && ((telOrd!=ycompany) || (bizhong!=ybizhong)) && date3!=""){
		telOrd = Number(telOrd);		
		if(telOrd>0 && bizhong!="" && date3!=""){
			var url2 = "../event/tel_credit.asp?ty=2&company="+telOrd+"&ord="+htOrd+"&bz="+bizhong+"&date3="+date3+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			$.ajax({
				url : url2 ,
				async:false,
				success:function(restr){
					if(restr=="0"){
						result = true;
					}else if(restr=="1"){
						document.getElementById("credit_intro").innerHTML="高于信用额度无法保存";
						result = false;
					}else if(restr=="2"){
						document.getElementById("credit_intro").innerHTML="高于信用额度无法保存";
						result = false;
					}

					if (result){
						result = checkQualifications();
					}
				}
			});
		}
	}
	return result;
}

