var xmlHttp = GetIE10SafeXmlHttp();

function checkForm(){
	var selectids = jQuery("#cpords").val();
	if(selectids == ""){
		alert("请选择统一规则或例外规则中的产品");
		return false;
	}
	var sort1 = jQuery("input[name=sort1]:checked").val();
	var sort2 = jQuery("input[name=sort2]:checked").val();
	if (sort1 == undefined || sort1 == "") {
		alert("请选择提成基数");
		return false;
	}
	if (sort2 == undefined || sort1 == "") {
		alert("请选择提成比例");
		return false;
	}
	var formula1 , formula2, num8, temp2;
	if(sort2 == "4"){
		for (var i = 0; i < 6; i++){

			formula1 = jQuery("#formula1"+i).val();
			formula2 = jQuery("#formula2"+i).val();
			num8 = jQuery("#num8"+i).val();			
			if(!(formula1=="" && formula2=="" && num8=="") && !(formula1!="" && formula2!="" && num8!="")){
				alert("请填写完整");
				if(formula1==""){
					jQuery("#formula1"+i).focus();
				}else if(formula2==""){
					jQuery("#formula2"+i).focus();
				}else if(num8==""){
					jQuery("#num8"+i).focus();
				}
				return false;
			}		
			if(formula1!=""){
				if(checkFormula(formula1) == false){
					alert("公式不规范，请重新填写");
					jQuery("#formula1"+i).focus();
					return false;
				}
			}
			if(formula2!=""){
				if(checkFormula(formula2) == false){
					alert("公式不规范，请重新填写");
					jQuery("#formula2"+i).focus();
					return false;
				}
			}
		}
	}
}

function checkFormula(formStr){
	if(formStr!=""){
		formStr = formStr.replace(/0/g,"").replace(/1/g,"").replace(/2/g,"").replace(/3/g,"").replace(/4/g,"").replace(/5/g,"").replace(/6/g,"").replace(/7/g,"").replace(/8/g,"").replace(/9/g,"");
		formStr = formStr.replace(/\+/g,"").replace(/\-/g,"").replace(/\*/g,"").replace(/\//g,"").replace(/\./g,"").replace(/\(/g,"").replace(/\)/g,"");
		formStr = formStr.replace(/{建议售价}/g,"").replace(/{最低售价}/g,"").replace(/{建议进价}/g,"").replace(/{最高进价}/g,"").replace(/{客户跟进程度价格}/g,"");
		if(formStr != ""){
			return false;
		}else{
			return true;
		}
	}else{
		return false;
	}
}

function addNew(){
	if(checkForm()!=false){
		jQuery("#add").attr("value","2");
		document.date.submit();
	}
}


var cpOrds = "";
var cpNames = "";
var clsIds = "";
jQuery(function(){
	cpOrds = jQuery("#cpords").val();
	cpNames = jQuery("#cpNames").val();
	clsIds = jQuery("#clsIds").val();
});

//选择产品
function selectCP(ord,obj){
	var funType = (obj?jQuery(obj):jQuery("#cp"+ord)).attr("funType");
	if(funType == "0"){
		if((","+cpOrds+",").indexOf(",0,")>-1){	//如果已选择了统一规则，又选择产品
			if(confirm("您已选择统一提成规则，如果要设置产品例外规则，\n\n需要清空统一规则的设置，确定要清空吗？")){
				qkongcp();
				jQuery('#cp0').css('color','').attr('funType','0');
			}else{
				return;
			}
		}else if(ord==0 && cpOrds!="" && (","+cpOrds+",").indexOf(",0,")==-1){
			if(confirm("您已选择例外提成规则，如果要设置统一提成规则，\n\n需要清空例外规则的设置，确定要清空吗？")){
				qkongcp();
				jQuery('.tree-folder[nid] a').css('color','').attr('funType','0');
			}else{
				return;
			}
		}
		jQuery("#cp"+ord).attr("funType","1");
		jQuery("#cpl"+ord).attr("funType","1");
		callServer4(ord);
	}else{
		jQuery("#cp"+ord).attr("funType","0");
		jQuery("#cpl"+ord).attr("funType","0");
		cancleCP(ord);
	}
}

function callServer4(ord) {
  var cpord, cptitle, sort1, sort2, formulaStr;
  formulaStr = "";
  var url = "get_cptcbl.asp?ord="+escape(ord);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		showCPtcbl(response,"ord", ord);
		xmlHttp.abort();
	  }
  };
  xmlHttp.send(null);  
}

