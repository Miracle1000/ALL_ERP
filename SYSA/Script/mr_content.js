

function callServer(ord) {
  var cateid = document.getElementById("cateid").value;
  if ((cateid == null) || (cateid == "")) return;
  var url = "cu.asp?cateid=" + escape(cateid)+"&ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage();
  };
  xmlHttp.send(null);
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	bm.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	bm.innerHTML=response;
	xmlHttp.abort();
  }

}

function callServer2(nameitr,ord,sort1,sort2) {
   var w  = nameitr;
   w=document.getElementById(w)
   var w2  = "tt"+nameitr;
   w2=document.getElementById(w2);
   var w3  = document.getElementById(nameitr);
   var id_show = document.getElementById("id_show").value;
   if (id_show != "") return;
  var url = "cu2.asp?ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.setRequestHeader("If-Modified-Since","0");
  xmlHttp.onreadystatechange = function(){

  updatePage2(w,w2);
  };
  xmlHttp.send(null);
}

function updatePage2(namei,w2) {
var test7=namei
var test6=w2
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
	var id_show= document.getElementById("id_show");
	id_show.value="1"
	xmlHttp.abort();
  }

}

function callServer3(e,ord,sort1,sort2) {
	if(e.checked==true){
		qx_open=1;
		if (sort2==19){
			//$("#nr_"+sort1).find(".sort2box").prop("checked",false);
			//$("#"+sort1+"_19_1").prop("checked",true);
			if (!confirm("确认关闭本栏目吗？")){
				e.checked=false;
				return false;
			}
		}else{
			$("#"+sort1+"_19_1").prop("checked",false);
		}
	}
	else{
		qx_open=0;
		//BUG 6395 Sword 2014-12-11 账号权限关闭栏目优化问题 
		if($("#nr_"+sort1).find(".sort2box:checked").size()==0){
			$("#"+sort1+"_19_1").prop("checked",true);
		}
	}
	if (sort1==21&&sort2==15){
		if (!confirm("该权限单一人员使用,请确认.")){
			if (e.checked==true){
				e.checked=false;
			}
			else{
				e.checked=true;
			}
			return false;
		}
	}
	var url = "add_qx.asp?ord="+escape(ord)+"&qx_open="+escape(qx_open)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);
	if (sort2==19){
		callServer4(ord,"nr_"+sort1,"jt_"+sort1,sort1,sort2);
	}
}

function ajaxSubmit_yh(nameitr,ord,sort1,sort2){
	//获取用户输入
	var w  = nameitr;
	w=document.getElementById(w)
	var wlist  = "tt"+nameitr;
	wlist=document.getElementById(wlist)
	var W1="",W2="",W3="";
	var wobj=document.getElementsByName("W1");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W1+=W1==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("W2");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W2+=W2==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("W3");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W3+=W3==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("member2");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W3+=W3==""?wobj[i].value:","+wobj[i].value;}
	var member1 = $(document.forms[0]).find("input[name=member1]:checked").val();
	wlist.innerHTML = ""
	var json = {};
	json.nameitr = escape(nameitr);
	json.ord = escape(ord);
	json.sort1 = escape(sort1);
	json.sort2 = escape(sort2);
	json.member1 = escape(member1);
	json.W3 = W3;
	jQuery.ajax({
		type: 'POST',
		url: '../../SYSA/manager/cu3.asp',
		cache: false,
		async: false,
		dataType: 'html',
		data: json,
		success: function (result) {
			xmlHttp.responseText = result;
			updatePage_yh(w, wlist);
		},
		error: function (rep) { }
	});
  xmlHttp.send(null);
}

function updatePage_yh(w,wlist) {
 var test7=w
 var test6=wlist
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	var id_show= document.getElementById("id_show");
	id_show.value=""
	xmlHttp.abort();
  }
}


function ajaxSubmit_gb(nameitr){
    //获取用户输入
	 var wlist  = "tt"+nameitr;
     wlist=document.all[wlist]

  xmlHttp.onreadystatechange = function(){
  updatePage_gb(wlist);
  };
  xmlHttp.send(null);
}

