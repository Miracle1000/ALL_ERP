function callServer(nameitr,ord,i,id) {
	window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
	var u_name = document.getElementById("u_name"+nameitr).value;
	var num1 = document.getElementById("num"+id).value;
	var date2 = document.getElementById("daysdate1_"+id+"Pos").value;
	var intro1 = document.getElementById("intro_"+id).value;
	var w  = document.all[nameitr];
	var w2  = getParent(window.event.srcElement,5)
	if(w2.tagName!="SPAN"){
		w2 = w2.parentElement;
	}
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu_add.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&num1="+escape(num1)+"&date2="+escape(date2)+"&intro1="+escape(intro1)+"&id="+escape(id)+"&i="+escape(i)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.send(null);  
	window.uintchangepan.innerHTML = xmlHttp.responseText;
}

function del3(str,id , event){
	var url = "del_cp.asp?id="+escape(id)+"&type=1&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
    plist.del(url,null,null,event);
}

function del2(str,id){
	var w  = str;
	var url = "del_cp.asp?id="+escape(id)+"&type=1&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_del2(w);
	};
	xmlHttp.send(null);  
}
function updatePage_del2(str) {
	try{
		document.getElementById(str).parentNode.parentNode.parentNode.parentNode.parentNode.innerHTML="";
	}catch(e){}
}

//单位改变  
function UnitCallServer(nameitr,ord,i,id) {
    var fromtype = document.getElementById("fromtype").value;
    var billtype = document.getElementById("billtype").value;
    var UpdateCol = ",UnitBL,commUnitAttr,num1,实际库存,可用库存,pricejy,price1,taxRate,invoiceType,discount,priceAfterDiscount,priceAfterTax,priceAfterDiscountTax,PriceAfterDiscountTaxPre,moneyAfterDiscount,taxValue,money1,";
	window.uintchangepan = plist.getParent(window.event.srcElement,5); //获取所在行
	var u_name = document.getElementById("u_name"+nameitr).value;
	var num1 = document.getElementById("num"+id).value;
	var num1AttrData = "";
	var attr2id = "";
	var parentListId = "";
	var parentListIdStr = "";
	var billListIdStr = "";
	if($("input[id^='parentListField_"+ id +"']").size()>0){ parentListField = $("#parentListField_"+ id).val();}
	if($("input[id^='fromlistid_"+ id +"']").size()>0){ parentListId = $("#fromlistid_"+ id).val();}
	if($("select[name='AttrsBatch_Attr2_"+ id +"']").size()>0){
		attr2id = $("select[name='AttrsBatch_Attr2_"+ id +"']").val();
	} else if ($("input[name='AttrsBatch_Attr2_" + id + "']").size() > 0) {
	    attr2id = $("input[name='AttrsBatch_Attr2_" + id + "']").val();
	}
	if($("input[name^='num1_AttrsBatch_Attr1_"+ id +"']").size()>0){
		$("input[name^='num1_AttrsBatch_Attr1_"+ id +"']").each(function(){
			var idStr = $(this).attr("name").replace("num1_AttrsBatch_Attr1_","");
			var arr_id = idStr.split("_");
			var attr1id = arr_id[1];
			billListIdStr += (billListIdStr==""?"":",") + arr_id[2];
			parentListIdStr += (parentListIdStr==""?"":",") + arr_id[3];
			var attrNum1 = $(this).val().replace(/,/g,"");
			num1AttrData += (num1AttrData==""?"":";") + "ProductAttr1="+ attr1id + ",attrNum1="+ attrNum1;
		});
	}
	if(parentListIdStr == ""){ parentListIdStr = parentListId; }
	var w  = document.all[nameitr];
	var w2  = getParent(window.event.srcElement,5)
	if(w2.tagName!="SPAN"){w2 = w2.parentElement;}
	var CGMainUnit = document.getElementById("CGMainUnit").value;
	var fromUnit = 0;
	try{fromUnit = document.getElementById("fromUnit_"+id).value;}catch(e){}
	var fromUnitBl = 1;
	try{fromUnitBl = document.getElementById("fromUnitBl_"+id).value;}catch(e){}
	var unitBl = 1;
	try{unitBl = document.getElementById("unitBl_"+id).value;}catch(e){}
	var fromNum = num1;
	if(CGMainUnit == "1" && fromUnit!="" && fromUnit!="0"){fromNum = jQuery("#fromNum_"+id).val();}
	var caigoulist = 0;
	if(jQuery("#caigoulist_"+id)){caigoulist = jQuery("#caigoulist_"+id).val();}
	if(caigoulist==""){caigoulist = 0;}
	var top = 0;
	if(jQuery("input[name='top']")){top = jQuery("input[name='top']").val();}

	if ((u_name == null) || (u_name == "")) return;

	jQuery.ajax({
		url:'cu_add.asp',
		data:{
			unit:escape(u_name),
			ord:escape(ord),
			attr2id:attr2id,
			num1AttrData:num1AttrData,
			billListIdStr:billListIdStr,
			parentListId:parentListId,
			parentListIdStr:parentListIdStr,
			num1:escape(num1),
			top:escape(top),
			id:escape(id),
			caigoulist:escape(caigoulist),
			fromtype:escape(fromtype),
			fromUnit:escape(fromUnit),
			fromUnitBl:escape(fromUnitBl),
			unitBl:escape(unitBl),
			i:escape(i),
			nameitr: escape(nameitr),
			billtype: escape(billtype)
		},
		type:'post',
		cache:false,
		success:function(r){
			var div = document.createElement("DIV")
			div.innerHTML = r
			var datatr =  $(div).children("table")[0].rows[0];
			var currRow = $(window.uintchangepan).children("table")[0].rows[0]
			var headRow = document.getElementById("productlistHead") //用定义表头
			if(headRow){
				for (var i=0;i<headRow.cells.length;i++ ){
					var cell= headRow.cells[i];
					var dbname = $(cell).attr("dbname");
					if(dbname && UpdateCol.indexOf("," + dbname + ",")>=0){			
						var nv = datatr.cells[i].innerHTML;
						try {
							currRow.cells[i].innerHTML = nv;
							window.__ASPFExecuter.DoExecute({
								tiggerobj: GetNumberDomNode(currRow),
								tiggerkey: "@@init",
								range: "row"
							});
						}catch (e){}
					}
				}
				var numbox = GetNumberDomNode(currRow);
				if (numbox) { numbox.onkeyup() };
			}
			else{
				window.uintchangepan.innerHTML = r;
			}
		},error:function(XMLHttpRequest, textStatus, errorThrown){
			alert(errorThrown);
		}
	});	
}

