
//显示排序
function showOrderPanel(){
	$("#orderPanel").toggle();
	$("#orderPanel").css("left",300);
	$("#orderPanel").css("top",0);
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
function changeOrder(n){
	$("#pageOrder").val(n);
	document.forms["formSearch"].submit();
}
function formSubmit(){
	$("#CurrPage").val("1");
	$("#companyName").val("");
	$("#contractName").val("");
	$("#contractNum1").val("0");
	$("#contractNum2").val("0");
	$("#intro").val("");
	$("#productName").val("");
	$("#productType").val("");
	$("#productNo").val("");
	$("#num1").val("0");
	$("#num2").val("0");
	$("#total1").val("0");
	$("#total2").val("0");
	$("#bz").val("0");
	$("#A2").val("");
	$("#productNo").val("");
	document.forms["formSearch"].submit();
}
function outputExcel(){
	if(confirm('确认导出为EXCEL文档？')){
		document.forms["formSearch"].action="../out/xls_hz.asp";
		document.forms["formSearch"].submit();
	}
}