//选择产品分类
function categoryTC(clsid) {
	var funType = jQuery("#b"+clsid).attr("funType");
	if(funType == "0"){
		if((","+cpOrds+",").indexOf(",0,")>-1){	//如果已选择了统一规则，又选择产品
			if(confirm("您已选择统一提成规则，如果要设置产品例外规则，\n\n需清空统一规则的设置，确定要清空吗？")){
				qkongcp();
				jQuery('#cp0').css('color','').attr('funType','0');
			}else{
				return;
			}
		}
		jQuery("#b"+clsid).attr("funType","1");
		jQuery("#a"+clsid+" a").css("funType","1");
		selectCls(clsid);
	}else{
		jQuery("#b"+clsid).attr("funType","0");
		jQuery("#b"+clsid+" a").css("color","");
		jQuery("#a"+clsid+" a").attr("funType","0");
		jQuery("#a"+clsid+" a").css("color","");
		cancleCls(clsid);
	}
}

function selectCls(clsid){
  var cpord, cptitle, sort1, sort2, formulaStr;
  formulaStr = "";
  var url = "get_cptcbl.asp?clsid="+escape(clsid);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		var allCls = '';
		if (response.indexOf("\3|\2|\1") > -1){
			var tmp = response.split('\3|\2|\1');
			response = tmp[0];
			allCls = tmp[1];
		}

		jQuery.each(allCls.split(','),function(){
			if ((','+clsIds+',').indexOf(','+this+',')<0){
				clsIds += (clsIds.length>0?',':'') + this;
			}
		});

		showCPtcbl(response,"cls", clsid);
		changeCheckState();
		xmlHttp.abort();
	  }
  };
  xmlHttp.send(null);  
}

//选择统一规则
function selectAllGZ(){
	var funType = jQuery("#allgz").attr("funType");
	if(funType == "0"){
		jQuery("#allgz").attr("funType","1");
	}else{
		jQuery("#allgz").attr("funType","0");
	}
}

function showCPtcbl(resTxt,type, tid){
	if(resTxt!=""){		
		var arr_res = "";
		var arr_res1 = "";
		var cpordStr = "";
		var cptitleStr = "";
		var arr_cpord = "";
		var arr_cptitle = "";
		var i = 0;

		if (resTxt.indexOf("\3|\3") > -1){
			arr_res1 = resTxt.split("\3|\3");
			cpordStr = arr_res1[0];
			cptitleStr = arr_res1[1];
			arr_res = arr_res1[2].split("\1,\1");
		}else{
			arr_res = resTxt.split("\1,\1");
			cpordStr = arr_res[0]; cptitleStr = arr_res[1];
		}
		sort1 = arr_res[2];  sort2 = arr_res[3];  formulaStr = arr_res[4]; 
		arr_cpord = cpordStr.split(",");
		arr_cptitle = cptitleStr.split(",\1");
		for (i=0; i<arr_cpord.length; i++){
			cpord = arr_cpord[i];
			cptitle = arr_cptitle[i];
			if(cpOrds == ""){
				cpOrds = cpord;
				cpNames = cptitle;
			} else {
				if((","+cpOrds+",").indexOf(","+cpord+",") == -1){
					cpOrds += ","+ cpord;
					cpNames += ", "+ cptitle;
				}
			}
		}
		if(cpNames.length>0){
			jQuery("#qkongcp").css("display","");
		}else{
			jQuery("#qkongcp").css("display","none");
		}

		var arr_formular = formulaStr.split("\2\3\2");
		var arr_tcbl = "";		
		for(i=0;i<arr_formular.length;i++){
			if (arr_formular[i]!=""){
				var arr_tcbl = arr_formular[i].split("\2,\2");
				if(sort2 == 1){
					jQuery("#num2").attr("value", arr_tcbl[2]);
				}else if(sort2 == 2){
					jQuery("#money1"+i).attr("value", arr_tcbl[0]);
					jQuery("#money2"+i).attr("value", arr_tcbl[1]);
					jQuery("#num6"+i).attr("value", arr_tcbl[2]);
				}else if(sort2 == 3){
					jQuery("#num3").attr("value", arr_tcbl[2]);
				}else if(sort2 == 4){
					jQuery("#formula1"+i).attr("value", arr_tcbl[0]);
					jQuery("#formula2"+i).attr("value", arr_tcbl[1]);
					jQuery("#num8"+i).attr("value", arr_tcbl[2]);
				}
			}			
		}
		if(type == "ord"){
			jQuery("#cp"+cpord).css("color","#ff0000");
			jQuery("#cpl"+cpord).css("color","#ff0000");
		}else if(type == "cls"){
			jQuery("#b"+tid +" a").css("color","#ff0000");
			jQuery("#a"+tid+" a").css("color","#ff0000");
		}
		jQuery("#cpNames").val(cpNames);
		jQuery("#cpords").attr("value",cpOrds);
		jQuery("#sort1"+sort1).attr("checked",true);
		jQuery("#sort2"+sort2).attr("checked",true);
		if(sort1 == 5){
			jQuery("#tcType23").css("display","none");
			jQuery("#tcType4").css("display","");
		}else{
			jQuery("#tcType23").css("display","");
			jQuery("#tcType4").css("display","none");
		}
		if(sort2 == 1){
			jQuery("#kh").css("display","");
			jQuery("#xm").css("display","none");
			jQuery("#cp").css("display","none");
			jQuery("#ht").css("display","none");	
		}else if(sort2 == 2){
			jQuery("#kh").css("display","none");
			jQuery("#xm").css("display","");
			jQuery("#cp").css("display","none");
			jQuery("#ht").css("display","none");	
		}else if(sort2 == 3){
			jQuery("#kh").css("display","none");
			jQuery("#xm").css("display","none");
			if((","+cpOrds+",").indexOf(",0,")==-1){
				jQuery("#cp").css("display","");
			}
			jQuery("#ht").css("display","none");			
		}else if(sort2 == 4){
			jQuery("#kh").css("display","none");
			jQuery("#xm").css("display","none");
			jQuery("#cp").css("display","none");
			jQuery("#ht").css("display","");	
		}
	}
}

