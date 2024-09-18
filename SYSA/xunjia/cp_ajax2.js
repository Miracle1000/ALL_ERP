function echo(p){document.write(p);	}

String.prototype.replaceAll = function(reallyDo, replaceWith, ignoreCase) {  
    if (!RegExp.prototype.isPrototypeOf(reallyDo)) {  
        return this.replace(new RegExp(reallyDo, (ignoreCase ? "gi": "g")), replaceWith);  
    } else {  
        return this.replace(reallyDo, replaceWith);  
    }  
}  

function UnitChange(nameitr,ord,i,id,event){
	window.uintchangepan = getParent(window.event.srcElement,5); //获取所在行
	var u_name = document.getElementById("u_name"+nameitr).value;
	var num1 = document.getElementById("num"+id).value;
	var w  = document.all[nameitr];
	var w2  = "tr_px"+i;

	w2=document.all[w2]
	if ((u_name == null) || (u_name == "")) return;

	var url = "cu.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
  
	xmlHttp.send(null);  
	window.uintchangepan.innerHTML = xmlHttp.responseText;
	window.uintchangepan = null
}

function callServer(nameitr,ord,i,id,event) {
	window.UnitRow = plist.getParent(window.event.srcElement,5);
	var u_name = document.getElementById("u_name"+nameitr).value;
	var num1 = document.getElementById("num"+id).value;
	var w  = document.all[nameitr];
	var w2  = "tr_px"+i;

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
   var test6 = window.UnitRow;
   if (xmlHttp.readyState < 4) {
	   test6.innerHTML="loading...";
    }
 
    if (xmlHttp.readyState == 4) {
   
    var response = xmlHttp.responseText;
	response = response.split('</noscript>')[1]
	try{ 
		test6.innerHTML=response;
		productListResize();
		//alert(test6.innerHTML)
	}
	catch(err)
	{alert(err)}
	

	xmlHttp.abort();
  }

}



function callServer5(s,nameitr,ord,id) {
  var w  =s ;
   w=document.all["tttttest"]
   var u_name = document.getElementById("u_name"+nameitr).value;
   if ((u_name == null) || (u_name == "")) return;

   var left=parseInt(event.clientX)+10;
	var top=parseInt(event.clientY)+10;  //鼠标的y坐标
	w.style.top=top+"px";
	w.style.left=left+"px";

  var url = "../contract/cu_kccx.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage_kc(w);
  };

  xmlHttp.send(null);  
}




function updatePage_kc(w) {
var test6=w;
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
   w=document.all["tttttest"]
   w.innerHTML="";
   xmlHttp.abort();
}


function callServer2(nameitr,ord,company,id,event) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var id_show = document.getElementById("id_show").value; 
   var w  = "ttcaigou";
   w=document.all[w]
   var w2  = "t"+nameitr;
   w2=document.all[w2]
   var w3  = document.all[nameitr];
   
  if (id_show != "") return;
	var left=parseInt(event.clientX)-15;
	if (parseInt(document.documentElement.scrollTop) >0)
	{
		var top=parseInt(event.clientY)+parseInt(document.documentElement.scrollTop);  //鼠标的y坐标
	}else{
	    var top = parseInt(event.clientY) + 5 + parseInt(document.documentElement.scrollTop);  //鼠标的y坐标
	}
	w.style.top=top+"px";
	w.style.left=left+"px";
  
  var url = "../caigou/cu2.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&company1="+escape(company)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w,w2);
  };
  xmlHttp.send(null);  
}

function updatePage2(namei,w2) {
var test7=namei
var test6=w2
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	var id_show= document.getElementById("id_show");
	id_show.value="1"
	xmlHttp.abort();
  }

}

function callServer2_ls(nameitr,ord,id,gys,unit,event) {
   var w  = "lstt"+nameitr;
   w=document.all[w];
	var left=parseInt(event.clientX);
	var top=parseInt(event.clientY)+5;  //鼠标的y坐标
	w.style.top=top+"px";
	w.style.left=left+"px";
  var url = "../caigou/cu_lishi.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  updatePage2_ls(w);
  };

  xmlHttp.send(null);  
}

