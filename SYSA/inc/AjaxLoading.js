$(document).ajaxStart(function (a,b,c) {
	// 打开微信聊天窗口时不显示加载效果
	var n = $("#wx-chat-wrap").size();
	if(n == 0){
		$("body").showLoading(); 
	};

}).ajaxSend(function (e, xhr, opts) {
}).ajaxError(function (e, xhr, opts) {
	$("body").hideLoading();  
}).ajaxSuccess(function (e, xhr, opts) {
	$("body").hideLoading();  
}).ajaxComplete(function (e, xhr, opts) {
	$("body").hideLoading();  
}).ajaxStop(function (){
	$("body").hideLoading();  
});
