$(function(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	var allPrice = GetQueryString("allPrice");
	var htid = GetQueryString("htid");
	$("#orderId").text( GetQueryString("paysheetno") );
	$("#orderPrice").text(FormatNumber(allPrice,2));
	bindPayEvent();
})
//支付按钮事件绑定
function bindPayEvent(){
	var id = GetQueryString("id");
	var htord = GetQueryString("htord");
    var sheetno = GetQueryString("paysheetno");
	$("#pay").one("click",function(){
		setTimeout(function(){
			wxPay(id,sheetno,function(){
				location="paySuccess.html?htord="+htord;
			}
		)},100);
	})
}
function wxPay(orderId,sheetno,callBack){
	 if(window.onwxPaying==true) { return false; }  //正在调用
	 window.onwxPaying=true;
	 if(initWeiXinApiConfig()==false) { bindPayEvent(); window.onwxPaying = false; return false; }  //调用之前先注册接口
	 $.ajax({
		url:'../../PayTypeSelect.asp?__msgId=getWXPayParams',
		dataType:"text",
		type:"post",
		contentType:"application/zsml",
		data:'{datas:[{id:"orderId",val:"'+orderId+'"},{id:"openid",val:"' + localStorage.openID + '"}, {id:"sheetno",val:"' + sheetno + '"}]}',
		success:function(r){
			var params;
			var msg =  null;
			try{
				msg = eval('(' + r + ')');
			}catch(e){
				alert("A.支付失败，获取支付参数失败！\n\n" + r)	
				bindPayEvent();
				window.onwxPaying = false;
				return;
			}
			if(!msg || (!msg.body && !msg.header)){
				alert("B.支付失败，获取支付参数失败！\n\n" + r)	
				bindPayEvent();
				window.onwxPaying = false;
				return;
			}
			if(msg.body ) {
				msg = msg.body.message
			}else{
				alert("C.支付失败，获取支付参数失败！\n\n" + msg.header.message)	
				bindPayEvent();
				window.onwxPaying = false;
				return;
			}
			if (msg.text=="success"){
				params = eval('(' + msg.data + ')');
			}else{
				alert("D.支付失败，获取支付参数失败！\n\n" + msg.data)
				bindPayEvent();
				window.onwxPaying = false;
				return;
			}

			WeixinJSBridge.invoke(
				'getBrandWCPayRequest',params,
				function(res){   
					if(res.err_msg == "get_brand_wcpay_request:ok" ) {
						//todo: 显示支付成功页面，订单信息等
						if(callBack){
							callBack.apply(this,[orderId]);
							window.onwxPaying = false;
							return;
						}
					} 
					if(res.err_msg == "get_brand_wcpay_request:cancel" ) {
						window.onwxPaying = false; //支付取消
					}
					else {
						alert('支付失败。\n\n信息：' + res.err_msg + '\n\n描述：' + res.err_desc) //.err_msg);
						window.onwxPaying = false;
					}
					bindPayEvent();
				}
			);
		},
		error: function(rep) {
			alert('与服务器通信发生错误,详细信息：' + rep.responseText);
			bindPayEvent();
			window.onwxPaying = false;
		}
	});
}