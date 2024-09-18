
//显示排序
function showOrderPanel(){
	$("#orderPanel").toggle();
	$("#orderPanel").css("left",300);
	$("#orderPanel").css("top",0);
}
function changeOrder(n){
	$("#pageOrder").val(n);
	document.forms["formSearch"].submit();
}
//分页跳转
function gotoPage(nPage){
	$("#CurrPage").val(nPage);
	document.forms["formSearch"].submit();
}
function changePageCount(){
	if($("#page_count")!="0"){
		document.forms["formSearch"].submit();
	}
}
function formSubmit(){
	document.forms["formSearch"].submit();
}
function outputExcel(){
	if(confirm('确认导出为EXCEL文档？')){
		exportExcel({
			debug:false,
			from:'form',
			formid:'formSearch',
			page:'../out/xls_salesProfit_2.asp'
		});
	}
}

function formulaSetting(){
	$('#settingPanel').show().dialog({}).dialog('open');
}

function saveFormula(){
	var formulaIdx = $(':radio:checked[name="formulaIdx"]').val();
	closeDialog();
	$.ajax({
		url:'?formulaIdx='+formulaIdx,
		cache:false,
		success:function(r){
			alert('公式设置成功！');
			window.location.reload();
		}
	});
}

function closeDialog(){
	$('#settingPanel').dialog('close');
}

function selectFormula(obj){
	$(obj).find(':radio').prop('checked','checked');
}