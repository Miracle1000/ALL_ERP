var xmlHttp = GetIE10SafeXmlHttp();

function callServer(nameitr,ord,i,id) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var num1 = document.getElementById("num"+id).value;
   var w  = document.all[nameitr];
   var w2  = "trpx"+i;
   w2=document.all[w2]
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w2);
  };
  
  xmlHttp.send(null);  
}


function callServer5(s,nameitr,ord,id) {
  var w  =s ;
   w=document.all[w]

   var u_name = document.getElementById("u_name"+nameitr).value;
   
   if ((u_name == null) || (u_name == "")) return;
  var url = "../contract/cu_kccx.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage_kc(w);
  };

  xmlHttp.send(null);  
}

function updatePage_kc(w) {
var test6=w
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
	xmlHttp.abort();
  }

}
function callServer6(t,nameitr,ord,id) {
   var w  =t;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}


function updatePage(w2) {
var test6=w2
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
	xmlHttp.abort();
  }

}


function callServer2_bj(nameitr,ord,id) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   
   var u_name = document.getElementById("u_name"+nameitr).value;
   var company = document.getElementsByName("company")[0].value;
   
   if ((u_name == null) || (u_name == "")) return;
	  var url = "../xunjia/cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&company="+escape(company)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	  xmlHttp.open("GET", url, false);
	  xmlHttp.onreadystatechange = function(){
			updatePage2_bj(w);
	  }
	  xmlHttp.send(null);  
}

function updatePage2_bj(w) {
var test6=w
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
	xmlHttp.abort();
  }

}


function callServer3_bj(nameitr,ord,id) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}


function xj_callServer4(ord,id,j,unit) {
 if ((ord == null) || (ord == "")) return;
  var url = "num_click.asp?ord="+escape(ord)+"&id="+escape(id) + "&j="+escape(j) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4(ord,id,j,unit);
  };
  xmlHttp.send(null);  
}



function updatePage4(ord,id,j,unit) {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    var res = xmlHttp.responseText;
	if (res.indexOf('out_of_lines:')==0){
		alert('询价明细超过限制，每个产品最多只能有'+res.replace('out_of_lines:','')+'条询价明细')
		return;
	}
	var w  = "trpx"+res;
  var url = "addlistadd.asp?ord="+escape(ord)+"&id="+escape(id)+"&j="+escape(j) + "&unit="+escape(unit) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage5(w,j);
  };
  xmlHttp.send(null);  
  }
}
//--TASK.2429.ZYF 2015-2-4 询价能显示实际供应商 
//--扩展函数，增加参数j，继承父函数的参数j
function updatePage5(w,j) {
var test3=document.all[w];
  if (xmlHttp.readyState < 4) {
	test3.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test3.innerHTML=response;
	xmlHttp.abort();
	try{
		var __numID = test3.innerHTML.match(/num1_\d+/g)[0];//--用正则匹配出数量文本框name值
		__numID = __numID.replace("1_","");					//--将name值处理为id值
		document.getElementById(__numID).value = document.getElementById("num1_" + j + "_" + j).value;//--为数量赋值
	}catch(e){}
  }
}


function callServer4(ord,id,j,unit) {
	if ((ord == null) || (ord == "")) return;
	var url = "addlistadd.asp?ord="+escape(ord)+"&id="+escape(id)+"&j="+escape(j) + "&unit="+escape(unit) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	plist.add(url,null);
}

function del(str,id){
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	plist.del(url,null)
}

function xj_del(str,id){
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	plist.del(url,null,true)  //删除时候不自动移动行
}


function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "../contract/search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_cp();
  };
  xmlHttp.send(null);  
}
function updatePage_cp() {
  if (xmlHttp.readyState < 4) {
	cp_search.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	cp_search.innerHTML=response;
	xmlHttp.abort();
  }
}

function ajaxSubmit_gys(nameitr,ord,unit,id){
    //获取用户输入
	var w  = "tt"+nameitr;
    var B=document.getElementById("B1").value;
    var C=document.getElementById("C1").value;
    var url = "../caigou/cu2.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr)+"&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_gys(w);
  };
  xmlHttp.send(null);  
}
function updatePage_gys(w) {
 var test7=document.all[w]
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	xmlHttp.abort();
  }
}

function chtotal(id,num_dot_xs) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,'');
moneyall.value=FormatNumber(money1,num_dot_xs);
}