function updatePage_gb(nameitr) {
 var wlist  = nameitr;
  if (xmlHttp.readyState < 4) {
	wlist.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {

    var response = xmlHttp.responseText;
	wlist.innerHTML=""
	xmlHttp.abort();
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

function check_ckxz(w) {
 var ck = document.getElementById(w);
   if(ck.checked)
   return true;
   return false;
}

function callServer3_lsclose(nameitr) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   var id_show= document.getElementById("id_show");
   id_show.value=""
   xmlHttp.abort();
}

function callServer2_jg(nameitr,ord,sort1)
{
	var w  = nameitr;
	w=document.getElementById(w)
	var w2  = "tt"+nameitr;
	w2=document.getElementById(w2);
	var w3  = document.getElementById(nameitr);
	var id_show = document.getElementById("id_show").value;
	if (id_show != "") return;
  var url = "cu2_jg.asp?ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&sort1="+escape(sort1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){updatePage2_jg(w,w2);};
  xmlHttp.send(null);
}

function updatePage2_jg(namei,w2)
{
	var test7=namei
	var test6=w2
  if (xmlHttp.readyState < 4)
  {
		test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4)
  {
    var response = xmlHttp.responseText;
		test6.innerHTML=response;
		var id_show= document.getElementById("id_show");
		id_show.value="1"
		xmlHttp.abort();
  }
}

function setJGOpen(ord,sort1,flg)
{
  var url = "setJGopen.asp?ord="+escape(ord)+"&flg="+(flg?1:0)+"&sort1="+escape(sort1)+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
}

function ajaxSubmit_yh_jg(nameitr,ord,sort1)
{
	//获取用户输入
	var w  = nameitr;
	w=document.getElementById(w)
	var wlist  = "tt"+nameitr;
	wlist=document.getElementById(wlist)

	var W1="",W2="",W3="",orgsids="";
	var wobj=document.getElementsByName("orgsid");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) orgsids+=orgsids==""?wobj[i].value:","+wobj[i].value;}
	var wobj=document.getElementsByName("W1");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W1+=W1==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("W2");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W2+=W2==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("W3");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W3+=W3==""?wobj[i].value:","+wobj[i].value;}
	wobj=document.getElementsByName("member2");
	for(var i=0;i<wobj.length;i++){if(wobj[i].checked) W3+=W3==""?wobj[i].value:","+wobj[i].value;}
	var member1 = document.getElementsByName("member1")[0].checked?1:3;

	var url = "cu3_jg.asp?timestamp=" + new Date().getTime() + "&nameitr="+escape(nameitr)+"&ord="+escape(ord)+"&sort1="+escape(sort1)+"&orgsids=" + escape(orgsids) + "&W1="+escape(W1)+"&W2="+escape(W2) +"&W3="+escape(W3)+"&member1="+escape(member1)+"&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage_yh_jg(w,wlist);
  };
  xmlHttp.send(null);
}

function updatePage_yh_jg(w,wlist) {
 var test7=w
 var test6=wlist
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {

    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	test6.innerHTML=""
	var id_show= document.getElementById("id_show");
	id_show.value=""
	xmlHttp.abort();
  }
}

function callServer4(ord,nameitr,nameitr2,sort1,sort2) {
   var w  = nameitr;
   w=document.getElementById(w)
  var url = "cu2_xs.asp?ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage4_xs(ord,w,nameitr2,sort1,sort2);
  };
  xmlHttp.send(null);
}

function updatePage4_xs(ord,nameitr,nameitr2,sort1,sort2) {
var test6=nameitr
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
	callServer5(ord,nameitr,nameitr2,sort1,sort2)
  }
}

function callServer5(ord,nameitr,nameitr2,sort1,sort2) {
   var w  = nameitr2;
   w=document.getElementById(w)
  var url = "cu2_xs2.asp?ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&nameitr2="+escape(nameitr2)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage4_xs2(w);
  };
  xmlHttp.send(null);
}

function updatePage4_xs2(w2) {
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

function callServer6(ord,sort2) {
  var url = "cu2_xs3.asp?ord="+escape(ord)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage4_xs3(ord,sort2);
  };
  xmlHttp.send(null);
}

function updatePage4_xs3(ord,sort2) {
  if (xmlHttp.readyState < 4) {
	nrlist.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	nrlist.innerHTML=response;
	callServer7(ord,sort2)
  }

}

