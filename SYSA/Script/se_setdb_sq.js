function callServer5(s, unit, ord, id, attr1id, attr2id) {
    var w = s;
    w = document.all[w]
    var url = "../contract/cu_kccx.asp?unit=" + escape(unit) + "&ord=" + escape(ord) + "&id=" + escape(id) + "&attr1id=" + attr1id + "&attr2id=" + attr2id + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_kc(w);
    };
    xmlHttp.send(null);
}

function updatePage_kc(w) {
    var test6 = w
    if (xmlHttp.readyState < 4) {
        test6.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        test6.innerHTML = response;
        xmlHttp.abort();
    }
}

function callServer6(t, nameitr, ord, id) {
    var w = t;
    w = document.all[w]
    w.innerHTML = "";
    xmlHttp.abort();
}


function add(ord,i,id) {
  var kuout = document.getElementById("kuout"+i).value;
  var kuoutlist = document.getElementById("kuoutlist"+i).value;
  var contractlist = document.getElementById("contractlist"+i).value;
  var unit1 = document.getElementById("unit"+i).value;
  var num1 = document.getElementById("num1"+i).value;
  var num1old =  document.getElementById("num1old"+i).value;
  var moneyall = document.getElementById("moneyall"+i).value;
  var ck = document.getElementById("ck"+i).value;
  var bz = document.getElementById("bz"+i).value;
  var js = document.getElementById("js"+i).value;
  var intro = document.getElementById("intro"+i).value;

   var w2  = "trpx"+(i-1)+"_"+id;
   w2=document.all[w2]
  if ( isNaN(num1) || ( Number(num1) >=  Number(num1old)) || (num1 == "") || ( Number(num1) == 0)) return;
  var url = "cu_ck.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&kuout="+escape(kuout) + "&kuoutlist="+escape(kuoutlist) + "&contractlist="+escape(contractlist)+"&unit="+escape(unit1)+"&moneyall="+escape(moneyall)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function ck(sort_ck) {
var w = document.getElementById("alli").value;

 for(var i=1; i<=w-1; i++)
　 {
document.getElementById("ck"+i).value = document.getElementById("ckall").value;

var id = document.getElementById("id"+i).value;
var ord = document.getElementById("ord_"+i).value;
var w2= document.getElementById("w"+i).value;
ckxz(ord,i,id,w2,sort_ck)
}
}
function check() {
    var w = document.getElementById("recordcount").value;
    if (w == 0) {
        alert("调拨明细为空，不可以保存");
        return false;
    }
    else {
            return true
    }
}
function del(str, id) {
    var w = document.getElementById("recordcount").value;
    document.getElementById("recordcount").value = w - 1 < 0 ? 0 : w - 1;
	var w  = str;
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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
	var money1=price.value * num.value
	moneyall.value=FormatNumber(money1,num_dot_xs)
}

function check_kh(ord,unit,unit2,ckjb,ck,id,num1,kcid) {
  var w  = "ck2xz_"+id;
   w=document.all[w];
  var url = "../store/ku_unit_cf.asp?ord="+escape(ord)+"&unit="+escape(unit)+"&unit2="+escape(unit2)+"&ckjb="+escape(ckjb)+"&ck="+escape(ck)+"&id="+escape(id)+"&num1="+escape(num1)+"&kcid="+escape(kcid)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(w);
  };
  xmlHttp.send(null);
}
function updatePage2(w) {
  var test7=w;
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

function ckxz(ord,i,id,w,sort_ck) {
  var kuout = document.getElementById("kuout"+i).value;
  var kuoutlist = document.getElementById("kuoutlist"+i).value;
  var contractlist = document.getElementById("contractlist"+i).value;
  var unit1 = document.getElementById("unit"+i).value;
  var num1 = document.getElementById("num1"+i).value;
  var num1old =  document.getElementById("num1old"+i).value;
  var moneyall = document.getElementById("moneyall"+i).value;
  var ck = document.getElementById("ck"+i).value;
  var bz = document.getElementById("bz"+i).value;
  var js = document.getElementById("js"+i).value;
  var intro = document.getElementById("intro"+i).value;

   var w2  = w;
   w2=document.all[w2]
  var url = "cu_ck2.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&sort_ck="+escape(sort_ck)+"&kuout="+escape(kuout) + "&kuoutlist="+escape(kuoutlist) + "&contractlist="+escape(contractlist)+"&unit="+escape(unit1)+"&moneyall="+escape(moneyall)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function ckxz2(ord,i,id,w) {
  var kuout = document.getElementById("kuout"+i).value;
  var kuoutlist = document.getElementById("kuoutlist"+i).value;
  var contractlist = document.getElementById("contractlist"+i).value;
  var unit1 = document.getElementById("unit"+i).value;
  var num1 = document.getElementById("num1"+i).value;
  var num1old =  document.getElementById("num1old"+i).value;
  var moneyall = document.getElementById("moneyall"+i).value;
  var ck = document.getElementById("ck"+i).value;
  var bz = document.getElementById("bz"+i).value;
  var js = document.getElementById("js"+i).value;
  var intro = document.getElementById("intro"+i).value;
   var w2  = w;
   w2=document.all[w2]
  var url = "cu_ck3.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&kuout="+escape(kuout) + "&kuoutlist="+escape(kuoutlist) + "&contractlist="+escape(contractlist)+"&unit="+escape(unit1)+"&moneyall="+escape(moneyall)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_ckxz2(w2);
  };
  xmlHttp.send(null);
}

function updatePage_ckxz2(w2) {
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

function check_ck(ord,id,i) {
   var num1 = document.getElementById("num1"+i).value;
   var num1old = document.getElementById("num1old"+i).value;
  if ( isNaN(num1) || (num1 == "") ) {
  alert("只能输入数字！")
  document.getElementById("num1"+i).value=num1old
  return false;
  }
  if (Number(num1) > Number(num1old)) {
  alert("大于应出库数量！")
  document.getElementById("num1"+i).value=num1old
  return false;
  }
  document.getElementById("num1"+i).value=Number(num1)
  return true;
}

function del_zd(id) {
  var url = "del_zd.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  };
  xmlHttp.send(null);
  zdkc(id)
}

function choosek(i)
{
    var num1 = document.getElementById("num3_" + i).value;
    var num1old =$("#num3_" + i).attr("oldnum");
    if (Number(num1)<=0) {
        alert("审批数量必须大于0！")
        document.getElementById("num3_" + i).value = num1old;
        return false;
    }
}