

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


function checklength(i){
	var ss=document.getElementById("intro"+i).value;
	if (document.getElementById("intro"+i).value.length>200){
		alert("长度不能超过200个字！");
		document.getElementById("intro"+i).value=ss.substr(0,200);
	}
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

function ph() {
var w = document.getElementById("alli").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("ph"+i).value = document.getElementById("phall").value;
}
}
function xlh() {
var w = document.getElementById("alli").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("xlh"+i).value = document.getElementById("xlhall").value;
}
}
function datesc() {
var w = document.getElementById("alli").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("daysdatesc"+i+"Pos").value = document.getElementById("daysOfMonth7Pos").value;
}
}
function dateyx() {
var w = document.getElementById("alli").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("daysdateyx"+i+"Pos").value = document.getElementById("daysOfMonth8Pos").value;
}
}
function bz() {
var w = document.getElementById("alli").value;
 for(var i=1; i<w; i++)
　 {
document.getElementById("bz"+i).value = document.getElementById("bzall").value;
}
}

function ck() {
var w = document.getElementById("alli").value;

 for(var i=1; i<=w-1; i++)
　 {
document.getElementById("ck"+i).value = document.getElementById("ckall").value;

var id = document.getElementById("id"+i).value;
var ord = document.getElementById("ord_"+i).value;
var w2= document.getElementById("w"+i).value;
ckxz(ord,i,id,w2,1)
}
}

function ck2() {
var w = document.getElementById("alli").value;

 for(var i=1; i<=w-1; i++)
　 {
document.getElementById("ck_2"+i).value = document.getElementById("ck2all").value;
}
}


function callServer4(ord,top,unit) {
	unit = unit || '';
	if ((ord == null) || (ord == "")) return;
	var url = "addlistadd_db_sq.asp?ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)+"&unit="+unit;
	plist.add(url,click_pl); // 添加
}


function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "search_cp.asp?cstore=1&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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

function chtotal(id)
{
var price= document.getElementById("pricetest"+id);
var num= document.getElementById("num"+id);
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value * num.value
moneyall.value=FormatNumber(money1,2)
}


function check_kh(ord,unit,unit2,ckjb,ck,id,num1,kcid) {
  var w  = "ck2xz_"+id;
   w=document.all[w]

  var url = "../store/ku_unit_cf.asp?ord="+escape(ord)+"&unit="+escape(unit)+"&unit2="+escape(unit2)+"&ckjb="+escape(ckjb)+"&ck="+escape(ck)+"&id="+escape(id)+"&num1="+escape(num1)+"&kcid="+escape(kcid)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w);
  };
  xmlHttp.send(null);
}
function updatePage2(w) {
  var test7=w

  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	xmlHttp.abort();
  }

}

function check_ckxz(i) {
   var ck = document.getElementById("ck"+i).value;
  if (ck != "") return true;
  alert("请先选择仓库！")
}

function check_sp() {
   var ck = document.getElementsByName("complete");
 for (var i=0;i<ck.length;i++)
 {
   if(ck[i].checked)
   return true;
  }
   alert("没有选中！");
  return false;


}



function ckxz(ord,i,id,w,sort1,kuout) {
  var unit1 = document.getElementById("unit"+i).value;
  var num1 = document.getElementById("num"+i).value;
  var ck = document.getElementById("ck"+i).value;
  var bz = document.getElementById("bz"+i).value;
  var js = document.getElementById("js"+i).value;
  var intro = document.getElementById("intro"+i).value;
   var w2  = w;
   w2=document.all[w2]
  var url = "cu_ck2_db.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&sort1="+escape(sort1)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&kuout="+escape(kuout)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_ckxz(w2);
  };

  xmlHttp.send(null);
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

function zdkc(id) {
   var w2  = "zdkc"+id;
   w2=document.all[w2]
  var url = "cu_kuindb.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage_zdkc(w2);
  };

  xmlHttp.send(null);
}

function updatePage_zdkc(w2) {
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





function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "../contract/search_cp.asp?cstore=1&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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

