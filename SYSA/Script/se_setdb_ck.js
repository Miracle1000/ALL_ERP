

function add(ord,i,id) {
	var kuout = document.getElementById("kuout"+i).value;
	var kuoutlist = document.getElementById("kuoutlist"+i).value;
	var contractlist = document.getElementById("contractlist"+i).value;
	var unit1 = document.getElementById("unit"+i).value;
	var num1 = document.getElementById("num1"+i).value;
	var num1old =  document.getElementById("num1old"+i).value;
	var moneyall = document.getElementById("moneyall"+i).value;
	var intro = document.getElementById("intro"+i).value;
	var ck = document.getElementById("ck"+i).value;
	var bz = document.getElementById("bz"+i).value;
	var js = document.getElementById("js"+i).value;
	var ph = document.getElementById("ph"+i).value;
	var xlh = document.getElementById("xlh"+i).value;
	var datesc = document.getElementById("datesc"+i).value;
	var dateyx = document.getElementById("dateyx"+i).value;
	var w2  = "trpx"+(i-1)+"_"+id;
	w2=document.all[w2];
	if ( isNaN(num1) || ( Number(num1) >=  Number(num1old)) || (num1 == "") || ( Number(num1) == 0)) return;
	var url = "cu_ck.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+
		"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&kuout="+escape(kuout) + 
		"&kuoutlist="+escape(kuoutlist) + "&contractlist="+escape(contractlist)+
		"&unit="+escape(unit1)+
		"&moneyall="+escape(moneyall)+"&ck="+escape(ck)+
		"&ph="+escape(ph)+
		"&xlh="+escape(xlh)+
		"&datesc="+escape(datesc)+
		"&dateyx="+escape(dateyx)+
		"&bz="+escape(bz)+"&js="+escape(js)+
		"&intro="+escape(intro)+
		"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	updatePage(w2);
	};
	xmlHttp.send(null);
}

function updatePage(w2) {
	var test6=w2;
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
	if(!document.getElementById("alli")) {return;}
	var w = document.getElementById("alli").value;
	for(var i=1; i<w; i++)
	{
		document.getElementById("ph"+i).value = document.getElementById("phall").value;
	}
}
function xlh() {
	if(!document.getElementById("alli")) {return;}
	var w = document.getElementById("alli").value;
	for(var i=1; i<w; i++)
	{
		document.getElementById("xlh"+i).value = document.getElementById("xlhall").value;
	}
}
function datesc() {
	if(!document.getElementById("alli")) {return;}
	var w = document.getElementById("alli").value;
	for(var i=1; i<w; i++)
	{
		document.getElementById("daysdatesc"+i+"Pos").value = document.getElementById("daysOfMonth7Pos").value;
	}
}
function dateyx() {
	if(!document.getElementById("alli")) {return;}
	var w = document.getElementById("alli").value;
	for(var i=1; i<w; i++)
	{
		document.getElementById("daysdateyx"+i+"Pos").value = document.getElementById("daysOfMonth8Pos").value;
	}
}
function bz() {
	if(!document.getElementById("alli")) {return;}
	var w = document.getElementById("alli").value;
	for(var i=1; i<w; i++)
	{
		document.getElementById("bz"+i).value = document.getElementById("bzall").value;
	}
}

function ck(sort_ck) {
	if(!document.getElementById("alli")) {return;}
	var w = document.getElementById("alli").value;
	for(var i=1; i<=w-1; i++)
	{
		var o=document.getElementById("ck"+i);
		var t=document.getElementById("ck0");
		o.value=t.value;
		o.parentElement.getElementsByTagName("label")[0].style.cssText="width:80px;height:20px;overflow:hidden;float:left;white-space:nowrap;text-overflow:ellipsis;";
		o.parentElement.getElementsByTagName("label")[0].title=t.parentElement.getElementsByTagName("label")[0].innerHTML;
		o.parentElement.getElementsByTagName("label")[0].innerHTML=t.parentElement.getElementsByTagName("label")[0].innerHTML;
		o.fireEvent("onchange");
	}
}

