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



var xmlHttp = GetIE10SafeXmlHttp();

function callServer(nameitr,ord) {
  var u_name = document.getElementById("u_name").value;
   var w  = document.all[nameitr];
   var w2  = "trpx";
   w2=document.all[w2]
  //if ((u_name == null) || (u_name == "")) return;
  var url = "cu_hb.asp?ord="+escape(ord)+"&gys="+escape(u_name) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage(w2);
  };

  xmlHttp.send(null);
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	cpmx2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	cpmx.innerHTML="";
	cpmx2.innerHTML=response;
	xmlHttp.abort();
  }
  //document.getElementById("intro").focus();
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

function checklimit(){
   var paylimits=document.getElementById("paylimit").value;
   if (paylimits=="1") //是否开启限制策略
   {
	 document.getElementById("limittips").innerHTML="";
	 if(document.getElementById('limit1').checked==true){  //金额策略
	    var limitmoneys=document.getElementById("limitmoney").value;    
		if (isNaN(limitmoneys)||limitmoneys.toString().length==0||limitmoneys==null)
		{
		  document.getElementById("limittips").innerHTML="请输入付款金额";
		  return false;
		}else{
		  if (parseFloat(limitmoneys)<0||parseFloat(limitmoneys)>999999999999.9999)
		  {
		    document.getElementById("limittips").innerHTML="付款金额不正确";
			return false;
		  }else{
			return true;
		  }
		}
	 }else{
	 	var limitpercents=document.getElementById("limitpercent").value;    
		if (isNaN(limitpercents)||limitpercents.toString().length==0||limitpercents==null)
		{
		  document.getElementById("limittips").innerHTML="请输入付款比例";
		  return false;
		}else{
		  if (parseFloat(limitpercents)<0||parseFloat(limitpercents)>100)
		  {
		    document.getElementById("limittips").innerHTML="付款比例不正确";
			return false;
		  }else{
			return true;
		  }
		}
	 }
   }else{
		return true;
   }
}
