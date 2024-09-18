
//BUG.2992.KILLER 2013-11-22 期初应收应付合计金额问题 
function updateTotal(id){
	var v = $("input[name=moneyall2_"+id+"]").val();
	var totalV = $("#moneysum_all").val();
	if(isNaN(v) || v=="") { v=0; }	//BUG.3356.binary.2014.01.04
	if(isNaN(totalV) || totalV=="") { totalV=0; }
	$("#moneysum_all").val(parseFloat(totalV) - parseFloat(v));
}

function mm(form)
{
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i];
		if ((e.name != 'chkall')&&(e.type=='checkbox'))
		e.checked = form.chkall.checked;
	}
}
function batchDel(form){
     var c=document.getElementsByName("selectids");
	 var chkstring=0;
	for (var ci=c.length-1;ci>=0;ci--)
	{			
		if (c[ci].checked==true)
		{
		updateTotal(c[ci].id.replace("selectids_",""));
		chkstring=1;
		del2(c[ci].id,c[ci].id.replace("selectids_",""));
		}
		
	}
	resetid();
	if (chkstring==0)
	{
	  alert("您没有选择任何内容，请选择后再删除！");
	}


}
var XMlHttp = GetIE10SafeXmlHttp();

var XMlHttp2 = GetIE10SafeXmlHttp();

var XMlHttp3 = GetIE10SafeXmlHttp();


function check_kh2(ord,ids){
  ids1=ids;
  var url = "../event/search_kh2.asp?mode=test&ord="+escape(ord)+"&id="+escape(ids)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  XMlHttp.open("GET", url, false);
  XMlHttp.onreadystatechange = function(){
	if (XMlHttp.readyState == 4) {
       var response = XMlHttp.responseText;
	   if (response=='999999999')
	   {
	     //此处不判断是否有增加空的
		 callServer7(1,1);  //新增一行
		 //调用点击事件
		  url2 = "balance_ajax.asp?mode=test&ord="+escape(ord)+"&top="+escape(top) + "&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		  XMlHttp2.open("GET", url2, false);
		  XMlHttp2.onreadystatechange = function(){
		     if (XMlHttp2.readyState == 4) {
			 ids1=XMlHttp2.responseText;}
		  }
		  XMlHttp2.send(null);
	   }
	}
  };
  XMlHttp.send(null);

  check_kh(ord,ids1);
	
}

function check_kh(ord,ids) {
	  var url = "../event/search_kh2.asp?ord="+escape(ord)+"&id="+escape(ids)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	  XMlHttp.open("GET", url, false);
	  XMlHttp.onreadystatechange = function(){

	  updatePage2(escape(ids));
	  };
	  XMlHttp.send(null);
}

function resetselect(){
	  var url = "../event/search_kh2.asp?mode=clear&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	  XMlHttp3.open("GET", url, false);
	  XMlHttp3.onreadystatechange = function(){
	  };
	  XMlHttp3.send(null);
}

function updatePage2(ids) {
  if (XMlHttp.readyState < 4) {
	if(document.getElementById("company_"+ids)){
	document.getElementById("company_"+ids).innerHTML="loading...";
	}
  }
  if (XMlHttp.readyState == 4) {
    var response = XMlHttp.responseText;
	if(document.getElementById("company_"+ids)){
		document.getElementById("company_"+ids).innerHTML=response;
		document.getElementsByName("company_bh_"+ids)[0].value=document.getElementsByName("company_khid_"+ids)[0].value;
		document.getElementsByName("gate_id_"+ids)[0].value=document.getElementsByName("company_userid_"+ids)[0].value;
		document.getElementsByName("gate_name_"+ids)[0].value=document.getElementsByName("company_username_"+ids)[0].value;
	}
	//updatePage3();
  }
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

function del_zd(id1,id2){
	if (id2==1)
	{
     document.getElementById(id1).style.display="block";  
	}else{
	 document.getElementById(id1).style.display="none";
	}
}

function callServer7(ord,top) {
	if ((ord == null) || (ord == "")) return;
	var url = "invoice_ajax.asp?ord="+escape(ord)+"&top="+escape(top) + "&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	plist.add(url,null);
	resetid();
}

function resetid(){
	var ii=0;
	var td_id=document.getElementById("getid");
	for (var i=0;i<td_id.children.length ;i++ )
	{
		var objs=td_id.children[i];
		if ((objs.tagName=="SPAN")&&(objs.id.indexOf("trpx")==0)&&(objs.innerHTML.length>0)&&(objs.id.indexOf("trpx_99999")!=0))
		{
		   ii++;
		   objs.children[0].rows[0].cells[0].innerHTML=ii;
		}
	}
}

function showGatePersonDiv(InputName,InputId,defaultval,strUrl,width,height)
{
	if(strUrl.indexOf("?")>=0)
	{
		strUrl=strUrl+"&InputName="+InputName+"&InputId="+InputId+"&W3="+defaultval;
		}
	else
	{
		strUrl=strUrl+"?InputName="+InputName+"&InputId="+InputId+"&W3="+defaultval;
		}
	var w = 960 , h = 640 ;
	window.open( strUrl ,'newwin','width=' + w + ',height=' + h + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
}


function GetUserVal(inputId,val,username)
{
	$("#"+inputId.replace("_name_","_id_")).val(val);
	$("#"+inputId+"").val(username);
}

function bz() {
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("bizhong_" + i)) {
            document.getElementById("bizhong_" + i).value = document.getElementById("bzall").value;
        }
    }
    xmlHttp.abort();
}

