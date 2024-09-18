var flag = false;
var pageNum = 1;
var s1 = 0;
var preDiv = 0;//0 列表  1 详情
$(function(){
		init();
		$("#top").hide();
		$("#billback").unbind().bind("click",function(){
			window.location = "../my.html";
		})
		//返回
		$(".myback").click(function(){
			var flag = $("#orderList").is(":hidden")
			if(flag){
			 $("#orderList").show();
			 $("#detailsList").hide();
			 $(".orderAllNum").show();
			}else{
				window.location = "../my.html";
				$(".orderAllNum").text("");
			}
		})
		$("#back").unbind().click(function(){
			window.location = "../my.html";
		})
		//搜索
		$(".searchTxt").unbind().bind("keydown",function(){
			if(event.keyCode==13){$(".searchBtn").click();}
		})
		$(".searchBtn").unbind().bind("click",function(){
			var txt = $(".searchTxt").val();
			if(txt){
				var id = GetQueryString("id");
				$("#loadDiv").show();
				searchData(txt,id);
			}else{
				alert("请输入关键字！");
				return;
			}
		})
		$("#exitDetail").unbind().bind("click",function(){
			$("#detailsListDiv").hide();
			$("#orderList").show();
			//清空订单详情中的相关信息
			$("#orderInfo").empty();
			$("#logisticsInfo").empty();
			$("#receiveInfo").empty();
			$("#detailsList").empty();
			$("#payInfo").empty();
			$("#timeInfo").empty();
		});
		
		$("#exitLogistics").unbind().bind("click",function(){
			$("#logisticsListDiv").hide();
			preDiv==0 ? $("#orderList").show() : $("#detailsListDiv").show();
			//清空物流详情中的相关信息
			$("#logisticInfo").empty();
		});
})
//页面初始化
function init(){
		var id = GetQueryString("id");
		$("#loadDiv").show();
		//待付款
		if(id == "NEED_PAY"){
			getData("NEED_PAY","NEED_PAY",pageNum);
			$("#orderKind").text("待付款订单");
		}
		//待发货
		else if(id == "NEED_SEND"){
			getData("NEED_SEND","NEED_SEND",pageNum);
			$("#orderKind").text("待发货订单");
		}
		//待收货
		else if(id == "NEED_RECEIVE"){
			getData("NEED_RECEIVE","NEED_RECEIVE",pageNum);
			$("#orderKind").text("待收货订单");
		}
		//获取全部订单列表
		else{
			getAllData(pageNum);
			$("#orderKind").text("全部订单")
		}
		
}
function searchData(obj,id){
	idstr = (id.toLowerCase()=="alllist" ? "" : id)
	var datas = '{datas: [{id:"searchKey",val:"'+obj+'"},{id:"openid",val:"'+localStorage.openID+'"},{id:"sort",val:"'+idstr+'"}]}';
	$.ajax({
		type:"post",
		url:"../../OrderList.asp?__msgId=refresh",
		processData:false,
		contentType:"application/zsml",
		data:datas,
		success:function(data){ 
			data = eval("("+data+")");
			if(data.body.source.table.rows.length != 0){
				$("#orderList").empty();
				createGoods(data);
				$("#loadDiv").hide();
			}else{
				$("#orderList").empty();
				$("#orderList").css({"background":"#F5F5F4"}).append($('<img src="../img/noOrder.png" style="display: block;margin: 0.5rem auto;width:2rem;">'));
				$("#loadDiv").hide();
			}
		}
	});
}
//全部的订单列表
function getAllData(pageNum){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'},{id:'pageindex',val:'"+pageNum+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../OrderList.asp?__msgId=refresh",
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data.body.source.table.rows.length != 0){
				if(pageNum==1){
					$("#orderList").empty();
				}
				createGoods(data);
				var allpage = data.body.source.table.page.pagecount;
				doScroll(allpage);
				$("#loadDiv").hide();
			}else{
				$("#orderList").empty();
				$("#orderList").css({"background":"#F5F5F4"}).append($('<img src="../img/noReOrder.png" style="display: block;margin: 0.5rem auto;width:2rem;">'));
				$("#loadDiv").hide();
			}
			flag = true;
		}
	});
}
//获取待付款  待收货  待发货
function getData(obj,btnId,pageNum){
	var datas = '{datas: [{id:"sort",val:"'+obj+'"},{id:"openid",val:"'+localStorage.openID+'"},{id:"pageindex",val:"'+pageNum+'"}]}';
	$.ajax({
		type:"post",
		url:"../../OrderList.asp?__msgId=refresh",
		processData:false,
		contentType:"application/zsml",
		data:datas,
		success:function(data){
			data = eval("("+data+")");
			if(data.body.source.table.rows.length != 0){
				if(pageNum==1){
					$("#orderList").empty();
				}
				createGoods(data,btnId);
				var allpage = data.body.source.table.page.pagecount;
				doScroll(allpage); 
				$("#loadDiv").hide();
			}else{
				$("#orderList").empty();
				$("#orderList").css({"background":"#F5F5F4"}).empty().html('<img src="../img/noReOrder.png" style="display: block;margin: 0.5rem auto;width:2rem;">');
				$("#loadDiv").hide();
			}
			flag = true;
		}
	});
}

