
function delqc(ord){
	if(ord != ""){
		if(confirm("确定要删除吗？")){
			var url = "delqc.asp?ord="+ ord +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState == 4) {
					var response = xmlHttp.responseText;
					if(response!=""){
						var arr_res = response.split("|");
						if(arr_res[0]=="0"){
							alert("请选择需删除的质检单");
						}else if(arr_res[0]=="1"){
							window.close();
							if(window.opener)window.opener.location.reload();
						}else if(arr_res[0]=="2"){
							alert("该质检单不允许删除");
						}
					}else{
						alert("出现未知错误，请重试");
					}
					xmlHttp.abort();
				}
			};
			xmlHttp.send(null); 
		}
	}
}
