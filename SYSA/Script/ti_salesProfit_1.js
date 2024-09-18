
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
	if (!confirm('确认导出为EXCEL文档？')) return;
	document.forms["formSearch"].action="../out/xls_salesProfit_1.asp";
	exportExcel({from:'form',formid:'formSearch'});
	document.forms["formSearch"].action="salesProfit_1.asp";
	document.forms["formSearch"].target="";
}
