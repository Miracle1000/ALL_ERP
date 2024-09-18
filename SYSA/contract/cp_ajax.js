String.prototype.replaceAll = function(reallyDo, replaceWith, ignoreCase) {  
    if (!RegExp.prototype.isPrototypeOf(reallyDo)) {  
        return this.replace(new RegExp(reallyDo, (ignoreCase ? "gi": "g")), replaceWith);  
    } else {  
        return this.replace(reallyDo, replaceWith);  
    }  
}  

window.RowIdKey = "trpx"; // 行id前缀
function callServer(nameitr,ord,i,id) {
  var u_name = document.getElementById("u_name"+nameitr).value;
  var num1 = document.getElementById("num"+id).value;
   var w  = document.all[nameitr];
   var w2  = window.RowIdKey + i;
   w2=document.all[w2]
  
   var currRow = window.event.srcElement.parentElement.parentElement.parentElement.parentElement.parentElement
	if(currRow.tagName=="TABLE") { currRow = currRow.parentElement; }
	if(!currRow || currRow.tagName!="SPAN") {
		currRow = w2
	}
	if(!currRow) { return false}


  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.setRequestHeader("If-Modified-Since","0");
  xmlHttp.onreadystatechange = function(){
	  if(!currRow) {return false}
	   updatePage(currRow);
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

function showPrice(id, ord) {
    var leftpos = event.x;
    var x = leftpos + document.documentElement.scrollLeft, y = event.y + document.documentElement.scrollTop;
	var wWid=document.documentElement.offsetWidth||document.body.offsetWidth;
	jQuery.ajax({
		url:"../price/cu_lishi.asp",
		cache:false,
		data:{
			unit:jQuery('#u_nametest'+id).val(),
			ord:ord
		},
		success:function(html){
			var $span = jQuery('#info_show_div');
			if($span.size()==0) $span=jQuery('<span id="info_show_div" style="width:auto;position:absolute;z-index:99999;margin-left:0;"/>').appendTo(jQuery(document.body));
			if (wWid - leftpos < $span.width()) {
			    $span.css({ left: x - $span.width(), top: y }).html(html).show();
			}else{
			  $span.css({left:x,top:y}).html(html).show();
			}
		},error:function(req){
			alert(req.responseText);
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



function del(str,id,event){
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	plist.del(url,null,null,event);
}

function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	var url = "../contract/search_cp.asp?B=" + escape(B) + "&C=" + encodeURIComponent(C) + "&top=" + escape(top) + "&sort1=" + escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_cp();
	};
	xmlHttp.send(null);  
}

function updatePage_cp(callBack) {
	if (xmlHttp.readyState < 4) {
		cp_search.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		cp_search.innerHTML=response;
		if(callBack){
			callBack.apply(this,arguments);
		}
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


function UnitChange(nameitr,ord,i,id,isContractDetialEdit,Httype) {
    var UpdateCol = ",commUnitAttr,price1,money1,discount,pricejy,tpricejy,priceAfterDiscount,priceIncludeTax,invoiceType,taxRate,priceAfterTaxPre,priceAfterTax,taxValue,moneyAfterConcessions,moneyAfterTax,concessions,jf,"; //单位更改默认只更新这几列数据
	window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
	var $unit = jQuery("#u_name"+nameitr);
	var u_name = $unit.val();
	var num1 = document.getElementById("num"+id).value;
	var w  = document.all[nameitr];
	var w2  = "trpx"+i;
	w2=document.all[w2];
	if ((u_name == null) || (u_name == "")) return;
	var data = {
		editFlg:(isContractDetialEdit?1:0),
		unit:u_name,
		ord:ord,
		num1:num1,
		id:id,
		i:i,
		nameitr: nameitr,
		Httype: Httype
	};

	if(isContractDetialEdit){
		data['oldUnit'] = $unit.attr('oldValue');
		data['numLimit'] = jQuery('#num'+id).attr('min');
		data['moneyLimit'] = jQuery('#moneyall_'+id).attr('minValue');
		data['hasInvoice'] = $unit.attr('hasInvoice');
		data['invType'] = jQuery('#invoiceType_'+id).val();
		data['oldcontractlist'] = jQuery('#oldcontractlist_'+id).val();
	}

	jQuery.ajax({
		url:"cu.asp",
		data:data,
		type:'get',
		async:false,
		success:function(html){
			var div = document.createElement("DIV")
			if (html.indexOf("</noscript>")>0){
				div.innerHTML = html.split("</noscript>")[1];
			}else{
				div.innerHTML = html;
			}
			var datatr =  div.children[0].rows[0];
			var currRow = jQuery(window.uintchangepan).children('table:eq(0)').get(0).rows[0];
			var headRow = document.getElementById("productlistHead") //用定义表头
			var offset = jQuery(headRow).attr("cellOffset");//单元格偏移量（因为有的页面前面多一列复选框，不计算便宜会导致错位）
			offset = offset?parseInt(offset):0;
		    //当前行的分类属性table
			//productattrstable
			if (headRow) {
				for (var i=0;i<headRow.cells.length;i++ ){
					var cell = headRow.cells[i];
					var dbname = $(cell).attr("dbname");
					if(dbname && UpdateCol.indexOf("," + dbname + ",")>=0){
						var nv = datatr.cells[i - offset].innerHTML;
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

function changeInvoice(idx){
	var $taxRate = jQuery('#taxRate_'+idx);
	var $invoiceType = jQuery('#invoiceType_'+idx);
	$taxRate.val($invoiceType.children(':selected').attr('taxRate'));
	//非IE兼容
	var jfzt = (document.getElementById("jf_"+idx)?1:0) ;
	if(!window.ActiveXObject){chtotal(idx,window.sysConfig.moneynumber,jfzt,$taxRate[0]);}
}

function checkPriceLimit(){
	var result=true;
	$('.input_price').each(function(){
		$obj = $(this);
		var minVal = $obj.attr('minZKPrice');
		var nowVal = $obj.val();
		var id=$obj.attr('id').replace('pricetest','');
		var discount = $('#zhekou'+id).val();
		if (nowVal.length==0 || discount.length==0 || isNaN(nowVal) || isNaN(discount)){
			$obj.next('span.red').remove();
			$('<span class="red">请正确输入数值</span>').insertAfter($obj);
			result = false;
			return;
		}
		var priceAfterDiscount = parseFloat(nowVal) * parseFloat(discount);
		$obj.next('span').remove();
		if(priceAfterDiscount < parseFloat(minVal)){
			$('<span class="red">折后单价('+FormatNumber(priceAfterDiscount,window.sysConfig.moneynumber)+')低于限价</span>').insertAfter($obj);
			$obj.trigger('focus');
			result = false;
		}
	});
	return result;
}

var isLocked = false;
window.chtotal=function(id,num_dot_xs,jfzt,obj) { 
	if (window.Event.prototype.propertyName != 'value') return;
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
		var zhekou= document.getElementById("zhekou"+id);
		var moneyall = document.getElementById("moneyall" + id);
		var n=num.value.replace(/,/g,''),p=price.value.replace(/,/g,''),m=moneyall.value.replace(/,/g,''),z=zhekou.value.replace(/,/g,'');
		if(m.length==0||n.length==0||p.length==0||z.length==0||isNaN(n)||isNaN(p)||isNaN(m)||isNaN(z)){isLocked=false;return;}
		if (objName.indexOf('moneyall')==0){
			if(parseFloat(n)==0||parseFloat(p)==0){
				zhekou.value = '1';
				isLocked=false;return;
			}
			var discount = parseFloat(m) / parseFloat(n) / parseFloat(p);
			zhekou.value = FormatNumber(discount,window.sysConfig.discountDotNum);
		}else{
			moneyall.value=FormatNumber(parseFloat(p)*parseFloat(n)*parseFloat(z),window.sysConfig.moneynumber)
		}
		if (jfzt == 1) {
		var jf= document.getElementById("jf_"+id);
		var jf2= document.getElementById("jf2_"+id);
		var num_jf=jf2.value.replace(/\,/g,'') * num.value.replace(/\,/g,'');
			jf.value=num_jf;
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
	var $num = jQuery("#num" + id);
    //税前
	var $price1 = jQuery("#pricetest"+id);
	var $discount = jQuery("#discount_"+id);
	var $discountValue = jQuery("#discountValue_"+id);
	var $priceAfterDiscount = jQuery("#priceAfterDiscount_" + id);
	var $moneyBeforeTax = jQuery('#moneyBeforeTax_' + id);
    //税后
	var $invoiceType = jQuery("#invoiceType_"+id);
	var $taxRate = jQuery("#taxRate_"+id);
	var $priceIncludeTax = jQuery('#priceIncludeTax_'+id);
	var $priceAfterTaxPre = jQuery('#priceAfterTaxPre_'+id);
	var $moneyAfterTax = jQuery('#moneyAfterTax_' + id);
    //优惠后
	var $concessions = jQuery('#concessions_' + id);
	var $priceAfterTax = jQuery('#priceAfterTax_' + id);
	var $moneyAfterConcessions = jQuery('#moneyAfterConcessions_' + id);
	var $taxValue = jQuery('#taxValue_' + id);
	var $moneyall = jQuery("#moneyall" + id);
	var includeTax = $invoiceType.attr("includeTax") == "1";
	//建议进价
	var $pricejy = jQuery('#pricejy' + id);
	//建议总价
	var $moneyjyall = jQuery('#moneyjyall' + id);
	var price1, priceAfterDiscount, priceAfterTaxPre, priceAfterTax;
	var num, num1 ,discount, invoiceType, taxRate, concessions, extras, discountValue;
	var moneyBeforeTax, moneyAfterTax, moneyAfterConcessions, moneyall;
	var pricejy,moneyjyall
	//在某种条件下需要修改的字段（有的字段在后面会修改，各种情况下不需要修改的字段不同）
	num = parseFloat($num.val());
	num1 = num;
	price1 = parseFloat($price1.val());//税前单价
	discount = parseFloat($discount.val());//折扣
	discountValue = discount //折扣
    //任务：2826 借货转合同价格编辑总价不变  xieyanhui20150609
	if (!discount && discount != 0) {
	    discount = 1;
	    discountValue = 1;
	}

	priceAfterDiscount = parseFloat($priceAfterDiscount.val());//折后单价
	taxRate = parseFloat($taxRate.val())/100; //税率
	priceIncludeTax = parseFloat($priceIncludeTax.val()); //含税单价
	priceAfterTaxPre = parseFloat($priceAfterTaxPre.val());//含税折后单价
	moneyAfterTax = parseFloat($moneyAfterTax.val());//含税总价

	concessions = parseFloat($concessions.val());//优惠金额
	priceAfterTax = parseFloat($priceAfterTax.val());//优惠后单价
	moneyAfterConcessions = parseFloat($moneyAfterConcessions.val()); //金额
	moneyall = parseFloat($moneyall.val());//优惠后总价

	pricejy = parseFloat($pricejy.val());//建议进价
	moneyjyall = parseFloat($moneyjyall.val());//建议总价
	var changeList = ['price1', 'discount', 'priceAfterDiscount', 'priceIncludeTax', 'priceAfterTaxPre', 'moneyBeforeTax', 'moneyAfterTax', 'concessions', 'priceAfterTax', 'moneyAfterConcessions', 'taxValue', 'moneyall', 'moneyjyall'];
	var fieldName = inputName.split("_")[0];
	if(inputName.indexOf("num1_")==0){
	    //含税总价
	    moneyAfterTax = priceIncludeTax * discount * num1;
	    //优惠后总价
	    moneyall = priceIncludeTax * discount * num1 - concessions;
	    //金额
	    moneyAfterConcessions = (priceIncludeTax * discount * num1 - concessions)/(1+taxRate) ;
	    //税额
	    taxValue = priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //优惠后单价
	    priceAfterTax = num1==0? 0 :(priceIncludeTax * discount * num1 - concessions) / num1;
	    //税前总价
	    moneyBeforeTax = price1 * discount * num1;
		//建议总价
		moneyjyall = pricejy * num1;

	    SetCurrFormulaInfoValue(id, num);
	} else if (inputName.indexOf("concessions_") == 0) {
	    //优惠后总价
	    moneyall = priceIncludeTax * discount * num1 - concessions;
	    //金额
	    moneyAfterConcessions = (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //税额
	    taxValue = priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //优惠后单价
	    priceAfterTax = num1==0 ? 0 : (priceIncludeTax * discount * num1 - concessions) / num1;
	} else if (inputName.indexOf("price1_") == 0) {
	    //税前折后单价
	    priceAfterDiscount = parseFloat(price1 * discount); //折后单价
	    //含税单价
	    priceIncludeTax = parseFloat(FormatNumber(parseFloat(price1) + parseFloat(price1) * taxRate, window.sysConfig.SalesPriceDotNum)); //含税单价
	    //含税折后单价
	    priceAfterTaxPre = parseFloat(priceIncludeTax * discount);
	    //含税总价
	    moneyAfterTax = priceIncludeTax * discount * num1;
	    //优惠后总价
	    moneyall = priceIncludeTax * discount * num1 - concessions;
	    //金额
	    moneyAfterConcessions = (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //税额
	    taxValue= priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //优惠后单价
	    priceAfterTax = num1==0 ? 0 : (priceIncludeTax * discount * num1 - concessions) / num1;
	    //税前总价
	   moneyBeforeTax = price1 * discount * num1;

	} else if (inputName.indexOf("discount_") == 0) {
	    //含税折后单价
	    priceAfterTaxPre = priceIncludeTax * discount;
	    //税前折后单价
	    priceAfterDiscount=priceIncludeTax/(1+taxRate) * discount;
	    //含税总价
	    moneyAfterTax = priceIncludeTax * discount * num1;
	    //优惠后总价
	    moneyall = priceIncludeTax * discount * num1 - concessions;
	    //金额
	    moneyAfterConcessions = (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //税额
	    taxValue = priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //优惠后单价
	    priceAfterTax = num1==0? 0 : (priceIncludeTax * discount * num1 - concessions) / num1;
	    //税前总价
	    moneyBeforeTax = price1 * discount * num1;
	} else if (inputName.indexOf("priceIncludeTax_") == 0) {
	    //税前单价
	    price1 = parseFloat(priceIncludeTax) / (1 + taxRate);
	    //含税折后单价
	    priceAfterTaxPre = parseFloat(priceIncludeTax * discount);
	    //税前折后单价
	    priceAfterDiscount = priceIncludeTax/(1+taxRate) * discount;
	    //含税总价
	    moneyAfterTax = priceIncludeTax * discount * num1;
	    //优惠后总价
	    moneyall = priceIncludeTax * discount * num1 - concessions;
	    //金额
	    moneyAfterConcessions = (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //税额
	    taxValue = priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //优惠后单价
	    priceAfterTax = num1 == 0 ? 0 : (priceIncludeTax * discount * num1 - concessions) / num1;
	    //税前总价
	    moneyBeforeTax = priceIncludeTax/(1+taxRate) * discount * num1;
	} else if (inputName.indexOf("taxRate_") == 0) {
	    //税前单价
	    price1 = priceIncludeTax/(1+taxRate);
	    //税前折后单价
	    priceAfterDiscount = priceIncludeTax/(1+taxRate) * discount;
	    //金额
	    moneyAfterConcessions= (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //税额
	    taxValue = priceIncludeTax * discount * num1 - concessions - (priceIncludeTax * discount * num1 - concessions)/(1+taxRate);
	    //税前总价
	    moneyBeforeTax = priceIncludeTax/(1+taxRate) * discount * num1;	
	} else if (inputName.indexOf("moneyAfterConcessions_") == 0) {
	    //优惠后总价
	    moneyall = parseFloat(FormatRound(moneyAfterConcessions * (1 + taxRate), window.sysConfig.moneynumber));
	    //税额
	    taxValue = moneyall - moneyAfterConcessions;
	    //含税总价
	    moneyAfterTax = moneyall + concessions;
	    //税前总价
	    moneyBeforeTax = (moneyall + concessions) / (1 + taxRate);
	    if (num1 != 0) {
	        //优惠后单价
	        priceAfterTax = num1 == 0 ? 0 : FormatNumber(moneyall / num1, window.sysConfig.SalesPriceDotNum);
	        //含税折后单价
	        priceAfterTaxPre = num1 == 0 ? 0 : FormatNumber((moneyall + concessions) / num1, window.sysConfig.SalesPriceDotNum);
	        //税前折后单价
	        priceAfterDiscount = num1 == 0 ? 0 : FormatNumber((moneyall + concessions) / num1 / (1 + taxRate), window.sysConfig.SalesPriceDotNum);
	        if (discount != 0) {
	            //税前单价
	            price1 = num1 == 0 ? 0 : FormatNumber((moneyall + concessions) / num1 / discount / (1 + taxRate), window.sysConfig.SalesPriceDotNum);
	            //含税单价
	            priceIncludeTax = num1 == 0 ? 0 : FormatNumber((moneyall + concessions) / num1 / discount, window.sysConfig.SalesPriceDotNum);
	        }
	    }
	}
	else if (inputName.indexOf("moneyAfterTax_") == 0) {
	    //优惠后总价
	    moneyall = moneyAfterTax - concessions;
	    //金额
	    moneyAfterConcessions = (moneyAfterTax-concessions)/(1+taxRate);
	    //税额
	    taxValue = moneyAfterTax-concessions - (moneyAfterTax-concessions)/(1+taxRate);
	    
	    moneyBeforeTax = FormatRound(moneyAfterTax / (1 + taxRate), window.sysConfig.moneynumber);

	    if (num1 != 0) {
	        //优惠后单价
	        priceAfterTax = num1 == 0 ? 0 : (moneyAfterTax - concessions) / num1;
	        //含税折后单价
	        priceAfterTaxPre = num1 == 0 ? 0 : moneyAfterTax / num1;
	        //税前折后单价
	        priceAfterDiscount = num1 == 0 ? 0 : FormatNumber(moneyAfterTax / num1 / (1 + taxRate), window.sysConfig.SalesPriceDotNum);
	        if (discount != 0) {
	            //含税单价
	            priceIncludeTax = num1 == 0 ? 0 : moneyAfterTax / num1 / discount;
	            //税前单价
	            price1 = num1 == 0 ? 0 : moneyAfterTax / num1 / discount / (1 + taxRate);
	        }
	    }
	}

	for (i=0;i<changeList.length ;i++ ){
		if(fieldName==changeList[i]) continue;//触发事件自身的值不需要改变
		if(changeList[i]=="discount"){
			eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.discountDotNum+"));");
		} else if (changeList[i] == "taxValue" || changeList[i] == "moneyBeforeTax" || changeList[i] == "moneyAfterTax" || changeList[i] == "moneyAfterConcessions" || changeList[i] == "moneyAfterConcessions" || changeList[i] == "moneyall" || changeList[i] == "concessions") {
            eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.moneynumber+"));");
		}else {
			eval("$"+changeList[i]+".val(FormatNumber("+changeList[i]+"+'',"+window.sysConfig.SalesPriceDotNum+"));");
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
	isLocked=false;
}

function checkValue(){return true;}

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

function callServer5(s,nameitr,ord,id, attr1id, attr2id) {
  var w  =s ;
   w=document.all[w]

   var u_name = document.getElementById("u_name"+nameitr).value;
   
   if ((u_name == null) || (u_name == "")) return;
   var url = "../contract/cu_kccx.asp?unit=" + escape(u_name) + "&ord=" + escape(ord) + "&id=" + escape(id) + "&nameitr=" + escape(nameitr) + "&attr1id=" + attr1id+ "&attr2id=" + attr2id + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
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
	test6.style.visibility = "hidden";
	var s = document.documentElement.scrollTop || document.body.scrollTop;
	var h = document.body.clientHeight;
	var o = test6.getBoundingClientRect();
	var t = o.top;
	test6.innerHTML=response;
	var th = test6.offsetHeight;
	if(th > ( h - t )){
		if( th > h ){ t = 20; }
		else{
			t = t - (th -(h - t)) - 10;
		}
	}
	if(t>0){ test6.style.top = t + s + "px"; }
	test6.style.visibility = "visible";
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

function setall_num_price(type,obj,num_dot_xs){
	var str_id="";
	var inputs=document.getElementsByTagName("input");
	if (type=="num" && inputs.length>0)
	{
		for (n=0;n<inputs.length;n++ )
		{
		    if (inputs[n].id.indexOf("num") == 0 && inputs[n].id.indexOf("Attr") < 0 && inputs[n].readOnly==false)
			{
				str_id=inputs[n].id.replace("num","");
				if(obj.value.length==0){
					inputs[n].value=inputs[n].defaultValue;
					inputs[n].style.color='#000';
				}else{
					inputs[n].value=obj.value;
				}
				chtotal(str_id, num_dot_xs, 0, inputs[n]);
			}
		}
	}
	else if (type == "discount" && inputs.length > 0) {
	    for (n = 0; n < inputs.length; n++) {
	        if (inputs[n].id.indexOf("discount_") >= 0) {
	            str_id = inputs[n].id.replace("discount_", "");
	            inputs[n].value = obj.value;
	            chtotal(str_id, num_dot_xs, 0, inputs[n]);
	        }
	    }
	}
	else if (type=="date" && inputs.length>0)
	{
		for (n=0;n<inputs.length;n++ )
		{	
			if (inputs[n].id.indexOf("daysdate1_")>=0)
			{
				str_id=inputs[n].id.replace("daysdate1_","").replace("Pos","");
				inputs[n].value=obj.value;
			}
		}
	}
	else if (type=="invoiceType")
	{
		var selects=document.getElementsByTagName("select");
		for (n=0;n<selects.length;n++ )
		{	
			if (selects[n].id.indexOf("invoiceType_")>=0)
			{
				var $obj = jQuery(selects[n]);
				$obj.val(obj.value);
				if($obj.find('option[value="'+obj.value+'"]').size()==0){
					$obj.val(0);
				}
				if($obj.attr('onchange')){
					$obj.trigger('onchange');
				}
				
			}
		}
	}
}


function refreshPrices(treetype, mxid, inpName){
	window.event = {propertyName:"value", srcElement:jQuery("input[name='"+inpName+"']")[0]};
	if(treetype == 3){
		chtotal(mxid, window.sysConfig.moneynumber);
	}else{
		var jf = 0;
		if(jQuery("input[name^='jf_']").size()>0){
			jf = 1;
		}
		chtotal(mxid, window.sysConfig.moneynumber, jf, jQuery("input[name='"+inpName+"']")[0]);
	}
}


//上下键控制数量和单价列上下换行
$(document).ready(function(){
	$(document).keydown(function(event){
		try{
			var inputobj = new Array("num","pricetest");
			//var id=$("input:focus").attr("id");
			var id=event.target.id;

			if(event.keyCode==38){
				for(var i=0;i<inputobj.length;i++){
					if (id.indexOf(inputobj[i].toString())==0)
					{
						var $cur = $("input[id^='"+inputobj[i].toString()+"'][type='text']")
						setTimeout(function () { $cur[$cur.index($("#" + id)) - 1].focus() }, 10);
						break;
					}
				}

			}
			if(event.keyCode==40){
				for(var i=0;i<inputobj.length;i++){
					if (id.indexOf(inputobj[i].toString())==0)
					{
						var $cur = $("input[id^='"+inputobj[i].toString()+"'][type='text']")
						setTimeout(function () { $cur[$cur.index($("#" + id)) + 1].focus(); }, 10);
						break;
					}
				}
			}
		}
		catch(e){};
	});
});