function callServer7(ord,sort2) {
  var url = "cu2_xs4.asp?ord="+escape(ord)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4_xs4();
  };
  xmlHttp.send(null);
}

function updatePage4_xs4() {
  if (xmlHttp.readyState < 4) {
	jtlist.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	jtlist.innerHTML=response;
	xmlHttp.abort();
  }

}

function callServer_addmb(e,ord,sort1,sort2) {
if(e.checked==true){
  	 qx_open=1;
  }
else{
    qx_open=0;
}

  var url = "add_mb.asp?ord="+escape(ord)+"&qx_open="+escape(qx_open)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
}

function call_personmb(ord) {
  var u_name = document.getElementById("person_mb").value;
  if ((u_name == null) || (u_name == "")) return;
  var url = "person_mb.asp?u_name=" + escape(u_name)+"&ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){

  update_personmb();
  };

  xmlHttp.send(null);
}
var select_old_value;

function call_setoldgwmb() {
    select_old_value = document.getElementById("gw_mb").value;
  
}
function call_gwmb(ord) {
    var gw_mb = document.getElementById("gw_mb").value;
    if ((gw_mb == null) || (gw_mb == "")) return;
    if (!confirm("确认应用此岗位模板吗？"))
    {
        document.getElementById("gw_mb").value = select_old_value;
        return false;
    }
    var url = "../../SYSN/json/comm/QxTemplateApply.ashx?mbid=" + escape(gw_mb) + "&ord=" + escape(ord) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, true);
    xmlHttp.onreadystatechange = function () {

        if (xmlHttp.readyState == 4) {
            var response = xmlHttp.responseText;
            if (response == 1)
            {
                alert('权限模板应用成功！');
                window.location.reload();
            }
            else
            {
                alert('权限模板应用失败，请重试！');
            }
            xmlHttp.abort();
        }

    };

    xmlHttp.send(null);
}

function update_personmb() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }

}

function callServer_delmb(ord) {
  var url = "del_mb.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){

  update_delmb();
  };

  xmlHttp.send(null);
}

function update_delmb() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在清空账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }

}

function callServer_mb(ord) {
  var url = "qbqx.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){

  update_mb();
  };
  xmlHttp.send(null);
}

function update_mb() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置超级管理员账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }
}
function callServer_mb2(ord) {
  var url = "qbqx2.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){

  update_mb2();
  };
  xmlHttp.send(null);
}
function update_mb2() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }
}
function callServer_mb3(ord) {
  var url = "qbqx3.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){

  update_mb3();
  };
  xmlHttp.send(null);
}
function update_mb3() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置经理账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }
}
function callServer_mb4(ord) {
  var url = "qbqx4.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){
  update_mb4();
  };
  xmlHttp.send(null);
}
function update_mb4() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置主管账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }
}
function callServer_mb5(ord) {
  var url = "qbqx5.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){
  update_mb5();
  };
  xmlHttp.send(null);
}
function update_mb5() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置普通账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }
}
function callServer_mb6(ord) {
  var url = "qbqx6.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){
  update_mb6();
  };
  xmlHttp.send(null);
}
function update_mb6() {
  if (xmlHttp.readyState < 4) {
	content_mb.innerHTML="<br>&nbsp;&nbsp;&nbsp;&nbsp;正在配置账号权限，请稍后...<br><br>";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	content_mb.innerHTML=response;
	xmlHttp.abort();
  }
}

window.onload = function () {
	try{
	if(parent.document.getElementById("cFF2")!=null){
		parent.document.getElementById("cFF2").style.height=document.body.scrollHeight;
		parent.parent.document.getElementById("cFF").style.height=parent.document.body.scrollHeight;
	}
	}catch(e){}
}

