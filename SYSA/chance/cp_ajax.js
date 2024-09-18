var xmlHttp = GetIE10SafeXmlHttp();
function callServer(nameitr,ord,i,id) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var num1 = document.getElementById("num"+id).value;
   var w  = document.all[nameitr];
   var w2  = "trpx"+i;
   w2=document.all[w2]
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function showPrice(id,ord){
	var x=event.x,y=event.y;
	jQuery.ajax({
		url:"../price/cu_lishi.asp",
		cache:false,
		data:{
			unit:jQuery('#u_nametest'+id).val(),
			ord:ord
		},
		success:function(html){
			var $span = jQuery('#info_show_div');
			if($span.size()==0) $span=jQuery('<span id="info_show_div" style="width:100px;position:absolute;z-index:99999;margin-left:0;"/>').appendTo(jQuery(document.body));
			$span.css({left:x,top:y}).html(html).show();
		}
	});
}

function callServer2(nameitr,ord,id) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   
   var u_name = document.getElementById("u_name"+nameitr).value;
   
   if ((u_name == null) || (u_name == "")) return;
  var url = "../price/cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w);
  };

  xmlHttp.send(null);  
}

function updatePage2(w) {
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


function callServer3(nameitr,ord,id) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}


function callServer4(ord,top,unit) {
	unit = unit || '';
	if ((ord == null) || (ord == "")) return;
	var url = "addlistadd.asp?ord=" + escape(ord) + "&top=" + escape(top) + "&unit=" + unit;
	url = window.GetLongAttrUrl(url, "ord");
	plist.add(url,null);
}


function del(str,id ,event){

	plist.del("../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100),null,null,event)

}

//.task.1437 项目生成生产计划明细的问题(解决项目明细修改保存后id发生变化的问题) by 常明 20140309
function UnitChange(nameitr,ord,i,id,isChanceDetialEdit) {
	var UpdateCol =  ",num1,price1,money1,折扣,pricejy,tpricejy,"; //单位更改默认只更新这几列数据
	window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
	var $unit = jQuery("#u_name"+nameitr);
	var u_name = $unit.val();
	var num1 = document.getElementById("num"+id).value;
	var w  = document.getElementById(nameitr);
	var w2  = "trpx"+i;
	w2=document.getElementById(w2);
	if ((u_name == null) || (u_name == "")) return;
	var data = {
		editFlg:(isChanceDetialEdit?1:0),
		unit:u_name,
		ord:ord,
		num1:num1,
		id:id,
		i:i,
		nameitr:nameitr
	};

	if(isChanceDetialEdit){
		data['oldchancelist'] = jQuery('#oldchancelist_'+id).val();
	}

	jQuery.ajax({
		url:"cu.asp",
		data:data,
		type:'get',
		async:false,
		success:function(html){
			var div = document.createElement("DIV")
			var v = html.split("<noscript></noscript>");
			if (v.length>1){
				html = v[1]
				div.innerHTML =v[1];
			}else{
				div.innerHTML = html;
			}
			var datatr =  div.children[0].rows[0];
			var currRow = jQuery(window.uintchangepan).children('table:eq(0)').get(0).rows[0];
			var headRow = document.getElementById("productlistHead") //用定义表头
			if (headRow) {
				for (var i=0;i<headRow.cells.length;i++ ){
					var cell = headRow.cells[i];
					if($(cell).attr("dbname")&& UpdateCol.indexOf("," + $(cell).attr("dbname") + ",")>=0){
						var nv = datatr.cells[i].innerHTML;
						try {
							currRow.cells[i].innerHTML = nv;
						}catch (e){}
					}
				}
			}else{
				window.uintchangepan.innerHTML = html;
			}
			div = null;	
			$unit.attr('oldValue',u_name);
		},
		error:function(resp){
			document.write(resp.responseText)
		}
	});
}


function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "../contract/search_cp.asp?B="+escape(B)+"&C="+encodeURI(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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
	xmlHttp.abort();
  }
}

function chtotal(id,num_dot_xs,jfzt) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var zhekou= document.getElementById("zhekou"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,'')  
moneyall.value=FormatNumber(money1,num_dot_xs)

}

function superSearch(inttype){
	if (inttype==2)
	{
		document.getElementById('kh').style.display='';
		document.getElementById('ht1').value='';
		document.getElementById('ht1').style.display='none';
		document.getElementById('tttt').className='zdy';
		document.getElementById('gd2').className='zdy1 top tophead';
		return false;
	}
}


function search_lb() {
	document.getElementById('kh').style.display='none';
	document.getElementById('ht1').style.display='block';
	document.getElementById('ht1').style.position='relative';
	document.getElementById('ht1').style.zIndex=1;
	document.getElementById('tttt').className='';
	document.getElementById('gd2').className='top';
	var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);  
    var response = xmlHttp.responseText;
	document.getElementById('ht1').innerHTML=response;
}

function callServer5(s,nameitr,ord,id) {
  var w  =s ;
   w=document.all[w]

   var u_name = document.getElementById("u_name"+nameitr).value;
   
   if ((u_name == null) || (u_name == "")) return;
  var url = "../contract/cu_kccx.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage_kc(w);
  };

  xmlHttp.send(null);  
}

function updatePage_kc(w) {
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
function callServer6(t,nameitr,ord,id) {
   var w  =t;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}

function cptj(ord,top) {
  setTimeout("callServer4('"+ord+"','"+top+"')",1000);
   xmlHttp.abort();
}

