var flag = false;
var buynum = 1;
var isAlert = false;
$(function(){
		$("#outerWrap").hide();
		$("#loadDiv").show();
		$("#back").unbind().bind("click",function(){
			$("#intoCarTig").remove();
			window.history.back();
		})
		doInit();
		//禁止图片轮播
		$(".carousel").carousel('pause');
		//左右滑动图片轮播
		$(".carousel").swipe({
		  swipeLeft: function() { 
		  	$(this).carousel('next');
		  	var i = $(".carousel li.active").index();
		 	$(".carousel li.active").index();
		 	showImgNum(i+2);
		  },
		  swipeRight: function() { 
		  	$(this).carousel('prev');
		  	var i = $(".carousel li.active").index();
		 	showImgNum(i);
		  },
		});
		//点击更多 出现可选属性弹框
		var moveWidth = $(".moreDiv").offsetWidth;
		$("#chooseBtn").click(function(){
			$("#moreWrap").fadeIn(300);
			$("#moreDiv").css({"-webkit-transform": "translateX(0)"});
		});
		$(".exit").click(function(){
			$("#moreDiv").css({"-webkit-transform": "translateX(90%)"})
			$("#moreWrap").fadeOut(600);
		})
		$("#moreWrap").swipe({
			swipeRight:function(){
			$("#moreDiv").css({"-webkit-transform": "translateX(90%)"});
				setTimeout(function(){
					$("#moreWrap").fadeOut(600);
				},1000)
			},
			swipeLeft:function(){
				return;
			}
		})
		
		//跳转购物车页面
		$("#carDiv").click(function(){
			window.location = "car.html";
		})
		$("#buyNow").attr("goodsId",GetQueryString("id"));
		//跳转支付页面
		$("#buyNow").unbind().bind("click",function(e){
			var isOnSale = $("#buyNow").attr("isOnSale");
			if(isOnSale == 1 && flag){
				var id = $("#buyNow").attr("goodsId");
				var buynum = 1;
				buynum = $("#number").val();
				window.location = "html/order.html?goodsId="+id+"&num="+buynum+"&uniqueFlag="+Math.random();
			}else{
//				if(isAlert == false){
//					alert("该商品库存不足或已下架！");
//				}
				return;
			}
		})
		window.onbeforeunload = function(e){
			$("input[type='number'][isSaved='0']").trigger('blur');
		}
})
function doInit(){
	var id = GetQueryString("id");
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	if(id){
		$.ajax({
			type:"post",
			dataType:"text",
			data:datas,
			async:false,
			contentType:"application/zsml",
			url:"../GoodsDetail.asp?__msgId=pageload&ord="+id,
			success:function(data){
				data = ("("+data+")");
				$("#loadDiv").hide();
				$("#outerWrap").show();
				getCarNum();
				var dataobj = eval("("+data+")");
				if(dataobj && dataobj.header && dataobj.header.status!=0) {
					alert(dataobj.header.message);
					return;
				}
				createDetailPage(dataobj);
				shareGoodMessage();
			}
		});
	}else{
		console.log("error");
	}
}
//创建页面基本结构
function createDetailPage(data){
	if(data.body.bill.groups.length == 0) {return}
	$.each(data.body.bill.groups,function(i){
		var id = data.body.bill.groups[i].id;
		var groups0 = getAttr(data.body.bill.groups[0].fields);
		//是否已经下架的标识
		$("#buyNow").attr("isOnSale",groups0["isOnSale"]);
		if(groups0["isOnSale"] == 0 || parseFloat(groups0["storage"]) <= 0){
			$("#buyNow").css("background","#bfbfbf");
		}else{
			$("#buyNow").css("background","#F15352");
		}
		parseFloat(groups0["storage"]) <= 0?flag = false:flag = true;
		//基本信息
		if(id=="baseInfo"){
			//介绍
			$("#goodsIntro").empty().html(groups0["intro3"]||'');
			//参数
			$("#param").empty().html(groups0["intro2"]||'');
			//售后
			$("#service").empty().html(groups0["intro1"]||'');
		}
		//商品图片
		if(id=="photos"){
			showMainInfo(data);
		}
		//当前商品属性
		if(id=="attributes"){
			createCurrentAttr(data);
		}
		//可选商品属性
		if(id=="sku_attributes"){
			//可选商品图片创建 购物车相关操作
			createChooseAttr(data);
			//创建
			getUnitAttr(data,groups0); 
		}
	});
}

