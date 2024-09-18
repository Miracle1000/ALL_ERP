$(function(){
	wxcnfg();
	wx.ready(function (){
		
	})
})



//获取订单中心接口
function getOrderCenter(){
	$.ajax({
		type:"get",
		url:"../../OrderList.asp?__mobile2_debug=1&__msgid=refresh",
		dataType:"text",
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			doStatus(data);
			console.log(data)
		}
	});
}