//清空选择的产品
function qkongcp(){
		cpOrds = ""; cpNames = ""; clsIds = "";
		jQuery("#cpords").attr("value",cpOrds);
		jQuery("#cpNames").val(cpNames);
		jQuery("#qkongcp").css("display","none");
		jQuery("input[name=sort1]").attr("checked",false);
		jQuery("input[name=sort2]").attr("checked",false);
		jQuery("#tcType23").css("display","");
		jQuery("#tcType4").css("display","none");
		jQuery("#kh").css("display","none");
		jQuery("#xm").css("display","none");
		jQuery("#cp").css("display","none");
		jQuery("#ht").css("display","none");
		jQuery("#cp_search a").css("color","");
		jQuery("#cp_search a[funType='1']").attr("funType","0");
		jQuery("input[name=num2]").attr("value","0");
		jQuery("input[name=num3]").attr("value","0");
		jQuery("input[name=money1]").attr("value","");
		jQuery("input[name=money2]").attr("value","");
		jQuery("input[name=num6]").attr("value","");
		jQuery("input[name=formula1]").attr("value","");
		jQuery("input[name=formula2]").attr("value","");
		jQuery("input[name=num8]").attr("value","");
}

//取消选择的产品
function cancleCP(ord){
		var cpord , cptitle;
		cpord = ord;		
		cptitle = jQuery("#cp"+cpord).attr("name");		
		jQuery("#cp"+cpord).css("color","");
		jQuery("#cpl"+cpord).css("color","");
		if (cpOrds == cpord){
			cpOrds = ""; cpNames = "";
		}else{
			cpOrds = ("a,"+cpOrds+",a").replace(","+cpord+",",",").replace("a,","").replace(",a","");
//			alert('['+cpNames+']-----['+cptitle+']');
			cpNames = ("{\2}, "+cpNames+", {\2}").replace(", "+cptitle+", ",", ").replace("{\2}, ","").replace(", {\2}","");
		}
		
		if(cpOrds.length>0){
			jQuery("#qkongcp").css("display","");
		}else{
			jQuery("#qkongcp").css("display","none");
		}
		jQuery("#cpords").attr("value",cpOrds);
		jQuery("#cpNames").val(cpNames);

		var arr_cpords = cpOrds.split(",");
		var lastOrd = arr_cpords[arr_cpords.length-1];
		if(lastOrd != ""){
			var url = "get_cptcbl.asp?ord="+escape(lastOrd);
			xmlHttp.open("GET", url, false);
			xmlHttp.onreadystatechange = function(){
			  if (xmlHttp.readyState == 4) {
				var response = xmlHttp.responseText;
				showCPtcbl(response,"ord", lastOrd);
				xmlHttp.abort();
			  }
			};
			xmlHttp.send(null);  
		}else{
			jQuery("input[name=sort1]").attr("checked",false);
			jQuery("input[name=sort2]").attr("checked",false);
			jQuery("#tcType23").css("display","");
			jQuery("#tcType4").css("display","none");
			jQuery("#kh").css("display","none");
			jQuery("#xm").css("display","none");
			jQuery("#cp").css("display","none");
			jQuery("#ht").css("display","none");	
			jQuery("input[name=num2]").attr("value","0");
			jQuery("input[name=num3]").attr("value","0");
			jQuery("input[name=money1]").attr("value","");
			jQuery("input[name=money2]").attr("value","");
			jQuery("input[name=num6]").attr("value","");
			jQuery("input[name=formula1]").attr("value","");
			jQuery("input[name=formula2]").attr("value","");
			jQuery("input[name=num8]").attr("value","");
		}
}


