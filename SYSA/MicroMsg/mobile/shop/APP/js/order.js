 var priceArry = [];
 var goodsId = GetQueryString("goodsId");
 var allPrice = 0;
 var clickindex = 0;

function checkHandle(obj){
	var result = $(obj).dateCkeck();
	if(!result.success){
		var id = $(obj).attr('id');
		$(obj).replaceWith(obj.outerHTML);
		$('#'+id).val('').bind('input',function(){checkHandle(this);});
	}
	return result.success;
}
 
$(function(){
		//手机转客户
		var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
		doCheck(datas);
		var uniqueFlag = GetQueryString("uniqueFlag");
		if(uniqueFlag == window.localStorage.uniqueFlag){
			goodsId = '';
		}
		window.localStorage.uniqueFlag = uniqueFlag;
		//创建商品列表
		if(goodsId){
			window.localStorage.removeItem("val");
			localStorage.removeItem("billKinds");
			doSingleGoods(goodsId);
		}else{
			window.localStorage.removeItem("val");
			localStorage.removeItem("billKinds");
			getAjax();
		}
	    localStorage.removeItem("ordAddr");
 	    var addressFlag = GetQueryString("kind");
 	    if(addressFlag){
	  		$("#main").hide();
	  		$("#addressDiv").show();
			chooseInit();
 	     }
		//时间控件配置
		var hasDatediv = false;
		var currYear = (new Date()).getFullYear();	
		var opt={};
		opt.date = {preset : 'date'};
		opt.datetime = {preset : 'datetime'};
		opt.time = {preset : 'time'};
		opt.default = {
			theme: 'android-ics light', //皮肤样式
	        display: 'modal', //显示方式 
	        mode: 'scroller', //日期选择模式
			lang:'zh',
	        startYear:currYear, //开始年份
	        endYear:currYear+10 //结束年份
		};
		$("#buyerMsg").unbind().bind("keydown",function(){
			$(this).attr("oldV",$(this).val());
		}).bind("keyup blur input",function(){
			if($(this).val().length>50){
				$("#msgTig").show();
				$(this).val($("#buyerMsg").attr("oldV"));
				return;
			}else{
				setTimeout(function(){$("#msgTig").hide();},1000)
			}
			$("#buyerMsg").attr("oldV",$(this).val());
		})
		$("#sendDate1").val('').scroller('destroy').scroller($.extend(opt['date'], opt['default']));
	  //时间控件配置结束
 	  //清除时间
 	    $("#clearTime").unbind().bind("click",function(){
 	  	  $("#sendDate1").val("");
 	    });
 	    $("#sendDate1")[0].oninput = function(e){checkHandle(this)};
		
		$("#addressBack").unbind().bind("click",function(){
			$("#addressDiv").hide();
			$("#main").show();
		})
		//打开税额种类
		$(".bill").unbind().bind("click",function(){
			$("#orderBillDiv").show();
			$("#main").hide();
			initBill();
		})
		$("#back").click(function(){
			$("#addressDiv,#orderBillDiv,#orderAllDiv").hide();
			history.back();
		})
		$(".order_info").bind("click",function(){
			$("#addressDiv").show();
			$("#main").hide();
			chooseInit();
		})

		$(".billKinds").html("不开票");
		$("#orderAllback").unbind().bind("click",function(){
			$("#orderAllDiv").hide();
			$("#main").show();
		})
		//提交订单
		checkOrder();
})

function doCheck(datas){
	$.ajax({
		type:"post", 
		data:datas,
		url:"../../ShopOrderConfirm.asp?__msgId=checkBind",
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			var status = data.body.message.text;
			if(status=="success"){
				$(".alert").hide();
			}else{
				$(".alert").show();
				//输入手机号验证
				$("#tel").blur(function(){
					
					checkTel($(this));
				})
				//提交
				$("#submit").click(function(){
					doSubmit();
				})
				//返回
				$("#return").click(function(){
					window.history.back();
				})
			}
		}
	});
}

