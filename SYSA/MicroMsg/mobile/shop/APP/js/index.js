
$(function(){
	 getData();
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
				window.location = "html/goodList.html?result="+encodeURIComponent(searTxt)+"&"+Math.random();
			}
		})
	 })
	 $("#indexback").click(function(){
	 	$("#searchDiv").hide();
	 })
	//banner
	 $("#carousel").swipe({
	  swipeLeft: function() { $(this).carousel('next'); },
	  swipeRight: function() { $(this).carousel('prev'); }
	 });	
})
//页面初始化
function getData(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../home.asp?__msgId=pageload",
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval('('+data+')');
		    var otherData = [];//除分类以外的商品
		    var banData ;
		    $.each(data.body.bill.groups,function(i){
		    	if(this.id.indexOf("banner") != 0){
		    		if(!this.fields[0] || !this.fields[0].source) return;
		    		otherData.push({title:this.caption,type:'other',datas:this.fields,groupId:this.id.split('_')[1]});
		    	}else{
		    		if(!this.fields[0] || !this.fields[0].source) return;
		    		var banArr = this.fields[0].source.table.cols;
					var  banO = getPro(banArr);
					var _banData = this.fields[0].source.table.rows;
					//banner部分创建
					$(".carousel-inner").empty();
					$(".carousel-indicators").empty();
					$.each(_banData, function(i) { 
						if(i <= 3){	
							var $li = $('<li class="item" style="background: url(../../../../Edit/upimages/shop/'+_banData[i][banO["photo"]]+') no-repeat center center;height:18rem;width:100%;z-index:1;position: fixed;background-size: cover;"></li>');
							//点击banner图片跳转页面
							$li.click(function(){
								window.location = _banData[i][banO["link"]];
							})
							$(".carousel-inner").append($li);
							var $circle = $('<li data-target="#carousel" data-slide-to="'+i+'"></li>');
							$(".carousel-indicators").append($circle);
							$(".item").eq(0).addClass('active');
							$("li[data-target='#carousel']").eq(0).addClass('active');
						}else{
							return;
						}
					});
		    	}
		    });
			createTitle(otherData);
			//点击商品页面跳转
			$('#main').find("figure").bind('click',function(){
	        	window.location = "detail.html?id="+ $(this).attr('gid');
			});
			$("#loadDiv").hide();
			getCarNum();
		},
		error:function(a){
			console.log(a);
		}
	});
}

//创建商品//商品部分创建
function createTitle(otherData){
	$.each(otherData,function(i){  
				if(otherData[i].datas.length != 0){	
					var _data = otherData[i].datas[0].source.table.rows;
					var div = $('<div class="container goodlist" ></div>');
					var title = $('<p class="big20 cb" style="padding: 3px 0;"  >'+
						 			'<span class="fl goodsTitle">'+otherData[i].title+'</span>'+
                                    (_data.length > 1 ? '<span class="fr morebtn" groupId="' + otherData[i].groupId + '" data-title="' + otherData[i].title + '"> 更多<em class="moreImg"></em> </span>' : '') +
						 		  '</p>');
					div.append(title);
					//点击"更多"列表
					setTimeout(function () {
					    $(".morebtn").unbind().bind("click", function () {
					        window.location = "html/goodList.html?groupId=" + $(this).attr("groupId") + "&title=" + $(this).attr("data-title");
					    })
					}, 300);
					var arr = otherData[i].datas[0].source.table.cols;
					var  o = getPro(arr);
					var dot = window.sysConfig.SalesPriceDotNum;
					for(var j = 0; j < 4 && j <_data.length; j++){
						var figure=$('<figure gid="'+_data[j][o["id"]]+'">'+
										'<div class="imgDiv"><img class="banImg" src="../../../../Edit/upimages/shop/'+getImgPath(_data[j][o["photo"]]).middle+'"></div>'+
								 		'<figcaption>'+
								 			'<p>'+_data[j][o["name"]]+'</p>'+
								 			'<p>￥'+_data[j][o["price"]]+'</p>'+
								 		'</figcaption>'+
						 			 '</figure>');
				        div.append(figure);
				 	};	
				}
				 $("#main").append(div);
		});
		$("#main").css("height",$("#main").height()+80+"px") ;

}