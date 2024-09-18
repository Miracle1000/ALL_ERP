
function callServerall() {
	var id_show = document.getElementById("id_show").value;
	if (id_show != "") return;
	var url = "../caigou/cu4.asp?type=all";
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePageall();
	};
	xmlHttp.send(null);  
}

function updatePageall() {
	var test7=document.getElementById("gysall");
	if (xmlHttp.readyState < 4) {
		test7.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test7.innerHTML=response;
		var id_show= document.getElementById("id_show");
		id_show.value="1"
		xmlHttp.abort();
	}
}

function listall_close(){
	document.all["gysall"].innerHTML="";
	var id_show= document.getElementById("id_show");
	id_show.value=""
	xmlHttp.abort();
}

function ajaxSubmit_gysall(){
    //获取用户输入
	var w  = "gysall";
	var B=document.getElementById("B1").value;
	var C=document.getElementById("C1").value;
    var url = "../caigou/cu4.asp?type=all&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage_gysall(w);
  };
  xmlHttp.send(null);  
}
function updatePage_gysall(w) {
	if (xmlHttp.readyState < 4) {
		document.getElementById(w).innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		document.getElementById(w).innerHTML=response;
	}
}
function callServerall_1(gysord,name){
	
    var url = "../caigou/cu5.asp?type=all&gysord="+escape(gysord)+"&tamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){		
		updatePage_1(name);
	}
	xmlHttp.send(null);  
}
function updatePage_1(name){
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		if(response == "<span id='trpx0'></span>-1"){
			alert("产品明细为空");
			return;
		}else{
			var trlist=response.split("");
			document.getElementById("gys_all").innerHTML=name+"";
		
			document.getElementById("contentall").innerHTML=response;
			document.getElementById("gysall").innerHTML="";
			var id_show= document.getElementById("id_show");
			id_show.value="";
			window.mxSpanRows=null;
		}
		xmlHttp.abort();
	}
}

function callServerall_2(gysord,name){
	
    var url = "../caigou/cu6.asp?type=all&gysord="+escape(gysord)+"&tamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){		
		updatePage_2(name);
	}
	xmlHttp.send(null);  
}
function updatePage_2(name){
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		if(response == ""){
			alert("产品明细为空");
			return;
		}else{
			var trlist=response.split("\2");
			document.getElementById("gys_all").innerHTML=name+"";
			for (n=0;n<trlist.length ; n++)
			{
				var tdArr = trlist[n].split("\1");
				if (document.getElementById("ttest"+tdArr[0]))
				{
					document.getElementById("ttest"+tdArr[0]).innerHTML = tdArr[1];
					document.getElementById("pricetest"+tdArr[0]).value = tdArr[2];
					chtotal(tdArr[0],window.sysConfig.moneynumber);
				}
			}
			document.getElementById("gysall").innerHTML="";
			var id_show= document.getElementById("id_show");
			id_show.value="";
			window.mxSpanRows=null;
		}
		xmlHttp.abort();
	}
}

function setall_num_price(type,obj,num_dot_xs){
	var str_id="";
	var inputs=document.getElementsByTagName("input");
	if (type=="num" && inputs.length>0)
	{
		for (n=0;n<inputs.length;n++ )
		{
			if (inputs[n].id.indexOf("num")>=0)
			{
				str_id=inputs[n].id.replace("num","");
				if(obj.value.length==0){
					inputs[n].value=inputs[n].defaultValue;
					inputs[n].style.color='#000';
				}else{
					inputs[n].value=obj.value;
				}
				inputs[n].value=obj.value;
				chtotal(str_id,num_dot_xs);
			}
		}
	}
	else if (type=="price" && inputs.length>0)
	{
		for (n=0;n<inputs.length;n++ )
		{	
			if (inputs[n].id.indexOf("pricetest")>=0)
			{
				str_id=inputs[n].id.replace("pricetest","");
				inputs[n].value=obj.value;
				chtotal(str_id,num_dot_xs);
				//document.getElementById("moneyall"+str_id).value=obj.value*document.getElementById("num"+str_id).value;
				//checkDot('moneyall'+str_id,num_dot_xs)
			}
		}
	}
}
//供应商选择翻页
function ReloadPage()
{
	var t = new Date();
	var smt = t.getTime().toString().replace(".","");
	var hs = false;
	var hs2 = false;
	var box = document.getElementById("gys_currIndex");
	var url = box.getAttribute("rdata").split("&");
	for (var i = 0; i < url.length ; i++ )
	{
		var item = url[i].split("=")
		if(item[0]=="currindex")
		{
			url[i] = "currindex=" + box.value;
			hs = true;
		}
		if(item[0]=="pagesize")
		{
			url[i] = "pagesize=" + document.getElementById("gys_pagesize").value;
			hs2 = true;
		}
		if(item=="timestamp")
		{
			url[i] = "timestamp=" + smt;
		}
	}
	if (hs==false)
	{
		url[url.length] = "currindex=" + box.value;
	}
	if (hs2==false)
	{
		url[url.length] = "pagesize=" + document.getElementById("gys_pagesize").value;
	}
	url = url.join("&")
	var url = "../caigou/cu4.asp?" + url;
	xmlHttp.open("GET", url, false);
	xmlHttp.send();
	document.getElementById("gys_listtb").parentNode.innerHTML = xmlHttp.responseText;
	xmlHttp.abort();
}
function Go_preIndex()
{
	var box = document.getElementById("gys_currIndex");
	var v = box.value - 1;
	if(v<0){ return; }
	document.getElementById("gys_currIndex").value = v;
	ReloadPage();
}
function Go_nextIndex()
{
	var box = document.getElementById("gys_currIndex");
	var v = box.value*1 + 1;
	if(v>box.options.length) {v = box.options.length;} 
	document.getElementById("gys_currIndex").value = v;
	ReloadPage();
}