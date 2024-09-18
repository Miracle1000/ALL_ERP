
function loadqc(act){
	var page = "qcsp";
	var noword = document.getElementById("caigouQC").value;
	var url = "loadqc.asp?ord="+noword+"&act="+act+"&page="+page+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;	
			var arr_res = response.split("|");
			if(arr_res[0]=="0"){
				alert("没有了");
			}else if(arr_res[0]=="1"){
				var tourl = arr_res[1];
				if(tourl != ""){
					window.location.href=page+".asp?ord="+tourl;
				}
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);  
}