function updatePage2_ls(w) {
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


function callServer3_ls(nameitr,ord,id) {
   var w  = "lstt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   xmlHttp.abort();
}

function callServer3(nameitr,ord,company,id) {
   var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = "t"+nameitr;
   w=document.all[w];
   var w2  = "ttcaigou";
   w2=document.all[w2];
  if ((u_name == null) || (u_name == "")) return;
  var url = "../caigou/cu3.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gs="+escape(company)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage3(w,nameitr,w2);
  };

  xmlHttp.send(null);  
}

function updatePage3(namei,id,w2) {
var test7=namei
var test6=w2
  
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML="";
	test7.innerHTML=response;
	try{
	    var price = document.getElementById("pricejc" + id).value;
	    var ProdincludeTax = document.getElementById("ProdincludeTax" + id).value;
	    var taxRate = document.getElementById("taxRate_" + id.replace("caigou", "")).value;
	    if (taxRate == 0) { taxRate = 0; } else { taxRate = taxRate / 100;}
	    if (ProdincludeTax == 1) {
	        price = price / (1 + taxRate);
	    }

		if (!price || price.length==0){ price = 0 ;}
		document.getElementById("pricetest"+id.replace("caigou","")).value =FormatNumber(price,window.sysConfig.StorePriceDotNum) ;
		chtotal(id.replace("caigou",""),window.sysConfig.StorePriceDotNum,0,document.getElementById("pricetest"+id.replace("caigou","")));
	}
	catch(e){}
	var id_show= document.getElementById("id_show");
	id_show.value=""
	productListResize();
	xmlHttp.abort();
  }
}

function callServer3_lsclose(nameitr) {
   var w  = "ttcaigou";
   w=document.all[w]
   w.innerHTML="";
   var id_show= document.getElementById("id_show");
   id_show.value=""
   xmlHttp.abort();
}

function callServer4_lsclose(nameitr) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   var id_show= document.getElementById("id_show");
   id_show.value=""
   xmlHttp.abort();
}


function getFreeRow(){  //获取空行
	var isAddNewPage = $("#tr_px0").html();
	if(isAddNewPage.indexOf("无产品明细")>-1){  //添加页面
		document.getElementById("tr_px0").innerHTML = "";
		return 0;
	}
	else{									//修改页面
		window.addnewPage = false;
		var ii = 0
		while(document.getElementById("tr_px" + ii)){
			if(document.getElementById("tr_px" + ii).innerHTML==""){return ii;}
			ii ++; 
		}
		return -1*(ii-1);
	}
}

function callServer4(ord,top,unit) {
 if ((ord == null) || (ord == "")) return;
  var url = "../contract/num_click.asp?ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);  
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4(ord,top,unit);
  };
  xmlHttp.send(null);  
}

function updatePage4(ord,top,unit) {
	unit = unit || '';	
	if (xmlHttp.readyState == 4) {
		var res = getFreeRow();  //;  直接从页面获取当前行信息  var res  = xmlHttp.responseText;
		var w  = "tr_px"+res;
		w=document.all[w]
		if(w){
			var url = "addlistadd2.asp?ord="+escape(ord)+ "&top=" + escape(top) + '&unit=' + unit;
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				updatePage5(w);
			};
			xmlHttp.send(null);
		}else{
			if(!window.dMaxRows){  //当没有定义最大行时  tbh 2010.12.08
				window.dMaxRows = res - 1;  //获取允许的最大行数
			}	
			window.alert("当前添加的明细行数已到达系统允许的最大值。\n\n详细情况，请咨询系统管理员。")
		}
	}
}

function updatePage5(w) {
    var test3 = w;
    var a = $(test3).attr('id')
	if (xmlHttp.readyState < 4) {
		test3.innerHTML="loading...";
	}

	if (xmlHttp.readyState == 4) {
		var wmxtr = $("#productlist table:first tr:last").html();
		if (wmxtr.indexOf("无产品明细")>-1){
			$("#productlist table:first tr:last").remove();
		}
		var response = xmlHttp.responseText;
		test3.innerHTML=response;
		$("#" + a).find("table.xunjia_pro_list tr td").eq(7).find('input').attr('unselectable', 'on');
		xmlHttp.abort();
		productListResize();
	}
}


