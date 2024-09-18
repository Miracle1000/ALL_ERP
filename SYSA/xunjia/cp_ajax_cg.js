var xmlHttp = GetIE10SafeXmlHttp();

function callServer(nameitr,ord,i,id) {
  var w2 = plist.getParent(window.event.srcElement,5);
  var u_name = document.getElementById("u_name"+nameitr).value;
  var num1 = document.getElementById("num"+id).value;
  var intro1 = document.getElementById("intro_"+id).value;
   var w  = document.all[nameitr];

  if ((u_name == null) || (u_name == "")) return;
  var url = "../caigou/cu.asp?isyg=1&unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&intro1="+escape(intro1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w2);
  };
  
  xmlHttp.send(null);  
}

function SaveValue(nameitr,xsord,xIn,xId)
{	
	callServer(nameitr,xsord,xIn,xId);
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

function callServer2(nameitr,ord,company,id) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var id_show = document.getElementById("id_show").value;
   var w  = "tt"+nameitr;
   w=document.all[w]
   var w2  = "t"+nameitr;
   w2=document.all[w2]
   var w3  = document.all[nameitr];
  if (id_show != "") return;
  
  var url = "../caigou/cu2.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&company1="+escape(company)+"&nameitr="+escape(nameitr);
 
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
  var url = "../caigou/cu3.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gs="+escape(company)+"&nameitr="+escape(nameitr);
  // document.write (url);
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
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML="";
	test7.innerHTML=response;
	var pricejctest= document.getElementById("pricejc"+id); 
    var pricetest= document.getElementById("price"+id);
    pricetest.value=pricejctest.value 
	var id_show= document.getElementById("id_show");
	id_show.value=""
	xmlHttp.abort();
  }
}


function callServer4(ord,top,unit) {
	unit = unit || '';
	if ((ord == null) || (ord == "")) return;
	var url = "../caigou/addlistadd13.asp?ord="+escape(ord)+"&top="+escape(top) + "&unit="+unit+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	plist.add(url,null);
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

function del(str,id){
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	plist.del(url,null);
}



function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "../caigou/search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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
  }
}

function ajaxSubmit_gys(nameitr,ord,unit,id){
    //获取用户输入
	var w  = "tt"+nameitr;
    //var B=document.forms[1].B.value;
    //var C=document.forms[1].C.value;
	var B=document.date.B.value;
    var C=document.date.C.value;
    var url = "../caigou/cu2.asp?id="+id+"&unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&B="+escape(B)+"&C="+escape(C) +"&stimestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);

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
  }
}

function NoSubmit(ev)

{

    if( ev.keyCode == 13 )

    {

        return false;

    }

    return true;

}



function chtotal(id,num_dot_xs) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,''); 
moneyall.value=FormatNumber(money1,num_dot_xs);
}

function callServer2_ls(nameitr,ord,id) {
   var w  = "lstt"+nameitr;
   w=document.all[w]
   var u_name = document.getElementById("u_name"+nameitr).value;
   var gys = document.getElementById("gys_"+id).value;
   if ((u_name == null) || (u_name == "")) return;
  var url = "../caigou/cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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


function callServer3_lsclose(nameitr) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   var id_show= document.getElementById("id_show");
   id_show.value=""
   xmlHttp.abort();
}

function search_lb() {
  var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_sh_lb();
  };
  xmlHttp.send(null);  
}
function updatePage_sh_lb() {
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

//by chenwei 20100909
function cptj(ord,top) {
  setTimeout("callServer4('"+ord+"','"+top+"')",1000);
   xmlHttp.abort();
}