function shareGoodMessage(){
	if(initWeiXinApiConfig()==false) { return false; }
	var fn = function(){
		wx.onMenuShareAppMessage({
			title: window.goodName, // 分享标题
			desc: window.goodAdInfo, // 分享描述
			link: window.location.href, // 分享链接，该链接域名或路径必须与当前页面对应的公众号JS安全域名一致
			imgUrl:"http://t1.zbintel.com/SYSA/Edit/upimages/shop/" + window.imgInfoUrl || '', // 分享图标
			type: 'link', // 分享类型,music、video或link，不填默认为link
			dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
			success: function () {  
				// 用户确认分享后执行的回调函数
			},
			cancel: function () { 
				// 用户取消分享后执行的回调函数
			}
		});
	}
	window.iswxload?fn():setTimeout(fn,1500);
}
function intoCar(data){
	var goodsid = data.body.bill.value;
	var index = getPro(data.body.bill.groups[1].fields[0].source.table.cols);
	var srcdata = data.body.bill.groups[1].fields[0].source.table.rows[0][index["fpath"]];
	//加入购物车
	$("#intoCar").unbind().bind("click",function(e){
		
		var goid = $("#buyNow").attr("goodsId");
		var id = goid ? goid : goodsid;
		var num1 = 1
		num1 = $("#number").val();
		var imgobj = document.getElementById("detailCarousel").getElementsByTagName("img")[0];
		addShopToCar(id, imgobj, num1);
	})		
}
//详情主页图片展现
function showMainInfo(data){
	$("#detailCarousel").empty();
	if(data.body.bill.groups[1].fields.length==0) {  
		var li = $('<li class="item"><img src="img/nopic100.jpg"></li>');
		li.addClass("active");
		li.appendTo($("#detailCarousel"));
	} else {
		var o = getPro(data.body.bill.groups[1].fields[0].source.table.cols);
		var rows = data.body.bill.groups[1].fields[0].source.table.rows;
		$.each(rows, function(i) {    
			var li = $('<li class="item"><img src="../../../../Edit/upimages/shop/'+rows[i][o["fpath"]]+'"></li>');
			if(i == 0){
				li.addClass("active");
			}
			li.appendTo($("#detailCarousel"));
		});
		window.imgInfoUrl = rows[0][o["fpath"]];
	}
	showImgNum(1);
	//创建当前商品名称 广告语 价格  属性
	var dot = window.sysConfig.SalesPriceDotNum;
	var groups0 = getAttr(data.body.bill.groups[0].fields);
	$(".intro").empty().append($('<p>'+groups0["name"]+'</p>'));
	window.goodName = groups0["name"]||'';
	$(".ads").empty().text(groups0["adWord"]||'');
	window.goodAdInfo = groups0["adWord"]||'';
	$(".priceDiv").empty().append($('<p class="price">'+FormatNumber(groups0["price"],dot)+'</p>'));
	createCurrentAttr(data);
}

//当前商品属性
function createCurrentAttr(data){
		var $span2_unit = getAttr(data.body.bill.groups[0].fields)["unit"];//单位
		var span1 = $('<span class="text-left fl span1">已选('+$span2_unit+')</span>:');
		if(data.body.bill.groups[2].fields.length != 0){
			$('<span>：</span>').appendTo(span1);
			var o = getPro(data.body.bill.groups[2].fields[0].source.table.cols);
			var rows = data.body.bill.groups[2].fields[0].source.table.rows;
			$.each(rows, function(i) {
				var span3 = $('<span style="color:#646869;font-size:12px"> '+rows[i][o["attrVal"]]+'</span>');
				span3.appendTo(span1);
			});
		}
		$("#chooseBtn").empty();
		span1.appendTo($("#chooseBtn"));
		$("#chooseBtn").append($('<span class="text-left fr" id="choose">  更多<em class="moreImg"></em>  </span>'));
}
//可选商品图片创建 购物车相关操作
function createChooseAttr(data){
	//创建可选属性页面的图片
	var groups0 = getAttr(data.body.bill.groups[0].fields);
		createChooseImg(data);
	//加入购物车
	intoCar(data);
	var dot = window.sysConfig.floatnumber;
	//购物车数量相关
	//对数量加减号相关操作
	$("input[type='number']").attr('isSaved','1')
	$("#number").unbind().bind("keydown",function(){
		$(this).attr("oldVal",$(this).val()).attr('isSaved','0');
		$(this).attr("oldVal",$(this).val());
		checkDot(this,dot,4);
	}).unbind("keyup").bind("keyup",function(){
		checkDot(this,dot,4);
		buynum = $(this).val();
	}).blur(function(){
		$(this).attr('isSaved','1');
		$(this).val()==''?$(this).val("1.00"):$(this).val();
		$(this).val()==0?$(this).val("1.00"):$(this).val();
		changeNum(GetQueryString("id"),$(this).val());
		buynum = $(this).val();
		checkDot(this,dot,4);
	}).focus(function(){
		 var me=this;
		 setTimeout(function(){(me.select())},10);
	})
	//购物车加
	$(".add").unbind().bind("click",function(){
		addCar($(this),groups0["storage"]);	
	})
	//购物车减
	$(".cut").unbind().bind("click",function(){
		cutCar($(this));
	})
}
function showImgNum(i){
	var num = $(".carousel li").size();
	if(i-1 == num) i = 1;
	if( i== 0) i = num;
	$(".imgsNum").text(i+"/"+num);
}

