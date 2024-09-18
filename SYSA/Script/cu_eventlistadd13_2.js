
var xmlHttp = GetIE10SafeXmlHttp();

function callServer(nameitr,ord,company) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = document.all[nameitr];
   var w2  = document.all[ord];
  
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&company1="+escape(company)+"&nameitr="+escape(nameitr);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w);
  };
  document.getElementById("t"+nameitr).style.display='none';
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


function callServer2(nameitr,ord,company) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = "tt"+nameitr;
   w=document.all[w]
   var w2  = document.all[ord];
   var w3  = document.all[nameitr];
  
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu2.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&company1="+escape(company)+"&nameitr="+escape(nameitr);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w);
  };
  document.getElementById("t"+nameitr).style.display='none';
  xmlHttp.send(null);  
}

function updatePage2(namei) {
var test7=namei
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
  }

}


function callServer3(nameitr,ord,company) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = document.all[nameitr];
   var w2  = document.all[ord];
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu3.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&gs="+escape(company);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage3(w);
  };
  document.getElementById("tt"+nameitr).style.display='none';
  xmlHttp.send(null);  
}

function updatePage3(namei) {
var test7=namei
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
  }
}

function chtotal(id) 
{ 
var price= document.getElementById("price"+id); 
var num= document.getElementById("num"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value * num.value 
moneyall.value=FormatNumber(money1,2)

} 

