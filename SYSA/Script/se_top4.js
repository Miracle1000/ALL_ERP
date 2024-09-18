

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
  var ck = document.getElementById("ck"+i).value;
  var bz = document.getElementById("bz"+i).value;
  var js = document.getElementById("js"+i).value;
  var intro = document.getElementById("intro"+i).value;
   var w2  = "trpx"+(i-1)+"_"+id;
   w2=document.all[w2]
  if ( isNaN(num1) || ( Number(num1) >=  Number(num1old)) || (num1 == "") || ( Number(num1) == 0)) return;
  var url = "cu_ck.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
    var colindex = document.getElementById("bzhHeader").cellIndex
	plist.setallvalue(colindex,document.getElementById("bzall").value,"select");
}

function ck(kuout) {
	var w = plist.getLength();

	for(var i=1; i<=w-1; i++)
	{

		if(document.getElementById("ck"+i)){
			try{
				document.getElementById("ck"+i).value = document.getElementById("ckall").value;
				var id = document.getElementById("id"+i).value;
				var ord = document.getElementById("ord_"+i).value;
				var w2= document.getElementById("w"+i).value;
				unitxz(ord,i,id,w2,1,kuout)

			}catch(e){
				alert( '仓库选择错误：\n' + e.message)
			}
		}
	}
}

function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_cp();
	}
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

var CFCurrRow =  new Object() //拆分后自动更新行
CFCurrRow.update = function(){
	if(CFCurrRow.Row) {
		var tr = CFCurrRow.Row.parentElement.parentElement;
		CFCurrRow.Row =  null;
		for (var i=1;i<tr.cells.length ;i ++ )
		{
			var td = tr.cells[i];
			if(td.all.length>0 && td.all[0].tagName=="SELECT" && td.all[0].id.indexOf("unit")>=0){
				var span = tr.parentElement.parentElement.parentElement
				td.all[0].fireEvent("onchange")  //触发单位的更改事件以便更新行信息
				var fonts = span.getElementsByTagName("font")
				for (var  ii= 0 ; ii < fonts.length ; ii ++ )
				{
					if(fonts[ii].className=="red"){fonts[ii].style.fontWeight = "bold" ;}
				}
				return;
			}
		}

	}
}

function check_kh(ord,unit,unit2,ckjb,ck,id,num1,kcid) {
  var w  = "ck2xz_"+id;
  w=document.all[w]
  CFCurrRow.Row = w;
  window.setTimeout("CFCurrRow.update()",100)
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

function getobjv(obj,v) {
	if(obj){ return obj.value}
	else{return v;}
}
function ckxz(ord,i,id,w,sort1,kuout) {
  window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
  var unit1 = getobjv(document.getElementById("unit"+i),'0')
  var num1 = getobjv(document.getElementById("num"+i),'0')
  var price1=getobjv(document.getElementById("pricetest"+i),'0')
  var money1=getobjv(document.getElementById("moneyall"+i),'0')
  var ck = getobjv(document.getElementById("ck"+i),'0')
  var bz = getobjv(document.getElementById("bz"+i),'0')
  var js = getobjv(document.getElementById("js"+i),'0')
  var intro = getobjv(document.getElementById("intro"+i),'')
  var date2 = getobjv(document.getElementById("daysdate2"+i+"Pos"),'');
  var zdy1 = getobjv(document.getElementById("zdy1"+i),'');
	var zdy2 = getobjv(document.getElementById("zdy2"+i),'');
	var zdy3 = getobjv(document.getElementById("zdy3"+i),'');
	var zdy4 = getobjv(document.getElementById("zdy4"+i),'');
	var zdy5 = getobjv(document.getElementById("zdy5"+i),0);
	var zdy6 = getobjv(document.getElementById("zdy6"+i),0);

   var w2  = w;
   w2=document.all[w2]
  var url = "cu_ck2_ck.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&price1="+escape(price1)+"&money1="+escape(money1)+"&sort1="+escape(sort1)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&date2="+escape(date2)+"&zdy1="+escape(zdy1)+"&zdy2="+escape(zdy2)+"&zdy3="+escape(zdy3)+"&zdy4="+escape(zdy4)+"&zdy5="+escape(zdy5)+"&zdy6="+escape(zdy6)+"&kuout="+escape(kuout)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  //xmlHttp.open("GET", url, false);
  //xmlHttp.send(null);
  //window.uintchangepan.innerHTML = xmlHttp.responseText;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_ckxz(w2);
  };
  xmlHttp.send(null);
}