function doSubmit(){
	if(checkTel($("#tel"))){
		var datas = '{datas:[{id:"mobile",val:"'+$("#tel").val()+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
		$.ajax({
			type:"post",
			url:"../../ShopOrderConfirm.asp?__msgId=userBind",
			dataType:"text",
			data:datas,
			contentType:"application/zsml",
			success:function(data){
				data = eval("("+data+")");
				$(".alert").hide();
			}
		});
	}else{
		checkTel($("#tel"));
		return ;
	}
}
//请求ajax
function getAjax(){
	var alldata = window.localStorage.getItem("alldata");
	var sendDate = $("#sendDate1").val();
	var payKind = $("#payWay").find($(".activeWay")).attr("way");
	var remark = $(".order_txt").val();
	var datas;
	if(alldata == null){
		datas = '{datas:[{id:"datejh",val:"'+sendDate+'"},{id:"payKind",val:"'+payKind+'"},'+
				'{id:"remark",val:"'+remark+'"},'+
				'{id:"openid",val:"'+localStorage.openID+'"}]}';
	}else{
		datas = '{datas:['+alldata+',{id:"datejh",val:"'+sendDate+'"},{id:"payKind",val:"'+payKind+'"},'+
				'{id:"remark",val:"'+remark+'"},'+
				'{id:"openid",val:"'+localStorage.openID+'"}]}';
	}
	$.ajax({
		type:"post",
		url:"../../ShopOrderConfirm.asp?__msgId=pageload",
		dataType:"text",
		processData:false,
		data:datas,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			console.log(data);
			//收货地址
			var addrData = getAttr(data.body.bill.groups[0].fields);
			localStorage.setItem("@invoiceType",addrData["@invoiceType"]);
			var goodsLength = data.body.bill.groups[3].fields.length
			if(goodsLength == 0){
				var recordcount = 0;
			}else{
				var recordcount = data.body.bill.groups[3].fields[0].source.table.page.recordcount;
			}
			var msg = addrData["@checkResult"];
			$("#shortMsg").empty();
			if(msg){
				$(".checkOrder").css("background","#bfbfbf").unbind("click");
				recordcount==1?$("#shortMsg").html('<span class="marks">!</span>商品库存不足'):$("#shortMsg").html('<span class="marks">!</span>部分商品库存不足')
			}
			//可开票据类型
			var data_bill = data.body.bill.groups[4].fields;
			if(goodsLength == 0){
				createOrder(0);
				getAllPrice();
			}else{
				//订单商品列表
				var datab = data.body.bill.groups[3].fields;
				//金额信息
				var datae = data.body.bill.groups[2].fields;
				createOrder(datab);
				createPrice(datae);
			}
			//支付方式
			payFun(data);
			//创建地址
			createInfo(addrData);
			$("#loadDiv").hide();
		},error : function(e){		
			console.log(e)
		}
	});
}

