

function pay()
{
	var w = document.getElementById("alli").value;
	for(var i=1; i<=w; i++)
　 {
	document.getElementById("pay_"+i).value = document.getElementById("pl_payall").value;
   }
}
//保留两位小数
function changeTwoDecimal(x)
{
   var f_x = parseFloat(x);
   if (isNaN(f_x))
   {
      alert('输入的值为空！');
      return false;
   }
   else
   {
	   var f_x = Math.round(x*100)/100;
	   return f_x;
   }
}
//按年付算回款日期
function hkdate_year(){
	var w=document.getElementById("alli").value;
	var date1=document.getElementById("ret_1").value;//获取第一个日期
	for(var i=1; i<=w; i++)
　 {
	j=i-1;
	document.getElementById("ret_"+i).value =dateaddjs("yyyy",j,date1);
   }
}
//按月算回款日期
function hkdate_month(){
	var w=document.getElementById("alli").value;
	var date1=document.getElementById("ret_1").value;//获取第一个日期
	for(var i=1; i<=w; i++)
　 {
	j=i-1;
	document.getElementById("ret_"+i).value =dateaddjs("m",j,date1);
   }
}
//按回款金额来算出对应的百分比
function per(id) 
{ 
	var htje= document.getElementById("summoney"); 
	var hkje = document.getElementById("money_hk"+id);
	var percent1=(hkje.value / htje.value)*100; 
	document.getElementById("percent"+id).value=percent1;//
	return true;
}
//按输入的百分比来算出对应的金额
function hk(id) 
{ 
	var htje= document.getElementById("summoney"); 
	var bfb= document.getElementById("percent"+id);
	if (isNaN(bfb.value) || (bfb.value == "") ){
		document.getElementById("money_hk"+id).fireEvent("onblur");
		return false;
	}
	else
	{
		var money1=htje.value * (bfb.value/100); 
		document.getElementById("money_hk"+id).value=money1;//
		document.getElementById("money_hk"+id).fireEvent("onblur");
		return true;
	}
}
function add(id,num_dot_xs) {
  var money1 = document.getElementById("money_ht"+id).value;
  var money2 = document.getElementById("money_hk"+id).value;
  var summoney = document.getElementById("summoney").value;
  var w2=id;
  var url = "plan.asp?summoney=" + escape(summoney)+"&money_ht=" + escape(money1)+"&money_hk="+escape(money2)+"&ord="+escape(id+1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage(w2);
  };  
  xmlHttp.send(null);  
}

function updatePage(w2) {
  var cw="fqjh_"+w2;
  cw=document.all[cw];
  if (xmlHttp.readyState < 4) {
	cw.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	cw.innerHTML=response;
	document.getElementById("alli").value=w2+1;
	xmlHttp.abort();
  }
}

function check_ck(id) {
   var htje= document.getElementById("summoney");//合同总金额
   var money1 = document.getElementById("money_ht"+id).value; //获取当前剩余金额
   var money2 = document.getElementById("money_hk"+id).value; //获取回款金额
   var per1=document.getElementById("percent"+id).value;//算出当前百分比
   //alert(Number(per1));
  if (isNaN(money1) || (money1 == "") ) {
  	return false;
  }
  if (Number(money2)<=0){
		document.getElementById("money_hk"+id).value=money1;
		document.getElementById("percent"+id).value=per1;
		document.getElementById("alli").value=id;
		return false;
  }
  if (Number(money2) > Number(money1)) {
	  alert("大于合同剩余金额！");
	  document.getElementById("money_hk"+id).value=money1;
	  document.getElementById("percent"+id).value=per1;
	  document.getElementById("alli").value=id;
	  return false;
  }
  else{
  	  return true;
  }
  //	  return true;
}

function del(str,id){
	var w  = document.all[str];
	var url = "del_hk.asp?ord="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage_del(w,id);
	};
	xmlHttp.send(null);  
}
function updatePage_del(str,id) {
     str.innerHTML="";
	 document.getElementById("alli").value=id-1;
}
