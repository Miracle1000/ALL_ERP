
function openwin()
{
window.open("../search/result4.asp","","height=250,width=450,resizable=yes,scrollbars=yes,status=no,toolbar=no,menubar=yes,location=no");
}


function check_kh(ord) {

  var url = "../event/search_kh.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
	xmlHttp.abort();
  }

}
