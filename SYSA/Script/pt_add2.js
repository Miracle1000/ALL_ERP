
    function checkAll3(str){
        var a=document.getElementById("h"+str).getElementsByTagName("input");
        var b=document.getElementById("i"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk3(str){
        var a=document.getElementById("h1").getElementsByTagName("input");
        var b=document.getElementById("i1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }
    function checkAll7(str){
        var a=document.getElementById("Wd"+str).getElementsByTagName("input");
        var b=document.getElementById("Wt"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }
    function fixChk7(str){
        var a=document.getElementById("Wd1").getElementsByTagName("input");
        var b=document.getElementById("Wt1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

function ask() {
  date.submit();
}
function ask2() {
document.all.date.action = "save2.asp?sort3=2";
}


function callServer(nameitr) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = document.all[nameitr];
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?name=" + escape(u_name);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage(w);
  };
  xmlHttp.send(null);
}
function updatePage(namei) {
	var test7=namei;
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		test7.innerHTML=response;
  }
}
function callServer2() {
  var unit1 = document.getElementById("unit1").value;
  if ((unit1 == null) || (unit1 == "")) return;
  var url = "cuunit.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(unit1);
  };
  xmlHttp.send(null);
}
function updatePage2(unit1) {
  if (xmlHttp.readyState < 4) {
	trpx0.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		trpx0.innerHTML=response;
	  var url1 = "cuunit3.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url1, true);
  xmlHttp.onreadystatechange = function(){
  updatePage3();
   };
	 xmlHttp.send(null);
  }
}
function updatePage3() {
  if (xmlHttp.readyState < 4) {
	trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit2.innerHTML=response;
		var cldiv=document.getElementById("celue_div");
		cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
  xmlHttp.abort();
  }
}
function callServer4(ord)
{
	if ((ord == null) || (ord == "")) return;
	var url = "num_click.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		updatePage4(ord);
	};
	xmlHttp.send(null);
}
function updatePage4(ord)
{
	if (xmlHttp.readyState == 4)
	{
		var res = xmlHttp.responseText;
		var w  = "trpx"+res;
		w=document.all[w]
		var url = "cuunit2.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function()
		{
			updatePage5(w,ord);
		};
		xmlHttp.send(null);
	}
}
function updatePage5(w,unitall) {
var test3=w;
  if (xmlHttp.readyState < 4) {
		test3.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		test3.innerHTML=response;
 		var url1 = "cuunit4.asp?unitall=" + escape(unitall)+"&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
	  xmlHttp.open("GET", url1, true);
	  xmlHttp.onreadystatechange = function(){
	  updatePage6();
   };
	 xmlHttp.send(null);
  }
}
function updatePage6() {
  if (xmlHttp.readyState < 4) {
		trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;
	  var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
	  xmlHttp.open("GET", url1, true);
	  xmlHttp.onreadystatechange = function(){
	  updatePage7();
   };
	 xmlHttp.send(null);
  }
}
function updatePage7() {
  if (xmlHttp.readyState < 4) {
		trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		trpx_unit1.innerHTML=response;
	  xmlHttp.abort();
		var cldiv=document.getElementById("celue_div");
		cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
  }
}
function del(str,id){
	var w  = document.all[str];
	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
 	xmlHttp.onreadystatechange = function(){
  	updatePage_del(w);
  };
  xmlHttp.send(null);
}
function updatePage_del(str) {
	if (xmlHttp.readyState < 4) {
		trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
    str.innerHTML="";
    var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
    xmlHttp.open("GET", url1, true);
    xmlHttp.onreadystatechange = function(){
    updatePage8();
   };
	 xmlHttp.send(null);
  }
}
function updatePage_del2(str) {
	if (xmlHttp.readyState < 4) {
		trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
    document.getElementById(str).style.display="none";
    var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
    xmlHttp.open("GET", url1, true);
    xmlHttp.onreadystatechange = function(){
    updatePage7();
   };
	 xmlHttp.send(null);
  }
}
function updatePage8() {
  if (xmlHttp.readyState < 4) {
		trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		trpx_unit1.innerHTML=response;
 		var url1 = "cuunit4.asp?timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
    xmlHttp.open("GET", url1, true);
    xmlHttp.onreadystatechange = function(){
    updatePage9();
   };
	 xmlHttp.send(null);
  }
}
function updatePage9() {
  if (xmlHttp.readyState < 4) {
	trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		trpx_unit2.innerHTML=response;
    xmlHttp.abort();
		var cldiv=document.getElementById("celue_div");
		cldiv.style.height=cldiv.children[0].offsetHeight+20+"px";
  }
}

function keydown()
{
	if(event.keyCode==13)
	{event.keyCode=9}
	else
	{
		keydowndeal(event);
	}
}
function keydown1()
{
 if(event.keyCode==13)
	{
	event.keyCode=9;
	hide_suggest();
	}
}
function onKeyPress()
{
	if (event.keyCode!=46 && event.keyCode!=45 && (event.keyCode<48 || event.keyCode>57)) event.returnValue=false;
}
function callServer_ts(m,name1) {
  var u_name = document.getElementById(name1).value;
  var w2  = "test"+m;
  w2=document.all[w2];
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu_ts.asp?name=" + escape(u_name)+"&ord="+escape(m)+"&timestamp=" + new Date().getTime() + "&date7="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_ts(w2,m);
  };
  xmlHttp.send(null);
}
function updatePage_ts(w,m) {
	var test6=w;
  if (xmlHttp.readyState < 4) {
		test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
		test6.innerHTML=response;
  }
}
function formCheck(){
	if(document.getElementById("flag1").value=="1"||document.getElementById("flag2").value=="1"||document.getElementById("flag3").value=="1"){
		return false;
	}else{
		return true;
  }
}

function CheckSelection()
{
	var rvalue=false;
	try
	{
		if(document.getElementById("rbtn2").checked)
		{
			var ulist=document.getElementsByName("W1");
			var notchecked=true;
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W2");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			ulist=document.getElementsByName("W3");
			for(var i=0;i<ulist.length;i++)
			{
				if(ulist[i].checked){notchecked=false;break;}
			}
			if(notchecked)
			{
				document.getElementById("ulist1").innerText="请选择可操作范围";
				rvalue = false;
			}
			else
			{
				document.getElementById("ulist1").innerText="";
				rvalue = true;
			}
		}
		else
		{
			rvalue = true;
		}
	}
	catch(e3){}
	finally
	{return rvalue;}
}