var curP1="",curP2="",curUid="",oldP1="",oldP2="",paste1="",paste2="";
function CopyPower(p1,p2,uid)
{
	if(curP1=="")
	{
		curP1=p1;curP2=p2;curUid=uid;
		document.getElementById("cp_"+p1+"_"+p2).style.cursor="point";
		document.getElementById("cp_"+p1+"_"+p2).style.color="#ff0000";
	}
	else if(oldP1=="")
	{
		oldP1=curP1;oldP2=curP2;
		curP1=p1;curP2=p2;curUid=uid;
		document.getElementById("cp_"+p1+"_"+p2).style.cursor="point";
		document.getElementById("cp_"+p1+"_"+p2).style.color="#ff0000";
		document.getElementById("cp_"+oldP1+"_"+oldP2).style.color="#6D779A";
		document.getElementById("cp_"+oldP1+"_"+oldP2).style.cursor="hand";
	}
	else
	{
		document.getElementById("cp_"+p1+"_"+p2).style.cursor="point";
		document.getElementById("cp_"+p1+"_"+p2).style.color="#ff0000";
		oldP1=curP1;oldP2=curP2;
		curP1=p1;curP2=p2;curUid=uid;
		document.getElementById("cp_"+oldP1+"_"+oldP2).style.color="#6D779A";
		document.getElementById("cp_"+oldP1+"_"+oldP2).style.cursor="hand";
	}
}

function PastePower(p1,p2,uid)
{
	if(curP1=="")
	{
		alert("请先在权限列表中点击复制再进行粘贴操作");
		return false;
	}
  var url = "cu2_paste.asp?ord="+escape(uid)+"&ptype=1&sortTo="+p1+"&sortTo2="+p2+"&sortFrom="+curP1+"&sortFrom2="+curP2+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){
	  if(xmlHttp.readyState == 4)
	  {
	    var response = xmlHttp.responseText;
			if(paste1!="") document.getElementById("showlbl_"+paste1+"_"+paste2).style.color="#6D779A";
			document.getElementById("showlbl_"+p1+"_"+p2).innerHTML=response.split("</noscript>")[1];
			document.getElementById("showlbl_"+p1+"_"+p2).style.color="#ff0000";
			xmlHttp.abort();
			paste1=p1;paste2=p2;
  	};
  }
  xmlHttp.send(null);
}

var curJG="",curUid="",oldJG="",pJG="";
function CopyJG(p1,uid)
{
	if(curJG=="")
	{
		curJG=p1;curUid=uid;
		document.getElementById("cp_"+p1+"_jg").style.cursor="point";
		document.getElementById("cp_"+p1+"_jg").style.color="#ff0000";
	}
	else if(oldJG=="")
	{
		oldJG=curJG;curJG=p1;curUid=uid;
		document.getElementById("cp_"+p1+"_jg").style.cursor="point";
		document.getElementById("cp_"+p1+"_jg").style.color="#ff0000";
		document.getElementById("cp_"+oldJG+"_jg").style.color="#6D779A";
		document.getElementById("cp_"+oldJG+"_jg").style.cursor="hand";
	}
	else
	{
		document.getElementById("cp_"+p1+"_jg").style.cursor="point";
		document.getElementById("cp_"+p1+"_jg").style.color="#ff0000";
		oldJG=curJG;curJG=p1;curUid=uid;
		document.getElementById("cp_"+oldJG+"_jg").style.color="#6D779A";
		document.getElementById("cp_"+oldJG+"_jg").style.cursor="hand";
	}
}

function PasteJG(p1,uid)
{
	if(curJG=="")
	{
		alert("请先在组织架构中点击复制再进行粘贴操作");
		return false;
	}
  var url = "cu2_paste.asp?ord="+escape(uid)+"&ptype=2&sortTo="+p1+"&sortFrom="+curJG+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, true);
  xmlHttp.onreadystatechange = function(){
	  if(xmlHttp.readyState == 4)
	  {
	    var response = xmlHttp.responseText;
			if(pJG!="") document.getElementById("showlbl_"+pJG+"_jg").style.color="#6D779A";
			document.getElementById("showlbl_"+p1+"_jg").innerHTML=response.split("</noscript>")[1];
			document.getElementById("showlbl_"+p1+"_jg").style.color="#ff0000";
			xmlHttp.abort();
			pJG=p1;
  	};
  }
  xmlHttp.send(null);
}

function uncheckChildren(id){
	if(id.indexOf("Wt") >= 0){
		var id1 = id.replace("t","d");
	}else if(id.indexOf("k") >= 0){
		var id1 = id.replace("k","r");
	}else{
		return;
	}
	if(!document.getElementById(id1).checked){
		var cDiv = document.getElementById(id);
		var chlds = cDiv.getElementsByTagName("input");
		for(var i = 0; i < chlds.length; i++){
			chlds[i].checked = false;
		}
	}
}