//购物车减
function cutCar($this){
	var num = parseInt($this.next().val());
		$this.next().val(num-1);
		$this.next().val()<=1?$this.next().val(1):$this.next().val(num-1);
		var lastnum = $("#number").val();
		var id = GetQueryString("id");
		changeNum(id,num,$this.prev());
		buynum = lastnum;
}
//购物车加
function addCar($this,storages){
		var num = parseInt($this.prev().val());
		var lastnum = parseInt($("#number").val());
		buynum = lastnum;
		var id = GetQueryString("id");
		console.log(parseFloat(num) > 9999);
		if(parseFloat(num) >= 9999){
			return;
		}else{
			console.log($("#number").val());
			$("#number").val(lastnum + 1);
//		    changeNum(id,num,$this.prev());		
		}
}

//属性页面的数量显示
function showGoodsNum(i){
	$("#number").val(i);
}

//获取网址里的信息
function GetQueryString(name){
		var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
	    var r = window.location.search.substr(1).match(reg);
	    if(r!=null){
	    return  unescape(r[2]);
	    }else{
	     return null;
	    }
	 }
 function ui_toast(msg) {
	if(document.getElementById("zb-toast")) {return;}
	$("<div id='zb-toast' style='position:fixed;top:4rem;padding:1rem;width:60%;left:20%;z-index:1000000;text-align:center;color:white;border-radius: 6px;background-color:rgba(0,0,0,0.75)'>"+ msg +"</div>").appendTo("body");
	setTimeout(function () {		
		$("#zb-toast").show().fadeOut(1000).remove();
	},3000);
	return;
};

//获取商品属性
function getUnitAttr(data,groups0){
	if(data.body.bill.groups[3].fields.length == 0) return;
	var canUseAttr = data.body.bill.groups[3].fields[0].source.table.rows;
	var units = [];
	var unitsNames = [];
	var titles = [];
	var titlesNames = [];
	$.each(canUseAttr,function(){
		var id = this[0],name = this[1],title = this[3],titleId = this[2];
		if (units.indexOf(id)<0) {
			units.push(id);
			unitsNames.push(name);
		}
		if (titles.indexOf(titleId)<0) {
			titles.push(titleId);
			titlesNames.push(title);
		}
	});
	$("#unitDiv").html('');
	//创建单位span
	var div1 = $('<div class="goodsStyle"><p>单位</p></div>');
	$.each(unitsNames, function(p) {    
	 	div1.append($('<span data-aid="0" data-vid="'+units[p]+'">'+unitsNames[p]+'</span>')); 	
		div1.appendTo($("#unitDiv"));
	});

	//创建属性列表
	//创建属性
	for(var i = 0; i<titles.length; i++){
		if(titlesNames[i].length>0){
			var div = $('<div class="goodsStyle"><p>'+titlesNames[i]+'</p></div>');
			div.appendTo($("#unitDiv"));
			var attrs = [];
			$.each(canUseAttr,function(){
				var aid = this[2] , vid = this[4],name = this[5];
				if (aid != titles[i] || attrs.indexOf(vid)>=0) return;
			    div.append('<span data-aid="'+aid+'" data-vid="'+vid+'">'+name+'</span>');
			    attrs.push(vid);
			});
		}
	};

	//属性选择
	$(".goodsStyle").each(function(){
		$(this).find("span").unbind("click").bind('click',function(){	
			if($(this).attr("canClick")=="0") {
				ui_toast("本商品没有此属性组合。");
				return;
			}
			$(this).hasClass("spanLink")?$(this).removeClass("spanLink"):$(this).addClass("spanLink").siblings("span").removeClass("spanLink");
			var $spans = $("span[class='spanLink']");
			var datas = ["{id:'openid',val:'"+localStorage.openID+"'}"];
			$.each($spans,function(){
				var aid,vid;
				datas.push('{id:"'+$(this).attr("data-aid")+'",val:"'+$(this).attr("data-vid")+'"}');
			});
			$.ajax({
				type:"post",
				url:"../GoodsDetail.asp?__msgId=pageload&product="+groups0['product'],
				dataType:"text",
				contentType:"application/zsml",  
				async:true,
				data:'{datas:['+datas.join(',')+']}',
				success:function(otherdata){
					var otherdata = eval("("+otherdata+")");
					$("#buyNow").attr("goodsId",otherdata.body.bill.value);
					var length1 = $("span[class='spanLink']").length;
					var length2 = $(".goodsStyle").length;
						var canUse = otherdata.body.bill.groups[3].fields[0].source.table.rows;
						$(".goodsStyle").find("span").each(function(){    
						var attr_id = parseInt($(this).attr("data-aid")),
							attr_vid = parseInt($(this).attr("data-vid"));
						var result = false;
						for(var k=0;k<canUse.length;k++){
							if(canUse[k][(attr_id == 0?0:4)]==attr_vid){
								result = true;
								break;
							}
						}
						if(!result){
							$(this).attr("canClick","0");	
						}else{
							$(this).attr("canClick","1");
						}
						createCurrentAttr(otherdata);
						createChooseImg(otherdata);
						showMainInfo(otherdata);
					});					
				},
				error:function(req,e,t){
					alert($);
				}
			});
		})
	})	
}

