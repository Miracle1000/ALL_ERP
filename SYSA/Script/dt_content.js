
function toArchive(ty,fileId,act){
	if(fileId==""){
		alert("您没有选择任何文档，请选择后再归档！");
	}else{
		var gdStr = "确认归档？";
		if(act==0){
			gdStr = "确认取消归档？";
		}
		if(confirm(gdStr)){
			var XMlHttp = GetIE10SafeXmlHttp();
			var url = ""
			if(ty=="document"){
				url = "archive.asp?ord="+fileId+"&act="+act+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			}else if(ty=="documentlist"){
				url = "archive.asp?id="+fileId+"&act="+act+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			}
			XMlHttp.open("GET", url, false);
			XMlHttp.onreadystatechange = function(){			
				if (XMlHttp.readyState == 4) {
					var response = XMlHttp.responseText;
					var arr_res = response.split("|");
					if(arr_res[0]=="-1"){
						if(act==1){
							alert("不允许归档！");
						}else if(act==0){
							alert("不允许取消归档！");
						}
						return;
					}else if(arr_res[0]=="0"){
						if(act==1){
							alert("您没有选择任何文档，请选择后再归档！");
						}else if(act==0){
							alert("您没有选择任何文档，请选择后再取消归档！");
						}
					}else if(arr_res[0]=="1"){
						window.location.reload();
					}else if(arr_res[0]=="2"){
						if(act==1){
							alert("不允许归档！");
						}else if(act==0){
							alert("不允许取消归档！");
						}
						return;
					}
				}
			};
			XMlHttp.send(null);
		}
	}
}

function delWD(ty,wdord){
	if(wdord!=""){
		if(confirm("确定删除?")){
			var XMlHttp = GetIE10SafeXmlHttp();
			var url = ""
			if(ty=="document"){
				url = "delete.asp?ord="+wdord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			}else if(ty="documentlist"){
				url = "delete.asp?id="+wdord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			}
			XMlHttp.open("GET", url, false);
			XMlHttp.onreadystatechange = function(){			
				if (XMlHttp.readyState == 4) {
					var response = XMlHttp.responseText;
					var arr_res = response.split("|");
					if(arr_res[0]=="-1"){
						alert("不允许删除！");
						return;
					}else if(arr_res[0]=="0"){
						alert("您没有选择任何文档，请选择后再删除！");
					}else if(arr_res[0]=="1"){
						if(ty=="document"){
							if(window.opener.lvw_refresh("mlistvw"))window.opener.lvw_refresh("mlistvw");window.close();
						}else if(ty="documentlist"){
							window.location.reload();
						}
					}else if(arr_res[0]=="2"){
						alert("不允许删除！");
						return;
					}
				}
			};
			XMlHttp.send(null);
		}
	}
}
