var xmlHttp = GetIE10SafeXmlHttp();

function changeUnit(obj) {
	var $o = jQuery(obj);
	var $tr = $o.parentsUntil('.dataTBody').last();
	var $num = $tr.find('.thNum');
	var $price = $tr.find('.thPrice');
	var $money = $tr.find('.thMoney');
	var $unit = $tr.find('.thUnit');
	var oldBl = parseFloat($unit.children('option[value="'+$unit.attr('oldValue')+'"]').attr('bl'));
	var newBl = parseFloat($unit.children('option:selected').attr('bl'));
	var oldPrice = parseFloat($price.attr('oldValue').replace(/,/g,''));
	var rate = newBl / oldBl ;
	var newPrice = oldPrice * rate;
	var oldNum = parseFloat($num.attr('oldValue'));
	var newNum = oldNum / rate;
	$num.val(FormatNumber(newNum,window.sysConfig.floatnumber));
	$num.attr('max',$num.val());
	$price.val(FormatNumber(newPrice,window.sysConfig.moneynumber));
}

function callServer2(nameitr,ord,id) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   
   var u_name = document.getElementById("u_name"+nameitr).value;
   
   if ((u_name == null) || (u_name == "")) return;
  var url = "../price/cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w);
  };

  xmlHttp.send(null);  
}

function updatePage2(w) {
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


function callServer3(nameitr,ord,id) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}


function callServer4(ord,top) {

 if ((ord == null) || (ord == "")) return;
  var url = "../contract/num_click.asp?ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4(ord,top);
  };
  xmlHttp.send(null);  
}


function updatePage4(ord,top) {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    var res = xmlHttp.responseText;
	var w  = "trpx"+res;
 w=document.all[w]
	
  var url = "addlistadd.asp?ord="+escape(ord)+"&top="+escape(top);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage5(w);
  };
  xmlHttp.send(null);  
  }
}

function updatePage5(w) {
var test3=w;
  if (xmlHttp.readyState < 4) {
	test3.innerHTML="loading...";
  }

  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	
	test3.innerHTML=response;
	
	xmlHttp.abort();
  }
}

function del(str,id){
	var w  = document.all[str];
		
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w);
  };
  xmlHttp.send(null);  
}
function updatePage_del(str) {
     str.innerHTML="";

}

function del2(str,id){
	var w  = str;
		
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del2(w);
  };
  xmlHttp.send(null);  
}
function updatePage_del2(str) {

     document.getElementById(str).innerHTML="";

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

function ajaxSubmit_gys(nameitr,ord,unit){
    //获取用户输入
	var w  = "tt"+nameitr;
    var B=document.forms[1].B.value;
    var C=document.forms[1].C.value;
    var url = "cu2.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
var price= document.getElementById("price1_"+id); 
var num= document.getElementById("num1_"+id); 
var moneyall= document.getElementById("money1_"+id);
var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,''); 
moneyall.value=FormatNumber(money1,num_dot_xs);
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