$(function(){
		$("#back").bind("click",function(){
			window.history.back();
		})
		getOrder();	
})
//获取当前此次订单列表
function getOrder(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../OrderGoodsList.asp?__msgId=refresh",
		dataType:"text",
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			var dataa = data.body.source.table.rows;
			var datab = getPro(data.body.source.table.cols);
			if(data.body.source.table.cols.length != 0){
				$(".orderAll").empty();
				createCurrentGoods(dataa,datab);
			}else{
				$(".orderAll").empty().html('<img src="../img/noGoods.jpg" style="display: block;margin: 0.05rem auto;width:0.3rem;">');
			}	
		}
	});
}
//创建当前商品页面结构
function createCurrentGoods(dataa,datab){
	for(i=0;i<dataa.length;i++){
		var $goods = $('<div class=" ov order_goods orderAllGoods">'+
						 '<dl class="order_dl1">'+
						  '<dt>'+
						    '<img src="../../../../../Edit/upimages/shop/'+getImgPath(dataa[i][datab["photo"]]).middle+'" class="order_phone"/>'+
						 '</dt>'+
						  '<dd>'+
						      '<a href="###">'+dataa[i][datab["name"]]+'</a>'+
							  '<p>￥'+dataa[i][datab["price"]]+'</p>'+
						 '</dd></dl>'+
						 '<p style="text-align:right;padding-right:0.1rem">数量：<span class="order_number"><span class="oneNum">'+dataa[i][datab["num1"]]+ '</span></span><p>'+
						 '</div>');
		$(".orderAll").append($goods);
	}
	var sum = 0;
	for(i=0;i<$(".orderAllGoods").length;i++){
		var $num = parseInt($(".orderAllGoods").eq(i).find($(".oneNum")).html());
		sum += $num;
		$(".orderAllNum").html("共"+sum+"件");
	}
}
