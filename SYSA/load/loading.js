var xmlHttp = GetIE10SafeXmlHttp();

function callServer() {
   var w  = "trpx";
   w=document.all[w]
  var url = "../load/alert.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w);
  };
  
  xmlHttp.send(null);  
}

function updatePage(w) {
var test6=w
  if (xmlHttp.readyState < 4) {
	trpx.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx.innerHTML=response;
	xmlHttp.abort();
  }

}
