
function openwin()
{
window.open("../search/result4.asp","","height=250,width=450,resizable=yes,scrollbars=yes,status=no,toolbar=no,menubar=yes,location=no");
}

var XMlHttp = GetIE10SafeXmlHttp();

function check_kh(ord) {

  var url = "../event/search_kh.asp?ord="+escape(ord)+"&cc=2&N=1&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  XMlHttp.open("GET", url, false);
  XMlHttp.onreadystatechange = function(){

  updatePage2();
  };
  XMlHttp.send(null);
}

function updatePage2() {
  if (XMlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (XMlHttp.readyState == 4) {
    var response = XMlHttp.responseText;
	khmc.innerHTML=response;
  }
}
function check_xm(ord) {
  var url = "../event/search_xm.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  XMlHttp.open("GET", url, false);
  XMlHttp.onreadystatechange = function(){

  updatePage3();
  };
  XMlHttp.send(null);
}

function updatePage3() {
  if (XMlHttp.readyState < 4) {
	xmmc.innerHTML="loading...";
  }
  if (XMlHttp.readyState == 4) {
    var response = XMlHttp.responseText;
	xmmc.innerHTML=response;
  }
}
