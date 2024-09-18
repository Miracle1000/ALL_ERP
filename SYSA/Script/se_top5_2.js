


function callServer(nameitr) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = document.all[nameitr];
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?name=" + escape(u_name);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w);
  };
  xmlHttp.send(null);  
}

function updatePage(namei) {
var test7=namei
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
  }

}

function callServer2() {
  var unit1 = document.getElementById("unit1").value;
  if ((unit1 == null) || (unit1 == "")) return;

  var url = "cuunit.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(unit1);
  };
  xmlHttp.send(null);  
}


function updatePage2(unit1) {
  if (xmlHttp.readyState < 4) {
	trpx0.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx0.innerHTML=response;
	
  var url1 = "cuunit3.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url1, true);
  xmlHttp.onreadystatechange = function(){
  updatePage3();
   };
	 xmlHttp.send(null); 
	
  }
}


function updatePage3() {
  if (xmlHttp.readyState < 4) {
	trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit2.innerHTML=response;
 
  xmlHttp.abort();
  }
}



function callServer4(ord) {

 if ((ord == null) || (ord == "")) return;
  var url = "../contract/num_click.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4(ord);
  };
  xmlHttp.send(null);  
}

function updatePage4(ord) {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    var res = xmlHttp.responseText;
	var w  = "trpx"+res;
 w=document.all[w]
  var url = "cu_pd2.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage5(w,ord);
  };
  xmlHttp.send(null);  
  }
}

function updatePage5(w,unitall) {
var test3=w;
  if (xmlHttp.readyState < 4) {
	test3.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test3.innerHTML=response;
	
 var url1 = "cu_pd.asp?unitall=" + escape(unitall)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url1, true);
  xmlHttp.onreadystatechange = function(){
  updatePage6();
   };
	 xmlHttp.send(null);
	
  }
}

function updatePage6() {
  if (xmlHttp.readyState < 4) {
	trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit2.innerHTML=response;
	 xmlHttp.abort();
 } 
}
function updatePage7() {
  if (xmlHttp.readyState < 4) {
	trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit1.innerHTML=response;
 
  xmlHttp.abort();
  }
}

function del(str,id){
	
	var w  = str;
	
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w);
  };
  xmlHttp.send(null);  
}
function updatePage_del(str) {
document.getElementById(str).style.display="none";

}

function chtotal(id,num_dot_xs) 
{ 
var price= document.getElementById("price1_"+id); 
var num1= document.getElementById("num1_"+id);
var num2= document.getElementById("num2_"+id);
var num3= document.getElementById("num3_"+id);   
var moneyall= document.getElementById("moneyall_"+id);
num3.value=num2.value-num1.value
var money1=price.value * num3.value 
moneyall.value=FormatNumber(money1,num_dot_xs)
}

function chtotal2(id,num_dot_xs) 
{ 
var price= document.getElementById("price1_"+id); 
var num1= document.getElementById("num1_"+id);
var num2= document.getElementById("num2_"+id);
var num3= document.getElementById("num3_"+id);   
var moneyall= document.getElementById("moneyall_"+id);
num2.value=num1.value
num3.value=num2.value-num1.value
var money1=price.value * num3.value 
moneyall.value=FormatNumber(money1,num_dot_xs)
}

