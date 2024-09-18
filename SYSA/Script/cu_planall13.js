
function Myopen(divID) {
	if (divID.style.display == "") {
		divID.style.display = "none"
	} else {
		divID.style.display = ""
	}
	divID.style.left = 300;
	divID.style.top = 0;
}

function search_lb(sp) {
	var url = "liebiao_tj.asp?sp="+sp+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_lb();
	};
	xmlHttp.send(null);  
}
function updatePage_lb() {
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