function GetNumberDomNode(domarea) {
	var boxs = $(domarea).find("input[id^='num']");
	for (var i = 0; i < boxs.length; i++) {
		if (boxs[i].id.indexOf("Attr") == -1) {
			return boxs[i];
		}
	}
	return null;
}



function callServer2(nameitr,ord,id,gys) {
	var w  = "tt"+nameitr;
	w=document.all[w]
	var u_name = document.getElementById("u_name"+nameitr).value;
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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


function callServer_price(nameitr, ord, id) {
    var x = event.x + document.documentElement.scrollLeft, y = event.y + document.documentElement.scrollTop;
	var u_name = document.getElementById("u_name"+nameitr).value;
	var gys = document.getElementById("gys_"+id).value;
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_price(x , y);
	};
	xmlHttp.send(null);  
}

function updatePage_price(x , y) {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		//<span id="lst1test<%=id%>" style="position:absolute;margin-left:0;"></span>
		var $span = jQuery('#info_show_div');
		if($span.size()==0) $span=jQuery('<span id="info_show_div" style="position:absolute;z-index:99999;margin-left:0;"/>').appendTo(jQuery(document.body));
		$span.css({ left: x, top: y }).html(response).show();
		resetShowBoxXy("info_show_div")
		xmlHttp.abort();
	}
}