//创建页面结构
function createGoods(obj,btnId){
	var data = obj.body.source.table.rows;
	var _data = getPro(obj.body.source.table.cols);
	var canLogistics = obj.body.source.table.layout.action;
	var goodsInfo;
	var orderType;
	for(i = 0; i < data.length; i++){
		orderType = btnId || data[i][_data["orderStatus"]];
		goodsInfo = eval(data[i][_data["goodsInfo"]]);
		var $div = $('<div class="orderAll" data-ord = "'+data[i][_data["ord"]]+'"></div>');
		var hdidStatus = orderType == "NEED_SEND"?'待发货':"";
		var hdid = $('<div style="clear:both;overflow:hidden;border-bottom:1px solid #ccc;">'+
						'<p class="hdid fl">订单编号：'+data[i][_data["htid"]]+'<p>'+
						'<p class="hdidStatus fr">'+hdidStatus+'</p>'+
					 '</div>');
		$div.append(hdid);
		var btn=null;
		if(orderType == "NEED_PAY"){
			btn =  $('<span style="padding:2px 4px;margin-top:0.03rem;" class="btn btn-small btn-danger fr" btn-id="'+orderType+'" ord="'+data[i][_data["ord"]]+'" allprice="'+data[i][_data["moneyToPay"]]+'" htid="'+data[i][_data["htid"]]+'">去付款</span>');
		}else if(orderType == "NEED_SEND"){
			btn =  $('<span class="fr" btn-id="'+orderType+'" ord="'+data[i][_data["ord"]]+'"></span>');
		}else if(orderType == "NEED_RECEIVE"){
			var bhtml = '<span style="padding:2px 4px;margin-top:0.03rem;" class="btn btn-small btn-danger fr" btn-id="'+orderType+'" ord="'+data[i][_data["ord"]]+'" allprice="'+data[i][_data["moneyToPay"]]+'" htid="'+data[i][_data["htid"]]+'">确认收货</span>'
			if(canLogistics=="_url"){
				bhtml = bhtml + '<span style="padding:2px 4px;margin-right:5px;margin-top:0.03rem;" class="btn btn-small btn-danger fr" btn-id="NEED_LOGISTICS" ord="'+data[i][_data["ord"]]+'" allprice="'+data[i][_data["moneyToPay"]]+'" htid="'+data[i][_data["htid"]]+'">查看物流</span>'
			}
			btn =  $(bhtml);
		}else if(orderType == "COMPLETED"){
			$div.addClass("orderAllOver");
		}else {
			btn =  $('<span class="fr" ><span>未知状态[' + orderType + ']</span></span>');
		}
		var $cb = $('<div style="overflow:hidden;clear:both"></div>');
		var j;
		var $price;
		var allPrice = data[i][_data["moneyToPay"]];
		var dot = window.sysConfig.moneynumber;
		//创建未支付页面
		if(goodsInfo.length == 1){
			j = 0;
			createSingle(goodsInfo[j],$div);
			$price = $('<span class="fl" style="padding-top:0.2rem;font-size:0.18rem">订单金额:￥'+FormatNumber(allPrice,2)+'</span>');
		}else{
			var price = 0;
			for( j = 0; j<goodsInfo.length && j<3 ; j++){
				createGoodsList(goodsInfo[j],$div);
				price += parseFloat(goodsInfo[j].price);
			}
			$price = $('<span class="fl" style="padding-top:0.1rem;font-size:0.18rem">订单金额:￥'+FormatNumber(allPrice,2)+'</span>');
			$div.append($('<span>... ...</span><br>'));
		}
		//按钮点击事件 去支付  确认收货  
		if (btn!=null)
		{
			btn.click(function(){
				var id = $(this).attr("btn-id");
				var ord = $(this).attr("ord");
				var htid = $(this).attr("htid");
				var pri = $(this).attr("allprice");
				//未付款
				if(id == "NEED_PAY"){
					doPay(ord,FormatNumber(pri,2),htid);
				//未收货  确认收货
				}else if(id == "NEED_RECEIVE"){
					$("#payDiv").show();
					$("#confirm").unbind().bind("click",function(){
						doConfirm(ord);
					})
					$("#cancel").click(function(){
						$("#payDiv").hide();
					})
				}else if(id=="NEED_LOGISTICS"){
					preDiv = 0 ;
					var ord = $(this).attr("ord");
					getlogisticsList(ord);
				}else {
					return;
				}
			})
		}
		$cb.append($price);
		if (btn!=null){$cb.append(btn);}
		$div.append($cb);
		$("#orderList").append($div);
	}
	//点击事件   进入商品详情order_dl1
	$(".orderAll").unbind().bind("click",function(ev){
		if(ev.target.tagName == "SPAN"){
			return
		}
		var ord = $(this).attr("data-ord");
		$("#orderList").hide();
		$("#detailsListDiv").show();
		getGoodsInfo(ord);
	})	
	//判断是否出现“回到顶部”
	var height = $("#detailsList").height();
	var screenH = window.screen.height;
	var disH = screenH-height;
	disH >= 100? $("#top").show():$("#top").hide();
	var InitOrderNo = GetQueryString("InitOrderNo");  //谭：从订单确认页面查看订单详情，该参数有值。 
	if(InitOrderNo && isNaN(InitOrderNo)==false) {
		$("#orderList").hide();
		$("#detailsListDiv").show();
		getGoodsInfo(InitOrderNo)
	}
}
//点击事件   进入物流详情
function getlogisticsList(ord){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../OrderList.asp?__msgId=getSendids&ord="+ord,
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data && data.header && data.header.status!=0) {
				alert("温馨提示6:"+data.header.message);
				return;
			}	
			$("#orderList").hide();
			$("#logisticsListDiv").show();
			var ids = data.body.message.text;
			var arrIds = ids.split(",");
			for(var i = 0 ; i<arrIds.length ; i++){
				getlogisticsInfo(arrIds[i]);
			}
		},error:function(){
			
		}
	});
}
//点击事件   进入物流详情
function getlogisticsInfo(ord){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../SendLogistics.asp?ord="+ord,
		processData:false,
		contentType: "application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data && data.header && data.header.status!=0) {
				alert(data.header.message);
				return;
			}
			var logisticsInfo = data.body.bill.groups[0].fields[0].source.table.rows;
			if (logisticsInfo.length>0){
				for(var j = 0; j<logisticsInfo.length;j++){
					var cols = getPro(data.body.bill.groups[0].fields[0].source.table.cols);
					createLogisticsList(logisticsInfo[j], cols , j , 1); 
				}
			}else{
				createLogisticsList(null, null , -1 , 1); 
			}
		}
	});
	
}
//物流列表页面
function createLogisticsList(obj, data , index ,showType){
	if(showType==1){
		if(index>=0){
			var styleStr = "text-align:left;font-size:13px;color:#cccccc;";
			var imgcss = "width:25%;padding-top:10px;line-height:20px;"
			var imgUrl = "gray_point.png";
			var styleStr1 ="text-align:left;font-size:12px;color:#cccccc;";
			if(index==0){	
				var $logistics_ProImg = $('<div class=" ov order_goods"  style="margin-bottom:10px;">'+
					  '<dl class="order_dl1" style="padding-top:0;padding-bottom:0">'+
					    '<dt style="height:100%;padding-top:8px;">'+
						    '<img  src="../../../../../Edit/upimages/shop/'+obj[data["photo"]]+'" class="order_phone"/>'+
						 '</dt>'+
						  '<dd style="line-height:25px;padding-left:0.2rem;padding-top:5px;">'+
							'<div style="clear:both;overflow:hidden;">'+
								'<span style="font-size:15px;color:back">物流状态&nbsp;</span><span style="color:#25ae5f;font-size:15px;">'+obj[data["wlstatus"]]+'</span>'+
							'</div>'+	
							'<div style="clear:both;overflow:hidden;">'+
								'<span style="font-size:13px;color:#999999">  承运公司：</span><span style="text-align:left;font-size:13px;color:#999999">'+obj[data["logisticName"]]+'</span>'+
							'</div>'+								
							'<div style="overflow:hidden;clear:both;">'+
								'<span style="font-size:13px;color:#999999">  运单编号：</span><span style="text-align:left;font-size:13px;color:#999999">'+obj[data["WaybillNumber"]] +'</span>'+				
							'</div>'+
					     '</dd></dl>'+   
					'</div>');
				$("#logisticInfo").append($logistics_ProImg);
				styleStr = "color:#25ae5f;font-size:14px;line-height:22px;";
				imgcss = "width:35%;padding-top:10px;";
				imgUrl = "green_point.png";
				styleStr1 = "color:#25ae5f;font-size:13px;line-height:22px;";
			}
			if (obj[data["AcceptStation"]].length>0 ){
				var $logistics_Proc = $('<div class=" ov order_goods" >'+
					  '<dl class="order_dl1" style="padding-top:0px;padding-bottom:0px;position:relative;">'+
						  '<div style="position:absolute;margin-left:15px;width:15%;background:url(../img/'+ imgUrl +') no-repeat; background-size:30%;height:100%;"></div>'+
						  '<dd style="height:100%;padding-top:6px;margin-left:15%;">'+
							'<div style="clear:both;overflow:hidden;">'+
								'<span style="'+styleStr+'">'+obj[data["AcceptStation"]]+'</span>'+
							'</div>'+	
							'<div style="clear:both;overflow:hidden;border-bottom:1px solid #eeeeee;padding-bottom:6px;">'+
								'<span style="'+styleStr1+'">'+obj[data["AcceptTime"]]+'</span>'+
							'</div>'+
					     '</dd></dl>'+   
					'</div>');
				$("#logisticInfo").append($logistics_Proc);
			}
			
		}else{
			var $logistics = $('<div class=" ov order_goods orderAllGoods"  style="height:30px;text-align:center;padding-top:5px;">暂无物流信息！</div>');
			$("#logisticInfo").append($logistics);
		}
	}else{
		var $logistics = $('<div class=" ov order_goods orderAllGoods logisticsInfo" data-ord="'+obj[data["ord"]]+'" '+ (index==0 || index==-1?' style="border-top:1px solid #ccc" ' : '' )+'>'+
							'<dl class="order_dl1" style="padding:0.07rem">'+
								'<dt style="height:50%;width:15%;font-weight:400;color:#646869;font-size:12px;padding-top:4px">'+
								'<img  src="../img/wuliu.png" class="order_phone" style="width:50%"/><br>物流'+(index==-1?"":index+1) +
								'</dt>'+
								'<dd style="width:75%;line-height:30px;">'+ 
								'<div style="float:left;width:100%;color:#25ae5f;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">'+(obj[data["AcceptStation"]].length >0 ? obj[data["AcceptStation"]] + "": "暂无物流信息！" ) + '</div>'+
								'<span style="size:5px;color:#646869;"> '+obj[data["AcceptTime"]] + '</span>' + 
								'</dd>'+
								'<dt style="width:10%;height:50%;padding-top:0.2rem;text-align:right;">'+
								'<img  src="../img/rtMore.png" class="order_phone" style="height:50%;width:25%"/>'+
								'</dt>'+
							'</dd></dl>'+   
						'</div>');
		$("#logisticsInfo").append($logistics);
			//点击事件   进入商品详情order_dl1
		$(".logisticsInfo").unbind().bind("click",function(ev){
			preDiv=1;
			var ord = $(this).attr("data-ord");
			$("#detailsListDiv").hide();
			$("#logisticsListDiv").show();
			getlogisticsInfo(ord);
		})	
	}
}
//点击事件   进入订单详情order_dl1
var pageN = 0;
function getGoodsInfo(ord) {
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}"; 
	$.ajax({
		type:"post",
		data:datas,
		url:"../../OrderDetail.asp?ord="+ord,
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data && data.header && data.header.status!=0) {
				alert(data.header.message);
				return;
			}
			var goodsInfo = data.body.bill.groups[5].fields[0].source.table.rows;
			var pagesize = data.body.bill.groups[5].fields[0].source.table.page.pagesize;
			var allpage = data.body.bill.groups[5].fields[0].source.table.page.pagecount;
			var currentPage  = data.body.bill.groups[5].fields[0].source.table.page.pageindex;
			var recordcount  = data.body.bill.groups[5].fields[0].source.table.page.recordcount;
			if(recordcount <= 3){
				$("#loadMore").hide();
			}else{
				$("#loadMore").show();
			}
			//payTime  sendTime(收货时间)  date7
			var orderInfo = getAttr(data.body.bill.groups[0].fields);
			var receiveInfo = getAttr(data.body.bill.groups[1].fields);
			var payKind = getAttr(data.body.bill.groups[2].fields);
			var moneyInfo = getAttr(data.body.bill.groups[4].fields);
			
			var logisticsInfo = data.body.bill.groups[6].fields[0].source.table.rows;

			$("#orderInfo").empty().append('<div style="background:#fff;padding:5px;clear:both;overflow:hidden">'+
								    	'<span style="float:left;">订单号：'+orderInfo.htid+'</span>'+
								    	'<span style="float:right;padding-right:10px">'+payKind.payKind+'</span>'+
								     '</div>');
			//物流信息
			$("#logisticsInfo").empty();
			if(logisticsInfo.length>0){
				for(var j = 0; j<logisticsInfo.length;j++){
					var cols = getPro(data.body.bill.groups[6].fields[0].source.table.cols);
					createLogisticsList(logisticsInfo[j], cols , (logisticsInfo.length ==1? -1 : j ), 0); 
				}
				$("#logisticsInfo").show();
			}
			//收货人信息
			var receiverInfo = $('<ul class="orderDetails">'+
										'<li><span class="receiver"><i class="userI"></i>'+receiveInfo.receiver+' </span><span style="photoImg"><i class="phoneI"></i>'+receiveInfo.mobile+'</span></li>'+
										'<li  style="text-align: left;color:#646869">'+receiveInfo.address+'</li>'+
								 '</ul>');
			$("#receiveInfo").empty().append(receiverInfo);
			//创建商品列表
			$("#detailsList").empty();
			for(var j = 0; j < 3 && j<goodsInfo.length;j++){
				var cols = getPro(data.body.bill.groups[5].fields[0].source.table.cols);
				createdetailsList(goodsInfo[j],cols); 
			}
			//点击加载更多		
			$("#loadMore").unbind().bind("click",function(){
				if(pageN++ == 0){
					for(var k = 3; k < 10 && k < goodsInfo.length;k++){
						var cols = getPro(data.body.bill.groups[5].fields[0].source.table.cols);
						createdetailsList(goodsInfo[k],cols); 
					}
					if(goodsInfo.length >= recordcount){
						$("#loadMore").hide();
					}else{
						$("#loadMore").show();
					}
				}else{					
					getMore(pageN,ord,allpage);
					pageN++;
				}
			})
			//商品订单付款信息
			$("#payInfo").empty();
			var $orderInfo = $('<ul class="orderDetails" style="clear:both;overflow:hidden">'+
								'<li><span class="msgleft" >付款方式： </span><span class="msgRight" s>'+payKind.payKind+'</span></li>'+
								'<li><span class="msgleft" >商品金额：</span><span class="msgRight" >￥ '+FormatNumber(moneyInfo.moneyBeforeTax,2)+'</span></li>'+
								'<li><span class="msgleft" >商品税额： </span><span  class="msgRight" >￥ '+FormatNumber(moneyInfo.taxValue,2)+'</span></li>'+
								'<li><span class="msgleft" >订单金额： </span><span  class="msgRight" >￥ '+FormatNumber(moneyInfo.money1,2)+'(运费:'+FormatNumber(moneyInfo.extras,2)+')</span></li>'+
							  '</ul>');		
			//发票信息  如果存在则创建
			if(data.body.bill.groups[3].fields[0]){
				var taxData = getPro(data.body.bill.groups[3].fields[0].source.table.cols);
				var taxInfo = data.body.bill.groups[3].fields[0].source.table.rows;
				$.each(taxInfo, function(j) {  
					 var taxLi = $('<li taxId = "'+taxInfo[j][taxData["id"]]+'"><span class="msgleft">发票信息： </span><span class="msgRight">'+taxInfo[j][taxData["name"]]+' >></span></li>');
					 taxLi.unbind().bind("click",function(){
						getTaxData($(this).attr("taxId"));
					})
					$orderInfo.append(taxLi);                                                        
				});
			}
			$("#payInfo").append($orderInfo);
			//订单时间问题
			$("#timeInfo").empty();
			var timeInfo = $('<ul class="orderDetails">'+
							  '<li style="text-align: right;">下单时间：'+orderInfo.date7+'</li>'+	
						    '</ul>');		
			//付款时间
			if(orderInfo.payTime){
				timeInfo.append('<li style="text-align: right;">付款时间：'+orderInfo.payTime+'</li>');
			}
			//发货时间
			if(orderInfo.sendTime){
				timeInfo.append('<li style="text-align: right;">发货时间：'+orderInfo.sendTime+'</li>');
			}
			//确认收货时间
			if(orderInfo.receiveTime){
				timeInfo.append('<li style="text-align: right;">确认收货时间：'+orderInfo.receiveTime+'</li>');
			}
			$("#timeInfo").append(timeInfo);
			getAllNum();
		}
	});
}
//分页获取更多商品
function getMore(pageNum,ord,allpage){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'},{id:'pageindex',val:'"+pageNum+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../orderGoodsList.asp?__msgId=refresh&ord="+ord,
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			var goodsInfo = data.body.source.table.rows;
			$.each(goodsInfo, function(j) { 
				var cols = getPro(data.body.source.table.cols);
				createdetailsList(goodsInfo[j],cols);  
			});
			if(allpage == pageNum){
				$("#loadMore").hide();
			}else{
				$("#loadMore").show();
			}
		}
	});
}
//获取发票信息
function getTaxData(id){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../OrderInvoiceInfo.asp?ord="+id,
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			$("#taxDiv").show();
			$("#taxDiv").delegate("#exit","click",function(){
				$("#taxDiv").hide();
			})
			var length = data.body.bill.groups[0].fields.length;
			var taxData = [];
			var taxTitles = [];
			var fields = data.body.bill.groups[0].fields;
			$.each(fields, function(k) {    
				taxTitles.push(fields[k].caption);
				taxData.push(fields[k].text);                                                       
			});
			var $li;
			$("#taxUl").empty();
			for(var j = 0;j < length; j++){   
				if(taxData[j] == undefined) taxData[j] = "";
				 $li = $('<li><span style="text-align: right;display:inline-block;width:30%">'+taxTitles[j]+'： </span><span style="vertical-align: top;text-align: left;display:inline-block;width:69%">'+taxData[j]+'</li>');                                        
				 $("#taxUl").append($li);
			};
		}
	});
}
//商品列表页面
function createGoodsList(obj,$div){
	var $goods = $('<div style="display:inline-block;height:0.8rem;width:0.8rem;margin:0.1rem 0.1rem 0 0;vertical-align:middle;'+
	 				'background:url(../../../../../Edit/upimages/shop/'+obj.photo+') no-repeat center center;background-size: 100%;" ></div>');
	$div.append($goods);
}

