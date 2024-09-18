function frameResize(){
document.getElementById("mxlist").style.height=I3.document.body.scrollHeight+0+"px";
}


var XMlHttp = GetIE10SafeXmlHttp();

function ask() {
	document.getElementById("ifsaveAndadd").value="1";
	var frm = document.getElementById("demo");
	if (frm.onsubmit.call(frm,arguments)){
		frm.submit();
	}
//document.all.form1.submit();
}

 
function callcompany(str){
	var cgord=document.getElementById("caigou").value;
    document.getElementById("mxlist").src="../event/cgmx2.asp?ID=company&company="+str+"&caigou="+cgord;
	if (!isNaN(str)){
		check_kh(str,'caigou_add');
	}
	//ord
}

function check_kh(ord,from) {
	from = from || '';
	var url = "../event/search_gys_1.asp?ord="+escape(ord) + "&from=" + from + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	XMlHttp.open("GET", url, false);
	XMlHttp.onreadystatechange = function(){
		updatePage2();
	};
	XMlHttp.send(null);
}

function updatePage2() {
  if (XMlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (XMlHttp.readyState == 4) {
    var response = XMlHttp.responseText;
	khmc.innerHTML=response;
	khmc.style.display="";
	updatePage3();
  }
}

function updatePage3() {
var company = document.getElementById("companyname").value;
var u_name = document.getElementById("htid").value;
var title = document.getElementById("title");
var zt=company+u_name;
	if (company!="请选择供应商"){
	title.value=zt;}
	XMlHttp.abort();
}
function chkgys(){
   var company=document.getElementById("companyname").value;
   if (company=="请选择供应商")
   {
     alert("请选择供应商！");
	 return false;
   }else{return true;}
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