//取消选择的分类
function cancleCls(clsid){
	var arr_res = "";
	var arr_res1 = "";
	var cpordStr = "";
	var cptitleStr = "";
	var arr_cpord = "";
	var arr_cptitle = "";
	var cpord, cptitle;
	var i = 0;
	var url = "get_cptcbl.asp?clsid="+escape(clsid);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		var allCls = '';
		if (response.indexOf("\3|\2|\1") > -1){
			var tmp = response.split('\3|\2|\1');
			response = tmp[0];
			allCls = tmp[1];
		}

		var clsSelector = allCls.replace(/,/g,'] a,.tree-folder[nid=');
		if (clsSelector.length>0){
			clsSelector = '.tree-folder[nid=' + clsSelector + '] a';
			jQuery(clsSelector).css('color','');
		}

		clsIds = ','+clsIds+',';
		jQuery.each(allCls.split(','),function(){
			clsIds = clsIds.replace(','+this+',',',');
		});
		clsIds = clsIds.replace(/^,/,'').replace(/,$/,'');
		changeCheckState();

		if (response!=""){		
			var arr_res1 = response.split("\3|\3");
			cpordStr = arr_res1[0];
			cptitleStr = arr_res1[1];
			arr_cpord = cpordStr.split(",");
			arr_cptitle = cptitleStr.split(",\1");
			for(i = 0; i<arr_cpord.length; i++){
				cpord = arr_cpord[i];
				cptitle = arr_cptitle[i];
				$('.search-list[pid=' + cpord + ']').css('color','').attr('funType','0');
				$('.tree-linkOfLeafNodes[lid=' + cpord + ']').css('color','').attr('funType','0');
				if (cpOrds == cpord){
					cpOrds = ""; cpNames = "";
				}else{
					cpOrds = ("a,"+cpOrds+",a").replace(","+cpord+",",",").replace("a,","").replace(",a","");
					cpNames = ("{\2}, "+cpNames+", {\2}").replace(", "+cptitle+", ",", ").replace("{\2}, ","").replace(", {\2}","");
				}
			}
			jQuery("#cpords").attr("value",cpOrds);
			jQuery("#cpNames").val(cpNames);
		}
		if(cpOrds == ""){
			jQuery("input[name=sort1]").attr("checked",false);
			jQuery("input[name=sort2]").attr("checked",false);
			jQuery("#tcType23").css("display","");
			jQuery("#tcType4").css("display","none");
			jQuery("#kh").css("display","none");
			jQuery("#xm").css("display","none");
			jQuery("#cp").css("display","none");
			jQuery("#ht").css("display","none");		
			jQuery("input[name=num2]").attr("value","0");
			jQuery("input[name=num3]").attr("value","0");
			jQuery("input[name=money1]").attr("value","");
			jQuery("input[name=money2]").attr("value","");
			jQuery("input[name=num6]").attr("value","");
			jQuery("input[name=formula1]").attr("value","");
			jQuery("input[name=formula2]").attr("value","");
			jQuery("input[name=num8]").attr("value","");
		}else{
			var arr_cpords = cpOrds.split(",");
			var lastOrd = arr_cpords[arr_cpords.length-1];
			if(lastOrd != ""){
				var url2 = "get_cptcbl.asp?ord="+escape(lastOrd);
				var xmlHttp2 = GetIE10SafeXmlHttp();
				xmlHttp2.open("GET", url2, false);
				xmlHttp2.onreadystatechange = function(){
				  if (xmlHttp2.readyState == 4) {
					var response2 = xmlHttp2.responseText;
					showCPtcbl(response2,"ord", lastOrd);
					xmlHttp2.abort();
				  }
				};
				xmlHttp2.send(null);  
			}	
			xmlHttp.abort();
		}
	  }
  };
  xmlHttp.send(null);  
}

