
//高级检索
var xmlHttp = GetIE10SafeXmlHttp(); 
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
function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=15;
}