//重新设置弹层的显示位置（公共函数）
function resetShowBoxXy(id) {
    var windowWidth = document.documentElement.clientWidth;//窗口宽度；
    var scrollLeft = document.documentElement.scrollLeft;
    var div = document.getElementById(id),
        divWidth,//元素宽度
        divWinLeft,//元素距离左边窗口的距离；
        divLeft;//元素距离定位父元素的left值
    if (div) { divWidth = div.offsetWidth; divLeft = div.offsetLeft, divWinLeft = divLeft - scrollLeft; };
    if (windowWidth - divWinLeft >= divWidth) { div.style.left = divLeft + 5 + "px"; return;}//5为img的宽度即操作的dom元素的宽；
    div.style.left = divLeft - divWidth + "px";
}

function callServer_price2(nameitr,ord,id) {
	jQuery('#info_show_div').hide();
}


//***************限制行数，新增函数 tbh 10.12.08 ********************//

function getFreeRow(){  //获取空行
	var isAddNewPage = $("#trpx0").html();
	if(isAddNewPage.indexOf("无产品明细")>-1){  //添加页面
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
		return -1;
	}
}

function moveRows(row){  //删除后填补
	var id = row.id.replace("trpx","");
	id = id * 1 + 1;
	var nextRow = document.getElementById("trpx" + id);
	if (nextRow) {
	    if (nextRow.children.length > 0) {
	        row.appendChild(nextRow.children[0]);
	    }
		//row.innerHTML = nextRow.innerHTML;
		//nextRow.innerHTML = "";
		//moveRows(nextRow);
	}
}

function getParent(child,parentIndex){  //获取指定级别的父节点
	for( var i= 0 ;i < parentIndex ; i++){
		child = child.parentElement;
	}
	return child;
}

// ******************************************************************//
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
		//tbh 2010.12.08 xmlHttp.responseText;  xmlHttp.responseText;
		var res=getFreeRow(); 
		var w  = "trpx"+res;
		w=document.all[w]
		if(w){
			var fromType = document.getElementById("fromtype").value;
			var url = "addlistadd.asp?type=cg&ord="+escape(ord)+"&top="+escape(top)+"&unit="+unit+"&fromType="+fromType;
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				updatePage5(w);
			}
			xmlHttp.send(null);
		}else{
			if(!window.dMaxRows){  //当没有定义最大行时  tbh 2010.12.08
				window.dMaxRows = (res - 1)*(-1);  //获取允许的最大行数
			}	
			window.alert("当前添加的明细行数已到达系统允许的最大值。\n\n详细情况，请咨询系统管理员。")
		}
	}
}

function updatePage5(w) {
	var test3=w;
	if (xmlHttp.readyState < 4) {
		test3.innerHTML="loading...";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test3.innerHTML=response;
		xmlHttp.abort();
		window.__ASPFExecuter.DoExecute({
			tiggerobj: GetNumberDomNode(test3),
			tiggerkey: "@@init",
			range: "row"
		});
	}
}

function del(str,id){
	var w  =  getParent(window.event.srcElement||event,6); //document.all[str];
	if (w.id.indexOf("trpx")<0){return;}
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
    xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function()
	{
		if(xmlHttp.readyState == 4){
			updatePage_del(w);
		}
	}
	xmlHttp.send(null);  
}
function updatePage_del(row) {
    row.innerHTML="";
    moveRows(row);
}

