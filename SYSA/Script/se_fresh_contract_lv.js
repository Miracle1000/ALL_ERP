

function check_kh(ord,from) {
	from = from || '';
	var url = "../event/search_kh.asp?ord="+escape(ord) + "&from=" + from + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage2();};
	xmlHttp.send(null);  
}

function updatePage2(){
	if (xmlHttp.readyState == 4){
	  var response = xmlHttp.responseText;
		khmc.innerHTML=response;
		updatePage3();
	}
}

function updatePage3(){
	var company = document.getElementById("companyname").value;
	var title = document.getElementById("title");
	var sortObj = document.getElementById("sort");
	var u_name = sortObj.value==""?"":sortObj.options[sortObj.selectedIndex].text;
	var zt=company+u_name
	title.value=zt;
	var telOrd = document.getElementById("companyOrd").value;	
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
	switch (typeof v)
	{
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

function getconttitle(name){ 
	var ContType=getSelectedText(name);
	var Contcompany=document.getElementById("companyname").value;
	if((ContType!="")&&(Contcompany=="")){
		document.getElementById("title").value=ContType;
	}
	if((ContType!="")&&(Contcompany!="")){
		document.getElementById("title").value=Contcompany + ContType;
	}
	if((ContType=="")&&(Contcompany!="")){
		document.getElementById("title").value=Contcompany;
	}
}

//获取下拉列表值
function getSelectedText(name)
{
	var obj=document.getElementById(name);
	for(i=0;i<obj.length;i++)
	{
		if(obj[i].selected==true){return obj[i].innerText;}
	}
}

function getHtmx(value){
	if(value!=""){
		document.getElementById("htI3").src='../event/htmx.asp?ID=company&ContectType='+ value;
	}else{
		document.getElementById("htI3").src='../event/htmx.asp?ID=company&ContectType=0';
	}
}

function lockMoneyInput(flg,obj){
	var $input = jQuery('#money_hk');
	if($input.size()==0) return;
	if(flg){
		$input.val(jQuery('#moneyall').val());
		$input.attr('readonly',true)
	}else{
		$input.removeAttr('readonly');
	}
}
