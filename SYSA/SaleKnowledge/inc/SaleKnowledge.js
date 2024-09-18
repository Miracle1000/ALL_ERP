// JavaScript Document

window.__ShowImgBigToSmall = true ;

$(document).ready(function(e) {
	$("textarea").css({"overflow":"hidden"}).each(function(e){//--多行文本自增长
		while (($(this).attr("scrollHeight") > $(this).attr("clientHeight"))){
			$(this).attr("rows",$(this).attr("rows") +1)
		}
	});
	$("body").css({"min-width":"800px"});
});


function RerurnSelect(objname,value,text){//--关闭当前页，并返回选中的信息
	if (window.opener)
	{
		window.opener.document.getElementsByName(objname)[0].value=value;
		window.opener.document.getElementById("s_"+objname+"_txt").value=text;
		window.opener.document.getElementById("s_"+objname+"_txt").style.color="#000";
	}
	window.close();
}
function RerurnSelect1(value,text){//--关闭当前页，并返回选中的信息
	if (window.opener)
	{
		if (window.opener.document.getElementsByName("Company")[0].value == "" || window.opener.document.getElementsByName("Company")[0].value == "0"){
			window.opener.document.getElementsByName("Company")[0].value=value;
			window.opener.document.getElementById("s_Company_txt").value=text;
		}
	}
}


var ListAction = {
	DoDel:function(id){
		var s = confirm("您确定要进行删除吗？");
		if (!s){
			return false;
		}
		ajax.regEvent("DoDel");
		ajax.addParam("id",id);
		var v = ajax.send();
		if (v == "true"){
			window.DoRefresh();
		}
	},
	DoDelClose:function(id){
		var s = confirm("您确定要进行删除吗？");
		if (!s){
			return false;
		}
		ajax.regEvent("DoDel");
		ajax.addParam("id",id);
		var v = ajax.send();
		if (v == "true"){
			window.close();
			if(opener){
				opener.window.DoRefresh();
			}
		}
	},
	DoSave:function(input,num){
		document.getElementById('SubmitType').value = num;
		return bill.doSave(input);
	}
}

function __as_tck_nck(nd) {//--重载__as_tck_nck事件
	var ck = nd.checked;
	if($ID(nd.id + "_b")) {
		$ID(nd.id + "_b").style.display = ck ? "" : "none";
		nd.parentNode.style.clear = ck  ? "both" : "none";
		var divs = $ID(nd.id + "_b").getElementsByTagName("div");
		for(var i = 0; i < divs.length; i++){
			if (divs[i].children[0] && divs[i].children[0].tagName.toLowerCase() == "pre"){
				if(divs[i].children[0].children[0] && divs[i].children[0].children[0].tagName.toLowerCase() == "input"){
					if (ck){
						divs[i].children[0].children[0].checked = true;
					}else{
						divs[i].children[0].children[0].checked = false;
					}
					__as_tck_nck(divs[i].children[0].children[0]);
				}
			}
		}
	}
}