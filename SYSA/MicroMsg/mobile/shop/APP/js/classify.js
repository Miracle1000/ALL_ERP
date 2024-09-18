var flag = false;
var pageNum = 1;
$(function(){
	$("#back").click(function(){
		window.history.back();
	})
	var bottom_h = $(".footer").height();
	var top_h = $("header").height();
	var winH = $(window).height();
	var hei = winH - top_h - bottom_h-10;
	$(".listWrap,.listNav").css("height",hei+"px");
	//出现加载页面
	$("#loadDiv").show();
	$("#top").hide();
	getCarNum();
	Goods.init();
	//加载分类  页面初始化
	getTitle();
	//搜索显隐
	search();
	//搜索显隐
	$("#showSearch").click(function(){
		$("#searchDiv").show();
		var searBtn = $("#al-search");
		searBtn.focus();
		searBtn.unbind().bind("keydown",function(){
			if(event.keyCode==13){$("#search").click();}
		});
		$("#search").click(function(){
			searTxt = searBtn.val();
			if(searTxt){
				window.bindSearchHistory("al-search");
				window.location = "html/goodList.html?result="+encodeURIComponent(searTxt);
			}
		 })
	})
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
				window.localStorage.scrollGoodsTopHeight=this.offsetTop -$(this).position().top;
				that.change(src);
			}else {
				return false;
			}
		})
		var carPhotos = $(".carPhoto");
		$(".goodsList").delegate("span","click",function(event){
			that.j++
			if(event.target.tagName== 'SPAN'){
				var _this = this;
				var $fig = $(this).parentsUntil("figure.cb").last().prev();
				var imgsrc = $(this).parent().attr("data-imgsrc");
				that.addCar(imgsrc,_this,$fig,parseInt(that.j));
			}else{
				return false;
			}
		})
	},
	change:function(src){
		window.location = src;
	},
	addCar:function(imgsrc,_this,fig,j){
		var id = $(_this).attr("data-id");
		addShopToCar(id, fig[0].getElementsByTagName("IMG")[0], 1); //加入购物车请求ajax
	}
}
//scroll事件  加载
var s1 = 0;
function doScroll(allpage){
	var direction = 'up';
	$(".goodsList")[0].onscroll = function(){
		if(pageNum >= allpage) return;
		direction = s1 - $(".goodsList")[0].scrollTop < 0 ? 'up' : 'dowm';
		s1 = $(".goodsList")[0].scrollTop;
		if(direction != "up"){return false;}
		if(flag==false){
			var scrollHeight = document.documentElement.scrollHeight;
			var scrollTop = $(".goodsList")[0].scrollTop + $(".goodsList").height();
			if(scrollHeight-scrollTop <= 100){
			    pageNum++;
			    var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'},{id:'sort',val:'"+window.localStorage.oldSortID+"'},{id:'pagesize',val:'20'},{id:'pageindex',val:'"+pageNum+"'}]}";
			    getLoad(pageNum,datas);
			}
		}
		
	}
}
//获取列表f
function createList(data){
	var o = getPro(data.body.source.table.cols);
	var mydata = data.body.source.table.rows;
	var dot = window.sysConfig.SalesPriceDotNum;
	$.each(mydata, function(i){	
		var fig = $('<figure class="cb" style="border-bottom:1px solid #F3F4F6"  data-src="detail.html?'+Math.random()+'&id='+mydata[i][o['id']]+'">'+
					'<div class="goodsImg" style="width:8rem;float:left;border:1px solid #ccc"><img class="mainimg" src="../../../../Edit/upimages/shop/'+getImgPath(mydata[i][o["photo"]]).middle+'"></div>'+
					'<figcaption style="width:60%;float:right">'+
						'<p class="intro" style="padding-left: 1rem">'+mydata[i][o["name"]]+'</p>'+
						'<p class="goodsPrice" style="padding-left: 1rem">'+FormatNumber(mydata[i][o["price"]],dot)+'</p>'+
						'<p data-imgsrc="../../../../Edit/upimages/shop/'+getImgPath(mydata[i][o["photo"]]).middle+'"><span data-stor="'+mydata[i][o["storage"]]+'" data-id='+mydata[i][o["id"]]+' class="carPhoto"></span></p>'+
					'</figcaption>'+
				'</figure>');
		$(".goodsList").append(fig);
	});
	$("#loadDiv").hide();
	$("#top").show();
	$("#changeLoad").hide();
}

