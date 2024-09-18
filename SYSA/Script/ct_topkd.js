
String.prototype.replaceAll = function(reallyDo, replaceWith, ignoreCase) {  
    if (!RegExp.prototype.isPrototypeOf(reallyDo)) {  
        return this.replace(new RegExp(reallyDo, (ignoreCase ? "gi": "g")), replaceWith);  
    } else {  
        return this.replace(reallyDo, replaceWith);  
    }  
}  

jQuery(function(){
	productListResize();
	jQuery(window).resize(function(){
		productListResize();
	});
});

function productListResize(){
	jQuery('#productlist').css({'width':jQuery('#productlist').parent().width()-1,'height':getProductListHeight()});
}

function getProductListHeight(){
	var h = 20;
	jQuery('#productlist').children().each(function(){
		if (jQuery(this).html().length>0)
		{
			h += jQuery(this).height();
		}
	});
	return h;
}

isIE = (document.all ? true : false);
function getIEPosX(elt) { return getIEPos(elt,"Left"); }
function getIEPosY(elt) { return getIEPos(elt,"Top"); }
function getIEPos(elt,which)
{
	iPos = 0
	while (elt!=null)
	{
		iPos += elt["offset" + which]
		elt = elt.offsetParent
	}
	return iPos
}

function changeInvoice(idx){
	var $taxRate = jQuery('#taxRate_'+idx);
	var $invoiceType = jQuery('#invoiceType_'+idx);
	$taxRate.val($invoiceType.children(':selected').attr('taxRate'));
	if(!window.ActiveXObject && $taxRate[0].tagName=='INPUT') {
		var code = $taxRate.attr('onpropertychange');
		if(code) { eval("(function(){" + code + "})").call($taxRate[0]); }
	}
}

function ask()
{
	document.all.date.action = "savelistadd13.asp";
}

function callServer(nameitr,ord,i,id,num_dot_xs)
{
	window.UnitRow = plist.getParent(window.event.srcElement,5);
	if( window.UnitRow.tagName=="TABLE")
	{
		window.UnitRow  =  window.UnitRow.parentElement;
	}
	var u_name = document.getElementById("u_name"+nameitr).value;
	var num1 = document.getElementById("num"+id).value;
	var num2=document.getElementById("moneyall"+id).value;
	var w  = document.all[nameitr];
	var w2  = "trpx"+i;
	w2=document.all[w2]
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu_kd.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&num2="+escape(num2)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage(w2,id,num_dot_xs);};
	xmlHttp.send(null);
}

function updatePage(w2,id,num_dot_xs)
{
	var test6=  window.UnitRow
	if (xmlHttp.readyState < 4)
	{
		test6.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test6.innerHTML=response;
		xmlHttp.abort();
		productListResize();
		var summoney=0;
		jQuery('#details').find(':input[name*="moneyall_"]').each(function(){
			if(this.name=='moneyall_0') return;
			var tmp = this.value;
			if(isNaN(tmp)||tmp=='') return;
			summoney+=parseFloat(tmp);
		});
		document.getElementById("premoney").value=FormatNumber(summoney,window.sysConfig.moneynumber);
		Calculation(4);
	}
}


function showPrice(id, ord) {
    var s = document.documentElement.scrollTop || document.body.scrollTop;
    var x = event.x, y = event.y + s;
	jQuery.ajax({
		url:"../price/cu_lishi.asp",
		cache:false,
		data:{
			unit:jQuery('#u_nametest'+id).val(),
			ord:ord
		},
		success:function(html){
			var $span = jQuery('#info_show_div');
			if($span.size()==0) $span=jQuery('<span id="info_show_div" ' +
				'style="width:334px;position:absolute;z-index:99999;margin-left:0;"/>').appendTo(jQuery(document.body));
			$span.css({left:x,top:y}).html(html).show();
		}
	});
}

function callServer2(nameitr,ord,id)
{
	var u_name = document.getElementById("u_name"+nameitr).value;
	if ((u_name == null) || (u_name == "")) return;
	var url = "../price/cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	var s = document.documentElement.scrollTop || document.body.scrollTop;
	var x = event.x, y = event.y + s;
	jQuery.ajax({
		url:url,
		cache:false,
		success:function(html){
			var $span = jQuery('#info_show_div');
			if($span.size()==0) $span=jQuery('<span id="info_show_div" style="width:100px;position:absolute;z-index:99999;margin-left:0;"/>').appendTo(jQuery(document.body));
			$span.css({left:x,top:y}).show().get(0).innerHTML=html;
		}
	});
}