function doSingleGoods(id){
	var buynum = GetQueryString("num");
	var alldata = window.localStorage.getItem("alldata");
	var sendDate = $("#sendDate1").val();
	var payKind = $("#payWay").find($(".activeWay")).attr("way");
	var remark = $(".order_txt").val();
	var datas;
	if(alldata == null){
		datas = '{datas:[{id:"datejh",val:"'+sendDate+'"},{id:"payKind",val:"'+payKind+'"},'+
				'{id:"remark",val:"'+remark+'"},'+
				'{id:"openid",val:"'+localStorage.openID+'"}]}';
	}else{
		datas = '{datas:['+alldata+',{id:"datejh",val:"'+sendDate+'"},{id:"payKind",val:"'+payKind+'"},'+
				'{id:"remark",val:"'+remark+'"},'+
				'{id:"openid",val:"'+localStorage.openID+'"}]}';
	}
	$.ajax({
		type:"post",
		url:"../../ShopOrderConfirm.asp?goodsId="+id+"&num="+buynum,
		contentType:"application/zsml",
		dataType:"text",
		data:datas,
		success:function(data){
			data = eval("("+data+")");
			//收货地址
			var addrData = getAttr(data.body.bill.groups[0].fields);
			localStorage.setItem("@invoiceType",addrData["@invoiceType"]);
			var msg = addrData["@checkResult"];
			$("#shortMsg").empty();
			if(msg){
				$("#shortMsg").html('<span class="marks">!</span>商品库存不足');
				$(".checkOrder").css("background","#bfbfbf").unbind("click");
			}
			//可开票据类型
			var data_bill = data.body.bill.groups[4].fields;
			//订单商品列表
			var datab = data.body.bill.groups[3].fields;
			//金额信息
			var datae = data.body.bill.groups[2].fields;
			//创建地址
			createInfo(addrData);
			createOrder(datab);
			createPrice(datae);
			$("#loadDiv").hide();
			//付款方式//支付方式
			payFun(data);
		}
	});
}
//创建收获用户收货地址页面结构
function createInfo(data){
	if(data["addrId"]==0){
		var $info = $('<span class="addressNull pr"><i class="noPlus">+</i>收货地址<span class="glyphicon glyphicon-chevron-right pa glyphiona"></span></span>');
		$(".order_info").attr("addrFlag","0");
		localStorage.ordAddr = 0;
	}else{
		var $info = $('<p id="haveAddr">'+
						'<span class="receiver"><i class="userI"></i>'+data["receiver"]+'</span>'+
						'<span class="photoImg"><i class="phoneI"></i>'+data["mobile"]+'</span>'+
					  '</p>'+
					  '<p class="pr address">'+
					  	'<span class="glyphicon glyphicon-map-marker"></span>'+
						'<span style="padding-left: 0.1rem;line-height: 2;color:#646869">地址:'+data["address"]+'</span>'+
						'<span class="glyphicon glyphicon-chevron-right fr">'+
						'</span>'+
					  '</p>');
		$(".order_info").attr("addrFlag","");
		localStorage.ordAddr = data["addrId"];
	}
	$(".order_info").empty().append($info);
	
}
//创建订单商品
function createOrder(data){
	console.log(data);
	if(data== 0){
		var $num = $('<p class="nullorder">您的订单为空...</p>');
	}else{
		var o = getPro(data[0].source.table.cols);
		var q = data[0].source.table.rows;
		var recordcount = data[0].source.table.page.recordcount;
		for(i=0;i<3 && i<q.length;i++){
			var $orderli = $('<li class="goodsLi"><a href="javascript:void(0)"><img src="../../../../../Edit/upimages/shop/'+q[i][o["photo"]]+'"></a></li>');
			$(".orderG").append($orderli);
		}
		var $num;
		if(q.length == 1){
		    var dot = window.sysConfig.SalesPriceDotNum;
			$num = $('<li class="overf">'+
						'<div style="clear:both;overflow:hidden">'+
							'<p class="orderGoodsInfo">'+q[0][o["name"]]+'</p>'+
							'<p style="text-align:left;font-size:12px;color:#646869">'+q[0][o["goodsInfo"]]+'</p>'+
						'</div>'+
						'<div style="overflow:hidden;clear:both;">'+
							'<p class="ordergoodsP">￥'+FormatNumber(q[0][o["price1"]],dot)+'</p>'+
							'<p class="fr" style="width:40%;text-align:right">x'+q[0][o["num1"]]+'</p>'+							
						'</div>'+
					  '</li>');
		}else{
			$num = $('<li style="font-size:0.16rem;color:#000;float:right;padding:30px 0.1rem"><span>...共'+(recordcount)+'件</span><span class="glyphicon glyphicon-chevron-right"></span></li>');
		}
		}
	$(".orderG").append($num);
	//分页
	var pageN = 1;
	var allpage = parseInt(recordcount/10)+1;
	$(".orderG").unbind().bind("click",function(){
		$("#orderAllDiv").show();
		$("#main").hide();
		//获取订单详情页信息
		getOrder(pageN,allpage)
	})
	$("#loadMore").unbind().bind("click",function(){
		pageN++;
		getOrder(pageN,allpage);
	})
}

//创建商品金额税额运费结构
function createPrice(datae){
	for(i=0;i<datae.length-1;i++){
		if(datae[i].text == undefined || datae[i].text == null){
			datae[i].text = 0;
		}
		var dot = window.sysConfig.moneynumber;
		var $price = $('<li><span class="order_lia">'+datae[i].caption+'</span><span class="order_lib price" id="'+datae[i].id+'">￥'+FormatNumber(datae[i].text,dot)+'</span></li>');
		$(".order_price").append($price);
		priceArry.push([datae[i].caption,datae[i].text]);
	}
	getAllPrice();
}


//点击提交订单
function checkOrder(){
	$(".checkOrder").unbind().bind("click",function(){
		//判断送货时间
		var timemsg = $("#sendDate1").checkReTime();
		if(!timemsg.success){
			createAlert(timemsg.msg);
			return;
		}else{
			saveInfo();
		}
	})
}

