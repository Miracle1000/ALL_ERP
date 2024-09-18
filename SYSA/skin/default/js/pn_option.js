window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
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
	}
}
//--图片自动缩小
window.__ShowImgBigToSmall=true ;

function ajaxRefreshPage(){
	try{window.DoRefresh();}catch(e){}
}
