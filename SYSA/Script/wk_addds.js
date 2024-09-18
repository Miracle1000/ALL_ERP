function callServer() {
  var u_name = document.getElementById("u_name").value;
  if ((u_name == null) || (u_name == "")) return;
  var url = "ds.asp?name=" + escape(u_name);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = updatePage;
  xmlHttp.send(null);  
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	test1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test1.innerHTML=response;
  }

}
function CheckUrl(){
	var url = document.getElementById("jzds_Url");
	var urlMsg = document.getElementById("jzds_Url_Msg");
	if (url.value.indexOf("http://") != 0  && url.value.length > 0)
	{
		url.style.color = "red";
		urlMsg.style.display = "inline";
		return false;
	}
	else
	{
		url.style.color = "";
		urlMsg.style.display = "none";
		return true;
	}
}
function showLay(){
	for(var i=1;i<9;i++){
		var objDiv = eval("Layer"+i);
		if (objDiv.style.display=="none"){
			objDiv.style.display="";
		}else{
			objDiv.style.display="none";
		}
	}
}