function callServer3(nameitr,ord,id)
{
	var w  = "tt"+nameitr;
	w=document.all[w];
	w.innerHTML="";
	xmlHttp.abort();
}

//***************限制行数，新增函数 tbh 10.12.08 ********************//
function getFreeRow()
    {
	var isAddNewPage = document.getElementById("trpx0").innerText||document.getElementById("trpx0").textContent;//.length <10;
	if(isAddNewPage && isAddNewPage.indexOf("无产品明细")>-1){  //添加页面
		document.getElementById("trpx0").innerHTML = "";
		return 0;
	}
	else{									//修改页面
		window.addnewPage = false;
		var ii = 0
		while(document.getElementById("trpx" + ii)){
			if(document.getElementById("trpx" + ii).innerHTML==""){return ii;}
			ii ++;
		}
		return -1*(ii-1);
	}
}

function moveRows(row)
{  //删除后填补
	var id = row.id.replace("trpx","");
	id = id * 1 + 1;
	var nextRow = document.getElementById("trpx" + id);
	if(nextRow)
	{
		row.innerHTML = nextRow.innerHTML;
		nextRow.innerHTML = "";
		moveRows(nextRow);
	}
}

function getParent(child,parentIndex)
{  //获取指定级别的父节点
	for( var i= 0 ;i < parentIndex ; i++)
	{
		child = child.parentElement;
	}
	return child;
}
// ******************************************************************//

function callServer4(ord,top,unit)
{
 if ((ord == null) || (ord == "")) return;
  var url = "../contract/num_click.asp?ord="+escape(ord)+"&top="+escape(top) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){updatePage4(ord,top,unit);};
  xmlHttp.send(null);
}

function updatePage4(ord,top,unit)
{	
	unit = unit || '';
	if (xmlHttp.readyState == 4)
	{
		var res = getFreeRow(); // tbh 2010.12.08 xmlHttp.responseText;
		var w  = "trpx"+res;
		w=document.all[w];
		if(w)
		{
			res =  xmlHttp.responseText;
			if(isNaN(res))
			{
				alert("合同临时数据可能已经被其它编辑页占用，需要重新打开编辑销售开单");
				return;
			}
			i=parseFloat(res);
			i+=1;
			var url = "addlistadd_kd.asp?ord="+escape(ord)+"&top="+escape(top)+"&unit="+unit;
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){updatePage5(w,i);};
			xmlHttp.send(null);
		}
		else
		{
			if(!window.dMaxRows)
			{//当没有定义最大行时  tbh 2010.12.08
				window.dMaxRows = res - 1;  //获取允许的最大行数
			}
		  window.alert("当前添加的明细行数已到达系统允许的最大值。\n\n详细情况，请咨询系统管理员。")
		}
	}
}

function getLastId(tryId)
{//获取最后行id
	var id = document.getElementById(tryId);
	while(!id)
	{
		tryId --;
		id = document.getElementById(tryId);
	}
	if(id)
	{
		return id.value;
	}
	else
	{
		return 10000;
	}
}

function updatePage5(w,i)
{
	var test3=w;
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test3.innerHTML=response;
		var id= getLastId(i);
		var money1=document.getElementById("moneyall"+id).value.replace(/\,/g, '');
		money1=parseFloat(money1);
		var premoney=document.getElementById("premoney");//开单总额
		money1+=parseFloat(premoney.value);
		premoney.value=FormatNumber(money1,window.sysConfig.moneynumber);
		Calculation(4);

		mavalue=premoney.value;
		var money1= document.getElementById("money_zs");//应收金额	
		money1.value=FormatNumber(mavalue,window.sysConfig.moneynumber);
		var money2= document.getElementById("money_hk");//实收金额
		var money3= document.getElementById("money_zl");//找零
		num3=parseFloat(money2.value)-parseFloat(mavalue); 
		if (num3<0) num3=0;
		money2.value=FormatNumber(mavalue,window.sysConfig.moneynumber);
		money3.value=FormatNumber(num3,window.sysConfig.moneynumber);

		document.getElementById("idStr").value=document.getElementById("idStr").value+","+id;
		xmlHttp.abort();
		productListResize();
	}
}