$.fn.checkReTime = function(){
	var nowDate = new Date();
	var y = nowDate.getFullYear();
	var m = ("0"+(nowDate.getMonth()+1));
	var day = "0"+nowDate.getDate();
	var today = parseInt(y+m.substring(m.length-2)+day.substring(day.length-2));
	var chooseDate= parseInt(($(this).val()).replace(/-/g,""));
	if(chooseDate<today){
		return {success:false,msg:'所选日期不能小于当前日期！'};
	}else{
		return {success:true,msg:''};
	}
}
//提交ajax
function saveInfo(){
	//留言控制
	checkLong($("#buyerMsg"),50);
	var account = $(".allPrice").val();
	var alldata = window.localStorage.getItem("alldata");
	var sendDate = $("#sendDate1").val();
	var payKind = $("#payWay").find($(".activeWay")).attr("way");
	var remark = $(".order_txt").val();
	var datas;
	if(alldata == null){
		var invoiceType = localStorage.getItem("@invoiceType");
		datas = '{datas:[{id:"datejh",val:"'+sendDate+'"},{id:"payKind",val:"'+payKind+'"},'+
				'{id:"remark",val:"'+remark+'"},{id:"invoiceType",val:"'+invoiceType+'"},'+
				'{id:"openid",val:"'+localStorage.openID+'"}]}';
	}else{
		datas = '{datas:['+alldata+',{id:"datejh",val:"'+sendDate+'"},{id:"payKind",val:"'+payKind+'"},'+
				'{id:"remark",val:"'+remark+'"},'+
				'{id:"openid",val:"'+localStorage.openID+'"}]}';
	}
	var addrFlag = $(".order_info").attr("addrFlag");
	if(addrFlag == ""){
		$.ajax({
			type:"post",
			url:"../../ShopOrderConfirm.asp?__msgId=__sys_dosave&addrId="+localStorage.ordAddr,
			dataType:"text",
			processData:false,
			contentType:"application/zsml",
			data:datas,
			success:function(data){
				data = eval("("+data+")");
				if(!data.body && data.success==false){
					createAlert(data.msg);
					$(".checkOrder").css("background","#bfbfbf").unbind("click");
					console.log("不可提交");
					return;
				}else if(data.header && data.header.status!=0){
					createAlert(data.header.message);
					$(".checkOrder").css("background","#bfbfbf").unbind("click");
					console.log("不可提交");
					return;
				}
		
				if(data.body.message.text == "success"){
					if(payKind == "2"){
						var _data = eval("("+data.body.message.data+")");
						window.localStorage.removeItem("alldata");
						window.location = "paySuccess.html?htord="+_data.htord+"&htid="+_data.htid;
					}else{
						var _data = eval("("+data.body.message.data+")");
						var id = _data.ord;
						window.localStorage.removeItem("alldata");
						window.location = "../../APP/html/pay.html?&paysheetno=" + _data.paysheetno + "&id="+id+"&allPrice="+_data.money+"&htord="+_data.htord+"&htid="+_data.htid;
					}
				}else{
					createAlert(data.body.message.data);
					//$(".checkOrder").css("background","#bfbfbf").unbind("click");
					console.log("不可提交");
				}
			},
			error:function(data){
				console.log(data)
			}
		 });
		
		
	}else{
		alert("请选择收货地址");
		return false;
	}
}

//获取点击地址
function getAddr(ordAddr){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../Shop_AddressAdd.asp?ord="+ordAddr,
		dataType:"text",
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			console.log(data);
			createAddr(data);
		},error:function(a,b,c){
			alert(a+b+c);
		}
	});
}

function getAreaText(areaData) {
	var datas = eval("(" + areaData + ")");
	var  addr = ""
	for (var i = 0; i<datas.length; i++)
	{
		var items = datas[i];
		for (var ii = 0; ii< items.length ; ii++ )
		{
			var aitem = items[ii];
			if(aitem[2]==1) {
				addr = addr + aitem[0] + " "
			}
		}
	}
	return addr;
}