function getParent(child,parentIndex){  //获取指定级别的父节点
	for( var i= 0 ;i < parentIndex ; i++){
		child = child.parentElement;
	}
	return child;
}

function getParentTrpx(child, parentIndex) {
    for (var i = 0 ; i < parentIndex ; i++) {
        child = child.parentElement;
        if (child.id.indexOf("tr_px") == 0) return child;
    }
    return child;

}

function del(str,id,event){
    var w = getParentTrpx(event.srcElement || event.target, 6); // w = document.all[str];
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
		
    xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if(xmlHttp.readyState == 4){			
			updatePage_del(w);
		}
  };
  xmlHttp.send(null);  

}


function moveRows(row){
	var id = row.id.replace("tr_px","");
	id = Number(id) + 1;
	var nextRow = document.getElementById("tr_px" + id);
	if(nextRow){
		row.innerHTML = nextRow.innerHTML;
		nextRow.innerHTML = "";
		//moveRows(nextRow);		
	}	
}



function updatePage_del(row) {
    row.innerHTML="";	
	moveRows(row); //删除中间行后，自动填充
	productListResize();
}


function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "../contract/search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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

function ajaxSubmit_gys(nameitr,ord,unit,id){
    //获取用户输入
	//BUG 5496 Sword 2014-8-4 询价单询价时检索供应商信息条件无法正常使用 
	var w  = ("tt"+nameitr).replace(id,"");
	
    //var B=document.forms[1].B.value;
    //var C=document.forms[1].C.value;
    var B=document.getElementById("B1").value;
    var C=document.getElementById("C1").value;
    var url = "../caigou/cu2.asp?id="+escape(id)+"&unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&B="+escape(B)+"&C="+escape(C) +"&stimestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

/*
function chtotal(id,num_dot_xs,jfzt) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value.replace(/\,/g,'') * num.value.replace(/\,/g,'');
moneyall.value=FormatNumber(money1,num_dot_xs);
} */

var isLocked = false;
function chtotal(id, num_dot_xs, jfzt, obj) {
	if (event.propertyName != 'value') return;

	if(isLocked){
		return;
	}else{
		isLocked = true;
	}

	//如果没传入obj参数，代表是以前程序调用的该方法，使用以前的逻辑
	if (obj==null||typeof(obj)!='object'){
		var eobj = event.srcElement;
		var objName = eobj.name;
		var price= document.getElementById("pricetest"+id); 
		var num= document.getElementById("num"+id); 
		var zhekou= document.getElementById("discount_"+id);
		var moneyall = document.getElementById("moneyall" + id);

		var n=num.value.replace(/,/g,''),p=price.value.replace(/,/g,''),m=moneyall.value.replace(/,/g,''),z=zhekou.value.replace(/,/g,'');
		if(m.length==0||n.length==0||p.length==0||z.length==0||isNaN(n)||isNaN(p)||isNaN(m)||isNaN(z)){isLocked=false;return;}
		if (objName.indexOf('moneyall')==0){
			if(parseFloat(n)==0||parseFloat(p)==0){
				zhekou.value = '1';
				isLocked=false;return;
			}
			var discount = //parseFloat(m) / parseFloat(n) / parseFloat(p);
			zhekou.value = FormatNumber(discount,window.sysConfig.discountDotNum);
		}else{
			moneyall.value=FormatNumber(parseFloat(p)*parseFloat(n)*parseFloat(z),window.sysConfig.moneynumber)
		}

		isLocked = false;
		return;
	}

	var $obj = jQuery(obj);
	if(isNaN($obj.val())||$obj.val().length==0){
		isLocked = false;
		return;
	}
	//使onpropertychange事件只触发一次

	var inputName = $obj.attr('name');
	var $price1 = jQuery("#pricetest"+id);
	var $num = jQuery("#num"+id);
	var $discount = jQuery("#discount_"+id);
	var $discountValue = jQuery("#discountValue_"+id);
	var $moneyall = jQuery("#moneyall"+id);
	var $priceAfterDiscount = jQuery("#priceAfterDiscount_"+id);
	var $invoiceType = jQuery("#invoiceType_"+id);
	var $taxRate = jQuery("#taxRate_"+id);
	var $priceIncludeTax = jQuery('#priceIncludeTax_'+id);
	var $priceAfterTax = jQuery('#priceAfterTax_'+id);
	var $taxValue = jQuery('#taxValue_'+id);
	//var $moneyBeforeTax = jQuery('#moneyBeforeTax_'+id);
	var $moneyAfterTax = jQuery('#moneyAfterTax_'+id);
	//var $concessions = jQuery('#concessions_'+id);
	var includeTax = $invoiceType.attr("includeTax")=="1";

	var formula1 = $invoiceType.children(':selected').attr('formula');//含税单价计算公式
	var formula2 = $invoiceType.children(':selected').attr('formula2');//未税单价计算公式
	var price1,priceAfterDiscount,priceAfterTax;
	var num,discount,invoiceType,taxRate,concessions,extras,discountValue;
	var moneyall,moneyAfterConcessions,moneyBeforeTax,moneyAfterTax;

	//在某种条件下需要修改的字段（有的字段在后面会修改，各种情况下不需要修改的字段不同）
	num = parseFloat($num.val());
	price1 = parseFloat($price1.val());//税前单价
	priceAfterDiscount = parseFloat($priceAfterDiscount.val());//折后单价
	taxRate = parseFloat($taxRate.val())/100; //税率
	priceIncludeTax = parseFloat($priceIncludeTax.val()); //含税单价
	priceAfterTax = parseFloat($priceAfterTax.val());
	discount = parseFloat($discount.val());//折扣
//	discountValue = parseFloat($discountValue.val());//折扣真实值
	discountValue = discount //改回原逻辑
	//任务：2826 借货转合同价格编辑总价不变  xieyanhui20150609
	if (!discount && discount!=0){
		discount = 1;
		discountValue = 1;
	}
	//concessions = parseFloat($concessions.val());//优惠金额
	moneyAfterTax = parseFloat($moneyAfterTax.val());//税后总价

	var changeList=['price1','discount','priceAfterDiscount','priceIncludeTax','priceAfterTax','taxValue','moneyAfterTax','moneyall'];
	var fieldName = inputName.split("_")[0];

	if(inputName.indexOf("taxRate_")==0 || inputName.indexOf("discount_")==0){
		if(inputName.indexOf("discount_")==0) discountValue = discount;
		//修改税率或折扣，分含税不含税两种情况
		if(includeTax){
			//含税：使用公式2计算未税单价，再算出其他价格
			price1 = parseFloat(priceIncludeTax/(1+taxRate)); //未税单价
			priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
		}else{
			//不含税：以未税单价为基础，用公式1计算各税后价格和总价
			priceIncludeTax = parseFloat(price1*(1 +taxRate)); //含税单价
			priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
		}
		priceAfterDiscount = parseFloat(price1 * discount); //折后单价
	}else if(inputName.indexOf("price1_")==0){
		//修改未税单价：价格相关均变化，需用公式1计算税后单价
		priceIncludeTax = parseFloat(price1 * ( 1  + taxRate)); //含税单价
		priceAfterDiscount = parseFloat(price1 * discount); //折后单价
		priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
	}else if (inputName.indexOf("priceAfterTax_")==0){
		//修改含税折后单价：仅变动折扣和未税折后单价的值
		discount = priceIncludeTax == 0 ? 1 : parseFloat(priceAfterTax / priceIncludeTax);
		priceAfterDiscount = parseFloat(price1 * discount);
	}else if (inputName.indexOf("priceIncludeTax_")==0){
		//修改含税单价：未税折后单价、未税单价以及各种总价发生变化，需用公式2计算未税单价
		price1 = parseFloat(priceIncludeTax/(1 + taxRate)); //未税单价
		priceAfterDiscount = parseFloat(price1 * discount); //折后单价
		priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
	}else if (inputName.indexOf("priceAfterDiscount_")==0){
		//修改未税折后单价：需用公式1计算含税单价、折扣
		discount = parseFloat(price1 == 0 ? 1 : priceAfterDiscount / price1);
		priceIncludeTax = parseFloat( price1 * (1 + taxRate)); //含税单价
		priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
	}

	moneyBeforeTax = priceAfterDiscount.toFixed(window.sysConfig.StorePriceDotNum) * num; //税前总价
	moneyAfterTax = priceAfterTax.toFixed(window.sysConfig.StorePriceDotNum) * num; //税后总价
	taxValue = moneyAfterTax - moneyBeforeTax; //税额
	moneyall = moneyBeforeTax //- concessions //总价

	for (i=0;i<changeList.length ;i++ ){
		if(fieldName==changeList[i]) continue;//触发事件自身的值不需要改变
		if (changeList[i] == "discount") {
			eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.discountDotNum+"));");
		}else if("|price1|priceAfterDiscount|priceIncludeTax|priceAfterTax|".indexOf("|"+changeList[i]+"|")>-1){
			eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.StorePriceDotNum+"));");
		}else{
			eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.moneynumber+"));");
		}
	}
	discountValue = discount
	$discountValue.val(discountValue);

	isLocked=false;
}


