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
	plist.add("addlistadd.asp?ord="+escape(ord)+"&top="+escape(top));
}

function del(str,id){

	plist.del("../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100))

}

function UnitChange(nameitr,ord,i,id) {
	  var UpdateCol =  ",num1,price1,money1,折扣,"; //单位更改默认只更新这几列数据
	  window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
	  var u_name = document.getElementById("u_name"+nameitr).value;
	  var num1 = document.getElementById("num"+id).value;
	   var w  = document.all[nameitr];
	   var w2  = "trpx"+i;
	   w2=document.all[w2]
	  if ((u_name == null) || (u_name == "")) return;
	  var url = "cu.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	  xmlHttp.open("GET", url, false);
	  xmlHttp.send(null);

	   var div = document.createElement("DIV")
	  div.innerHTML = xmlHttp.responseText
	  var datatr =  div.all[0].rows[0];
	  var currRow = window.uintchangepan.all[0].rows[0]
	  var headRow = document.getElementById("productlistHead") //用定义表头
	  if(headRow){
			for (var i=0;i<headRow.cells.length;i++ )
			{
				var cell= headRow.cells[i];
				if(cell.dbname && UpdateCol.indexOf("," + cell.dbname + ",")>=0){
					var nv = datatr.cells[i].innerHTML;
					currRow.cells[i].innerHTML = nv;
				}
			}
	  }
	  else{
			 window.uintchangepan.innerHTML = xmlHttp.responseText;
	  }
	  div = null;	
	 
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

function chtotal(id,num_dot_xs,jfzt) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var zhekou= document.getElementById("zhekou"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,'')  
moneyall.value=FormatNumber(money1,num_dot_xs)

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

function cptj(ord,top) {
  setTimeout("callServer4('"+ord+"','"+top+"')",1000);
   xmlHttp.abort();
}


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