//创建收获用户基本信息页面结构
function createAddr(data){
	if(data.body.model == "message"){
		var $info = $('<span class="addressNull pr"><i class="noPlus">+</i>收货地址<span class="glyphicon glyphicon-chevron-right pa glyphiona"></span></span>');
		$(".order_info").attr("addrFlag","0");
	}else{
		var dataa = getAttr(data.body.bill.groups[0].fields);
		var areaText = getAreaText(dataa["@areaData"]);
		var $info = $('<p id="haveAddr">'+
						'<span class="receiver "><i class="userI"></i>'+dataa["receiver"]+'</span>'+
						'<span class="photoImg "><i class="phoneI"></i>'+dataa["mobile"]+'</span>'+
					  '</p>'+
					  '<p class="pr address">'+
					  	'<span class="glyphicon glyphicon-map-marker"></span>'+
						'<span style="padding-left: 0.1rem;line-height: 2;color:#646869">地址:'+ areaText + dataa["address"]+'</span>'+
						'<span class="glyphicon glyphicon-chevron-right fr">'+
						'</span>'+
					  '</p>');
		$(".order_info").attr("addrFlag","")
	}
		$(".order_info").empty().append($info);
		
}
//全部商品列表 详情信息
function getOrder(pageNum,allpage){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'},{id:'pageindex',val:'"+pageNum+"'}]}";
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
				if(pageNum == 1){
					$(".orderAll").empty();
				}
				createCurrentGoods(dataa,datab);
			}else{
				$(".orderAll").empty().html('<img src="../img/noOrder.png" style="display: block;margin: 0.05rem auto;width:0.3rem;">');
			}	
			if(allpage == pageNum){
				$("#loadMore").hide();
			}else{
				console.log(allpage+"allpage");
				console.log(pageNum);
				$("#loadMore").show();
			}
		}
	});
}
//创建当前商品页面结构
function createCurrentGoods(dataa,datab){
    var dot = window.sysConfig.SalesPriceDotNum;
	for(i=0;i<dataa.length;i++){
		var $goods;
		var stor = parseFloat(dataa[i][datab["storage"]]);
		if(stor <= 0 || parseFloat(dataa[i][datab["num1"]]) > stor){
			$goods = $('<div class=" ov order_goods orderAllGoods" '+ ((i==dataa.length-1)?'style="border-bottom:0px"':'') +'>'+
						 '<dl class="order_dl1">'+
						  '<dt style="height:100%">'+
						    '<img src="../../../../../Edit/upimages/shop/'+getImgPath(dataa[i][datab["photo"]]).middle+'" class="order_phone"/>'+
						 '</dt>'+
							  '<dd>'+
							      '<p class="orderGoodsInfo2">'+dataa[i][datab["name"]]+'</p>'+
								  '<p style="color:#F15352;font-size:15px;">￥'+FormatNumber(dataa[i][datab["price"]],dot)+'</p>'+
							 '</dd>'+
						 '</dl>'+
						 '<div class="cb">'+
							 '<p style="color:#000;text-align:left;float:left;padding-left: 0.1rem;font-weight: bold;">库存不足，当前库存：'+stor+'</p>'+
							 '<p style="text-align:right;padding-right:0.1rem;float:right">X '+dataa[i][datab["num1"]]+ '<p>'+
						 '<div>'+
						 '</div>');			
		}else{
			$goods = $('<div class=" ov order_goods orderAllGoods"  '+ ((i==dataa.length-1)?'style="border-bottom:0px"':'') +'>'+
						 '<dl class="order_dl1">'+
						  '<dt style="height:100%">'+
						    '<img src="../../../../../Edit/upimages/shop/'+getImgPath(dataa[i][datab["photo"]]).middle+'" class="order_phone"/>'+
						 '</dt>'+
							  '<dd>'+
							  	  '<div style="clear:both;overflow:hidden">'+
										'<p class="orderGoodsInfo2">'+dataa[i][datab["name"]]+'</p>'+
										'<p style="text-align:left;font-size:12px;color:#646869">'+dataa[i][datab["goodsInfo"]]+'</p>'+
								  '</div>'+
								  '<div style="overflow:hidden;clear:both;">'+
									'<p class="ordergoodsP">￥'+FormatNumber(dataa[i][datab["price"]],dot)+'</p>'+
									'<p class="fr" style="width:40%;text-align:right">x'+dataa[i][datab["num1"]]+'</p>'+							
								  '</div>'+
							 '</dd>'+
						 '</dl>'+
						'</div>');
		}
		$(".orderAll").append($goods);
	}
	$(".countAll").html("共"+$(".orderAllGoods").length+"件");
	
}
//收货地址
function chooseInit(){
	//新建收货地址
	$("#newAddress").unbind().bind("click",function(){
		window.location = "newAddress.html?chooseAddr=chooseAddr&"+Math.random();
	})
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../Shop_AddressList.asp?__msgId=refresh",
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data.body.source.table.rows.length != 0){
				$("#addressList").empty();
				var o = getPro(data.body.source.table.cols);
				var rows = data.body.source.table.rows;
				$.each(rows, function(i) {    
					var $ul = $('<ul style="clear:both;overflow:hidden;">'+
								'<li style="padding-left:15px" class="chooseBtn" data-ord='+rows[i][o["addrId"]]+'>'+
									'<div class="haveAddr">'+
										'<span class="receiver"><i class="userI"></i>'+rows[i][o["receiver"]]+'</span>'+
										'<span class="photoImg text-right" ><i class="phoneI"></i>'+rows[i][o["mobile"]]+'</span>'+
									'</div>'+
									'<p style="line-height: 2;clear:both;overflow:hidden;color:#646869">'+rows[i][o["address"]]+'</p>'+
								'</li>'+
								'<li class="addrLi" style="clear:both;overflow:hidden;padding:6px 15px">'+
									'<div class="fl" style="width:30%">'+
										'<span class="text-center defaultBtn" data-ord="'+rows[i][o["addrId"]]+'">默认</span>'+
									'</div>'+
									'<div class="fr text-right" style="width:48%">'+
										'<span class="editDiv text-right glyphicon-edit1" data-ord="'+rows[i][o["addrId"]]+'">'+
										    '<span class="glyphicon glyphicon-edit" ></span><em class="editWords" style="padding-right:10px">修改</em>'+
										'</span>'+
										'<span class="editDiv text-left glyphicon-trash1" data-ord="'+rows[i][o["addrId"]]+'">'+
											'  <span class="glyphicon glyphicon-trash" ></span><em class="editWords">删除</em>'+
										'</span>'+								
									'</div>'+
								'</li>'+
								'</ul>');
					$("#addressList").append($ul);
					//遍历收货地址
					$(".chooseBtn").unbind().bind("click",function(event){
						localStorage.ordAddr = $(this).attr("data-ord");
						$("#addressDiv").hide();
						$("#main").show();
						getAddr($(this).attr("data-ord"));
						$(".order_info").empty();
					})
					//返回订单列表
					$("#addressBack").unbind().bind("click",function(){
						var len = $("#addressList ul li").length;
						if(len == 0){
							$(".order_info").html($('<span class="addressNull pr"><i class="noPlus">+</i>收货地址<span class="glyphicon glyphicon-chevron-right pa glyphiona"></span></span>'))
							$(".order_info").attr("addrFlag","0");
						}
						$("#addressDiv").hide();
						$("#main").show();
					})
					//点击选择默认地址
					$(".defaultBtn").unbind().bind("click",function(){
						$(".defaultBtn").removeClass("default");
						$(this).addClass("default");
						var addrId = $(this).attr("data-ord");
						var datas = '{datas:[{id:"isDefault",val:"1"},{id:"openid",val:"'+localStorage.openID+'"}]}';
						$.ajax({
							type:"post",
							url:"../../Shop_AddressAdd.asp?__msgId=setDefault&addrId="+addrId,
							dataType:"text",
							processData:false,
							contentType:"application/zsml",
							data:datas,
							success:function(data){
								console.log(data);
							}
						})
					})
					//添加默认地址
					if(rows[i][o["isDefault"]]==1){
						$(".defaultBtn").eq(i).addClass("default");
					}else{
						$(".defaultBtn").eq(i).removeClass("default");
					}
					//编辑地址修改收货地址
					$(".glyphicon-edit1").unbind().bind("click",function(event){
						window.location = "editAddress.html?choose=choose&addrld="+$(this).attr("data-ord")+"&"+Math.random();
					})
					//新建收货地址是否固定在底部
					var clientH = $(window).height();
					var addrListH = $("#addressList").height();
					if((addrListH - clientH) >= 100){
						$("#addressList").css({"margin-bottom":"2.2rem"})
						$("#addrWrap").addClass("newAddressFix");
					}else{
						$("#addressList").css({"margin-bottom":"0rem"})
						$("#addrWrap").removeClass("newAddressFix");
					}
					//删除
					$(".glyphicon-trash1").unbind().bind("click",function(event){
						var $this = $(this);
						createConfirm("确定要删除当前地址吗？",function(){
							var addrld = $this.attr("data-ord");
							console.log(addrld);
							var o = $this.parent().parent();
							o.animate({"height":"0"},300,function(){
								$this.hide();	
							})
							doDel(addrld);									
						},function(){});
					});
				});
			}else{
				$("#addressList").empty();
				$("#addressList").append('<figure class="noAddr">'+
						                 ' <img src="../img/noAddr.jpg" style="width: 1.2rem;">'+
						                 ' <figcaption>还没有收货地址</figcaption>'+
					                   	'</figure>');
				return false;
			}
		}
	})
}
function doDel(addrld){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../Shop_AddressAdd.asp?__msgId=delete&ord="+addrld,
		dataType:"text",
		processData:false,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			chooseInit();
		}
	})
}
function initBill(){
	$("#billback").unbind().bind("click",function(){
		$("#orderBillDiv").hide();
		$("#main").show();
	})
	if($(".bill_kinds li").size()==0){
		var $billKinds = $("input[name='bill']");
		$(".bill_ok").unbind().bind("click",function(){
			$("#orderBillDiv").hide();
			$("#main").show();
			if(localStorage.getItem("val")){
				$(".billKinds").empty().text(localStorage.getItem("val"))
			}else {
				$(".billKinds").empty().text("不开票");
			}
			$(".order_price").empty();
			for(var i = 0; i<priceArry.length; i++){
				var $li = $('<li><span class="order_lia">'+priceArry[i][0]+'</span><span class="order_lib" >￥'+priceArry[i][1]+'</span></li>');
				$(".order_price").append($li);	
			}
			getAllPrice();
		})
		billKinds();
	}
}
//点击增值税出现文本框填写
function addValue($billKinds){
	$billKinds.unbind().bind("click",function(){
		clickindex = $(this).index("input[name='bill']");
		for(i=0;i<$billKinds.length;i++){
			if($billKinds[i].checked){
				if(window.localStorage){
					localStorage.setItem("billKinds",$billKinds[i].value);
				}
			}
		}
	})
}

