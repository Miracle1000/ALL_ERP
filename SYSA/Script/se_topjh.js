

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
  var date2 = document.getElementById("daysdate1_"+i+"Pos").value;
  var intro = document.getElementById("intro"+i).value;

   var w2  = "trpx"+(i-1)+"_"+id;
   w2=document.all[w2]
  if ( isNaN(num1) || ( Number(num1) >=  Number(num1old)) || (num1 == "") || ( Number(num1) == 0)) return;
  var url = "cu_ck.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&moneyall="+escape(moneyall)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&date2="+escape(date2)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
	plist.setallvalue(8,document.getElementById("bzall").value)
}

function ck(top) {
	for(var i=1; i<= 1000; i++)
	{
		if(document.getElementById("ck"+i)){
			document.getElementById("ck"+i).style.cssText = "height:20px;overflow:hidden;float:left;white-space:nowrap;text-overflow:ellipsis;";
			document.getElementById("ck"+i).title = document.getElementById("ckall").value;
			document.getElementById("ck"+i).value = document.getElementById("ckall").value;
			var id = document.getElementById("id"+i).value;
			var ord = document.getElementById("ord_"+i).value;
			var w2= document.getElementById("w"+i).value;
			ckxz(ord,i,id,w2,1,top)
		}
	}
}

function del(str,id){
	var w  = document.all[str];

	var url = "../caigou/del_cp.asp?id="+escape(id)+"&isjh=1&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w);
  };
  xmlHttp.send(null);
}
function updatePage_del(str) {
     str.innerHTML="";

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


function check_kh(ord, unit, unit2, ckjb, ck, id, num1, kcid, numid) {
  var w  = "ck2xz_"+id;
   w=document.all[w]
   var x = $("[name='num1_" + id + "']");
   var url = "../store/ku_unit_cf.asp?ord=" + escape(ord) + "&unit=" + escape(unit) + "&unit2=" + escape(unit2) + "&ckjb=" + escape(ckjb) + "&ck=" + escape(ck) + "&id=" + escape(id) + "&num1=" + escape(num1) + "&numid=" + numid + "&kcid=" + escape(kcid) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w,x);
  };
  xmlHttp.send(null);
}
function updatePage2(w,x) {
  var test7=w

  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
      test7.innerHTML = response;
      var kclimitArr = response.split("<!--num_kclimit=");
      if (kclimitArr.length > 1) {
          var kclimit = kclimitArr[1].replace("-->", "");
          if (!isNaN(kclimit)) { x.attr("max", kclimit) }
      }
	xmlHttp.abort();
  }
}

function check_ckxz(i) {
   var ck = document.getElementById("ck"+i).value;
  if (ck != "" && ck != "0") return true;
  alert("请先选择仓库！");
  var ckname=document.getElementById("ck"+i).name;
  document.getElementsByName("way1_"+ckname.replace("ck_",""))[0].checked=true;
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



function ckxz(ord,i,id,w,sort1,top) {
  var unit1 = document.getElementById("unit"+i).value;
  var num1 = document.getElementById("num"+i).value;
  var ck = document.getElementById("ck"+i).value;
  var bz = document.getElementById("bz"+i).value;
  var date2 = document.getElementById("daysdate1_"+i+"Pos").value;
  var intro = document.getElementById("intro"+i).value;
    var productAttr1 = document.getElementById("ProductAttr1_" + i) ? document.getElementById("ProductAttr1_" + i).value:"";
    var productAttr2 = document.getElementById("ProductAttr2_" + i)?document.getElementById("ProductAttr2_"+i).value:"";

    var w2  = w;
   w2=document.all[w2]
  var url = "cu_ck2_jh.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&sort1="+escape(sort1)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&unit="+escape(unit1)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&date2="+escape(date2)+"&intro="+escape(intro)+"&productAttr1="+escape(productAttr1)+"&productAttr2="+escape(productAttr2)+"&top="+escape(top)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function zdkc(id,n) {
	var w2  = "zdkc"+id;
	w2=document.all[w2]
	var url = "cu_kuin2.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage_zdkc(w2,n);
	};

  xmlHttp.send(null);
}

function updatePage_zdkc(w2,n) {
var test6=w2
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	if(response.indexOf('已指定：0.0</b>')>-1){response='';}
	if (response.length==0 && n==1)
	{
		var ckname=test6.id;
		document.getElementsByName("way1_"+ckname.replace("zdkc",""))[1].checked=true;
	}
	test6.innerHTML=response;
	xmlHttp.abort();
  }
}


function callServer4(ord,top,unit) {
	unit = unit || '';
	if ((ord == null) || (ord == "")) return;
	var url = "addlistadd_jh.asp?ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)+"&unit="+unit;
	plist.add(url,click_pl); // 添加
}

function add_zd(i,ord,unit,id,ck,contractlist,kuout,kuoutlist,productAttr1,productAttr2)
{
	if(check_ckxz(i)){
		window.open('../store/ku_select_ck.asp?ord='+ord+'&unit='+unit+'&id='+id+'&ck='+ck+'&num1='+document.getElementById('num'+i).value+'&contractlist='+contractlist+'&kuout='+kuout+'&kuoutlist='+kuoutlist+'&productAttr1='+productAttr1+'&productAttr2='+productAttr2+'&sort_ck=6','newwin23','width='+1000+',height='+400+',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');
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


function del_zd(id) {
  var url = "del_zd.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  };
    xmlHttp.send(null);
    zdkc(id,0)
    document.all["zdkc" + id].innerHTML=""
  xmlHttp.abort();
}


//拆分页面跳转
function openurltocf(productid, unit, ck, atrr1, atrr2, moreunit, Ismode, id, numid) {
    var num1 = document.getElementById("num" + numid).value;
    var attr1 = 0;
    var attr2 = 0;
    if (document.getElementById("ProductAttr1_" + numid))
    {
        attr1 = document.getElementById("ProductAttr1_" + numid).value;
        attr2 = document.getElementById("ProductAttr2_" + numid).value;
    }
    window.open('../../sysn/view/store/kuout/KuAppointSplit.ashx?productid=' + productid + '&unit=' + unit + '&ck=' + ck + '&attr1=' + attr1 + '&attr2=' + attr2 + '&moreunit=' + moreunit + '&Ismode=3&id=' + id + '&numid='+numid+'&cfnum1=' + num1 + '', 'newwin23', 'width=' + 800 + ',height=' + 400 + ',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');

}