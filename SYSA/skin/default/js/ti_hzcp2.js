//--图片自动缩小
window.__ShowImgBigToSmall=true ;
window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}

function setSort(inx){
	var ids = "";
	$("input[name=sortinfo]:checked").each(function(){
		ids +=this.value;
	});
	ajax.regEvent("setSortInfo");
	ajax.addParam("ids",ids);
	ajax.exec();
	ReportSubmit();
}