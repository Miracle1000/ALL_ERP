

function callServer2() {
  var sp=document.getElementById("th_sp").value;
  var company=document.getElementById("th_company").value;
  var url = "liebiao_tj.asp?company="+company+"&sp="+sp+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
function __toggleGateNode(obj){
	var div=jQuery(obj);
	if(!obj.checked){
		div.next().find(':checked').each(function(){this.click();});
		div.next().hide();
		div.prev().hide();
	}else{
		div.next().show();
		div.prev().show();
	}
}
