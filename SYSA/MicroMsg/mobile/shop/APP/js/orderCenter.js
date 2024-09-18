$(function(){
	wxcnfg();
	wx.ready(function (){
		finish();
	})
	
})
//点击确认收货完成
function finish(){
	$(".letPay").bind("click",function(){
		$(this).parent().parent().find(".finish").show();
	})
}