//获取左侧tab导航
function getTitle(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		contentType:"application/zsml",//用网址访问时 加上这句话
		url:"../SortList.asp?__msgId=refresh",
		dataType:'text',
		success:function(data){
			data = eval('('+data+')');
			if(!data.body && data.success==false){
				alert(data.msg);
				return;
			}else if(data.header && data.header.status==1){
				alert(data.header.message);
				return;
			}
			if(data.body.source.table.cols != 0){
				$(".listNav").empty();
				var o = getPro(data.body.source.table.cols);
				var mydata = data.body.source.table.rows;
				$.each(mydata, function(i){    
					var li = $('<li data-id='+mydata[i][o["id"]]+'>'+mydata[i][o["name"]]+'</<li>');
					if(i==0){
						li.addClass("navLink");
					}
					$(".listNav").append(li);  
				});
				doClick();
				if(window.localStorage.oldSortIndex){
					$(".listNav").scrollTop(window.localStorage.scrollTopHeight);
					$(".listNav li").eq(window.localStorage.oldSortIndex).trigger("click");
				}else{
					$(".listNav li").eq(0).trigger("click");
				}
			}else{
				$(".listWrap").html("<p style='text-align:center; font-size:1.2rem'>获取列表失败</p>");
			}
		},
		error:function(a,b,c){
			console.log("获取分类失败:"+b);
		},
	});
}
function doClick(){
	//点击左侧导航分类切换
		$(".listNav").delegate("li","click",function(){
			$(this).addClass("navLink").siblings().removeClass("navLink");
			var id = $(this).attr("data-id");
			window.localStorage.oldSortID = id;
			window.localStorage.oldSortIndex =$(this).index();
			window.localStorage.scrollTopHeight =this.offsetTop -$(this).position().top;
			var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'},{id:'sort',val:'"+id+"'}]}";
			pageNum = 1;
			$(".goodsList").animate({scrollTop:0},200); 
			getLoad(pageNum,datas);
		})
}
function getLoad(pageNum,datas){
	console.log(pageNum);
	$("#changeLoad").show();
	flag = true;
	$.ajax({
		type:"post",
		url:"../GoodsList.asp?__msgId=refresh",
		dataType:"text",
		contentType:"application/zsml",
		processData:false,
		data:datas,
		async:false,
		success:function(data){
			data = eval('('+data+')');
			console.log(pageNum);
//			alert(JSON.stringify(data.body.source.table.rows))
			if(pageNum==1){
				$(".goodsList").empty();
			}
			if(!data.body.source) return;
			if(data.body.source.table.rows != 0){
				createList(data);
				var pageindex = data.body.source.table.page.pageindex;
				var allpage = data.body.source.table.page.pagecount;
//				alert(JSON.stringify(data.body.source.table.page))
				var length = $(".goodsList figure").length;
				console.log("pageindex -----"+pageindex+" allpage----"+allpage);
				if(pageindex >= allpage && length>=6){
			        $(".goodsList").append("<p style='margin-bottom: 3rem;text-align:center;font-size:12px;padding:5px;color:#F15352'>亲，已经到底部啦</p>")
			    	return;
				}
				doScroll(allpage);
				//获取总页码
			}else{
				$("#loadDiv").hide();
				$("#top").show();
				$("#changeLoad").hide();
				$(".goodsList").append('<img src="img/noList.png" style="display: block;margin:2rem auto;;width: 14rem;">');
			}
			if(window.localStorage.scrollGoodsTopHeight){
				if($(".goodsList").scrollTop()+10 <window.localStorage.scrollGoodsTopHeight){
					$(".goodsList").scrollTop(window.localStorage.scrollGoodsTopHeight);
				}else{
					window.localStorage.removeItem("scrollGoodsTopHeight");
				}
			}
			flag = false;
		}
	});
}
function search(){
	$("#showSearch").click(function(){
	 	$("#searchDiv").show();
	 	$("#search-input").blur(function(){
	 		var searTxt = $("#search-input").val().replace(/\s+/g,"");
			if(searTxt != ""){
				$(".right-btn").find("img").attr({"src":"img/searc.png","id":"search"});
				$("#search").click(function(){
					window.location = "html/goodList.html?result="+encodeURIComponent(searTxt);
				})
			}else{
				$(".right-btn").find("img").attr({"src":"img/brush.png","id":"sweep"});
			}
		}).focus(function(){
			$(".right-btn").find("img").attr({"src":"img/searc.png","id":"search"});
		})
	 })
	 $("#indexback").click(function(){
	 	$("#searchDiv").hide();
	 })
}
//获取控件坐标
function GetObjectPos(element,model) {
    if (arguments.length > 2 || element == null) {
        return null;
    }
    var elmt = element;
    var offsetTop = elmt.offsetTop;
    var offsetLeft = elmt.offsetLeft;
    var offsetWidth = elmt.offsetWidth;
    var offsetHeight = elmt.offsetHeight;
    elmt = elmt.offsetParent;
    while (elmt) {
		// add this judge 
		if (model!=1)
		{	
			if (elmt.style.position == 'absolute' || elmt.style.position == 'relative'
				|| (elmt.style.overflow != 'visible' && elmt.style.overflow != '')) {
				//break;  Binry.2014.2.13.暂时注释, 如别的div
			}
		}

		offsetTop += elmt.offsetTop;
		offsetLeft += elmt.offsetLeft;
		 elmt = elmt.offsetParent;
    }	
    return { top: offsetTop, left: offsetLeft, width: offsetWidth, height: offsetHeight };
} 