function lx(tag) {
    if (tag == 0) {
        for (var i = 1; i < 1000; i++) {
            if (document.getElementById("lx_" + i)) {
                var obj = document.getElementById("lxall");
                document.getElementById("lx_" + i).value = obj.value;

                document.getElementById("TaxRate_" + i).value = obj.options[obj.selectedIndex].getAttribute("taxrate");
            }
        }
    } else {
        var obj = document.getElementById("lx_" + tag);
        document.getElementById("TaxRate_" + tag).value = obj.options[obj.selectedIndex].getAttribute("taxrate");
    }
}

function ly() {
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("ly_" + i)) {
            document.getElementById("ly_" + i).value = document.getElementById("lyall").value;
        }
    }
    xmlHttp.abort();
}
function invoicenumall(){
	for (var i = 1; i < 1000; i++) {
        if (document.getElementById("invoicenum_" + i)) {
            document.getElementById("invoicenum_" + i).value = document.getElementById("invoicenum_all").value;
        }
    }
	xmlHttp.abort();
}
function moneyall() {
	if(document.getElementById("allcount")){
		document.getElementById("allcount").checked=true;
	}
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("moneyall_" + i)) {
            document.getElementById("moneyall_" + i).value = document.getElementById("moneyall_all").value;
        }
    }
	if(document.getElementById("allcount")){
		document.getElementById("allcount").checked=false;
		chtotals(0,0);
	}
    xmlHttp.abort();
}

function TaxRateValueAll() {
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("TaxRate_" + i)) {
            document.getElementById("TaxRate_" + i).value = document.getElementById("TaxRate_All").value;
        }
    }
}

function datesc() {
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("daysdate1_" + i+"Pos")) {
            document.getElementById("daysdate1_" + i+"Pos").value = document.getElementById("daysOfMonth7Pos").value;
        }
    }
    xmlHttp.abort();
}
function gateall() {
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("gate_name_" + i) && document.getElementById("gate_name_all").value.length>0) {
            document.getElementById("gate_name_" + i).value = document.getElementById("gate_name_all").value;
        }
        if (document.getElementById("gate_id_" + i) && document.getElementById("gate_id_all").value.length>0) {
            document.getElementById("gate_id_" + i).value = document.getElementById("gate_id_all").value;
        }
    }
    xmlHttp.abort();
}
function chtotals(id,types){
	if(document.getElementById("allcount")){
		if(document.getElementById("allcount").checked==true){
		return false;
		}
	}
	document.getElementById("moneysum_all").value=0;
    for (var i = 1; i < 1000; i++) {
		var allmoneys=parseFloat(document.getElementById("moneysum_all").value);
        if (document.getElementById("moneyall_" + i)) {
			if (!isNaN(parseFloat(document.getElementById("moneyall_" + i).value)))
			{
			//alert(parseFloat(document.getElementById("moneyall_" + i).value));
			  document.getElementById("moneysum_all").value = allmoneys+parseFloat(document.getElementById("moneyall_" + i).value);
			}
        }
    }
    xmlHttp.abort();
}
function reset_bh(form) {
	location.reload();
	return false;
	form.reset();
    for (var i = 1; i < 1000; i++) {
        if (document.getElementById("company_khid_" + i)) {
			var names=document.getElementById("company_khid_" + i).name.replace("_khid_","_bh_");
            document.getElementsByName(names)[0].value = document.getElementById("company_khid_" + i).value;
			var names1=document.getElementById("company_userid_" + i).name.replace("company_userid_","gate_id_");
			document.getElementsByName(names1)[0].value = document.getElementById("company_userid_" + i).value;
			var names2=document.getElementById("company_username_" + i).name.replace("company_username_","gate_name_");
			document.getElementsByName(names2)[0].value = document.getElementById("company_username_" + i).value;
        }
    }
    xmlHttp.abort();
}

