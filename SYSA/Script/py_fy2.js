

function callServer2() {
  var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2();
  };
  xmlHttp.send(null);  
}
function updatePage2() {
var test7="ht1"
  if (xmlHttp.readyState < 4) {
	ht1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	ht1.innerHTML=response;
	xmlHttp.abort();
  }
}
function go(loc) {
window.location.href = loc;
}

function getPersons()
{
	var url = "AjaxPerson.asp?t=" + Math.round(Math.random()*100);
	xmlHttp.open("get",url,false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			document.getElementById("persons").innerHTML=xmlHttp.responseText.split("</noscript>")[1];
		}
	};
	xmlHttp.send(null);
}