function del(str,id){
	var w  = str;
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_del(w);
	};
	xmlHttp.send(null);
}
function updatePage_del(str){
	document.getElementById(str).style.display="none";
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
	var money1=price.value * num.value;
	moneyall.value=FormatNumber(money1,num_dot_xs);
}
function check_kh(ord,unit,unit2,ckjb,ck,id,num1,kcid,numid) {
	var w  = "ck2xz_"+id;
	w=document.all[w];
	var url = "../store/ku_unit_cf.asp?ord=" + escape(ord) + "&unit=" + escape(unit) + "&unit2=" + escape(unit2) + "&ckjb=" + escape(ckjb) + "&ck=" + escape(ck) + "&id=" + escape(id) + "&num1=" + escape(num1) + "&kcid=" + escape(kcid) + "&numid=" + escape(numid) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage2(w);
	};
  	xmlHttp.send(null);
}
function updatePage2(w) {
	var test7=w;
	var sID = w.id.split("_")[1];
	if (xmlHttp.readyState < 4) {
		test7.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test7.innerHTML=response;
		var stidx = response.indexOf("<b>");
		var edidx = response.indexOf("</b>");
		var allv = response.slice(stidx+3,edidx-1);
		var smax = allv.split(" ");
		var max = parseFloat(smax[smax.length-1].replace(/\,/g,""));
		var chDom = document.querySelector("input[name='num1_"+ sID +"']").setAttribute("max",max);
		xmlHttp.abort();
	}
}

function check_ckxz(i) {
	var ck = document.getElementById("ck"+i).value;
	if (ck != "") return true;
	alert("请先选择仓库！");
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

function ckxz(ord, i, id, w, sort_ck, attr1id, attr2id) {
	var kuout = jQuery('#kuout'+i).val();
	var kuoutlist = jQuery('#kuoutlist'+i).val();
	var contractlist = jQuery('#contractlist'+i).val();
	var unit1 = jQuery('#unit'+i).val();
	var num1 = jQuery('#num1'+i).val();
	var num1old =  jQuery('#num1old'+i).val();
	var moneyall = jQuery('#moneyall'+i).val();
	var ck = jQuery('#ck'+i).val();
	var bz = jQuery('#bz'+i).val();
	var js = jQuery('#js'+i).val();
	var intro = jQuery('#intro'+i).val();
	var ph = jQuery('#ph'+i).val();
	var xlh = jQuery('#xlh'+i).val();
	var datesc = jQuery('#datesc'+i).val();
	var dateyx = jQuery('#dateyx'+i).val();
	var zdy1 = jQuery('#zdy1'+i).val() || '';
	var zdy2 = jQuery('#zdy2'+i).val() || '';
	var zdy3 = jQuery('#zdy3'+i).val() || '';
	var zdy4 = jQuery('#zdy4'+i).val() || '';
	var zdy5 = jQuery('#zdy5'+i).val() || '';
	var zdy6 = jQuery('#zdy6'+i).val() || '';
	zdy1 = zdy1.replace(/\n/g, "vbcrlf").replace(/\r/g, "");
    zdy2 = zdy2.replace(/\n/g, "vbcrlf").replace(/\r/g, "");
	zdy3 = zdy3.replace(/\n/g, "vbcrlf").replace(/\r/g, "");
	zdy4 = zdy4.replace(/\n/g, "vbcrlf").replace(/\r/g, "");
	var w2  = w;
	w2 = document.all[w2];
	var url = "cu_ck2_db.asp?timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
	jQuery.ajax({
		url : url,
		type:'post',
		data:{
			ord:ord,
			num1:num1,
			num1old:num1old,
			intro1:intro,
			sort_ck:sort_ck,
			kuoutlist:kuoutlist,
			contractlist:contractlist,
			id:id,
			i:i,
			kuout:kuout,
			unit: unit1,
			ProductAttr1: attr1id,
			ProductAttr2: attr2id,
			moneyall:moneyall,
			ck:ck,
			ph:ph,
			xlh:xlh,
			datesc:datesc,
			dateyx:dateyx,
			bz:bz,
			js:js,
			intro:intro,
			zdy1:zdy1,
			zdy2:zdy2,
			zdy3:zdy3,
			zdy4:zdy4,
			zdy5:zdy5,
			zdy6:zdy6
		},
		success:function(r){
			jQuery('#' + w)[0].innerHTML=r;
		}
	});
}

function updatePage_ckxz(w2) {
	var test6=w2;
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
	var ph = document.getElementById("ph"+i).value;
	var xlh = document.getElementById("xlh"+i).value;
	var datesc = document.getElementById("datesc"+i).value;
	var dateyx = document.getElementById("dateyx"+i).value;
  var w2  = w;
  w2=document.all[w2];
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
	w2=document.all[w2];
	var url = "cu_kuin2.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_zdkc(w2);
	};
	xmlHttp.send(null);
}