function changeInvoice(idx){
	var mxEditAble = jQuery("#invoiceType_"+idx).attr("mxEditAble");
	if(mxEditAble == "0"){
		//jQuery("#invoiceType_"+idx+" option:first").prop("selected", 'selected'); 
		jQuery("#invoiceType_"+idx).find("option[value='0']").attr("selected",true);
		return;
	}
	var $taxRate = jQuery('#taxRate_'+idx);
	var $invoiceType = jQuery('#invoiceType_'+idx);
	$taxRate.val($invoiceType.children(':selected').attr('taxRate'));
	//非IE兼容
	var jfzt = (document.getElementById("jf_"+idx)?1:0) ;
	if(!window.ActiveXObject){chtotal(idx,window.sysConfig.moneynumber,jfzt,$taxRate[0]);}
}

function search_lb() {
  var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_sh_lb();
  };
  xmlHttp.send(null);  
}
function updatePage_sh_lb() {
var test7="ht1"
  if (xmlHttp.readyState < 4) {
	ht1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	ht1.innerHTML=response;
	xmlHttp.abort();
  }
}

function callServer4_2(ord, id, j, unit) {
	var status = $("#Xunjiastatus_" + id).val();
	if (status != null && status == "1") return;
 //alert(ord+':'+id+':'+j+':'+unit)
 if ((ord == null) || (ord == "")) return;
  var url = "num_click.asp?ord="+escape(ord)+"&id="+escape(id) + "&j="+escape(j) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4_2(ord,id,j,unit);
  };
  xmlHttp.send(null);  
}


