function showTreeATitle(){
	jQuery(".tvw_n_txt .tvw_txt").mouseover(function(){
		if($(this).attr("title")==""){
		  $(this).attr("title",this.innerText);
		}
	});
}

var sc = 1
function expTree(obj) {	
	if(obj.innerText=="全部收缩") 
	{
		obj.innerText="全部展开"
		sc = 0;
	}
	else{
		sc = 1;
		obj.innerText="全部收缩"
	}
	doSearch();
}

var ht = 0
function expTreeHT(obj) {	
	if(obj.innerText=="全部收缩") 
	{
		obj.innerText="全部展开"
		ht = 1;
	}
	else{
		ht = 0;
		obj.innerText="全部收缩"
	}
	doSearchHT();
}

function doSearch(){	//搜索产品
	tvw.callback("cpcls",beforeSearch,"");
}

function doSearchHT(){	//搜索合同
	tvw.callback("htcls",beforeSearchHT,"");
}


function beforeSearch(){		//产品
	var t = document.getElementById("cpKeywords").value;	
	ajax.addParam("explan",sc==1?1:0);
	ajax.addParam("C", t=="按回车搜索" ? "":t);
	ajax.addParam("B",document.getElementById("cpB").value);
	ajax.addParam("ajCode",document.getElementById("cpajCode").value);
}

function beforeSearchHT(){		//合同
	var t = document.getElementById("htKeywords").value;	
	ajax.addParam("explan",ht==1?1:0);
	ajax.addParam("C", t=="按回车搜索" ? "":t);
	ajax.addParam("B",document.getElementById("htB").value);
	ajax.addParam("ajCode",document.getElementById("htajCode").value);
}

function ajaxSubmitCP(obj) {	//产品树快速检索
	if(obj.value.replace(/\s/,"").length==0) 
	{
		obj.style.color="#999999";
	}
	else{
		obj.style.color="#000000";
	}
	doSearch();
}

function ajaxSubmitHT(obj) {	//合同树快速检索
	if(obj.value.replace(/\s/,"").length==0) 
	{
		obj.style.color="#999999";
	}
	else{
		obj.style.color="#000000";
	}
	doSearchHT();
}

function showGroup(){	//产品树 显示分类
	var obj = document.getElementById("cpKeywords")
	obj.value="按回车搜索";
	obj.style.color="#999999";
	sc = 0;
	$ID("expTree").innerText="全部展开"
	doSearch();
}

//-----产品高级搜索  开始-------
function ShowCPAdvance(button){ //显示产品高级搜索
	var ie6 = false;
	if (window.ActiveXObject) {
		var ua = navigator.userAgent.toLowerCase();
		var ie=ua.match(/msie ([\d.]+)/)[1];
		ie6 = (ie == 6.0);
	}
	if(ie6) {
		var divCP = document.getElementById("divdlg_cpsasd");
		if(divCP) {
			try{
				if(divCP.bgDiv) { divCP.bgDiv.outerHTML="";}
				divCP.outerHTML = "";	
			}catch(e){}
		}
	}	
	divCP = DivOpen("cpsasd","高级检索",400,570,70,document.getElementById("cpjsdiv").offsetWidth-button.offsetWidth-2,true,10);			
	//if(!window.apageHTML ) {
		var url = ajax.url;
		ajax.url = "topadd.asp";
		ajax.regEvent("ShowCPAdvance");
		window.apageHTML = ajax.send();
		divCP.innerHTML = window.apageHTML;
		ajax.url = url;
	//}
	//else{
	//	divCP.innerHTML = window.apageHTML;
	//}
	var height2 = document.getElementById("cpadsIF").offsetHeight;
	if (height2>510)
	{
		height2 = Number(height2);
		divCP.style.height = height2 + "px";
		document.getElementById("divdlg_cpsasd").style.height=(height2+70) + "px";
	}

}

kdown = function(txt){
	if(event.keyCode==13) 
	{
		document.getElementById("doAsButton").click();
		txt.focus();
		txt.select();
		event.returnValue=false;
		return false
	}
}

ckcpflall = function(obj) {
	var box = parent.document.getElementsByName("cpfl");
	var checked = obj.checked;
	for (var i = 0; i < box.length ; i++)
	{
		box[i].checked =  checked;
	}
}