function checkSort1(){
	var sort1 = 1;
	if(jQuery("#sort15").attr("checked")){
		sort1 = 5;
	}
	if(sort1 == 5){
		jQuery("#tcType23").css("display","none");
		jQuery("#tcType4").css("display","");
		jQuery("#xm").css("display","none");
		jQuery("#cp").css("display","none");
	}else{
		jQuery("#tcType23").css("display","");
		jQuery("#tcType4").css("display","none");
		jQuery("#ht").css("display","none");
	}
}

function checkSort2(sid){
	jQuery("#blType font").css("display","none");
	if(sid == "sort21"){
		jQuery("#kh").css("display","");
	}else if(sid == "sort22"){
		jQuery("#xm").css("display","");
	}else if(sid == "sort23"){
		var showNum3 = true;
		if((","+cpOrds+",").indexOf(",0,")>-1){
			showNum3 = false;
		}
		if(showNum3 == true){
			jQuery("#cp").css("display","");
		}
	}else if(sid == "sort24"){
		jQuery("#ht").css("display","");
	}
}

function ajaxSubmit(sort1){
	//获取用户输入
	var B=document.forms[0].B.value;
	var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
	var url = "search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
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
		changeCheckState();
		xmlHttp.abort();
	}
}

window.__onAfterTreeNodePage = function(){
	changeCheckState();
};

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

function showDIV(show,v,divid){			//显示/隐藏层
	if(show==1){
		document.getElementById(divid).style.display = "";
	}else if(show==0){
		if(v==""){
			document.getElementById(divid).innerHTML = ""
		}
		document.getElementById(divid).style.display = "none";
	}
}



function selectAll(){
	jQuery("input[name='member2']").attr("checked",true);
}

function selectFan(){
	jQuery("input[name='member2']").each(function(){
            if (this.checked) {
                this.checked = false;
            }else {
                this.checked = true;
            }
     });	
}

function batSetStatus(v){
	if (v!=""){
		try{
			jQuery("select[name^='status_']").attr("value",v);
		}catch(e){}
	}
}

//判断录入必须是数字,参数idot为1/0,用于判断是否可以录入小数点
function checkOnlyNum(idot){
	if (idot==null){idot=0;}
	var char_code = window.event.charCode ? window.event.charCode : window.event.keyCode;
	if((char_code<48 || char_code >57) && (idot==0 || (idot=1 && char_code!=46))) {return false;}
	
}

jQuery(function(){
	setTimeout(function(){
		__toggleNode(jQuery('.tree-folder-closed[nid=0]')[0],false,function(){
			changeCheckState();
		});
	},10);
});

function changeCheckState(){
	var ordSelector = cpOrds.replace(/,/g,'],.tree-linkOfLeafNodes[lid=');
//	jQuery('.tree-linkOfLeafNodes[lid]').css('color','');
	if (ordSelector.length>0){
		ordSelector = '.tree-linkOfLeafNodes[lid=' + ordSelector + ']';
		jQuery(ordSelector).css('color','red');
	}

	var schSelector = cpOrds.replace(/,/g,'],.search-list[pid=');
//	jQuery('.tree-linkOfLeafNodes[lid]').css('color','');
	if (schSelector.length>0){
		schSelector = '.search-list[pid=' + schSelector + ']';
		jQuery(schSelector).css('color','red').attr('funType','1');
	}

	var clsSelector = clsIds.replace(/,/g,'] a,.tree-folder[nid=');
//	jQuery('.tree-folder[nid]').css('color','');
	if (clsSelector.length>0){
		clsSelector = '.tree-folder[nid=' + clsSelector + '] a';
		jQuery(clsSelector).css('color','red');
	}
}