function updatePage4_2(ord,id,j,unit) {
	if (xmlHttp.readyState < 4) {
	}
	if (xmlHttp.readyState == 4) {
		var res = xmlHttp.responseText;
		if (res.indexOf('out_of_lines:')==0){
			alert('询价明细超过限制，每个产品最多只能有'+res.replace('out_of_lines:','')+'条询价明细')
			return;
		}
		var w  = "trpx"+res;
		var url = "addlistadd3.asp?ord="+escape(ord)+"&id="+escape(id)+"&j="+escape(j) + "&unit="+(unit) + "&stimestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){
			updatePage5_2(w,id);
		};
	xmlHttp.send(null);  
	}
}
//--TASK.2429.ZYF 2015-2-4 询价能显示实际供应商 
//--扩展函数，增加参数j，继承父函数的参数j
function updatePage5_2(w,id) {
var test3=$("#"+w);
  if (xmlHttp.readyState < 4) {
	test3.html("loading...");
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test3.html(response);
	xmlHttp.abort();
      try {
		test3.find("input[name^='num1_']").val($("#num" + id).val());
		test3.find("input[name^='price1_']").val($("#pricetest" + id).val());
		test3.find("input[name^='taxRate_']").val($("#taxRate_" + id).val());
		test3.find("select[name^='invoiceType_']").val($("#invoiceType_" + id).val());
		test3.find("input[name^='discount_']").val($("#discount_" + id).val());
		test3.find("input[name^='priceAfterDiscount_']").val($("#priceAfterDiscount_" + id).val());
		test3.find("input[name^='priceIncludeTax_']").val($("#priceIncludeTax_" + id).val());
		test3.find("input[name^='priceAfterTax_']").val($("#priceAfterTax_" + id).val());
		test3.find("input[name^='moneyall_']").val($("#moneyall" + id).val());
		test3.find("input[name^='taxValue_']").val($("#taxValue_" + id).val());
		test3.find("input[name^='moneyAfterTax_']").val($("#moneyAfterTax_" + id).val());
		test3.find("input[name^='date1_']").val($("#daysdate1_" + id+"Pos").val());
		test3.find("textarea[name^='intro_']").val($("#intro_" + id).val());
		test3.find("input[name^='zdy1_']").val($("#zdy1_" + id).val());
		test3.find("input[name^='zdy2_']").val($("#zdy2_" + id).val());
		test3.find("input[name^='zdy3_']").val($("#zdy3_" + id).val());
		test3.find("input[name^='zdy4_']").val($("#zdy4_" + id).val());
		test3.find("select[name^='zdy5_']").val($("#zdy5_" + id).val());
		test3.find("select[name^='zdy6_']").val($("#zdy6_" + id).val());
	}catch(e){}
	productListResize();
  }
}

