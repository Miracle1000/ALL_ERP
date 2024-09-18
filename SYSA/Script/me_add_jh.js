

function check_kh(ord) { 
  var url = "../event/search_cp.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(ord);
  };
  xmlHttp.send(null);  
}

function updatePage2(ord) {
  if (xmlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	khmc.innerHTML=response;
	callServer2(ord)
  }
}

function callServer2(ord) { 
  var url = "../event/search_unit.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage3(ord);
  };
  xmlHttp.send(null);  
}

function updatePage3(ord) {
  if (xmlHttp.readyState < 4) {
	unit.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	unit.innerHTML=response;
	xmlHttp.abort();
  }
}