function callServer5(s,nameitr,ord,id)
{
	var tar=event.target||event.srcElement;
	var u_name = document.getElementById("u_name"+nameitr).value;
	if ((u_name == null) || (u_name == "")) return;
	var url = "../contract/cu_kccx.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	var x = $(tar).offset().left+15,y=$(tar).offset().top+15;
	jQuery.ajax({
		url:url,
		cache:false,
		success:function(html){
			var $span = jQuery('#info_show_div');
			if($span.size()==0) $span=jQuery('<span id="info_show_div" style="width:440px;position:absolute;z-index:99999;margin-left:0;"/>').appendTo(jQuery(document.body));
			$span.css({left:x,top:y}).show().get(0).innerHTML=html;
		}
	});
}

function callServer6(t,nameitr,ord,id)
{
	jQuery('#info_show_div').html('').hide();
}

function del6(str,id,num_dot_xs)
{
	var w  =getParent(window.event.srcElement,6);  // document.all[str];
	var premoney= document.getElementById("premoney");
	var money2= document.getElementById("money_hk");
	num1=document.getElementById("moneyall"+id).value;
	num_zs=premoney.value;
	num_zs-=num1;
	premoney.value=FormatNumber(num_zs,num_dot_xs);
	Calculation(4);
	//money2.value=FormatNumber(num_hk,num_dot_xs);
	document.getElementById("idStr").value=document.getElementById("idStr").value.replace(","+id,"");
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if(xmlHttp.readyState == 4)
		{
			updatePage_del(w,id,num_dot_xs);
		}
	}
	xmlHttp.send(null);
}

function updatePage_del(str,id,num_dot_xs)
{
	str.innerHTML="";
	moveRows(str); //删除中间行后，自动填充
	productListResize();
}

function ajaxSubmit(sort1)
{
	//获取用户输入
	var B=document.forms[0].B.value;
	var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	//Task.1440.binary.cstore=1表示只显示实体产品
	var url = "../contract/search_cp.asp?cstore=" + (window.ShowOnlyCanStoreProduct==1?1:0) + "&B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_cp();};
	xmlHttp.send(null);
}

function updatePage_cp()
{
  if (xmlHttp.readyState == 4)
  {
		var response = xmlHttp.responseText;
		cp_search.innerHTML=response;
		xmlHttp.abort();
	}
}

function ajaxSubmit_gys(nameitr,ord,unit)
{
	//获取用户输入
	var w  = "tt"+nameitr;
	var B=document.forms[1].B.value;
	var C=document.forms[1].C.value;
	var url = "cu2.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_gys(w);};
	xmlHttp.send(null);
}

function updatePage_gys(w)
{
	var test7=document.all[w]
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		test7.innerHTML=response;
		xmlHttp.abort();
	}
}

