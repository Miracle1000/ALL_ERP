

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
document.all.date.action = "savelistfh.asp?top="+window.sentTop; 
} 


function del(str,id){
    var w  = str;	
    var url = "../contract/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function(){
        updatePage_del(w);
    };
    xmlHttp.send(null);  
}
function updatePage_del(str) {
    document.getElementById(str).style.display="none";
    $('#mxdiv').css({ 'height': $('#mxdiv').eq(0).height() -37 });
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

function chtotal(id) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value * num.value 
moneyall.value=FormatNumber(money1,2)
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

function check_kh(ord){
    setTimeout("check_kh2("+ord+");",500);
}

function check_kh2(ord) {
  var url = "../sent/search_lxr.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2();
  };
  xmlHttp.send(null);  
}

function updatePage2() {
  if (xmlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        khmc.innerHTML = response;
        var pid = document.getElementById("cperson").value;
        showContact(pid);
	    xmlHttp.abort();
  }
}
function checkbhstr(){
	document.getElementById("bh_ts").innerText="";
	return true;
}
window.DoRefresh=function()
{
	$.ajax({
	url:"select_lxr.asp?company="+window.sentKH+"&order1="+window.sentOrder1,
		success:function(r){
			$('#personDiv').html(r);
		}
	});
}

$(function(){
	var mxdiv = $('#mxdiv');
	var h = 0;
	var wg = 4;
    try {
        if ($("body").get(0).scrollHeight > $("body").innerHeight()) {
            wg = 20;
        }
        $('#introinfo').css({ 'width': $('#mxdiv').get(0).scrollWidth });
        mxdiv.css({ 'width': $('body').width() - wg });
        if (mxdiv.get(0).scrollWidth > mxdiv.innerWidth()) {
            h = 20;
        }
        mxdiv.css({ 'height': mxdiv.eq(0).height() + h });
    } catch (e) { }
	$(window).resize(function(){
		resizeDiv(); 
	});
});

function resizeDiv(){
		var h = 0;
		var wg = 4;
		if ($("body").get(0).scrollHeight > $("body").innerHeight())	{
			wg = 20; 
		}
		$('#mxdiv').css({ 'width': $('body')[0].clientWidth - wg });
		$('#introinfo').css({ 'width': $('#mxdiv').get(0).scrollWidth });
		if($('#mxdiv').get(0).scrollWidth>$('#mxdiv').innerWidth()){
			h = 20;
		}
		$('#mxdiv').css({'height':$('#mxdiv').eq(0).height()+h});
}

  function showContact(id) {
	  if (id == "") { return false; };
	  var tmpstr = document.getElementById("tmpCStr").value;
	  if (tmpstr == "") { return false; };
	  document.getElementById("phone").value = "";
	  document.getElementById("mobile").value = "";
	  var arr_person = tmpstr.split("\1");
	  for (var i = 0; i < arr_person.length; i++) {
		  var arr_contact = arr_person[i].split("\2");
		  if (arr_contact.length > 0) {
			  if (id == arr_contact[0]) {
				  if (arr_contact[1] != "") {
					  document.getElementById("phone").value = arr_contact[1];
				  }
				  if (arr_contact[2] != "") {
					  document.getElementById("mobile").value = arr_contact[2];
				  }
				  break;
			  }
		  }
	  }
  }

