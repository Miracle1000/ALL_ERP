
function callServer2() {
  var url = "liebiao_tj.asp?gategroup=1&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function setLockItems(obj, ldata)
{
	obj.title = obj.checked ? "取消标题栏" : "默认标题栏";
	var url = "setLockItems.asp?o=" + (obj.checked?"1":"0") + "&ld=" + escape(ldata) + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send();
	var r = xmlHttp.responseText;
	if(r!="ok"){alert(r)}
}
