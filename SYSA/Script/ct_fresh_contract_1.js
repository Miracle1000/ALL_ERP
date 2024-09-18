
var xmlHttp = false;
try {
  xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
} catch (e) {
  try {
    xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
  } catch (e2) {
    xmlHttp = false;
  }
}
if (!xmlHttp && typeof XMLHttpRequest != 'undefined') {
  xmlHttp = new XMLHttpRequest();
}
function check_kh(ord,from) {
	from = from || '';
  var url = "../event/search_kh.asp?ord="+escape(ord) + "&from=" + from +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
   xmlHttp.onreadystatechange = function() {}
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
var u_name = document.getElementById("htid").value;
var title = document.getElementById("title");
var zt=company+u_name
	title.value=zt;
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

