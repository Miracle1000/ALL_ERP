


function add(ord,i,id) {
  var iall = document.getElementById("i").value;
  var top = document.getElementById("top").value;
  var kuinlist = document.getElementById("kuinlist"+i).value;
  var caigoulist = document.getElementById("caigoulist"+i).value;
  var gys = document.getElementById("gys"+i).value;
  var unit1 = document.getElementById("unit"+i).value;
  var num1 = document.getElementById("num1"+i).value;
  var num1old =  document.getElementById("num1old"+i).value;
  var moneyall = document.getElementById("moneyall"+i).value;
  var ck = document.getElementById("ck"+i).value;
  var ph = document.getElementById("ph"+i).value;
  var xlh = document.getElementById("xlh"+i).value;
  var datesc = document.getElementById("daysdatesc"+i+"Pos").value;
  var dateyx = document.getElementById("daysdateyx"+i+"Pos").value;
  var bz = document.getElementById("bz"+i).value;
  var js = document.getElementById("js"+i).value;
  var intro = document.getElementById("intro"+i).value;
  var w2  = "trpx"+(i-1);
  w2=document.all[w2];
  if ( isNaN(num1) || ( Number(num1) >=  Number(num1old)) || (num1 == "") || ( Number(num1) == 0)) return;
  var url = "cu.asp?iall=" + escape(iall)+"&top="+escape(top)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&intro1="+escape(intro)+"&id="+escape(id)+"&i="+escape(i)+"&kuinlist="+escape(kuinlist) + "&caigoulist="+escape(caigoulist)+"&gys="+escape(gys)+"&unit="+escape(unit1)+"&moneyall="+escape(moneyall)+"&ck="+escape(ck)+"&ph="+escape(ph)+"&xlh="+escape(xlh)+"&datesc="+escape(datesc)+"&dateyx="+escape(dateyx)+"&bz="+escape(bz)+"&js="+escape(js)+"&intro="+escape(intro)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
	var w = document.getElementById("i").value;
	for(var i=1; i<w; i++)
	{
		document.getElementById("ph"+i).value = document.getElementById("phall").value;
	}
}
function xlh() {
	var w = document.getElementById("i").value;
  for(var i=1; i<w; i++)
　{
		document.getElementById("xlh"+i).value = document.getElementById("xlhall").value;
	}
}
function datesc() {
	var ret7 = jQuery("#daysOfMonth7Pos").val();	
	jQuery("input[name^='datesc_'").each(function(){
		jQuery(this).val(ret7);
		jQuery(this).change();
	});
}
function dateyx() {
	var ret8 = jQuery("#daysOfMonth8Pos").val();
	jQuery("input[name^='dateyx_'").each(function(){
		jQuery(this).val(ret8);
		jQuery(this).change();
	});
}
function bz() {
	var w = document.getElementById("i").value;
 	for(var i=1; i<w; i++)
　{
		document.getElementById("bz"+i).value = document.getElementById("bzall").value;
	}
}
function ck() {
	var w = document.getElementById("i").value;
 	for(var i=1; i<w; i++)
　{
		var o=document.getElementById("ck"+i);
		var t=document.getElementById("ck0");
		o.value=t.value;
		o.parentElement.getElementsByTagName("label")[0].style.cssText="width:80px;height:20px;overflow:hidden;float:left;white-space:nowrap;text-overflow:ellipsis;";
		o.parentElement.getElementsByTagName("label")[0].title=t.parentElement.getElementsByTagName("label")[0].innerHTML;
		o.parentElement.getElementsByTagName("label")[0].innerHTML=t.parentElement.getElementsByTagName("label")[0].innerHTML;
	}
}

function del(str,id){
	var w  = str;
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function chtotal(id)
{
	var price= document.getElementById("pricetest"+id);
	var num= document.getElementById("num"+id);
	var moneyall= document.getElementById("moneyall"+id);
	var money1=price.value * num.value;
	moneyall.value=FormatNumber(money1,2);
}
//格式化内容
function formatData(obj, type)
{
	var ov = obj.getAttribute("oldvalue");
	var v = obj.value;
	var fnum = "a";
	if(window.event.propertyName!="value") {return;}
	if(obj.getAttribute("fving")==1) {return;}
	if(!type) {type = obj.getAttribute("datatype");}
	if(!ov && ov!=="") {ov = obj.defaultValue;}
	switch(type)
	{
		case "float":
			v = v.replace(" ","z");  //使空格不为数字
			if(isNaN(v)){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}
			break;
		case "money":
			fnum = window.sysConfig.moneynumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "number":
			fnum = window.sysConfig.floatnumber;
			v = v.replace(" ","z");  //使空格不为数字
			break;
		case "int":
			if(isNaN(v) || v.indexOf(".") >= 0){
				obj.setAttribute("fving",1)
				if(ov.length>0 && isNaN(ov)) { obj.value =  "";}
				else {obj.value = ov;}
				obj.setAttribute("fving",0)
			}
			break;
		default:
	}
	if(!isNaN(fnum))
	{
		var cv = v;
		var f = isNaN(v)
		if( f == false )
		{
			var s = v.toString().split(".");
			if(s.length==2){
				if(s[1].length > fnum){
					s[1] = s[1].substr(0,fnum);
				}
				v = s[0] + "." + s[1]
			}
		}
		else{
			if(v.replace(/\s/g,"").length==0) {
				v = "0";
				window.setTimeout(function (){obj.select();},100);
			}
			else{
				v = ov;
			}
		}
		if(cv!=v) {
			obj.setAttribute("fving",1);
			obj.value = v;
			obj.setAttribute("fving",0)
		}
	}
	obj.setAttribute("oldvalue", obj.value);
}
