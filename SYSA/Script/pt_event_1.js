
function test()
{
    if (!confirm('您确定要删除吗？')) return false;
}

function mm(form)
{
	for (var i=0;i<form.elements.length;i++)
	{
		var e = form.elements[i];
		if (e.name != 'chkall')
		e.checked = form.chkall.checked;
	}
}

function Myopen(divID){ //根据传递的参数确定显示的层
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=300;
	divID.style.top=0;
}

function panelClose(){
	jQuery('#includeTaxSettingPanel').hide();
	jQuery('#productListPanel').show();
}

function setIncludeTax(btn){
	var $btn = jQuery(btn);
	var isAllProductIncludeTax = jQuery(':radio:checked[name="isAllProductIncludeTax"]').val();
	$btn.attr('value','处理中...').prop('disabled','disabled');
	jQuery.ajax({
		url:'../product/event.asp',
		data:{isAllProductIncludeTax:isAllProductIncludeTax,batchSetting:1},
		cache:false,
		success:function(r){
			panelClose();
			jQuery('#includeTaxSettingPanel').remove();
		}
	});
}

function PrintAll(isSum){
	var selectid = document.getElementsByName("selectid");
	var ids = "";
	for(var i = 0; i < selectid.length; i++){
		if(selectid[i].checked){
			ids = ids + "," + selectid[i].value;
		}
	}
	ids = ids.replace(",","");
	if(ids.length == 0){
		alert("您没有选择任何信息，请选择后再打印！");
		return false;
	}
	ids = ids.split(",");
	if (ids.length > 200){alert("选择的单据数量不要超过200个！");return false;}
	window.OpenNoUrl('../Manufacture/inc/printerResolve.asp?formid=' + ids + '&sort=2003&isSum='+isSum,'newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
}


function NewPrintAll(isSum){
	var selectid = document.getElementsByName("selectid");
	var ids = "";
	for(var i = 0; i < selectid.length; i++){
		if(selectid[i].checked){
			ids = ids + "|" + selectid[i].value;
		}
	}
	ids = ids.replace("|","");
	if(ids.length == 0){
		alert("您没有选择任何信息，请选择后再打印！");
		return false;
	}
	var idsArr = ids.split("|");
	if (idsArr.length > 50){alert("选择的单据数量不要超过50个！");return false;}
	window.OpenNoUrl('../../SYSN/view/comm/TemplatePreview.ashx?sort=2003&ord='+ids,'newwin77multiprint','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')
}
	
window.OpenNoUrl = function(url, name, attr) {
	//通过代理的方式，屏蔽url
	var urls = window.location.href.split("/");
	urls[urls.length-1] = url;
	window.currOpenNoUrl= urls.join("/");
	window.open(  window.sysCurrPath + "inc/datawin.asp", name, attr);
}