window.parent.expNode = function(chk){
	var isCollapsed = chk.checked == true;
	var $chk = $(chk);
	var $tr = $chk.parent().parent();
	var $box = $tr.next();
	var id = $tr.attr('value');
	if (isCollapsed){
		if (!$box.attr('loaded')){
			$.ajax({
				url:'?__msgId=getNode&id=' + id,
				async:false,
				cache:false,
				success:function(html){
					$box.show().children().eq(1).html('<table>'+html+'</table>');
				}
			});
			$box.attr('loaded',true);
		}else{
			$box.show();
		}
	}else{
		$box.hide();
	}
}


function getckInputs(div){
	var cs = new Array();
	var elms = div.getElementsByTagName("input")
	for(var i = 0 ;  i < elms.length ; i ++){
		if(elms[i].checked==true && !elms[i].getAttribute("isAll")){
			cs[cs.length] = elms[i].getAttribute("tag");
		}
	}	
	return cs.join(",");
}


//执行产品高级检索
doASearch = function(si){			
	var code = new Array();
	for(var i = 1; i <= si ; i++){
		var elem = $ID("cp_a_s" + i);				
		if (elem.tagName == "INPUT"){
			code[code.length] =  elem.id + "\1\2" + elem.db + "\1\2" + elem.value;					
		}else if (elem.tagName == "SELECT"){
			code[code.length] =  elem.id + "\1\2" + elem.db + "\1\2" + elem.options[elem.selectedIndex].value;	
		}else{
			code[code.length] =  elem.id + "\1\2" + elem.db + "\1\2" + getckInputs(elem);
		}				
	}
	SearchCPKey(code.join("\3\4"));
}

function SearchCPKey(ajCode){
	if(ajCode){		
		ajax.regEvent("cpcls_ctree");
		ajax.addParam("ajCode", ajCode);
		var r = ajax.send();	
		if(r!=""){
			$ID("cpTreeHtml").innerHTML=r;
		}
	}	
}

//-----产品高级搜索  结束-------


//-----合同高级搜索  开始-------
function ShowHTAdvance(button){ //显示合同高级搜索
	var ie6 = false;
	if (window.ActiveXObject) {
		var ua = navigator.userAgent.toLowerCase();
		var ie=ua.match(/msie ([\d.]+)/)[1];
		ie6 = (ie == 6.0);
	}
	if(ie6) {
		var divHT = document.getElementById("divdlg_htsasd");
		if(divHT) {
			try{
				if(divHT.bgDiv) { divHT.bgDiv.outerHTML="";}
				divHT.outerHTML = "";	
			}catch(e){}
		}
	}	
	divHT = DivOpen("htsasd","高级检索",400,570,70,document.getElementById("htjsdiv").offsetWidth-button.offsetWidth-2,true,10);			
	//if(!window.apageHTML ) {
		var url = ajax.url;
		ajax.url = "topadd.asp";
		ajax.regEvent("ShowHTAdvance");
		window.apageHTML = ajax.send();
		divHT.innerHTML = window.apageHTML;
		ajax.url = url;
	//}
	//else{
	//	divHT.innerHTML = window.apageHTML;
	//}
	var height2 = document.getElementById("htadsIF").offsetHeight;
	if (height2>510)
	{
		height2 = Number(height2);
		divHT.style.height = height2 + "px";
		document.getElementById("divdlg_htsasd").style.height=(height2+70) + "px";
	}

}

//执行高级检索
doASearchHT = function(si){			
	var code = new Array();
	for(var i = 1; i <= si ; i++){
		var elem = $ID("ht_a_s" + i);				
		if (elem.tagName == "INPUT"){
			code[code.length] =  elem.id + "\1\2" + elem.db + "\1\2" + elem.value;					
		}else if (elem.tagName == "SELECT"){
			code[code.length] =  elem.id + "\1\2" + elem.db + "\1\2" + elem.options[elem.selectedIndex].value;	
		}else{
			code[code.length] =  elem.id + "\1\2" + elem.db + "\1\2" + getckInputs(elem);
		}				
	}
	SearchHTKey(code.join("\3\4"));
}

function SearchHTKey(ajCode){
	if(ajCode){		
		ajax.regEvent("htcls_ctree");
		ajax.addParam("ajCode", ajCode);
		var r = ajax.send();	
		if(r!=""){
			$ID("htTreeHtml").innerHTML=r;
		}
	}	
}