var isLocked = false;
function chtotal(id,num_dot_xs,jfzt,obj) { 
	if (obj==null||typeof(obj)!='object'){
		alert('函数调用缺少必要参数！');
		return;
	}

	var $obj = jQuery(obj);
	if(isNaN($obj.val())||$obj.val().length==0) return;
	try{
		if(window.event && window.event.propertyName != "value"){ 
			return;
		}
	}catch(e){}
	//使onpropertychange事件只触发一次
	if(isLocked){
		return;
	}else{
		isLocked = true;
	}

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
	var $moneyBeforeTax = jQuery('#moneyBeforeTax_'+id);
	var $moneyAfterTax = jQuery('#moneyAfterTax_'+id);
	var $concessions = jQuery('#concessions_'+id);
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
	discountValue = parseFloat($discountValue.val());//折扣真实值
	concessions = parseFloat($concessions.val());//优惠金额
	moneyAfterTax = parseFloat($moneyAfterTax.val());//税后总价

	var changeList=['price1','discount','priceAfterDiscount','priceIncludeTax','priceAfterTax','taxValue','moneyBeforeTax','moneyAfterTax','concessions','moneyall'];
	var fieldName = inputName.split("_")[0];

	if(inputName.indexOf("taxRate_")==0 || inputName.indexOf("discount_")==0){
		if(inputName.indexOf("discount_")==0) discountValue = discount;
		//修改税率或折扣，分含税不含税两种情况
		if(includeTax){
			//含税：使用公式2计算未税单价，再算出其他价格
			price1 = FormatNumber(parseFloat(eval(formula2.replaceAll('{含税单价}',priceIncludeTax).replaceAll('{税率}',taxRate))),window.sysConfig.moneynumber); //未税单价
			priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
		}else{
			//不含税：以未税单价为基础，用公式1计算各税后价格和总价
			priceIncludeTax = FormatNumber(parseFloat(eval(formula1.replaceAll('{未税单价}',price1).replaceAll('{税率}',taxRate))),window.sysConfig.moneynumber); //含税单价
			priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
		}

		priceAfterDiscount = parseFloat(price1 * discount); //折后单价
	}else if(inputName.indexOf("price1_")==0){
		//修改未税单价：价格相关均变化，需用公式1计算税后单价
		priceIncludeTax = FormatNumber(parseFloat(eval(formula1.replaceAll('{未税单价}',price1).replaceAll('{税率}',taxRate))),window.sysConfig.moneynumber); //含税单价
		priceAfterDiscount = parseFloat(price1 * discount); //折后单价
		priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
	}else if (inputName.indexOf("priceAfterTax_")==0){
		//修改含税折后单价：仅变动折扣和未税折后单价的值
		discount = priceIncludeTax == 0 ? 0 : parseFloat(priceAfterTax / priceIncludeTax);
		priceAfterDiscount = parseFloat(price1 * discount);
	}else if (inputName.indexOf("priceIncludeTax_")==0){
		//修改含税单价：未税折后单价、未税单价以及各种总价发生变化，需用公式2计算未税单价
		price1 = FormatNumber(parseFloat(eval(formula2.replaceAll('{含税单价}',priceIncludeTax).replaceAll('{税率}',taxRate))),window.sysConfig.moneynumber); //未税单价
		priceAfterDiscount = parseFloat(price1 * discount); //折后单价
		priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
	}else if (inputName.indexOf("priceAfterDiscount_")==0){
		//修改未税折后单价：需用公式1计算含税单价、折扣
		discount = parseFloat(price1 == 0 ? 0 : priceAfterDiscount / price1);
		priceIncludeTax = FormatNumber(parseFloat(eval(formula1.replaceAll('{未税单价}',price1).replaceAll('{税率}',taxRate))),window.sysConfig.moneynumber); //含税单价
		priceAfterTax = parseFloat(priceIncludeTax * discount); //含税折后单价
	}

	moneyBeforeTax = priceAfterDiscount * num; //税前总价
	moneyAfterTax = priceAfterTax * num; //税后总价
	taxValue = moneyAfterTax - moneyBeforeTax; //税额
	moneyall = moneyAfterTax - concessions //总价

	for (i=0;i<changeList.length ;i++ ){
		if(fieldName==changeList[i]) continue;//触发事件自身的值不需要改变
		if(changeList[i]=="discount"){
			eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.discountDotNum+"));");
		}else{
			eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.moneynumber+"));");
		}
	}
	discountValue = discount
	$discountValue.val(discountValue);

	if (jfzt == 1) {
		var jf= document.getElementById("jf_"+id);
		var jf2= document.getElementById("jf2_"+id);
		var num_jf=jf2.value.replace(/\,/g,'') * num;
		jf.value=num_jf;
	}

	var summoney=0;
	jQuery('#details').find(':input[name*="moneyall_"]').each(function(){
		if(this.name=='moneyall_0') return;
		var tmp = this.value;
		if(isNaN(tmp)||tmp=='') return;
		summoney+=parseFloat(tmp);
	});
	document.getElementById("premoney").value=FormatNumber(summoney,window.sysConfig.moneynumber);
	Calculation(4);
	isLocked=false;
}