function changeNum(id,newNum){
	datas = '{datas:[{id:"newNum",val:"'+newNum+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
		//修改数量
		$.ajax({
			type:"post",
			url:"../ShopCars.asp?__msgId=changeNum&idType=goods&id="+id+"&kind=increase",
			data:datas,
			contentType:"application/zsml",
			dataType:"text",
			success:function(data){
				data = ("("+data+")");
			}
		});
}

//checkDot(this,4,5)
//控制小数位数
function checkDot($this,num_dot,int_dot){
		if (typeof(num_dot) == "undefined") {
			num_dot = _numDot;
		}
		if(typeof(int_dot) == "undefined"){
			int_dot = 5;	//整数位最大长度默认为5
		}
		var txtvalueObj = $this;
		var re = /[^\d\.]/g;
		if(re.test(txtvalueObj.value)){
			txtvalueObj.value = txtvalueObj.value.replace(/[^\d\.]/g,'');
		}else{
			var txtvalue=txtvalueObj.value;//正则获取的是数字
			if (txtvalue.indexOf('.')>=0){
			var txt1,txt2,txt3;
			txt1=txtvalue.split('.');		
			txt2=txt1[0];
			if(txt2.indexOf('-')>=0){txt2="-"+txt2.replace(/\-/g,'');}
			txt3=txt1[1].replace(/\-/g,'');		
			if (txt2.length==0){
				txt2="0";
			}else{
				if (txt2.length>int_dot){
				//整数部分不能大于5位
					txt2=txt2.substr(0,int_dot);
				}			
			}
			if (txt1.length==2){
				if (txt3.length>num_dot){
				//小数部分不能大于5位
					txt3=txt3.substr(0,num_dot);
				}
			}	
			txtvalueObj.value=txt2+"."+txt3;
		}
		else{
		//整数不能超过5位
			if (txtvalue.length>int_dot){
				txtvalueObj.value=txtvalue.substr(0,int_dot);
			}
			else{
				if (txtvalue.indexOf('-')>=0){
					txtvalueObj.value="-"+txtvalue.replace(/\-/g,'');
				}
			}
		}
	  }
	}	
	

function checkStorage(strorage,num,oldVal){
	if(parseFloat(num)>=parseFloat(strorage)){
		if(isAlert == false && parseFloat(num)>parseFloat(strorage)){
			alert("该商品库存最多购买"+strorage);
		}
		$("#number").val(strorage);
		isAlert = true ;
		return false;
	}else{
		isAlert = false ;
		return true;
	}
}

function createChooseImg(data){
	if(data.body.bill.groups[1].fields.length == 0) return;
	var o = getPro(data.body.bill.groups[1].fields[0].source.table.cols);
	var rows = data.body.bill.groups[1].fields[0].source.table.rows;
	var groups0 = getAttr(data.body.bill.groups[0].fields);
	var dot = window.sysConfig.moneynumber;
	$("#showImg").empty();
	$("#showImg").append('<li class="fl"><div class="chooseImgWrap"><img  src="../../../../Edit/upimages/shop/'+rows[0][o["fpath"]]+'"></div></li>'+
						 '<li class="fl">'+
							'<p class="price1">'+FormatNumber(groups0["price"],dot)+'</p>'+
							'<p class="kuCun">库存:'+groups0["@storageText"]+'</p>'+
						 '</li>');
}