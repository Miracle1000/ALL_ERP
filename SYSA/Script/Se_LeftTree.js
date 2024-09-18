
$(document).ready(function(e) {
	SetHeight();
	SetWidth();
	$(window).resize(function(e) {
		SetHeight();
	})
	$("body").click(function(e){
		SetWidth();
	}); 
});
function SetHeight(){
	var bh = $("body").height();
	var th = $("#topFrame").height();
	if (bh > th){
		$("#menu_mainFrame").height(bh - th);
	}else{
		$("#menu_mainFrame").height(0);
	}
}
function SetWidth(){
	var w = $("#tvw_KnowledgeTree").width();
	$("#bodyFrame").width(w+100);
	//$("#tvw_KnowledgeTree").width(w+50);
}
window.__on_afterPageStatus = function(){//--翻页条回调函数
	SetWidth();
};