function createSingle(obj,$div){
	console.log(obj);
	var $goods = $('<dl class="order_dl1">'+
					  '<dt>'+
					    '<img src="../../../../../Edit/upimages/shop/'+obj.photo+'" class="order_phone"/>'+
					 '</dt>'+
					  '<dd>'+
				  		'<div style="clear:both;overflow:hidden">'+
							'<a class="orderGoodsInfo" href="../detail.html?id='+obj.id+'">'+obj.name+'</a>'+
							'<p style="text-align:left;font-size:12px;color:#646869">'+obj.goodsInfo+'</p>'+
						'</div>'+
					'</dd></dl>');
	$div.append($goods);
}
//商品详细列表页面
function createdetailsList(obj,data){
	var $goods = $('<div class=" ov order_goods orderAllGoods" >'+
					  '<dl class="order_dl1">'+
					    '<dt style="height:100%">'+
						    '<img  src="../../../../../Edit/upimages/shop/'+obj[data["photo"]]+'" class="order_phone"/>'+
						 '</dt>'+
						  '<dd>'+
							'<div style="clear:both;overflow:hidden;">'+
								'<a class="orderGoodsInfo2" href="../detail.html?id='+obj[data["id"]]+'">'+obj[data["name"]]+'</a>'+
								'<p style="text-align:left;font-size:12px;color:#646869">'+obj[data["goodsInfo"]]+'</p>'+
							'</div>'+								
							'<div style="overflow:hidden;clear:both;">'+
								'<p class="ordergoodsP">￥'+FormatNumber(obj[data["price1"]],2)+'</p>'+
								'<p class="fr" style="width:40%;text-align:right">x'+obj[data["num1"]]+'</p>'+							
							'</div>'+
					     '</dd></dl>'+   
					'</div>');
	$("#detailsList").append($goods);
}
//'<div style="clear:both;overflow:hidden">'+
//	'<p class="orderGoodsInfo2">'+dataa[i][datab["name"]]+'</p>'+
//	'<p style="text-align:left;font-size:12px;color:#646869">'+dataa[i][datab["goodsInfo"]]+'</p>'+
//'</div>'+
//'<div style="overflow:hidden;clear:both;">'+
//	'<p class="ordergoodsP">￥'+FormatNumber(dataa[i][datab["price"]],dot)+'</p>'+
//	'<p class="fr" style="width:10%;text-align:right">x'+dataa[i][datab["num1"]]+'</p>'+							
//'</div>'+