function zdkc(id) {
   var w2  = "zdkc"+id;
   w2=document.all[w2]
  var url = "cu_kuin2.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function callServer4(ord,top) {
	if ((ord == null) || (ord == "")) return;
	var url = "addlistadd_ck.asp?ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function del_zd(id) {
  var url = "del_zd.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  };
  xmlHttp.send(null);
  zdkc(id)
}

function callServer_cktips(nameitr,ord,id) {
   var w  = "tttest"+nameitr;
   w=document.all[w]
   var u_name = document.all["unit_"+nameitr].value;

   if ((u_name == null) || (u_name == "")) return;
  var url = "../price/cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage_cktips(w);
  };

  xmlHttp.send(null);
}

function updatePage_cktips(w) {
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

function callServer_cktips2(nameitr,ord,id) {
   var w  = "tttest"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}

function gettotalmoney(i)
{
	var pronum=document.getElementById("num"+i).value==""?0:document.getElementById("num"+i).value;
	var proprice=document.getElementById("price"+i).value==""?0:document.getElementById("price"+i).value;
	if(!isNaN(pronum)&&!isNaN(proprice))
	{
		document.getElementById("money"+i).value=FormatNumber(proprice*pronum,2)
	}
}

function unitxz(ord,i,id,w,sort1,kuout) {
  var  unit1 = 0 , price1 = 0 , money1 = 0 , num1 = 0 , ck = 0 , bz = 0 , js = 0 , intro = "",date2="",zdy1="",zdy2="",zdy3="",zdy4="",zdy5=0,zdy6=0
  try {
  if(document.getElementById("unit"+i)){ unit1 = document.getElementById("unit"+i).value ; }
  if(document.getElementById("pricetest"+i)){ price1=document.getElementById("pricetest"+i).value ; }
  if(document.getElementById("moneyall"+i)){ money1=document.getElementById("moneyall"+i).value; }
  if(document.getElementById("num"+i)){ num1 = document.getElementById("num"+i).value; }
  if(document.getElementById("ck"+i)){ ck = document.getElementById("ck"+i).value; }
  if(document.getElementById("bz"+i)){ bz = document.getElementById("bz"+i).value; }
  if(document.getElementById("js"+i)){ js = document.getElementById("js"+i).value; }
  if(document.getElementById("intro"+i)){intro = document.getElementById("intro"+i).value;}
  if(document.getElementById("date2"+i)){date2 = document.getElementById("date2"+i).value;}
  if(document.getElementById("zdy1"+i)){zdy1 = document.getElementById("zdy1"+i).value;}
  if(document.getElementById("zdy2"+i)){zdy2 = document.getElementById("zdy2"+i).value;}
  if(document.getElementById("zdy3"+i)){zdy3 = document.getElementById("zdy3"+i).value;}
  if(document.getElementById("zdy4"+i)){zdy4 = document.getElementById("zdy4"+i).value;}
  if(document.getElementById("zdy5"+i)){zdy5 = document.getElementById("zdy5"+i).value;}
  if(document.getElementById("zdy6"+i)){zdy6 = document.getElementById("zdy6"+i).value;}
 }
 catch(e){}

   var w2  = w;
   w2=document.all[w2]
  var url = "cu_ck2_ck.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&price1="+escape(price1)+"&money1="+escape(money1)+"&sort1="+escape(sort1)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&date2="+escape(date2)+"&zdy1="+escape(zdy1)+"&zdy2="+escape(zdy2)+"&zdy3="+escape(zdy3)+"&zdy4="+escape(zdy4)+"&zdy5="+escape(zdy5)+"&zdy6="+escape(zdy6)+"&kuout="+escape(kuout)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);

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
