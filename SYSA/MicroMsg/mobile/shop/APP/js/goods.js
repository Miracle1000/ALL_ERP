$(function(){
	
		Goods.init();
		$(".listNav").delegate("li","click",function(){
			$(".goodsList").empty();
			$(this).addClass("navLink").siblings().removeClass("navLink");
			var id = $(this).attr("data-id");
			console.log(id);
			$.ajax({
				type:"post",
				url:"../GoodsList.asp?__msgId=refresh",
				dataType:"text",
				contentType:"application/zsml",//用网址访问时 加上这句话
				processData:false,
				data:'{datas: [{id:"sort",val:'+id+'}]}',
				success:function(data){
					data = eval('('+data+')');
					console.log(data);
					var o = getPro(data.body.source.table.cols);
					var mydata = data.body.source.table.rows;
					$.each(mydata, function(i) {    
					console.log(mydata);
					var fig = $('<figure  data-src="detail.html?id='+mydata[i][o["id"]]+'>'+
									'<div class="col-xs-3 goodsImg"><img src="'+mydata[i][o["photo"]]+'"></div>'+
	  								'<figcaption class="col-xs-9 pst">'+
										'<p class="intro">'+mydata[i][o["name"]]+'</p>'+
										'<p class="goodsAttr">'+mydata[i][o["name"]]+'</p>'+
										'<p class="goodsPrice">'+mydata[i][o["price"]]+'</p>'+
										'<p data-imgsrc="img/demo.png"><span data-id='+mydata[i][o["id"]]+' class="glyphicon glyphicon-shopping-cart"></span></p>'+
									'</figcaption>'+
								'</figure>');
					$(".goodsList").append(fig);
				});
				}
			});
		})
		//加载分类
		getTitle();
		//加载分类页面
		getGoodsData();
	
})
//商品跳转
var Goods = {
	btn:$(".goodsList figure"),
	j :0,//暂定点击次数
	init:function(){
		var that = this;
		$(".goodsList").delegate("figure","click",function(event){
			if(event.target.tagName!= 'SPAN'){
				var src = $(this).attr("data-src");
				that.change(src);
			}else {
				return false;
			}
		})
		$(".goodsList").delegate("span","click",function(event){
			that.j++
			if(event.target.tagName== 'SPAN'){
				var _this = this;
				var imgsrc = $(this).parent().attr("data-imgsrc");
				that.addCar(imgsrc,_this,parseInt(that.j));
			}else{
				return false;
			}
		})
	},
	change:function(src){
		window.location = src;
		console.log(src);
	},
	addCar:function(imgsrc,_this,j){
		var img = $("<div class='addCarImg'><img  src='"+imgsrc+"' >");
		img.appendTo($(_this).parent());
		setTimeout(function(){
			img.css("display","none");
		},1000);
		//请求ajax
		$.ajax({
			type:"get",
			url:"../ShopCars.asp?__msgId=addToCars&id="+$(_this).attr("data-id"),
			dataType:"text",
			contentType:"application/zsml",
			success:function(data){
				
			}
		});
		getCarNum();
	}
}

function getGoodsData(){
	$.ajax({
		type:"get",
		contentType:"application/zsml",//用网址访问时 加上这句话
		url:"../GoodsList.asp?__msgId=refresh",
		dataType:"text",
		success:function(data){
			data = eval('('+data+')');
			var o = getPro(data.body.source.table.cols)
			var mydata = data.body.source.table.rows;
			$.each(mydata, function(i) {    
				var fig = $('<figure data-src="detail.html">'+
									'<div class="col-xs-3 goodsImg"><img src="img/demo.png"></div>'+
	  								'<figcaption class="col-xs-9 pst">'+
										'<p class="intro">'+mydata[i][o["name"]]+'</p>'+
										'<p class="goodsAttr">不锈钢金属边框、5英寸窄边</p>'+
										'<p class="goodsPrice">'+mydata[i][o["price"]]+'</p>'+
										'<p data-imgsrc="img/demo.png"><span data-id='+mydata[i][o["id"]]+' class="glyphicon glyphicon-shopping-cart"></span></p>'+
									'</figcaption>'+
								'</figure>');
				$(".goodsList").append(fig);
			});
		},
		error:function(){
			console.log("erro");
		},
	});
}
function getTitle(){
	$.ajax({
		type:"get",
		contentType:"application/zsml",//用网址访问时 加上这句话
		url:"../SortList.asp?__msgId=refresh",
		dataType:'text',
		success:function(data){
			data = eval('('+data+')');
			var o = getPro(data.body.source.table.cols)
			var mydata = data.body.source.table.rows;
			$.each(mydata, function(i){    
				var li = $('<li data-id='+mydata[i][o["id"]]+'>'+mydata[i][o["name"]]+'</<li>');
				if(i==0){
					li.addClass("navLink");
				}
				$(".listNav").append(li);                                                          
			});
		},
		error:function(a,b,c){
			console.log("获取分类失败:"+b);
		},
	});
}
//获取字段
function getPro(arr){
	var o = {};	
	for(var k=0;k<arr.length;k++){
		o[arr[k].id] = k;
	}
	return o;
} 
