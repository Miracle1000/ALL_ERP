
var errorcount = 0;
function returnStr() {
	var str = " ";
	if (errorcount > 0) {
		str = "<"
		for (i = 0; i < errorcount; i++)
			str = str + "-";
	} errorcount++; return str
}
function checkdata() {
	var str = document.getElementById("NowMoney");
	if (str) {
		var Expression = eval("/[^0-9.-]+/gi");
		var objExp = new RegExp(Expression);
		if (objExp.test(str.value) == true) {
			str.focus(); moneytwo.innerHTML = returnStr() + "输入的金额格式有错误";
			selectText(str);
			return false;
		} else moneytwo.innerHTML = " *";
		if (str.value < 922337203685477.5808 && str.value > -922337203685477.5808) {
			moneytwo.innerHTML = " "; errorcount = 0; return true;
		}
		else {
			str.focus();
			moneytwo.innerHTML ="金额太大";
			selectText(str);
		}
		return false;
	}
}

function checkFrameForm(){
	var iframeWindow = document.getElementById('customFieldsFrame').contentWindow;
	var iframeForm = iframeWindow.document.getElementById('demo');
	var iframeVal = iframeWindow.Validator.Validate(iframeForm,2);
	if (iframeVal){
		iframeForm.submit();
	}
	return iframeVal;
}

function selectText(str) {
	var txt = str.createTextRange();
	var sel = txt.duplicate();
	sel.moveStart("character", str.value.length);
	sel.setEndPoint("EndToStart", txt);
	sel.select();
}
	
function checkNowMoney(){
	var NowMoney = document.getElementById("NowMoney").value;
	if(NowMoney==""){NowMoney=0}
	NowMoney = Number(NowMoney);
	
	if(NowMoney<=0){
		document.getElementById("moneytwo").innerHTML="金额须大于0";
		return false;
	}else if(NowMoney>922337203685477.5808){
		document.getElementById("moneytwo").innerHTML="金额太大";
		return false;
	}
}

//检测计算公式 Sword
function checkFormula()
{
	var priceFormula = $("#priceFormula").val();
	var priceBeforeTaxFormula = $("#priceBeforeTaxFormula").val();
	if(priceFormula.length==0){
		alert("含税单价公式必填");
		$("#priceFormula").select();
		return false;
	}
	else{
		priceFormula = priceFormula.replace("/","+").replace("{未税单价}","1").replace("{税率}","1");
		try{
			var s=eval(priceFormula);
		}catch(e){
			alert("含税单价公式有误");
			$("#priceFormula").select();
			return false;
		}
	}
	if(priceBeforeTaxFormula.length==0){
		alert("未税单价公式必填");
		$("#priceBeforeTaxFormula").select();
		return false;
	}
	else{
		priceBeforeTaxFormula = priceBeforeTaxFormula.replace("/","+").replace("{税率}","1").replace("{含税单价}","1");
		try{
			var s=eval(priceBeforeTaxFormula);
		}catch(e){
			alert("未税单价公式有误");
			$("#priceBeforeTaxFormula").select();
			return false;
		}
	}
	
}


function checkCustomFields(){
	var iframeWindow = document.getElementById('customFieldsFrame').contentWindow;
	//票据类型设置中，检测是否有重名字段
	var fields = [];
	jQuery('.fieldName').each(function(i,item){fields.push(item.value)});
	iframeWindow.jQuery('.fieldName').each(function(i,item){fields.push(item.value)});
	for(var i=0;i<fields.length;i++){
		var tmpval = fields[i];
		for(var j=0;j<fields.length;j++){
			if(j==i) continue;
			if(fields[j] == tmpval){
				alert("字段名称【"+tmpval+"】有重复，请核对！");
				return false;
			}
		}
	}
	return (iframeWindow.Validator.Validate(iframeWindow.document.getElementById('demo'),2)&&iframeWindow.chk_ditto());
}

function addField(){
	document.getElementById('customFieldsFrame').contentWindow.document.getElementById('btn_fieldAdd').click();
}

function checkTaxRate(){
	var taxRate = document.getElementById('taxRate').value;
	if (taxRate.length==0 || parseFloat(taxRate)>100){
		alert("税率必须在0-100之间!");
		return false;
	}
	return true;
}

function saveFields(){
	
	var iframe = document.getElementById('customFieldsFrame');
	iframe.contentWindow.document.getElementById('btn_fieldSave').click();
	iframe.onload();
}

function copyItem(obj){
	window.clipboardData.setData('Text',obj.innerHTML.split('(')[0]);
}

function Mycheckdata(num_dot_xs){
var str = document.getElementById("NowMoney");
var reCat = /[^0-9\.-]|\d-|\.-|-\.|-{2,}|\.{2,}/g;
if(reCat.test(str.value) == true){
str.value = str.value.replace(/[^\d.-]|\d-|\.-|-\.|-{2,}|\.{2,}/g,'');
}else moneytwo.innerHTML = "";
if(str.value < 922337203685477.5808 && str.value > -922337203685477.5808)
{moneytwo.innerHTML = "";
if(str.value.indexOf(".") > 0 && str.value.indexOf(".") < str.value.length - 1){
var thisobj = str.value.split(".");if (thisobj.length > 1){
if(thisobj[1].length > num_dot_xs){
str.value = str.value.substring(0,str.value.length-1);}}}
return true;}else{str.focus();
moneytwo.innerHTML="金额太大";
selectText(str);}return false;
}