//发票类型
function billKinds(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		url:"../../ShopOrderConfirm.asp?__msgId=pageload",
		dataType:"text",
		data:datas,
		contentType:"application/zsml",//用网址访问时 加上这句话
		success:function(data){
			data = eval('('+data+')');
			var billData = data.body.bill.groups[4].fields;
			if(billData.length != 0){
				var dataa = data.body.bill.groups[4].fields[0].source.table.rows;
				createBill(dataa);
				chooseBill(dataa);
			}else{
				$(".bill_kinds").html("<p style='tect-align:center; font-size:0.14rem; padding:0.3rem 0 0.1rem 0'>无可用票据类型...</p>")
			}	
		}
	});
}
//创建页面基本结构
function createBill(dataa){
	$(".bill_kinds").empty();
	for(i=0;i<dataa.length;i++){
		var $billkinds = $('<li class="billClasify" value="'+dataa[i][1]+'">'+
								'<span>'+
									'<input type="radio" name="bill" value="'+dataa[i][1]+'" id="'+dataa[i][0]+'">'+
									'<label for="'+dataa[i][0]+'">'+dataa[i][1]+'</label>'+
								'</span>'+
								'<ul class="oneBill"></ul>'+
							'</li>');
		$(".bill_kinds").append($billkinds);
	}
	var billClasify = $(".billClasify");
	var $billKinds = $("input[name='bill']");
	$.each(billClasify, function(n) {    
		if(billClasify.eq(n).attr("value") == $(".billKinds").text()){
			$billKinds.eq(n).attr('isClicked','1');
			$billKinds.eq(n).attr("checked",true);
		}
	});
	addValue($billKinds);
}
//点击选择发票类型
function chooseBill(data){
	$(".billClasify span").unbind().bind("click",function(ev){
		var $target = $(this).parent();
		var $currselect = $(".billClasify[isClicked=1]");
		if($target!=$currselect){
			$currselect.attr('isClicked','');
		}
		$target.attr('isClicked','1');
		var $nowBillId = data[$target.index()][0];
		var $nowBillVal = data[$target.index()][1];
		setBill($nowBillId,$nowBillVal,$target);
		$target.find(".oneBill").slideDown().parent().siblings().find(".oneBill").slideUp();
		if(window.localStorage){
			//taxname
			window.localStorage.setItem("val",$nowBillVal);
		}
		//提交
		clickBill($(this),$nowBillId);
	})
}