function updatePage_zdkc(w2) {
	var test6=w2;
	if (xmlHttp.readyState < 4) {
		test6.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		if(response.indexOf('0.0</b>')!=-1)response='';
		test6.innerHTML=response;
		xmlHttp.abort();
	}
}

function check_ck(ord,id,i) {
	var num1 = document.getElementById("num1"+i).value;
	var num1old = document.getElementById("num1old"+i).value;
	if ( isNaN(num1) || (num1 == "") ) {
		alert("只能输入数字！");
		document.getElementById("num1"+i).value=num1old;
		return false;
	}
	if (Number(num1) > Number(num1old)) {
		alert("大于应出库数量！");
		document.getElementById("num1"+i).value=num1old;
		return false;
	}
	document.getElementById("num1"+i).value=Number(num1);
	return true;
}

function del_zd(id) {
	var url = "del_zd.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	};
	xmlHttp.send(null);
	document.all["zdkc" + id].innerHTML = "";
}


function CheckNum()
{
	var arrInput=document.getElementsByTagName("input");
	var fOriNum=0,fSelectNum=0;
	for(var i=0;i<arrInput.length;i++)
	{
		if(arrInput[i].name.indexOf("num1_")>=0)
		{
			var tmpvalue=0;
			var tmpobj=document.getElementsByName("way1_"+arrInput[i].name.replace("num1_",""));
			for(var j=0;j<tmpobj.length;j++)
			{
				if(tmpobj[j].checked) tmpvalue=parseInt(tmpobj[j].value);
			}
			if(tmpvalue==2)
			{
				fOriNum=parseFloat(arrInput[i].value);
				var tmpstr=document.getElementById("zdkc"+arrInput[i].name.replace("num1_","")).innerText;
				if(tmpstr!="")
				{
					fSelectNum=parseFloat(tmpstr.replace("已指定：","").replace(/,/g,""));
					if(fSelectNum<fOriNum)
					{
						alert("已指定的数量（"+fSelectNum+"）小于总数量（"+fOriNum+"），请继续选择！");
						return false;
					}
				}
			}
		}
	}
	return true;
}
//拆分页面跳转
function openurltocf(productid, unit, ck, attr1, attr2, moreunit, Ismode, id,numid)
{
    var num1 = document.getElementById("num1" + numid).value;
    if (document.getElementsByName("ProductAttr1_" + id).length > 0) {
        attr1 = document.getElementsByName("ProductAttr1_" + id)[0].value;
        attr2 = document.getElementsByName("ProductAttr2_" + id)[0].value;
    }
    window.open('../../sysn/view/store/kuout/KuAppointSplit.ashx?productid=' + productid + '&unit=' + unit + '&ck=' + ck + '&attr1=' + attr1 + '&attr2=' + attr2 + '&moreunit=' + moreunit + '&Ismode=3&id=' + id + '&cfnum1=' + num1 + '&numid=' + numid + '&attr1=' + attr1 + '&attr2=' + attr2 + '', 'newwin23', 'width=' + 800 + ',height=' + 400 + ',toolbar=0,scrollbars=1,resizable=1,left=100,top=100');

}