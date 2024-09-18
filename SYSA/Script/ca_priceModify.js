var runLock = false;
//FormularulesConfig.js已经有部分定义，此处改写差异的部分
window.CurrFormulaConfig.FieldsMap =  {   //公式字段映射关系
	"num_%d": "数量",
	"price1_%d": "未税单价",  //price1 / InitPrice/单价
	"taxRate_%d": "税率",
	"discount_%d": "折扣",
	"priceAfterDiscount_%d": "未税折后单价",   //DstPrice / 未税折后单价
	"priceAfterTax_%d": "含税单价",			//	TaxPrice  /含税单价
	"PriceAfterDiscountTaxPre_%d": "含税折后单价",  //含税折后单价 /TaxDstPrice 
	"TaxDstMoney_%d": "税后总价",     //采购总价：【折后】【惠前】【未税】
	"Concessions_%d": "明细优惠",
	"priceAfterDiscountTax_%d": "优惠后单价",
	"MoneyAfterDiscount_%d": "金额",
	"taxValue_%d": "税额",
	"money1_%d": "优惠后总价",       //money1 
	"taxRate_%d[IncludeTax]": "产品是否含税"
}

__ASPFExecuter.GetCurrRow = function (srcobj) {
	return $(srcobj).closest("tr[l_r]")[0];
}


//该函数已经被FormulaRulesExecer代替
function chtotal(obj) { }

function showPrice(obj,ord,unit,company){
	var $obj = $(obj);
	var $panel = $('#pricePanel');
	if($panel.size()==0){
		$panel = $(''+
		'<div id="pricePanel" style="position:absolute;width:380px"></div>'
		).appendTo(document.body);
	}

	$.ajax({
		url:"cu_lishi.asp?unit=" + unit + "&ord="+ ord + "&gys="+ company,
		success:function(r){
			$panel.css({left:$obj.position().left + 12,top:$obj.position().top+42}).show();
			$panel[0].innerHTML = r;
		}
	});
	event.cancelBubble = true;
}

function hidePrice(){
	var $panel = $('#pricePanel');
	$panel.empty().hide();
}

function checkPriceLimit(){
	var result=true;
	$('.cg_price').each(function(){
		var $obj = $(this);
		var maxVal = $obj.attr('maxZKPrice');
		var nowVal = $obj.val();
		var id=$obj.attr('id').replace('price_','');
		var discount = $('#discount_'+id).val();
		if (nowVal.length==0 || discount.length==0 || isNaN(nowVal) || isNaN(discount)){
			result = false;
			return;
		}
		var priceAfterDiscount = parseFloat(nowVal) * parseFloat(discount);
		$obj.next('span').remove();
		if(priceAfterDiscount > parseFloat(maxVal)){
			$('<span class="red">折后单价('+FormatNumber(priceAfterDiscount,window.sysConfig.moneynumber)+')高于限价</span>').insertAfter($obj);
			result = false;
		}
	});
	return result;
}

function changeInvoice(idx){
	var $taxRate = jQuery('#taxRate_'+idx);
	var $invoiceType = jQuery('#invoiceType_'+idx);
	$taxRate.val($invoiceType.children(':selected').attr('taxRate'));
	__ASPFExecuter.EventLister({ target: $taxRate[0] });
	//非IE兼容
	if(!window.ActiveXObject){chtotal($taxRate[0]);}
}