//将发票信息存入后台接口
function setBill(id,val,index){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../ShopInvoiceFields.asp?__msgId=pageload&invoiceType="+id,
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval('('+data+')');
			var billInfo = data.body.bill.groups[1].fields;
			createBillInfo(billInfo,index);
			var taxValue = data.body.bill.groups[0].fields[0].text;
			for(var i = priceArry.length-1; i>=0 ; i--){
					if(priceArry[i][0] == "商品税额"){
						priceArry.splice(i,1);
						break;
					}
				}
			if(parseFloat(taxValue) != 0 && parseFloat(taxValue) != "" && parseFloat(taxValue) != null){
				var dotNum = window.sysConfig.moneynumber;
				taxValue = FormatNumber(taxValue,dotNum);
				priceArry.push(["商品税额",taxValue]);
			}else{
				for(var i = priceArry.length-1; i>=0 ; i--){
					if(priceArry[i][0] == "商品税额"){
						priceArry.splice(i,1);
						break;
					}
				}
			}
		}
	});
}

//创建发票内容填写
function createBillInfo(billInfo,obj){
	var $oneBill = obj.find(".oneBill");
	$oneBill.empty();
	for(i=0;i<billInfo.length;i++){
		var billI = billInfo[i].type;
		var txt = billInfo[i].text?billInfo[i].text:"";
		switch(billI){
			case "text":
			var $billInfo = $('<li style="position:relative;clear:both" >'+
								'<span class="fl billin">'+billInfo[i].caption+':</span>'+
								'<input type="text" value="' + txt + '" onfocus="this.select()" class="fl txt1" id="'+billInfo[i].id+'" notNull="'+billInfo[i].notnull+'" maxL="'+billInfo[i].maxl+'">'+
								'<p class="taxErro"></p>'+
							'</li>');
			break;
			case "textarea":
			var $billInfo = $('<li style="position:relative;clear:both" >'+
								'<span class="fl billin">'+billInfo[i].caption+':</span>'+
								'<textarea class="fl txt1" id="'+billInfo[i].id+'" notNull="'+billInfo[i].notnull+'" maxL="'+billInfo[i].maxl+'">' + txt + '</textarea>'+
								'<p class="taxErro"></p></li>');
			break;
			case "date":
			var $billInfo = $('<li style="position:relative;clear:both" >'+
								'<span class="fl billin">'+billInfo[i].caption+':</span>'+
								'<input type="date" class="fl txt1" value="' + txt + '" id="'+billInfo[i].id+'" notNull="'+billInfo[i].notnull+'" maxL="'+billInfo[i].maxl+'">'+
								'<p class="taxErro"></p></li>');
			break;
			case "webbox":
			var $billInfo = $('<li style="position:relative;clear:both" >'+
								'<span class="fl billin">'+billInfo[i].caption+':</span>'+
								'<textarea class="fl txt1" id="'+billInfo[i].id+'" notNull="'+billInfo[i].notnull+'" maxL="'+billInfo[i].maxl+'"></textarea>'+
								'<p class="taxErro"></p></li>');
			break;
			case "select":
			var $billInfo = $('<li style="position:relative;clear:both" >'+
								'<span class="fl billin">'+billInfo[i].caption+':</span>'+
								'<select class="billSel txt1" id="'+billInfo[i].id+'" notNull="'+billInfo[i].notnull+'" maxL="'+billInfo[i].maxl+'"></select>'+
								'<p class="taxErro"></p></li>');
			var $billOptions = billInfo[i].source.options;
			for(j=0;j<$billOptions.length;j++){
				var $option = $('<option value="'+$billOptions[j].v+'">'+$billOptions[j].n+'</option>');	
				$billInfo.find("select").append($option);
			}
			break;
		}
		$oneBill.append($billInfo);
		var inputs = $oneBill.find(".txt1");
		$.each(inputs,function(i){
			$(this).unbind().bind("blur",function(){
				$(this).validate();
			})
		})
	}
}
//点击确认选择发票类型
function clickBill($target,$nowBillId){
	$(".bill_ok").unbind().bind("click",function(){
		var inputs = $(".billClasify[isClicked=1]").find(".txt1");
		var result = true;
		var obj;
		$.each(inputs,function(i){
			if(!$(this).validate()){
				if(!obj) obj = this;
				result = false;
			}
		})
		if(!result){
			obj.focus();
			return;
		}
		saveBillInfo($target,$nowBillId);
		$("#orderBillDiv").hide();
		$("#main").show();
		$(".billKinds").empty().text(localStorage.getItem("val"))
		$(".order_price").empty();
		for(var i = 0; i<priceArry.length; i++){
			var $li = $('<li><span class="order_lia">'+priceArry[i][0]+'</span><span class="order_lib" >￥'+priceArry[i][1]+'</span></li>');
			$(".order_price").append($li);	
		}
		getAllPrice();
	})
}
//存储数据
function saveBillInfo($target,$nowBillId){
	var $input = $target.siblings().find(".txt1");
	var datas = ['{id:"invoiceType",val:"'+$nowBillId+'"}'];
	for(i=0;i<$input.length;i++){
		datas.push('{id:"'+$input.eq(i).attr("id")+'",val:"'+$input.eq(i).val()+'"}');
	}
	alldata = datas.join(",")
	if(window.localStorage){
		window.localStorage.setItem("alldata",alldata);
	}
}