function callServer2_ls(nameitr,ord,id,gys,unit) {
   var w  = "lstt"+nameitr;
   w=document.all[w]
  var url = "../caigou/cu_lishi.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2_ls(w);
  };

  xmlHttp.send(null);  
}

function updatePage2_ls(w) {
var test6=w
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
	xmlHttp.abort();
  }

}


function callServer3_ls(nameitr,ord,id) {
   var w  = "lstt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}

function callServer2(nameitr,ord,company,id) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var id_show = document.getElementById("id_show").value; 
   var w  = "tt"+nameitr;
   w=document.all[w]
   var w2  = "t"+nameitr;
   w2=document.all[w2]
   var w3  = document.all[nameitr];
  if (id_show != "") return;
  var url = "../caigou/cu2.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&company1="+escape(company)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w,w2);
  };
  xmlHttp.send(null);  
}

function updatePage2(namei,w2) {
var test7=namei
var test6=w2
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


function callServer3(nameitr,ord,company,id) {
	var u_name = document.getElementById("u_name"+nameitr).value;
	var w  = "t"+nameitr;
	w=document.all[w];
	var w2  = "tt"+nameitr;
	w2=document.all[w2];
	if ((u_name == null) || (u_name == "")) return;

	var url = "../caigou/cu3.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gs="+escape(company)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage3(w,nameitr,w2);
	};
	xmlHttp.send(null);  
}

function updatePage3(namei,id,w2) {
	var test7=namei
	var test6=w2
	if (xmlHttp.readyState < 4) {
		test7.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4){
		var response = xmlHttp.responseText;
		test6.innerHTML="";
		test7.innerHTML=response;
		try{
			var price= document.getElementById("pricejc"+id).value; 
			if (!price || price.length==0){ price = 0 ;}
			document.getElementById("pricetest"+id.replace("caigou","")).value =price ;
			var num = document.getElementById("num"+id.replace("caigou","")).value ; 
			if (!num || num.length==0){ num = 0 ;}
			document.getElementById("moneyall"+id.replace("caigou","")).value =FormatNumber(num*price,window.sysConfig.moneynumber) ;
		}catch(e){}
		var id_show= document.getElementById("id_show");
		id_show.value=""
		xmlHttp.abort();
	}
}

function callServer3_lsclose(nameitr) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   var id_show= document.getElementById("id_show");
   id_show.value=""
   xmlHttp.abort();
}


function callServer7(nameitr,ord,xjid) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = "tt"+nameitr;
   w=document.all[w]
  var url = "../xunjia/getXunjiaAction.asp?mxpxid="+escape(ord)+"&nameitr="+escape(nameitr) + "&xjid="+escape(xjid) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage7(w);
  };
  xmlHttp.send(null);  
}

function updatePage7(namei) {
var test7=namei
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	xmlHttp.abort();
  }

}

//无需询价操作
function callServer8(status,pid) {
	var url = "../xunjia/setXunjiaResult.asp?xjstatus="+escape(status)+"&pid="+escape(pid) + "&timestamp=" + new Date().getTime();
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage8(status,pid);
	};
	xmlHttp.send(null);  
}

function updatePage8(status,pid) {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		if(status=="1")
		{
			document.getElementById("xj_1_"+pid).style.display="none";
			document.getElementById("xj_2_"+pid).style.display="none";
			document.getElementById("xj_3_"+pid).style.display="";
			document.getElementById("price_xj_"+pid).style.display="none";
		}else{
			document.getElementById("xj_1_"+pid).style.display="";
			document.getElementById("xj_2_"+pid).style.display="";
			document.getElementById("xj_3_"+pid).style.display="none";
			document.getElementById("price_xj_"+pid).style.display="";
		}
		xmlHttp.abort();
	}
}
	function reloadgysPage()
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
		var url = "../caigou/cu2.asp?" + url;
		xmlHttp.open("GET", url, false);
		xmlHttp.send();
		document.getElementById("gys_listtb").parentNode.innerHTML = xmlHttp.responseText;
		xmlHttp.abort();
	}
	function gys_preIndex()
	{
		var box = document.getElementById("gys_currIndex");
		var v = box.value - 1;
		if(v<0){ return; }
		document.getElementById("gys_currIndex").value = v;
		reloadgysPage();
	}
	function gys_nextIndex()
	{
		var box = document.getElementById("gys_currIndex");
		var v = box.value*1 + 1;
		if(v>box.options.length) {v = box.options.length;} 
		document.getElementById("gys_currIndex").value = v;
		reloadgysPage();

	}