function submitForm(){
	if (!Validator.Validate(document.getElementById("frm"),2) || !checkPriceLimit()) return;
	var data = '';
	$('.cg_price1').each(function(){
		var $obj = $(this);
		var id=$obj.attr('id').replace('price1_','');
		var price = $obj.val();
		var discount =  $('#discount_'+id).val();
		var priceAfterDiscount =  $('#priceAfterDiscount_'+id).val();
		var priceAfterTax =  $('#priceAfterTax_'+id).val();
		var priceAfterDiscountTax =  $('#priceAfterDiscountTax_'+id).val();
		var moneyAfterDiscount = $('#MoneyAfterDiscount_' + id).val();
		var taxValue =  $('#taxValue_'+id).val();
		var money = $('#money1_'+id).val();
		var taxRate =  $('#taxRate_'+id).val();
		var invoiceType = $('#invoiceType_'+id).val();
		var num=$("#num_" + id).val();
		var formulAttrs = $(".cell_" + id);
		var ProductAttrBatchId=0;
		var ProductAttr2 = 0;
		var PriceAfterDiscountTaxPre = $('#PriceAfterDiscountTaxPre_' + id).val();
		var TaxDstMoney = $('#TaxDstMoney_' + id).val();
		var Concessions = $('#Concessions_' + id).val();
		var cpord=0;
		if($("#ProductAttrBatchId_" + id).size()>0){ProductAttrBatchId=$("#ProductAttrBatchId_" + id).val();}
		if($("#ProductAttr2_" + id).size()>0){ProductAttr2=$("#ProductAttr2_" + id).val();}
		if($("#cpord_" + id).size()>0){cpord=$("#cpord_" + id).val();}
		var v = "";
		var formula = "";
		formulAttrs.each(function () {
			if (formula.length == 0) { formula = this.getAttribute("formula");}
			var vttr = this.getAttribute("vttr");
			v += v.length > 0 ? "," : "";
			v += "'" + this.getAttribute("vttk") + "':'" + vttr + this.value + "'";
		});
		if (v.length > 0) { v = "{'formula':'" + formula + "','v':{" + v + "}}";}
		data += (data.length == 0 ? '' : '\3\4') + id + '\1\2' + price + '\1\2' + discount
			+ '\1\2' + priceAfterDiscount + '\1\2' + priceAfterTax + '\1\2' + priceAfterDiscountTax
			+ '\1\2' + moneyAfterDiscount + '\1\2' + taxValue + '\1\2' + money + '\1\2' + taxRate
			+ '\1\2' + invoiceType + '\1\2' + num + '\1\2' + v + '\1\2' + ProductAttrBatchId + '\1\2'
			+ ProductAttr2 + '\1\2' + PriceAfterDiscountTaxPre + '\1\2' + TaxDstMoney + '\1\2' + Concessions + '\1\2' + cpord;
	});
	if (data.length>0){
		var ax=new xmlHttp();
		ax.regEvent("savePrices");
		ax.addParam("data", data);
		ax.addParam("yhmoney", (document.getElementById("yhvalue") || { value: 0 }).value);
		ax.addParam("CaigouOrd", document.getElementById("CaigouOrd").value);
		ax.send(function(r){
				var result;
				try{
					result = eval('(' + r + ')');
				}catch(e){
					if(confirm('提交过程中出现错误，点击确定查看具体的错误信息\n(点击确定后将会覆盖当前页面内容)')){
						document.write(r);
						return;
					}
				}
				if (result.success){
					if (result.action == 'redirect'){
						window.location = result.location;
					}else{
						app.Alert(result.msg);
						try{opener.window.location.reload();}catch(e){}
						window.close();
					}
				}else{
					app.Alert(result.msg);
				}
			});
	}
}

$(function(){
	$(document.body).mouseover(function(){
		hidePrice();
	});
});

function checkMergeNum(numObj){
	var numName = numObj.name;
	var num1, mergeNum, id;
	if(numName == "sorce6"){
		$("input[id^='num_']").each(function(){
			num1 = $(this).val();
			mergeNum = $(this).attr("mergeNum");
			id = $(this).attr("id").replace("num_","");
			if(num1!=""){num1=parseFloat(num1);} else{num1=0;}
			if(mergeNum!=""){mergeNum=parseFloat(mergeNum);} else{mergeNum=0;}
			if(mergeNum>0){
				if(num1 > mergeNum){
					$("#numTip_"+id).html(" (超量)");
				}else{
					$("#numTip_"+id).html("");
				}
			}
		});
	}else{
		num1 = numObj.value;
		mergeNum = $(numObj).attr("mergeNum");
		id = numObj.id.replace("num_","");
		if(num1!=""){num1=parseFloat(num1);} else{num1=0;}
		if(mergeNum!=""){mergeNum=parseFloat(mergeNum);} else{mergeNum=0;}
		if(mergeNum>0){
			if(num1 > mergeNum){
				$("#numTip_"+id).html(" (超量)");
			}else{
				$("#numTip_"+id).html("");
			}
		}
	}
	
}