function getAllNum(){
	var num = 0;
	for(i = 0;i < $(".orderAllGoods").length; i++){
		num += parseInt($(".orderAllGoods").eq(i).find($(".oneNum")).html());
	}
}
//确认收货
function doConfirm(ord){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../OrderList.asp?__msgId=receiveConfirm&ord="+ord,
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			$("#payDiv").hide();
			//更新当前页面
			init();
		}
	});
}
//订单付款
function doPay(ord,allPrice,htid){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../OrderList.asp?__msgId=getPayBack&ord="+ord,
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data.body.message.text == "success"){
				var sheetno = data.body.message.data;
				var id = sheetno.split("O")[1]*1
				window.location = "../../APP/html/pay.html?paysheetno=" + sheetno + "&id="+id+"&allPrice="+allPrice+"&htid="+htid+"&htord="+ord;
			}else{
				alert(data.body.message.data);
			}
		},error:function(){
			
		}
	});
}
function doScroll(allpage){
	var direction = 'up';
	window.onscroll = function(){
		var id = GetQueryString("id")
		if(pageNum >= allpage) return;
		direction = s1 - document.body.scrollTop < 0 ? 'up' : 'dowm';
		s1 = document.body.scrollTop;
		flag = true;
		if(direction != "up"){
			return false;
		}
		if(flag){
			var scrollHeight = document.documentElement.scrollHeight;
			var scrollTop = document.body.scrollTop + window.innerHeight;
			if(scrollHeight-scrollTop <= 0){
				flag = false;
			    pageNum++;
			   if(id == "NEED_RECEIVE" || id == "NEED_SEND" || id == "NEED_PAY"){
			    	getData(id,id,pageNum);
			    }else{
			    	getAllData(pageNum);
			    }
			      //获取总页码
			    if(pageNum === allpage){
			        $(".goodsList").append("<p style='text-align:center;font-size:12px;padding:5px;color:#F15352'>亲，已经到底部啦</p>")
			    }
			}else{
				
			}
		}
		
	}
}