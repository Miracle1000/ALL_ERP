
var xmlHttp = GetIE10SafeXmlHttp();
function check_kh(ord) {

  var url = "../event/search_gys.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