function checkValue(){
	var errorMsg = [];
	jQuery('input[name="mxidlists"]').each(function(i,item){
		var id = item.value;
		var $price1 = jQuery("#pricetest"+id);
		var $num = jQuery("#num"+id);
		var $discount = jQuery("#discountValue_"+id);
		var $moneyall = jQuery("#moneyall"+id);
		var $priceAfterDiscount = jQuery("#priceAfterDiscount_"+id);
		var $invoiceType = jQuery("#invoiceType_"+id);
		var $taxRate = jQuery("#taxRate_"+id);
		var $priceIncludeTax = jQuery('#priceIncludeTax_'+id);
		var $priceAfterTax = jQuery('#priceAfterTax_'+id);
		var $taxValue = jQuery('#taxValue_'+id);
		var $moneyBeforeTax = jQuery('#moneyBeforeTax_'+id);
		var $moneyAfterTax = jQuery('#moneyAfterTax_'+id);
		var $concessions = jQuery('#concessions_'+id);

		var formula1 = $invoiceType.children(':selected').attr('formula');//含税单价计算公式
		var formula2 = $invoiceType.children(':selected').attr('formula2');//未税单价计算公式
		var price1,priceAfterDiscount,priceAfterTax;
		var num,discount,invoiceType,taxRate,concessions;
		var moneyall,moneyBeforeTax,moneyAfterTax;
		var proName = jQuery(item).parentsUntil('tr').last().children('a[alt="查看产品详情"]').text();

		num = parseFloat($num.val());
		price1 = parseFloat($price1.val());//税前单价
		priceAfterDiscount = parseFloat($priceAfterDiscount.val());//折后单价
		taxRate = parseFloat($taxRate.val())/100; //税率
		priceIncludeTax = parseFloat($priceIncludeTax.val()); //含税单价
		priceAfterTax = parseFloat($priceAfterTax.val());
		discount = parseFloat($discount.val()) || 1;//折扣
		concessions = parseFloat($concessions.val());//优惠金额
		moneyAfterTax = parseFloat($moneyAfterTax.val());//税后总价

		/*
			验证以下公式
			未税单价 * 折扣 = 未税折后单价
			含税单价 * 折扣 = 含税折后单价
			含税折后单价 * 数量 = 含税总价
			公式一
			公式二
		*/
		var dotNum = window.sysConfig.moneynumber;
		var p = Math.pow(10,-1 * dotNum);
		if (Math.round(Math.abs(price1 * discount - priceAfterDiscount),dotNum) > p){
			errorMsg.push('第['+(i+1)+']行产品价格不符合公式[单价*折扣=未税折后单价](' + price1 + ' * ' + discount + '=' + priceAfterDiscount + ')\n');
			return;
		}
		if (Math.round(Math.abs(priceIncludeTax * discount - priceAfterTax),dotNum) > p){
			errorMsg.push('第['+(i+1)+']行产品价格不符合公式[含税单价*折扣=含税折后单价](' + priceIncludeTax + ' * ' + discount + '=' + priceAfterTax + ')\n');
			return;
		}
		if (Math.round(Math.abs(priceAfterTax * num - moneyAfterTax),dotNum) > p){
			errorMsg.push('第['+(i+1)+']行产品价格不符合公式[含税折后单价*数量=税后总价](' + priceAfterTax + ' * ' + num + ' = ' + moneyAfterTax + ')\n');
			return;
		}
		if (Math.round(Math.abs(priceIncludeTax - eval(formula1.replaceAll('{未税单价}',price1).replaceAll('{税率}',taxRate))),dotNum) > p){
			errorMsg.push('第['+(i+1)+']行产品价格不符合公式[含税单价=' + formula1.replaceAll('{','').replaceAll('}','') + ']' +
							'(' + priceIncludeTax + '=' + formula1.replaceAll('{未税单价}',price1).replaceAll('{税率}',taxRate) +
						'\n');
			return;
		}
		if (Math.round(Math.abs(price1 - eval(formula2.replaceAll('{含税单价}',priceIncludeTax).replaceAll('{税率}',taxRate))),dotNum) > p){
			errorMsg.push('第['+(i+1)+']行产品价格不符合公式[未税单价=' + formula2.replaceAll('{','').replaceAll('}','') + ']' +
							'(' + price1 + '=' + formula2.replaceAll('{含税单价}',priceIncludeTax).replaceAll('{税率}',taxRate) +
						'\n');
			return;
		}
	});

	if (errorMsg.length>0){
		alert('系统检测到以下问题导致提交失败：\n'+
			errorMsg.join('') +
			'请核对后再保存！');
		return false;
	}
	return true;
}

