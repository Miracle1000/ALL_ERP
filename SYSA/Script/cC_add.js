
function loadQCMX() {
	var url = "../event/cgqcmx.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		var qcmx = document.getElementById("qcmx")
		if (xmlHttp.readyState < 4) {
		qcmx.innerHTML="loading...";
		}
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			qcmx.innerHTML=response;
			xmlHttp.abort();
			setMXdiv();
		}
	};
	xmlHttp.send(null);  
}


function trim(str){ //删除左右两端的空格
	return str.replace(/(^\s*)|(\s*$)/g,"");
}

function mm(form)
{
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i];
		if (e.name != 'chkall')
		e.checked = form.chkall.checked;
	}
}

function setAllvalue(obj2){
	var name2 = obj2.name;
	var name1 = name2.replace("_2","");
	var inputs = document.getElementsByName(name1);
	for(i=0; i<inputs.length;i++){
		inputs[i].value = obj2.value;	
	}
	
}

function checkItems(){
	var mxAll = 0;
	mxAll = Number(document.getElementById("mxAll").value);	
	if(mxAll>0){
		if(typeof(document.date.thebox.length)=="undefined"){
			if(document.date.thebox.checked==false){
				alert("请选择质检单");	
				document.date.thebox.focus();
				return false;
			}else{
				return confirm("确定要删除吗？");
			}
		}else{
			var tbchecked = 0;
			for(i=0;i<mxAll;i++){
				if(document.date.thebox[i].checked==true){
					tbchecked = 1;
					break;
				}
			}
			if(tbchecked == 0){
				alert("请选择质检单");	
				document.date.thebox[0].focus();
				return false;	
			}else if(tbchecked == 1){
				return confirm("确定要删除吗？");
			}
		}
	}else{
		alert("质检明细中无记录，请选择关联采购单");	
	}
	
}

function delMXitems(){
	if(checkItems()){
		var mxAll = Number(document.getElementById("mxAll").value);
		var tbStr = "";
		
		if(typeof(document.date.thebox.length)=="undefined"){
			tbStr = document.date.thebox.value;
		}else{
			for(i=0;i<document.date.thebox.length;i++){
				if(document.date.thebox[i].checked==true){
					tbStr += trim(document.date.thebox[i].value) + ",";
				}
			}
		}
		if(tbStr!=""){
			delMX(tbStr);
		}
		
	}
}

function delMXitem(ord){
	if(ord!=""){
		if(confirm("确定要删除吗？")){
			delMX(ord);
		}
	}
}

function delMX(tbStr){
		var tabmx = document.getElementById("tabmx");
		var mxAll = Number(document.getElementById("mxAll").value);
		var cgord = document.getElementById("caigou").value;
		tbStr = tbStr + "";
		if(tbStr.indexOf(",")==-1){
			tbStr = trim(tbStr);
		}else{
			tbStr = tbStr.substr(0,tbStr.length-1);
		}
		var arr_tb = tbStr.split(",");
		var len_tb = arr_tb.length;
		var url = "../event/cgqcmx_del.asp?ord="+tbStr+"&cgord="+cgord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){
			if (xmlHttp.readyState == 4) {
				var restx = xmlHttp.responseText;
				if(restx == "1"){
					for(i=0;i<=len_tb;i++){
						if(arr_tb[i] != ""){
							try{
								tabmx.deleteRow(document.getElementById("tr"+arr_tb[i]).rowIndex);
							}catch(e){}
						}
					}
					if((mxAll-len_tb)<1){
						try{
							tabmx.deleteRow(document.getElementById("tr0").rowIndex);;	
						}catch(e){}
					}
					if((mxAll-len_tb)>0){
						document.getElementById("mxAll").value = (mxAll-len_tb);
					}else{
						document.getElementById("mxAll").value = 0;
					}
				}else if(restx == "0"){
					alert("质检明细中无记录，请选择关联采购单");	
				}else{
					alert("质检明细删除出现未知错误，请重试");	
				}
				xmlHttp.abort();
			}
		};
		xmlHttp.send(null);  
}

function setMXdiv(){
	var mxdiv = document.getElementById("mxdiv");
	mxdiv.style.width = (document.getElementById("posW").offsetLeft) + "px";
}

function checkAllMX(){
	var mxAll = Number(document.getElementById("mxAll").value);
	if(mxAll<1){
		alert("质检明细中无记录，请选择关联采购单");
		return false;
	}
}