function CClearYouhui() {
	var allyhmoney =  document.getElementById("yhvalue").value*1;
	if(allyhmoney<=0) { return alert("已清零"); }
	if (!confirm('整单优惠金额清零后不可恢复，确认清零？')) { return; }
	document.getElementById('yhvalue').value = formatNumDot(0, cmoneyBit);
}

function SplitYouhui(){
	var allyhmoney =  document.getElementById("yhvalue").value*1;
	if(allyhmoney<=0) { return alert("已无整单优惠可分摊"); }
	var TaxDstMoneyBoxs =  $("input[id^='money1_'][type!='hidden']");
	if(TaxDstMoneyBoxs.length==0) { return alert('无可修改单价的采购明细，无法分摊'); }
	var summoney1 = 0;
	for(var  i = 0; i<TaxDstMoneyBoxs.length; i++){
		summoney1 = summoney1 +  TaxDstMoneyBoxs[i].value*1;
	}
	if(summoney1<=0) { return alert('无修改价格的采购明细，无法分摊');  }
	if(summoney1<allyhmoney ) {return alert("可修改价格的采购明细金额不足，无法分摊优惠"); }
	if (!confirm('整单优惠金额将分配至各明细优惠中，确认分摊？')) { return; }
	var alllen = TaxDstMoneyBoxs.length; 
	var addsumvalue = 0;
	for(var  i = 0; i<alllen; i++){
		var newv = 0;
		var itemdstMoney = (TaxDstMoneyBoxs[i].value+"").replace(",","").replace(",","").replace(",","").replace(",","")*1;
		var mxyhBoxid = TaxDstMoneyBoxs[i].id.replace("money1_", "Concessions_");
		if(i<alllen-1) {
			newv = formatNumDot((itemdstMoney / summoney1) * allyhmoney, cmoneyBit);
			var addsumvaluetemp = addsumvalue * 1 + newv * 1;
			if (addsumvaluetemp > allyhmoney) {
				newv = newv - (addsumvaluetemp - allyhmoney);
			}
		} else {
			newv =  allyhmoney*1 - addsumvalue;
		}
		if (newv > itemdstMoney) { newv = itemdstMoney; }
		addsumvalue = addsumvalue * 1 + newv*1;
		var yhbox = document.getElementById(mxyhBoxid);
		yhbox.value = formatNumDot((yhbox.value * 1 + newv * 1), cmoneyBit);
		yhbox.readOnly = false;
		__ASPFExecuter.EventLister({ target: yhbox });
		yhbox.readOnly = true;
	}
	document.getElementById("yhvalue").value = formatNumDot(0, cmoneyBit);
}

function CaigouSaveBeforeAlertMessage() {
	var xmlhttp = new XMLHttpRequest();
	var virpath = window.virpath;  //window.sysCurrPath
	xmlhttp.open("GET", virpath + "../sysn/view/store/caigou/UpdateVerifi.ashx?t=" + (new Date()).getTime() + "&msgid=CaigouBeforeSavemsg&" + window.location.href.split("?")[1], false);
	xmlhttp.send();
	var r =eval( "(" +  xmlhttp.responseText + ")" );
	xmlhttp = null;
	if (r.length > 0) { return confirm("保存后更新[" + r.join("],[") + "]单据中的价格，确认保存？"); }
	return  true;
}