function chtotal_all(num_dot_xs)
{
	var money_all=0;
	var moneyall=0;
	var idStr=document.getElementById("idStr").value;
	arrIdStr=idStr.split(",");
	for(var i=0;i<arrIdStr.length;i++)
	{
		if(arrIdStr[i]!="")
		{
			moneyall=document.getElementById("moneyall"+arrIdStr[i]).value;
			if(isNaN(moneyall)||moneyall=="") { moneyall = 0 } money_all+=parseFloat(moneyall);
		}
	}
	document.getElementById("premoney").value=FormatNumber(money_all,num_dot_xs);
	Calculation(4);
}
function chtotal2(num1,num2,num_dot_xs)
{
	if(isNaN(num1)) { num1 = 0 }
	if(isNaN(num2)) { num2 = 0 }
	var premoney= document.getElementById("premoney");
	num1-=parseFloat(num2);
	num1+=parseFloat(money1.value);
	premoney.value=FormatNumber(num1,num_dot_xs);
	Calculation(4);
}

function chtotal3(num_dot_xs)
{
	var money1= document.getElementById("money_zs");//应收	
    money2= document.getElementById("money_hk");//实收
	var money3= document.getElementById("money_zl");//找零
    num1=money1.value;
    if(num1==""){num1=0;}
	num1=parseFloat(num1);
    num_hk=money2.value;
    if(num_hk==""){num_hk=0;}
	num_hk=parseFloat(num_hk);
	num3=num_hk-num1;
	if (num3>0)
	{
		money3.value=FormatNumber(num3,num_dot_xs);
	}
	else 
	{
		money3.value=FormatNumber(0,num_dot_xs);
	}
	
}

function search_lb()
{
	var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage_sh_lb();};
	xmlHttp.send(null);
}

function updatePage_sh_lb()
{
	var test7="ht1"
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		ht1.innerHTML=response;
		xmlHttp.abort();
	}
}

function check_kh(ord)
{
	var url = "../event/search_kh.asp?xskd=1&ord="+escape(ord)+"&from=contract_add&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePagekd2();};
	xmlHttp.send(null);
}

function updatePagekd2()
{
	if (xmlHttp.readyState == 4)
	{
		var response = xmlHttp.responseText;
		khmc.innerHTML=response;
		updatePagekd3();
	}
}

function updatePagekd3()
{
	var company = document.getElementById("companyname").value;
	var u_name = document.getElementById("htid").value;
	var zt=company+u_name
	var telOrd = document.date.company.value;	
	if(window.__onAddressSelect){
		if (telOrd!=''){
			$.ajax({
				url:'../MicroMsg/Addresses.asp?__msgId=getDefAddress&company='+telOrd,
				success:function(r){
					var json = eval('(' + r.replace(/\r\n/g,'"+\r\n"') + ')');
					window.__onAddressSelect.apply(this,[null,json]);
				}
			});
		}else{
			window.__onAddressSelect.apply(this,[null,{}]);
		}
	}

	if(telOrd!=""){
		telOrd = Number(telOrd);
		if(telOrd>0){
			var url2 = "../event/tel_credit.asp?ty=1&company="+telOrd+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
			var XMlHttp2 =  GetIE10SafeXmlHttp();
			XMlHttp2.open("GET", url2, false);
			XMlHttp2.onreadystatechange = function(){
				if (XMlHttp2.readyState == 4) {
					var restr = XMlHttp2.responseText;
					var arr_restr=restr.split("|");
					if(arr_restr[0]=="0"){
						document.getElementById("tip_credit").style.display="none";
						document.getElementById("tel_credit").innerHTML="";
					}else if(arr_restr[0]=="1"){
						document.getElementById("tip_credit").style.display="block";
						document.getElementById("tel_credit").innerHTML=arr_restr[1];
					}
					XMlHttp2.abort();
				}	
			};
			XMlHttp2.send(null);
		}
	}
	
	xmlHttp.abort();
}

function ask2()
{
	document.all.date.action = "save4.asp?ord="+window.billHTrd+"&sort3=2";
}

function check_kh32(ord,unit,unit2,ckjb,ck,id,num1,kcid,funindex)
{
	var w  = "ck2xz_"+id;
	w=document.all[w];
	if(!funindex){funindex="";}
	var url = "../store/ku_unit_cf.asp?funindex="+funindex+"&ord="+escape(ord)+"&unit="+escape(unit)+"&unit2="+escape(unit2)+"&ckjb="+escape(ckjb)+"&ck="+escape(ck)+"&id="+escape(id)+"&num1="+escape(num1)+"&kcid="+escape(kcid)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){updatePage2(w,id,num1,unit,unit2,ord);};
  xmlHttp.send(null);
}
// -->