//by chenwei 20100909
function cptj(ord,top) {
  setTimeout("callServer4('"+ord+"','"+top+"')",1000);
   xmlHttp.abort();
}


function xj_callServer4(ord,id,j,unit) {
 if ((ord == null) || (ord == "")) return;
  var url = "num_click.asp?ord="+escape(ord)+"&id="+escape(id) + "&j="+escape(j) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  xj_updatePage4(ord,id,j,unit);
  };
  xmlHttp.send(null);  
}



function xj_updatePage4(ord,id,j,unit) {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    var res = xmlHttp.responseText;
	if (res.indexOf('out_of_lines:')==0){
		alert('询价明细超过限制，每个产品最多只能有'+res.replace('out_of_lines:','')+'条询价明细')
		return;
	}
	var w  = "trpx"+res;
  var url = "addlistadd.asp?ord="+escape(ord)+"&id="+escape(id)+"&j="+escape(j) + "&unit="+escape(unit) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  xj_updatePage5(w,id);
  };
  xmlHttp.send(null);  
  }
}
//--TASK.2429.ZYF 2015-2-4 询价能显示实际供应商 
//--扩展函数，增加参数j，继承父函数的参数j
function xj_updatePage5(w,id) {
var test3=$("#"+w);
  if (xmlHttp.readyState < 4) {
	test3.html("loading...");
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test3.html(response);
	xmlHttp.abort();
	try{
		test3.find("input[name^='num1_']").val($("#num" + id).val());
	}catch(e){}
	productListResize();
  }
}


function callServer7(nameitr,ord,xjid) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = "tt"+nameitr;
   w=document.all[w]
  var url = "../xunjia/getXunjiaAction.asp?mxpxid="+escape(ord)+"&nameitr="+escape(nameitr) + "&xjid="+escape(xjid) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage7(w);
  };
  xmlHttp.send(null);  
}

function updatePage7(namei) {
var test7=namei
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	xmlHttp.abort();
  }

}


//无需询价操作
function callServer8(status,pid) {
	var fromtype = $("#fromtype").val();
	var url = "../xunjia/setXunjiaResult.asp?xjstatus="+escape(status)+"&pid="+escape(pid) + "&fromtype="+fromtype+"&timestamp=" + new Date().getTime();
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage8(status,pid);
	};
	xmlHttp.send(null);  
}

function updatePage8(status,pid) {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		if(status=="1")
		{
			document.getElementById("xj_pro_1_" + pid).style.display = "none";
			document.getElementById("xj_1_"+pid).style.display="none";
			document.getElementById("xj_2_"+pid).style.display="none";
			document.getElementById("xj_3_"+pid).style.display="";
			document.getElementById("price_xj_"+pid).style.display="none";
			$("#Xunjiastatus_" + pid).val(1);
			$("#price_xj_" + pid + ">span").html("");
		} else {
			document.getElementById("xj_pro_1_" + pid).style.display = "";
			document.getElementById("xj_1_"+pid).style.display="";
			document.getElementById("xj_2_"+pid).style.display="";
			document.getElementById("xj_3_"+pid).style.display="none";
			document.getElementById("price_xj_"+pid).style.display="";
			$("#Xunjiastatus_"+pid).val(0);
		}
		productListResize();
		xmlHttp.abort();
	}
}



