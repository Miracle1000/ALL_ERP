


function callServer() {
  var u_name = document.getElementById("u_name").value;
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?name=" + escape(u_name);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = updatePage;
  xmlHttp.send(null);  
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	test1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test1.innerHTML=response; }
}
 function window.onload(){
 parent.document.getElementById("cFF2").style.height=document.body.scrollHeight;
 parent.parent.document.getElementById("cFF").style.height=parent.document.body.scrollHeight;
}
