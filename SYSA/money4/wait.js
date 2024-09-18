var flag = false;
var pageNum = 1;
var s1 = 0;
var preDiv = 0;//0 鍒楄〃  1 璇︽儏
$(function(){
		init();
		$("#top").hide();
		$("#billback").unbind().bind("click",function(){
			window.location = "../my.html";
		})
		//杩斿洖
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
		//鎼滅储
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
				alert("璇疯緭鍏ュ叧閿瓧锛?);
				return;
			}
		})
		$("#exitDetail").unbind().bind("click",function(){
			$("#detailsListDiv").hide();
			$("#orderList").show();
			//娓呯┖璁㈠崟璇︽儏涓殑鐩稿叧淇℃伅
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
			//娓呯┖鐗╂祦璇︽儏涓殑鐩稿叧淇℃伅
			$("#logisticInfo").empty();
		});
})
//椤甸潰鍒濆鍖?
function init(){
		var id = GetQueryString("id");
		$("#loadDiv").show();
		//寰呬粯娆?
		if(id == "NEED_PAY"){
			getData("NEED_PAY","NEED_PAY",pageNum);
			$("#orderKind").text("寰呬粯娆捐鍗?);
		}
		//寰呭彂璐?
		else if(id == "NEED_SEND"){
			getData("NEED_SEND","NEED_SEND",pageNum);
			$("#orderKind").text("寰呭彂璐ц鍗?);
		}
		//寰呮敹璐?
		else if(id == "NEED_RECEIVE"){
			getData("NEED_RECEIVE","NEED_RECEIVE",pageNum);
			$("#orderKind").text("寰呮敹璐ц鍗?);
		}
		//鑾峰彇鍏ㄩ儴璁㈠崟鍒楄〃
		else{
			getAllData(pageNum);
			$("#orderKind").text("鍏ㄩ儴璁㈠崟")
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
//鍏ㄩ儴鐨勮鍗曞垪琛?
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
//鑾峰彇寰呬粯娆? 寰呮敹璐? 寰呭彂璐?
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

//鍒涘缓椤甸潰缁撴瀯
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
		var hdidStatus = orderType == "NEED_SEND"?'寰呭彂璐?:"";
		var hdid = $('<div style="clear:both;overflow:hidden;border-bottom:1px solid #ccc;">'+
						'<p class="hdid fl">璁㈠崟缂栧彿锛?+data[i][_data["htid"]]+'<p>'+
						'<p class="hdidStatus fr">'+hdidStatus+'</p>'+
					 '</div>');
		$div.append(hdid);
		var btn=null;
		if(orderType == "NEED_PAY"){
			btn =  $('<span style="padding:2px 4px;margin-top:0.03rem;" class="btn btn-small btn-danger fr" btn-id="'+orderType+'" ord="'+data[i][_data["ord"]]+'" allprice="'+data[i][_data["moneyToPay"]]+'" htid="'+data[i][_data["htid"]]+'">鍘讳粯娆?/span>');
		}else if(orderType == "NEED_SEND"){
			btn =  $('<span class="fr" btn-id="'+orderType+'" ord="'+data[i][_data["ord"]]+'"></span>');
		}else if(orderType == "NEED_RECEIVE"){
			var bhtml = '<span style="padding:2px 4px;margin-top:0.03rem;" class="btn btn-small btn-danger fr" btn-id="'+orderType+'" ord="'+data[i][_data["ord"]]+'" allprice="'+data[i][_data["moneyToPay"]]+'" htid="'+data[i][_data["htid"]]+'">纭鏀惰揣</span>'
			if(canLogistics=="_url"){
				bhtml = bhtml + '<span style="padding:2px 4px;margin-right:5px;margin-top:0.03rem;" class="btn btn-small btn-danger fr" btn-id="NEED_LOGISTICS" ord="'+data[i][_data["ord"]]+'" allprice="'+data[i][_data["moneyToPay"]]+'" htid="'+data[i][_data["htid"]]+'">鏌ョ湅鐗╂祦</span>'
			}
			btn =  $(bhtml);
		}else if(orderType == "COMPLETED"){
			$div.addClass("orderAllOver");
		}else {
			btn =  $('<span class="fr" ><span>鏈煡鐘舵€乕' + orderType + ']</span></span>');
		}
		var $cb = $('<div style="overflow:hidden;clear:both"></div>');
		var j;
		var $price;
		var allPrice = data[i][_data["moneyToPay"]];
		var dot = window.sysConfig.moneynumber;
		//鍒涘缓鏈敮浠橀〉闈?
		if(goodsInfo.length == 1){
			j = 0;
			createSingle(goodsInfo[j],$div);
			$price = $('<span class="fl" style="padding-top:0.2rem;font-size:0.18rem">璁㈠崟閲戦:锟?+FormatNumber(allPrice,2)+'</span>');
		}else{
			var price = 0;
			for( j = 0; j<goodsInfo.length && j<3 ; j++){
				createGoodsList(goodsInfo[j],$div);
				price += parseFloat(goodsInfo[j].price);
			}
			$price = $('<span class="fl" style="padding-top:0.1rem;font-size:0.18rem">璁㈠崟閲戦:锟?+FormatNumber(allPrice,2)+'</span>');
			$div.append($('<span>... ...</span><br>'));
		}
		//鎸夐挳鐐瑰嚮浜嬩欢 鍘绘敮浠? 纭鏀惰揣  
		if (btn!=null)
		{
			btn.click(function(){
				var id = $(this).attr("btn-id");
				var ord = $(this).attr("ord");
				var htid = $(this).attr("htid");
				var pri = $(this).attr("allprice");
				//鏈粯娆?
				if(id == "NEED_PAY"){
					doPay(ord,FormatNumber(pri,2),htid);
				//鏈敹璐? 纭鏀惰揣
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
	//鐐瑰嚮浜嬩欢   杩涘叆鍟嗗搧璇︽儏order_dl1
	$(".orderAll").unbind().bind("click",function(ev){
		if(ev.target.tagName == "SPAN"){
			return
		}
		var ord = $(this).attr("data-ord");
		$("#orderList").hide();
		$("#detailsListDiv").show();
		getGoodsInfo(ord);
	})	
	//鍒ゆ柇鏄惁鍑虹幇鈥滃洖鍒伴《閮ㄢ€?
	var height = $("#detailsList").height();
	var screenH = window.screen.height;
	var disH = screenH-height;
	disH >= 100? $("#top").show():$("#top").hide();
	var InitOrderNo = GetQueryString("InitOrderNo");  //璋細浠庤鍗曠‘璁ら〉闈㈡煡鐪嬭鍗曡鎯咃紝璇ュ弬鏁版湁鍊笺€?
	if(InitOrderNo && isNaN(InitOrderNo)==false) {
		$("#orderList").hide();
		$("#detailsListDiv").show();
		getGoodsInfo(InitOrderNo)
	}
}
//鐐瑰嚮浜嬩欢   杩涘叆鐗╂祦璇︽儏
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
				alert("娓╅Θ鎻愮ず6:"+data.header.message);
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
//鐐瑰嚮浜嬩欢   杩涘叆鐗╂祦璇︽儏
function getlogisticsInfo(ord){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../SendLogistics.asp?ord="+ord,
		processData:false,
		contentType:"application/zsml",
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
//鐗╂祦鍒楄〃椤甸潰
function createLogisticsList(obj, data , index ,showType){
	if(showType==1){
		if(index>=0){
			var styleStr = "text-align:left;font-size:10px;color:#cccccc";
			var imgcss = "width:25%;padding-top:10px;"
			var imgUrl = "gray_point.png";
			if(index==0){	
				var $logistics_ProImg = $('<div class=" ov order_goods"  style="margin-bottom:10px;">'+
					  '<dl class="order_dl1">'+
					    '<dt style="height:100%">'+
						    '<img  src="../../../../../Edit/upimages/shop/'+obj[data["photo"]]+'" class="order_phone"/>'+
						 '</dt>'+
						  '<dd style="line-height:25px;padding-left:0.2rem;padding-top:6px;">'+
							'<div style="clear:both;overflow:hidden;">'+
								'<span>鐗╂祦鐘舵€侊細  </span><span style="color:#99cc00;font-weight:bold;">'+obj[data["wlstatus"]]+'</span>'+
							'</div>'+	
							'<div style="clear:both;overflow:hidden;">'+
								'<span>鎵胯繍鍏徃锛? </span><span style="text-align:left;font-size:12px;color:#646869">'+obj[data["logisticName"]]+'</span>'+
							'</div>'+								
							'<div style="overflow:hidden;clear:both;">'+
								'<span>杩愬崟缂栧彿锛? </span><span>'+obj[data["WaybillNumber"]] +'</span>'+				
							'</div>'+
					     '</dd></dl>'+   
					'</div>');
				$("#logisticInfo").append($logistics_ProImg);
				styleStr = "color:#99cc00;font-weight:bold;";
				imgcss = "width:35%;padding-top:10px;";
				imgUrl = "green_point.png";
			}
			if (obj[data["AcceptStation"]].length>0 ){
				var $logistics_Proc = $('<div class=" ov order_goods" >'+
					  '<dl class="order_dl1" style="padding-top:0px;padding-bottom:0px;position:relative;">'+
						'<div style="width:1px;background-color:#cccccc;height:100%;position:absolute;left:0.43rem;"></div>'+
					    '<dt style="width:15%;height:auto;">'+
						    '<img  src="../../../../../images/'+ imgUrl +'" class="order_phone" style="'+imgcss+'"/>'+
						 '</dt>'+
						  '<dd style="height:100%;line-height:25px;padding-left:0.2rem;padding-top:6px;">'+
							'<div style="clear:both;overflow:hidden;">'+
								'<span style="'+styleStr+'">'+obj[data["AcceptStation"]]+'</span>'+
							'</div>'+	
							'<div style="clear:both;overflow:hidden;border-bottom:1px solid #eeeeee;">'+
								'<span style="'+styleStr+'">'+obj[data["AcceptTime"]]+'</span>'+
							'</div>'+
					     '</dd></dl>'+   
					'</div>');
				$("#logisticInfo").append($logistics_Proc);
			}
			
		}else{
			var $logistics = $('<div class=" ov order_goods orderAllGoods"  style="height:30px;text-align:center;padding-top:5px;">鏆傛棤鐗╂祦淇℃伅锛?/div>');
			$("#logisticInfo").append($logistics);
		}
	}else{
		var $logistics = $('<div class=" ov order_goods orderAllGoods logisticsInfo" data-ord="'+obj[data["ord"]]+'">'+
							  	'<dl class="order_dl1">'+
							    	'<dt style="height:50%;width:20%;font-weight:100;">'+
								    '<img  src="../img/wait3.png" class="order_phone" style="width:50%"/><br>鐗╂祦'+(index==-1?"":index+1) +
								 	'</dt>'+
									'<dd style="width:65%;color:#99cc00;font-weight:bold;line-height:25px;">'+ 
									(obj[data["AcceptStation"]].length >0 ? obj[data["AcceptStation"]] + "<br>": "鏆傛棤鐗╂祦淇℃伅锛? ) +
									obj[data["AcceptTime"]]+
									'</dd>'+
									'<dt style="height:50%;padding-top:3px;text-align:right;width:15%;">'+
								    '<img  src="../img/rtMore.png" class="order_phone" style="height:50%;width:15%"/>'+
								 	'</dt>'+
							    '</dd></dl>'+   
							'</div>');
		$("#logisticsInfo").append($logistics);
			//鐐瑰嚮浜嬩欢   杩涘叆鍟嗗搧璇︽儏order_dl1
		$(".logisticsInfo").unbind().bind("click",function(ev){
			preDiv=1;
			var ord = $(this).attr("data-ord");
			$("#detailsListDiv").hide();
			$("#logisticsListDiv").show();
			getlogisticsInfo(ord);
		})	
	}
}
//鐐瑰嚮浜嬩欢   杩涘叆璁㈠崟璇︽儏order_dl1
var pageN = 0;
function getGoodsInfo(ord){
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
			//payTime  sendTime(鏀惰揣鏃堕棿)  date7
			var orderInfo = getAttr(data.body.bill.groups[0].fields);
			var receiveInfo = getAttr(data.body.bill.groups[1].fields);
			var payKind = getAttr(data.body.bill.groups[2].fields);
			var moneyInfo = getAttr(data.body.bill.groups[4].fields);
			
			var logisticsInfo = data.body.bill.groups[6].fields[0].source.table.rows;

			$("#orderInfo").empty().append('<div style="background:#fff;padding:10px;clear:both;overflow:hidden">'+
								    	'<span style="float:left;">璁㈠崟鍗曞彿锛?+orderInfo.htid+'</span>'+
								    	'<span style="float:right;padding-right:10px">'+payKind.payKind+'</span>'+
								     '</div>');
			//鐗╂祦淇℃伅
			$("#logisticsInfo").empty();
			if(logisticsInfo.length>0){
				for(var j = 0; j<logisticsInfo.length;j++){
					var cols = getPro(data.body.bill.groups[6].fields[0].source.table.cols);
					createLogisticsList(logisticsInfo[j], cols , (logisticsInfo.length ==1? -1 : j ), 0); 
				}
				$("#logisticsInfo").show();
			}
			//鏀惰揣浜轰俊鎭?
			var receiverInfo = $('<ul class="orderDetails">'+
										'<li><span class="receiver"><i class="userI"></i>'+receiveInfo.receiver+' </span><span style="photoImg"><i class="phoneI"></i>'+receiveInfo.mobile+'</span></li>'+
										'<li  style="text-align: left;color:#646869">'+receiveInfo.address+'</li>'+
								 '</ul>');
			$("#receiveInfo").empty().append(receiverInfo);
			//鍒涘缓鍟嗗搧鍒楄〃
			$("#detailsList").empty();
			for(var j = 0; j < 3 && j<goodsInfo.length;j++){
				var cols = getPro(data.body.bill.groups[5].fields[0].source.table.cols);
				createdetailsList(goodsInfo[j],cols); 
			}
			//鐐瑰嚮鍔犺浇鏇村		
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
			//鍟嗗搧璁㈠崟浠樻淇℃伅
			$("#payInfo").empty();
			var $orderInfo = $('<ul class="orderDetails" style="clear:both;overflow:hidden">'+
								'<li><span class="msgleft" >浠樻鏂瑰紡锛?</span><span class="msgRight" s>'+payKind.payKind+'</span></li>'+
								'<li><span class="msgleft" >鍟嗗搧閲戦锛?/span><span class="msgRight" >锟?'+FormatNumber(moneyInfo.moneyBeforeTax,2)+'</span></li>'+
								'<li><span class="msgleft" >鍟嗗搧绋庨锛?</span><span  class="msgRight" >锟?'+FormatNumber(moneyInfo.taxValue,2)+'</span></li>'+
								'<li><span class="msgleft" >璁㈠崟閲戦锛?</span><span  class="msgRight" >锟?'+FormatNumber(moneyInfo.money1,2)+'(杩愯垂:'+FormatNumber(moneyInfo.extras,2)+')</span></li>'+
							  '</ul>');		
			//鍙戠エ淇℃伅  濡傛灉瀛樺湪鍒欏垱寤?
			if(data.body.bill.groups[3].fields[0]){
				var taxData = getPro(data.body.bill.groups[3].fields[0].source.table.cols);
				var taxInfo = data.body.bill.groups[3].fields[0].source.table.rows;
				$.each(taxInfo, function(j) {  
					 var taxLi = $('<li taxId = "'+taxInfo[j][taxData["id"]]+'"><span class="msgleft">鍙戠エ淇℃伅锛?</span><span class="msgRight">'+taxInfo[j][taxData["name"]]+' >></span></li>');
					 taxLi.unbind().bind("click",function(){
						getTaxData($(this).attr("taxId"));
					})
					$orderInfo.append(taxLi);                                                        
				});
			}
			$("#payInfo").append($orderInfo);
			//璁㈠崟鏃堕棿闂
			$("#timeInfo").empty();
			var timeInfo = $('<ul class="orderDetails">'+
							  '<li style="text-align: right;">涓嬪崟鏃堕棿锛?+orderInfo.date7+'</li>'+	
						    '</ul>');		
			//浠樻鏃堕棿
			if(orderInfo.payTime){
				timeInfo.append('<li style="text-align: right;">浠樻鏃堕棿锛?+orderInfo.payTime+'</li>');
			}
			//鍙戣揣鏃堕棿
			if(orderInfo.sendTime){
				timeInfo.append('<li style="text-align: right;">鍙戣揣鏃堕棿锛?+orderInfo.sendTime+'</li>');
			}
			//纭鏀惰揣鏃堕棿
			if(orderInfo.receiveTime){
				timeInfo.append('<li style="text-align: right;">纭鏀惰揣鏃堕棿锛?+orderInfo.receiveTime+'</li>');
			}
			$("#timeInfo").append(timeInfo);
			getAllNum();
		}
	});
}
//鍒嗛〉鑾峰彇鏇村鍟嗗搧
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
//鑾峰彇鍙戠エ淇℃伅
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
				 $li = $('<li><span style="text-align: right;display:inline-block;width:30%">'+taxTitles[j]+'锛?</span><span style="vertical-align: top;text-align: left;display:inline-block;width:69%">'+taxData[j]+'</li>');                                        
				 $("#taxUl").append($li);
			};
		}
	});
}
//鍟嗗搧鍒楄〃椤甸潰
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
//鍟嗗搧璇︾粏鍒楄〃椤甸潰
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
								'<p class="ordergoodsP">锟?+FormatNumber(obj[data["price1"]],2)+'</p>'+
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
//	'<p class="ordergoodsP">锟?+FormatNumber(dataa[i][datab["price"]],dot)+'</p>'+
//	'<p class="fr" style="width:10%;text-align:right">x'+dataa[i][datab["num1"]]+'</p>'+							
//'</div>'+

function getAllNum(){
	var num = 0;
	for(i = 0;i < $(".orderAllGoods").length; i++){
		num += parseInt($(".orderAllGoods").eq(i).find($(".oneNum")).html());
	}
}
//纭鏀惰揣
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
			//鏇存柊褰撳墠椤甸潰
			init();
		}
	});
}
//璁㈠崟浠樻
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
			      //鑾峰彇鎬婚〉鐮?
			    if(pageNum === allpage){
			        $(".goodsList").append("<p style='text-align:center;font-size:12px;padding:5px;color:#F15352'>浜诧紝宸茬粡鍒板簳閮ㄥ暒</p>")
			    }
			}else{
				
			}
		}
		
	}
}