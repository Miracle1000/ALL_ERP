 
function xjContet(xjord, price){
	if(price==0){
		window.open('content2.asp?ord='+xjord,'newwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50');
	}else{
		window.open('content.asp?ord='+xjord,'newwin','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50');
	}
}

function bjContet(bjord){
    window.open('../../SYSN/view/sales/price/price.ashx?ord=' + bjord + '&view=details', 'neww545in', 'width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50');
}

//打开询价编辑页面
function xjEditWin(xjord){
	window.open('top.asp?ord='+xjord,'newwinedit','width=' + 1100 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
}
function priceXjEditWin(bjord){
	window.open('topadd.asp?top='+bjord,'newwinedit','width=' + 1000 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
}
function ygXjEditWin(ygord,xjord){
	window.open('top2.asp?fromtype=2&fromid='+ygord+'&ord='+xjord,'newwinedit','width=' + 900 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
}

//打开定价页面
function mkPriceWin(xjord){
	window.open('makePrice.asp?ord='+xjord,'newwinmkprice','width=' + 1100 + ',height=' + 700 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
}

//打开预购添加页面
function addYGWin(xjord){
	window.open('../../SYSN/view/store/yugou/YuGou.ashx?fromtype=3&fromid='+xjord,'neww3w7in','width=' + 1165 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=50');
}

//打开采购添加页面
function addCGWin(xjord) {
	window.open('../../SYSN/view/store/caigou/caigou.ashx?fromtype=3&fromid='+xjord,'newwcgw7in','width=' + 1165 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=50');
}

//打开询价修改页面
function xjCorrectWin(xjord){
	window.open('correct.asp?ord='+xjord,'newwincor','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
}

function batDel(){
	var selectid = "";
	var noDel = "";
	var arr_noDel;
	var i = 0;
	$("input[name='selectid']").each(function(){
		if($(this).attr("checked")){
			if($(this).attr("delAble")=="1"){
				selectid += (selectid==""?"":",") + $(this).val();
			}else{
				noDel += (noDel==""?"":",") + $(this).val();
			}
		}
	});
	if(noDel!=""){
		arr_noDel = noDel.split(",");
		for(i=0;i<arr_noDel.length;i++){
			$("#tip_"+arr_noDel[i]).html("不可以删除");
		}
		alert("有不可以删除的询价单");
		return;
	}
	if(selectid == ""){
		alert("您没有选择任何询价，请选择后再删除！");
		return;
	}else{		
		if(confirm("确认删除吗？")){
			jQuery.ajax({
				url:'deleteall.asp',
				data:{selectid:selectid	},
				type:'post',
				success:function(r){
					if(r!=""){
						var arr_res = r.split("|");
						if(arr_res[0]=="0"){
							alert("您没有选择任何询价，请选择后再删除！");
							return;
						}else if(arr_res[0]=="1"){
							window.location.reload();
						}else if(arr_res[0]=="2"){
							gotourl('noDel='+arr_res[1]);
						}
					}
				},error:function(XMLHttpRequest, textStatus, errorThrown){
					alert(errorThrown);
				}
			});			
		}
	}
}

function batZP(){
	var selectid = "";
	var nozp = "";
	var arr_nozp;
	var i = 0;
	$("input[name='selectid']").each(function(){
		if($(this).attr("checked")){
			if($(this).attr("zpAble")=="1"){
				selectid += (selectid==""?"":",") + $(this).val();
			}else{
				nozp += (nozp==""?"":",") + $(this).val();
			}
		}
	});
	if(nozp!=""){
		arr_nozp = nozp.split(",");
		for(i=0;i<arr_nozp.length;i++){
			$("#tip_"+arr_nozp[i]).html("不可以指派");
		}
		alert("有不可以指派的询价单");
		return;
	}
	if(selectid == ""){
		alert("您没有选择任何询价，请选择后再指派！");
		return;
	}else{		
		var curhref = window.location.href;
		var curSearch = "";
		if(curhref.indexOf("?")>0){
			curSearch = curhref.substring(curhref.indexOf("?")+1);
			curSearch = escape(curSearch)
		}
		window.location.href="orderallhy.asp?selectid="+selectid+"&retUrl="+curSearch;
	}
}

function mm(form) {
	if($("#chkall").attr("checked")){ // jquery 版本过低导致直接用attr切换选中属性会出问题
		$("input[name='selectid']").prop("checked",true);
	}else{
		$("input[name='selectid']").removeAttr("checked",false);
	}
}

//询价单 中止
function setXjStatus(xjord, status){
	var tipStr = "";
	if(status!=4){tipStr = "取消" ;}
	if(confirm("确定要"+tipStr+"终止吗？")){
		jQuery.ajax({
			url:'ajax_save.asp',
			data:{msgid:"setXjStatus", ord:xjord, status:status	},
			type:'post',
			success:function(r){
				if(r=="1"){
					if(window.opener)window.opener.location.reload();
					window.location.reload();
				}
			},error:function(XMLHttpRequest, textStatus, errorThrown){
				alert(errorThrown);
			}
		});		
	}
}

function Myopen_px(divID){
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=308;
	divID.style.top=5;
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