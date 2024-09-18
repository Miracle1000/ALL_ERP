var flag = false;
var pageNum = 1;
var s1 = 0;

//函数.创建生成列表
function createList(data){
	var title = GetQueryString("title");
	if(title && title!="null"){	document.title = title;	}	
	var o = getPro(data.body.source.table.cols)
	var mydata = data.body.source.table.rows;
	var dot;
	$("#loadDiv").hide();
	$.each(mydata, function(i) {    
	    dot = window.sysConfig.SalesPriceDotNum;
		var fig = $('<figure class="cb" data-id="'+mydata[i][o["id"]]+'" >'+
						'<div class="goodsImg fl"><img  src="../../../../../Edit/upimages/shop/'+mydata[i][o["photo"]]+'"></div>'+
						'<figcaption class="pst fr">'+
							'<p class="intro">'+mydata[i][o["name"]]+'</p>'+
							'<p class="goodsPrice">'+mydata[i][o["price"]]+'</p>'+
						'</figcaption>'+
					'</figure>');
		$("#searchList").css("background","#F3F5F7").append(fig);
	});
	var	h = $("#searchList").height();
	var screenH = window.screen.height;
	h >= screenH?$("#top").show():$("#top").hide();
}

//函数.加载列表
function loadMore(name,obj,pageNum){
	var datas="{datas:[{id:'"+name+"',val:'"+obj.replace("QrUrlzzzzzzzz","QrUrl=")+"'},{id:'openid',val:'"+localStorage.openID+"'},{id:'pageindex',val:'"+pageNum+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../GoodsList.asp?__msgId=refresh",
		contentType:"application/zsml", //用网址访问时 加上这句话
		dataType:"text",
		processData:false,
		success:function(data){
			data = eval("("+data+")");
			if(data.header.status!=0) { alert("温馨提示4:"+data.header.message); return; }
			$("#searchDiv").hide();
			$("#searchList").show();
			if(data.body.source.table.rows.length != 0){
				$("#searchList").css("background","#fff");
				if(pageNum==1){
					$("#searchList").empty();
				}
				createList(data);  //创建列表
				var allpage = data.body.source.table.page.pagecount;
				doScroll(allpage);
			}else{
				$("#orderList").empty();
				$("#top").hide();
				$("#searchList").css("background","#fff").html('<img src="../img/noNeedOrder.png" style="display: block;margin: 3rem auto;width:12rem;">');
			}
			flag = true;
		},
		error:function(){
			console.log("ajax erro");
		}
	});
}

//函数.搜索按钮点击事件
function onSearchButtonClick() {
	var searBtn = $("#al-search");
	var searTxt = searBtn.val();
	if(searTxt){
		if(window.bindSearchHistory) { window.bindSearchHistory("al-search"); }
		$("#showSearch").val(searTxt);
		pageNum = 1
		loadMore("searchKey",searTxt,pageNum);
	}
}

//函数.搜索文本框点击事件
function onShowSearch_Click(evt) {
	$("#searchDiv").show();
	var searBtn = $("#al-search");
	searBtn.focus();
	searBtn.unbind().bind("keydown",function(){
		if(event.keyCode==13){$("#search").click();}
	});
}

//函数.控制滚动加载
function doScroll(allpage){
	var direction = 'up';
	window.onscroll = function(){
		var id = GetQueryString("id")
		if (pageNum >= allpage) return;
		var scrollT = document.documentElement.scrollTop || document.body.scrollTop;//ios doc.body 取不到滚动值，安卓doc.doc...取不到滚动值 
		direction = s1 - scrollT < 0 ? 'up' : 'dowm';
		s1 = scrollT;
		flag = true;
		if(direction != "up"){
			return false;
		}
		if(flag){
			var scrollHeight = document.documentElement.scrollHeight;
			var scrollTop = scrollT + window.innerHeight;
			console.log(scrollHeight-scrollTop);
			if(scrollHeight-scrollTop <= 0){
				flag = false;
			    pageNum++;
			    var searchKey = GetQueryString("result");
				var groupId = GetQueryString("groupId");
				if(searchKey){
					loadMore("searchKey",searchKey,pageNum);
				}
				else if(groupId){
					loadMore("groupId",groupId,pageNum);
				}
			    if(pageNum === allpage){
			        $(".goodsList").append("<p style='text-align:center;font-size:12px;padding:5px;color:#F15352'>亲，已经到底部啦</p>")
			    }
			}else{
				
			}
		}
		
	}
}


$(function(){
		var searchKey = GetQueryString("result");
		var groupId = GetQueryString("groupId");
		if(searchKey){
			try{
				if(GetQueryString("ScanQR") != 1) {
					$("#showSearch").val(searchKey);
					$("#al-search").val(searchKey);
				}
			}catch(e){}
			loadMore("searchKey",searchKey,pageNum);
		}
		else if(groupId){
			loadMore("groupId",groupId,pageNum);
		}
		$("#back").unbind().bind("click",function(){
			window.history.back();
		})
		$("#indexback").unbind().bind("click",function(){
			$("#searchDiv").hide();
			$("#searchList").show();
		})
		//绑定搜索文本框点击事件
		$("#showSearch").click(onShowSearch_Click);
		//绑定搜索按钮点击事件
		$("#search").click(onSearchButtonClick)
		//点击每个商品跳商品详情
		$("#searchList").delegate("figure","click",function(event){
			window.location = "../detail.html?id="+$(this).attr("data-id");
		})
		$("#searchList").delegate("span","click",function(event){
			if(event.target.tagName== 'SPAN'){
				var img = $("<div class='addCarImg'><img  src='"+$(this).attr("data-photo")+"' >");
				img.appendTo($(this).parent());
				setTimeout(function(){
					img.hide();
				},1000);
				//加入购物车请求ajax
				var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
				$.ajax({
					type:"post",
					data:datas,
					url:"../../ShopCars.asp?__msgId=addToCars&id="+$(_this).attr("data-id"),
					dataType:"text",
					contentType:"application/zsml",
					success:function(data){
						console.log("add success");
					}
				});
			}else{
				return false;
			}
		})
})