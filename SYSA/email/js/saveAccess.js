// JavaScript Document
	var xmlHttp = GetIE10SafeXmlHttp();
		//获取附件
function getAccess(sendID,recvID,strID,isdel) 
{
  var url = "getAccess.asp?sendID="+sendID+"&recvID="+recvID+"&delMail="+isdel+"&mytimestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	//alert(url);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){
  updateAccess();
  };
  xmlHttp.send(null);  
}

function updateAccess() {
	if (xmlHttp.readyState < 4) {
		Access.innerHTML="正在下载附件，请稍等！loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText.split("</noscript>")[1];
		Access.innerHTML=response;
		if (response.length==0)
		{
			alert("获取失败,请进入邮箱直接下载！");
		}
		try
		{
			window.parent.location.reload();
		}
		catch(e1)
		{}
	}
}
function callServer2() {
  var url = "liebiao_tj_recv.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
