

// 一个简单的测试是否IE浏览器的表达式
isIE = (document.all ? true : false);

// 得到IE中各元素真正的位移量，即使这个元素在一个表格中
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which) {
 iPos = 0
 while (elt!=null) {
  iPos += elt["offset" + which]
  elt = elt.offsetParent
 }
 return iPos
}
function ask() {
document.all.date.action = "savelistadd13.asp";
}


function add(ord,i,id) {
  var unit1 = document.getElementById("unit"+i).value;
  var num1 = document.getElementById("num"+i).value;
  var moneyall = document.getElementById("moneyall"+i).value;
  var ck = document.getElementById("ck"+i).value;
  var bz = document.getElementById("bz"+i).value;
  var js = document.getElementById("js"+i).value;
  var intro = document.getElementById("intro"+i).value;

  var w2  = "trpx"+(i-1)+"_"+id;
  w2=document.all[w2]
  if ( isNaN(num1) || ( Number(num1) >=  Number(num1old)) || (num1 == "") || ( Number(num1) == 0)) return;
  var url = "cu_ck.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&moneyall="+escape(moneyall)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function del(str,id)
{
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	plist.createSpanRows()
	var currRow = plist.getCurrRow(window.event.srcElement)

	if(currRow.all.length > 0){ plist.del(url,null); }
	else{
		currRow = window.event.srcElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function () {
			try{  //屏蔽错误
				plist.delcallback(currRow)();
			}
			catch(e){}
		}
		xmlHttp.send(null);
	}
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

function ph() {  //批号整体录入
var w = plist.getLength();
 for(var i=1; i<w; i++)
{
		if(document.getElementById("ph"+i)) document.getElementById("ph"+i).value = document.getElementById("phall").value;
}
}
function xlh() {
var w = plist.getLength();
 for(var i=1; i<w; i++)
　 {
		if(document.getElementById("xlh"+i))  document.getElementById("xlh"+i).value = document.getElementById("xlhall").value;
}
}
function datesc() {
var w = plist.getLength();
 for(var i=1; i<w; i++)
　 {
		if(document.getElementById("daysdatesc"+i+"Pos"))  document.getElementById("daysdatesc"+i+"Pos").value = document.getElementById("daysOfMonth7Pos").value;
}
}
function dateyx() {
var w = plist.getLength();
 for(var i=1; i<w; i++)
{
		if(document.getElementById("daysdateyx"+i+"Pos")) document.getElementById("daysdateyx"+i+"Pos").value = document.getElementById("daysOfMonth8Pos").value;
}
}
function bz() {
var w = plist.getLength();
 for(var i=1; i<w; i++)
{
		if(document.getElementById("bz"+i)) document.getElementById("bz"+i).value = document.getElementById("bzall").value;
}
}

function ck(kuout) {
	var w = plist.getLength();
	for(var i=1; i<=w-1; i++)
	{
		if(document.getElementById("ck"+i)){
			document.getElementById("ck"+i).value = document.getElementById("ckall").value;
			var id = document.getElementById("id"+i).value;
			var ord = document.getElementById("ord_"+i).value;
			var w2= document.getElementById("w"+i).value;
		}
	}
}

function callServer4(ord,top) {
	if ((ord == null) || (ord == "")) return;
	url = "addlistadd_rk.asp?Minus=1&ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	plist.add(url,click_pl);
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

function click_pl() {
  var url = "click_pl.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updateclick_pl();
  };
  xmlHttp.send(null);
}

function updateclick_pl() {
  if (xmlHttp.readyState < 4) {
	all_num.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	all_num.innerHTML=response;
	xmlHttp.abort();
  }
}

function getobjvalue(obj,v){
	if (obj) return obj.value;
	else return v;
}
function ckxz(ord,i,id,w) {
	window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
	var unit1 = document.getElementById("unit"+i).value;
	var num1 = document.getElementById("num"+i).value;
	var price1 = document.getElementById("pricetest"+i).value;
	var money1 = document.getElementById("moneyall"+i).value;
	var ck = document.getElementById("ck"+i).value;
	var ph = document.getElementById("ph"+i).value;
	var xlh = document.getElementById("xlh"+i).value;
	var datesc = document.getElementById("daysdatesc"+i+"Pos").value;
	var dateyx = document.getElementById("daysdateyx"+i+"Pos").value;
	var bz = document.getElementById("bz"+i).value;
	var js = document.getElementById("js"+i).value;
	var intro = getobjvalue(document.getElementById("intro"+i),"");
	var date2 = getobjvalue(document.getElementById("daysdate2"+i+"Pos"),"");
	var zdy1 = getobjvalue(document.getElementById("zdy1"+i),"");
	var zdy2 = getobjvalue(document.getElementById("zdy2"+i),"");
	var zdy3 = getobjvalue(document.getElementById("zdy3"+i),"");
	var zdy4 = getobjvalue(document.getElementById("zdy4"+i),"");
	var zdy5 = getobjvalue(document.getElementById("zdy5"+i),0);
	var zdy6 = getobjvalue(document.getElementById("zdy6"+i),0);

  	var w2  = w;
  	w2=document.all[w2]
  	var url = "cu_ck2_rk.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&price1="+escape(price1)+"&money1="+escape(money1)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&date2="+escape(date2)+"&zdy1="+escape(zdy1)+"&zdy2="+escape(zdy2)+"&zdy3="+escape(zdy3)+"&zdy4="+escape(zdy4)+"&zdy5="+escape(zdy5)+"&zdy6="+escape(zdy6)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
  window.uintchangepan.innerHTML = xmlHttp.responseText;
}

function ckxzall(ord,i,id,w) {
	window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
	var unit1 = document.getElementById("unit"+i).value;
	var num1 = document.getElementById("num"+i).value;
	var price1 = document.getElementById("pricetest"+i).value;
	var money1 = document.getElementById("moneyall"+i).value;
	var ck = document.getElementById("ck"+i).value;
	var ph = document.getElementById("ph"+i).value;
	var xlh = document.getElementById("xlh"+i).value;
	var datesc = document.getElementById("daysdatesc"+i+"Pos").value;
	var dateyx = document.getElementById("daysdateyx"+i+"Pos").value;
	var bz = document.getElementById("bz"+i).value;
	var js = document.getElementById("js"+i).value;
	var intro = document.getElementById("intro"+i).value;

   var w2  = w;
   w2=document.all[w2]
  var url = "cu_ck2_rk.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&price1="+escape(price1)+"&money1="+escape(money1)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
  window.uintchangepan.innerHTML = xmlHttp.responseText;
}


function updatePage_ckxz(w2) {
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
