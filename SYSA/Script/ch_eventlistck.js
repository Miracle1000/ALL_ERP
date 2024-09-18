
var xmlHttp = GetIE10SafeXmlHttp();

function callServer(nameitr,ord,i,id) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var num1 = document.getElementById("num"+id).value;
  var date2 = document.getElementById("daysdate1_"+id+"Pos").value;
  var intro1 = document.getElementById("intro_"+id).value;
   var w  = document.all[nameitr];
   var w2  = "trpx"+i;
   w2=document.all[w2]
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu_add.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&date2="+escape(date2)+"&intro1="+escape(intro1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w2);
  };

  xmlHttp.send(null);
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
function ph() {
var w = document.getElementById("i").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("ph"+i).value = document.getElementById("phall").value;
}
}
function xlh() {
var w = document.getElementById("i").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("xlh"+i).value = document.getElementById("xlhall").value;
}
}
function datesc() {
var w = document.getElementById("i").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("daysdatesc"+i+"Pos").value = document.getElementById("daysOfMonth7Pos").value;
}
}
function dateyx() {
var w = document.getElementById("i").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("daysdateyx"+i+"Pos").value = document.getElementById("daysOfMonth8Pos").value;
}
}
function bz() {
var w = document.getElementById("i").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("bz"+i).value = document.getElementById("bzall").value;
}
}

function del(str,id){

	var w  = str;

	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w);
  };
  xmlHttp.send(null);
}
function updatePage_del(str) {
document.getElementById(str).style.display="none";

}



function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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
	if(price&&num&&moneyall)
	{
		var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,'');
		moneyall.value=FormatNumber(money1,num_dot_xs);
	}
}

function callServer2(nameitr,ord,id) {
	var w  = "showStoreInfo";
	w=document.all[w]
	w.style.left = event.x;
	w.style.top = event.y;
	var u_name = document.getElementById("u_name"+nameitr).value;

	if ((u_name == null) || (u_name == "")) return;
	var url = "../contract/cu_kccx.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
   var w  = "showStoreInfo";
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}

$(function () {
	resizeDiv();
	$(window).resize(function () {
		resizeDiv();
	});
});
function resizeDiv() {
	var allwidth = $(window).width();
	var mxbox = $('#mxdiv');
	mxbox.css({ 'width': allwidth, 'borderBottom': '0px' });
	if (document.documentElement.className.indexOf("IE7") >= 0) {
		var h = 0;
		if (mxbox.get(0).scrollWidth > $('#mxdiv').innerWidth()) { h = 20; }
		mxbox.css({ 'height': $('#mxdiv').children().eq(0).height() + h });
	}
}
