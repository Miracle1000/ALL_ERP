var xmlHttp = GetIE10SafeXmlHttp();

function callServer(nameitr,ord,i,id) {
  window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
  var u_name = document.getElementById("u_name"+nameitr).value;
  var num1 = document.getElementById("num"+id).value;
  var date2 = document.getElementById("daysdate1_"+id+"Pos").value;
  var intro1 = document.getElementById("intro_"+id).value;
   var w  = document.all[nameitr];
   var w2  = "trpx"+i;
   w2=document.all[w2]
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&date2="+escape(date2)+"&intro1="+escape(intro1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);  
  window.uintchangepan.innerHTML = xmlHttp.responseText;
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
  var url = "cu2.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&company1="+escape(company)+"&nameitr="+escape(nameitr);
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
  var url = "cu3.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gs="+escape(company)+"&nameitr="+escape(nameitr);
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
  var url = "../contract/num_click.asp?ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4(ord,top,unit);
  };
  xmlHttp.send(null);  
}


function updatePage4(ord,top,unit) {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    var res = xmlHttp.responseText;
	var w  = "trpx"+res;
 w=document.all[w]
	
  var url = "addlistadd13.asp?type=cg&ord="+escape(ord)+"&top="+escape(top)+"&unit="+unit;
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
	
    ar w  = str;
	
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

function del2(str,id){
	var w  = str;
	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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
    var url = "../contract/search_cp.asp?B="+escape(B)+"&C="+encodeURI(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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
    var B=document.forms[1].B.value;
    var C=document.forms[1].C.value;
    var url = "cu2.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&id="+escape(id)+"&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function checkPriceLimit(){
	var result=true;
	$('.input_price').each(function(){
		$obj = $(this);
		var maxVal = $obj.attr('maxZKPrice');
		var nowVal = $obj.val();
		var id=$obj.attr('id').replace('pricetest','');
		var discount = $('#zhekou'+id).val();
		if (nowVal.length==0 || discount.length==0 || isNaN(nowVal) || isNaN(discount)){
			result = false;
			return;
		}
		var priceAfterDiscount = parseFloat(nowVal) * parseFloat(discount);
		$obj.next('span').remove();
		if(priceAfterDiscount > parseFloat(maxVal)){
			$('<span class="red">折后单价('+FormatNumber(priceAfterDiscount,window.sysConfig.moneynumber)+')高于限价</span>').insertAfter($obj);
			$obj.trigger('focus');
			result = false;
		}
	});
	return result;
}

var runLock = false;
function chtotal(id,num_dot_xs,jfzt){ 
	if(runLock) return;
	runLock = true;
	var obj = event.srcElement;
	var objName = obj.name;
	var price= document.getElementById("pricetest"+id); 
	var num= document.getElementById("num"+id); 
	var zhekou= document.getElementById("zhekou"+id); 
	var moneyall= document.getElementById("moneyall"+id);

	var n=num.value,p=price.value,m=moneyall.value,z=zhekou.value;
	if(m.length==0||n.length==0||p.length==0||z.length==0||isNaN(n)||isNaN(p)||isNaN(m)||isNaN(z)){
		if(parseFloat(n)==0||parseFloat(p)==0){
			zhekou.value = '1';
			runLock = false;
			return;
		}
		runLock=false;
		return;
	}

	if (objName.indexOf('moneyall')==0){
		var discount = parseFloat(m) / parseFloat(n) / parseFloat(p);
		zhekou.value = FormatNumber(discount,window.sysConfig.discountDotNum);
	}else{
		moneyall.value=FormatNumber(parseFloat(p)*parseFloat(n)*parseFloat(z),num_dot_xs)
	}
	runLock=false;
}

function callServer2_ls(nameitr,ord,id) {
   var w  = "lstt"+nameitr;
   w=document.all[w]
   var u_name = document.getElementById("u_name"+nameitr).value;
   var gys = document.getElementById("gys_"+id).value;
   if ((u_name == null) || (u_name == "")) return;
  var url = "cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
