


function add() {
  var money1 = document.getElementById("money1").value;
  var money2 =  document.getElementById("money2").value;
   
  var url = "cu_sp.asp?money1=" + escape(money1)+"&money2="+escape(money2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage();
  };  
  xmlHttp.send(null);  
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	dybf.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	dybf.innerHTML=response;
	xmlHttp.abort();
  }
}

var numcount=0;
function check_ck() {
   var money1 = document.getElementById("money1").value; 
   var money2 = document.getElementById("money2").value;
   
  if ( isNaN(money1) || (money1 == "") ) {  
  return false;
  }
  
  if (Number(money1) > Number(money2) && numcount ==0) {
  alert("已大于应收票！")
  numcount=1;
 // document.getElementById("money1").value=money2;
 // return false;
  }
  return true;
}




function check_ck2(id,money2) {
   var money1 = document.getElementById("money1_"+id).value;

  if ( isNaN(money1) || (money1 == "") ) {
		return false;
  }
  if (Number(money1) > Number(money2) && numcount==0) {
	  alert("已大于应收票！")
      numcount=1;
	//  document.getElementById("money1_"+id).value=money2
	 // return false;
  }
  return true;
}

function chtotal(id,num_dot_xs)
{
	var price= document.getElementById("money1_"+id);
	var moneyall= document.getElementById("moneyall_"+id);
	var money1 = document.getElementById("money1");
	var money1all=document.getElementById("money1all");

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
	money1.value = money3;
	money1all.value=money3;
	add_hb(id);
	
	xmlHttp.abort();
}

function add_hb(id) {
  var money1 = document.getElementById("money1_"+id).value;
  var money2 =  document.getElementById("moneyall2_"+id).value;

  var url = "cu_hbsp.asp?money1=" + escape(money1)+"&money2="+escape(money2)+"&id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
function del(str,id,rd,num_dot_xs){
	var w  = document.all[str];
	var money1= document.getElementById("money1");
	num1=document.getElementById("money1_"+id).value;
	num_zs = money1.value;
	num_zs = num_zs.replace(",", "");
	num1 = num1.replace(",", "");
	if (num1 == 0) { num1 = "0.00" };
	len1 = money1.toString().indexOf(".") == -1 ? 0 : money1.toString().split(".")[1].length;
	len2 = num_zs.toString().indexOf(".") == -1 ? 0 : num_zs.toString().split(".")[1].length;
	m = Math.pow(10, Math.max(len1, len2));
	num_zs = (num_zs * m - num1 * m) / m;
	money1.value = num_zs.toFixed(num_dot_xs);
	var url = "../money2/del_cp.asp?id="+escape(id)+"&rd="+escape(rd)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w,id,num_dot_xs);
  };
  xmlHttp.send(null);
}
function updatePage_del(str,id,num_dot_xs) {
     str.innerHTML="";

 }
