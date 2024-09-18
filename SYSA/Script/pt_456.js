
function ask() { 
  date.submit(); 
}

function callServer(nameitr) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = document.all[nameitr];
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?name=" + escape(u_name);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w);
  };
  xmlHttp.send(null);  
}

function updatePage(namei) {
var test7=namei
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
  }

}