//获取用户输入
function ajaxSubmit(sort1){
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
//获取用户输入
function ajaxSubmit_gys(nameitr,ord,unit){
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

function checkPriceLimit(){
	var result=true;
	$('.input_price').each(function(){
		$obj = $(this);
		var maxVal = $obj.attr('maxZKPrice');
		var nowVal = $obj.val();
		var id=$obj.attr('id').replace('pricetest','');
		var discount = $('#zhekou'+id).val();
		if (nowVal.length==0 || discount.length==0 || isNaN(nowVal) || isNaN(discount)){
			result = false;
			return;
		}
		var priceAfterDiscount = parseFloat(nowVal) * parseFloat(discount);
		$obj.next('span').remove();
		if(priceAfterDiscount > parseFloat(maxVal)){
			$('<span class="red">折后单价('+FormatNumber(priceAfterDiscount,window.sysConfig.moneynumber)+')高于限价</span>').insertAfter($obj);
			$obj.trigger('focus');
			result = false;
		}
	});
	return result;
}

function CheckForm(frm){
	var ret = true;
	if(jQuery("input[type='text'][name^='num1_AttrsBatch_Attr1_']").size()>0){
		var attr1id = "";
		jQuery("input[name='__sys_productattrs_batchid']").each(function(){
			var id = jQuery(this).val();
			var sumAttr1Num = 0;
			var num1 = parseFloat(jQuery("#num"+id).val().replace(/,/g,""));
			jQuery("input[type='text'][name^='num1_AttrsBatch_Attr1_"+id+"']").each(function(){
				var Attr1Num = jQuery(this).val().replace(/,/g,"");
				if(Attr1Num!=""){
					Attr1Num = parseFloat(Attr1Num);
					sumAttr1Num += Attr1Num;
				}
			});
			if(sumAttr1Num>0 && num1>0){
				if(parseFloat(FormatNumber(sumAttr1Num,window.sysConfig.floatnumber)) != parseFloat(FormatNumber(num1,window.sysConfig.floatnumber))){
					attr1id = jQuery("input[type='text'][name^='num1_AttrsBatch_Attr1_"+id+"']").first().attr("id");
					ret = false;
					return false;
				}
			}
		});
		if(ret==false){
			alert("属性合计数量与小计数量不相等，请重新录入！");
			jQuery("#"+attr1id).focus();
		}
	}
	return ret;
}

function inpGetFoucs(id, inp) {
	jQuery(inp).attr("ydefValuet", inp.value);
	jQuery(inp).select();
}


var runLock = false , canCost = false;
setTimeout(function(){canCost = true;}, 1000);

//function chtotal(id, num_dot_xs, jfzt, upType) {   
//binary.2020.07.28 此函数已作废，参见  SYSA\caigou\FormulaRulesConfig.js
//}

function changeInvoice(idx){
	var $taxRate = jQuery('#taxRate_'+idx);
	var $invoiceType = jQuery('#invoiceType_'+idx);
	$taxRate.val($invoiceType.children(':selected').attr('taxRate'));
	//非IE兼容
	if (!window.ActiveXObject) {
		__ASPFExecuter.EventLister({ target: $taxRate[0] });
	}
}

var isIe = isIE();
function setall_num_price(type,obj,num_dot_xs){
	var str_id="";
	var inputs=document.getElementsByTagName("input");
	if (type=="num" && inputs.length>0)
	{
		for (n=0;n<inputs.length;n++ )
		{
			if (inputs[n].readOnly) { continue;}
			if (inputs[n].id.indexOf("num")>=0 && inputs[n].id.indexOf("Attrs")==-1 && jQuery(inputs[n]).parent().attr("class")!="attrreadsum")
			{
				str_id=inputs[n].id.replace("num","");
				if (obj.value.length == 0) {
				    if (inputs[n].value = inputs[n].defaultValue)
				    {
				        inputs[n].value = inputs[n].defaultValue;
				    }					
					inputs[n].style.color='#000';
				}else{
					inputs[n].value=obj.value;
				}
				SetCurrFormulaInfoValue(inputs[n].id.replace("num",""), inputs[n].value)
				__ASPFExecuter.EventLister({ target: inputs[n]});
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
			if (selects[n].disabled) { continue; }
			if (selects[n].id.indexOf("invoiceType_")>=0)
			{
				for (var i = 0; i < selects[n].options.length; i++) { 
					if (selects[n].options[i].value == obj.value) { 
						selects[n].options[i].selected = true; 
						str_id=selects[n].id.replace("invoiceType_","");
						changeInvoice(str_id);
						break; 
					}
				} 
				//selects[n].value=obj.value;		
			}
		}
	}
	else if (type=="taxRate")
	{
		var taxrate = obj.value;
		var jf = jQuery("#jf").val();
		if(taxrate==""){taxrate = 0;}
		if(jf==""){jf = 0;}
		jQuery("input[type='text'][id^='taxRate_']").not("[readonly]").val(taxrate);
		if(isIe == false){
			jQuery("input[type='text'][id^='taxRate_']").not("[readonly]").each(function () {
				var tid = jQuery(this).attr("id").replace("taxRate_", "");
				__ASPFExecuter.EventLister({ target: jQuery(this)[0] });
			});
		}
	}
	else if (type=="zhekou")
	{
		var zhekou = obj.value;
		var jf = jQuery("#jf").val();
		if(zhekou==""){zhekou = 0;}
		if(jf==""){jf = 0;}
		jQuery("input[type='text'][id^='zhekou']").not("[readonly]").val(zhekou);
		if(isIe == false){
			jQuery("input[type='text'][id^='zhekou']").not("[readonly]").each(function () {
				var jobj = jQuery(this);
				var tid = jobj.attr("id").replace("zhekou", "");
				__ASPFExecuter.EventLister({ target: jobj[0] });
			});
		}
	}
}

function isIE() { //ie?
	if (!!window.ActiveXObject || "ActiveXObject" in window)
		return true;
	else
		return false;
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

function callServer5(s,nameitr,ord,id, attr1id, attr2id) {
	var w  =s ;
	w=document.all[w]
	var u_name = document.getElementById("u_name"+nameitr).value;
	if ((u_name == null) || (u_name == "")) return;
	var url = "../contract/cu_kccx.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&nameitr="+escape(nameitr) + "&attr1id=" + attr1id+ "&attr2id=" + attr2id + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function callServer2_ls(nameitr,ord,id) {
	var w  = "lstt"+nameitr;
	w=document.all[w]
	var u_name = document.getElementById("u_name"+nameitr).value;
	var gys = document.getElementById("gys_"+id).value;
	if ((u_name == null) || (u_name == "")) return;
	var url = "cu_lishi.asp?unit=" + escape(u_name)+"&ord="+escape(ord)+"&id="+escape(id)+"&gys="+escape(gys)+"&nameitr="+escape(nameitr) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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


function callServer3_lsclose(nameitr) {
	var w  = "tt"+nameitr;
	w=document.all[w]
	w.innerHTML="";
	var id_show= document.getElementById("id_show");
	id_show.value=""
	xmlHttp.abort();
}

function checkall(obj){
    $("input[name='delchecks']").prop("checked", obj.checked);
}

function invsel() {
    try {
        var c = 0;
        $("input[name='delchecks']").each(function () {
            $(this).prop("checked", !$(this).prop("checked"));
            if ($(this).prop("checked")) { c++ };
        })

        $("input[name='checkalls']").prop("checked", c == $("input[name='delchecks']").length ? true : false)
    }

    catch(e){}
}


function delall(event){
	if (confirm("确定批量删除吗?")){
		var ckboxs = $("input[name='delchecks']:checked");
		var s = "";
		for (var i = ckboxs.length-1; i>=0; i--){
			s = s + (s.length>0? ",":"") +  ckboxs[i].value;
		}
		if (s.length>0){
			var url = "del_cp.asp?id="+escape(s)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
				if (xmlHttp.readyState==4)
				{
					for (var i = ckboxs.length-1; i>=0; i--){
						var currRow = plist.getCurrRow(ckboxs[i]);
						currRow.innerHTML="";
						moveRows(currRow);
					}
				}
			}
			xmlHttp.send(null);
		}
	}
}

function checkMergeNum(numObj){
	var numName = numObj.name;
	var num1, mergeNum, id;
	if(numName == "sorce6"){
		$("input[name^='num1_']").each(function(){
			num1 = $(this).val();
			mergeNum = $(this).attr("mergeNum");
			id = $(this).attr("id").replace("num","");
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
		id = numObj.id.replace("num","");
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