function getAllPrice(){
	allPrice = 0;
	$.each(priceArry, function(k) {  
		allPrice += parseFloat(priceArry[k][1].toString().replace(/\,/g,""));                                                    
	});
	$(".allPrice").text(FormatNumber(allPrice,2));
}
function payFun(data){
	if(!data.body.bill.groups[5].fields[0]) {
		alert("没有设置付款方式");
		return;
	}
	var payWay = data.body.bill.groups[5].fields[0].source.table.rows;
	var payIndex = getPro(data.body.bill.groups[5].fields[0].source.table.cols);
	$("#payWay").empty();
	if(payWay.length == 1){
		$("#payWayBtn p").remove();
		var $li =  $('<li style="float:left;width:49%;text-align:left;color:#646869">付款方式</li>'+
					 '<li class="activeWay" style="color:#000;float:right;text-align:right;width:49%;" way="'+payWay[0][payIndex["id"]]+'">'+payWay[0][payIndex["name"]]+'&nbsp;</li>');
		$("#payWay").css({"padding":"5px 0.1rem","clear":"both","oveflow":"hidden"}).append($li);
	}else{
		$.each(payWay, function(k){ 
			var $li =  $('<li  ></li>');
			var $span = $('<span way="'+payWay[k][payIndex["id"]]+'">'+payWay[k][payIndex["name"]]+'</span>');
			$("#payWay").append($span);
		});
		$("#payWay span:first").addClass("activeWay");
		$("#payWay span").bind("click",function(){
		$(this).addClass("activeWay").siblings().removeClass("activeWay");
	 })
	}
}