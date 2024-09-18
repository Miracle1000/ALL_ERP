$(function(){
		init();
		$("#pay").attr("canGo","0").css("background","rgb(191,191,191)");
		$("#back").unbind().bind("click",function(){
			window.history.back();
		})
		//全选
		$("#allBtn,#allBtn_1").unbind().bind("click",function(){
			allChoose();
		})	
		//点击编辑 全选删除
		$("#edit").unbind().bind("click",function(){
			$(".allcheckbox").attr("isModify","1");
			var kind = $(this).attr('data-kind');
			if(kind == 'edit'){
				$("#footer").hide();
				$("#footer_1").show();
				$(".lose1").hide();
				$(".lose3").show();
				$(".lose3").addClass('checkbox');
				$(".lose4").removeClass('notShow');
				$(".lose4").addClass('carList');
				$(this).attr('data-kind','complete').text("完成");
			}else{
				$("#footer").show();
				$("#footer_1").hide();
				$(".lose1").show();
				$(".lose3").hide();
				$(".lose3").removeClass('checkbox');
				$(".lose4").addClass('notShow');
				$(".lose4").removeClass('carList');
				$(this).attr('data-kind','edit').text("编辑");
				$(".allcheckbox").attr("isModify","0");
				init();
			}
		})
		$("#footer").delegate("#pay","click",function(){
			var length = $(".carList .checkbox.checked").size();
			var canGo = $("#pay").attr("canGo");
			var numberInput = $("input[type='number'][isSaved='0']");
			if(numberInput.length > 0){
				var id = $("#"+numberInput[0].id.replace("input","car")).attr("car-id");
				var newNum = numberInput.val();
				changeNum(id,newNum,numberInput,function(){
					if(length != 0 && canGo == ""){
						window.location = "html/order.html?tmpf=" + (new Date()).getTime();
					}else{
						createAlert("请选择商品！")
						return false;
					}		
				});
			}else{
				if(length != 0 && canGo == ""){
					window.location = "html/order.html?tmpf=" + (new Date()).getTime();
				}else{
					createAlert("请选择商品！")
					return false;
				}		
			}
		})
})
function alldele(){
	//全部删除
	$("#footer_1").undelegate().delegate("#allDel","click",function(){
		var ids = [];
		var checkboxs = $(".carList .checkbox.checked");
		$.each(checkboxs, function(i) {    
			ids.push($(this).attr("car-id"));                                                          
		});
		createConfirm("确定要删除全部商品吗？",function(){
			var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
			$.ajax({
				type:"post",
				url:"../ShopCars.asp?__msgId=delete&id="+ids.join(","),
				contentType:"application/zsml",
				data:datas,
				success:function(data){
				  data = eval("("+data+")");
				  init();
				  getCarNum();
				  showAllPrice();
				}
			});
			
		},function(){})
//		if(confirm("确定要删除吗？")){
//		}else{
//			return false;
//		}
	})
}

function init(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	//购物车数据请求
	$.ajax({
		type:"post",
		url:"../ShopCars.asp?__msgId=refresh",
		data:datas,
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval('('+data+')');
			if(!data.body && data.success==false){
				alert("温馨提示1:"+data.msg);
				return;
			}else if(data.header && data.header.status==1){
				alert("温馨提示2:"+data.header.message);
				return;
			}
			$("#loadDiv").hide();
			if(data.body.source.table.rows.length != 0){
				var o = getPro(data.body.source.table.cols);
				var rows = data.body.source.table.rows;
				var money;
				$("#carListDiv").empty();
				$.each(rows, function(i) {   
					var $div;
					//此时库存不足或者下架 
					if((rows[i][o["checked"]] == "1" && rows[i][o["storage"]] <= "0")
					|| (rows[i][o["checked"]] == "1" && rows[i][o["onSale"]] == "0")
					|| rows[i][o["onSale"]] == "0"){
						createLose($div,rows,o,i, (rows[i][o["onSale"]] == "0"?"商品已下架":"库存不足"));
					}else if(rows[i][o["storage"]] <= "0" ){
						createLose($div,rows,o,i,"库存不足");
					}else{
						createList(data,$div,rows,o,i);
					}					
				});
				oncreateListEnd();
				$(".allcheckbox").attr("isModify","0");
				$("#pay").attr("canGo","").css("background","#F15352");
				//左滑删除 右滑取消
				leftOrRinght();
				//商品跳转
				$(".name,.goodsImg").unbind().bind("click",function(event){
					var goodid= $(this).attr("data-goodid");
					window.location = "detail.html?id="+goodid;
				})
				//反选
				$(".carList").find(".checkbox").unbind().bind('click',function(){
						reverseChoose(this,$(this));
						allCheck();
				})
				
				$(".lose3").unbind().bind('click',function(){
						reverseChoose(this,$(this));
						allCheck();
				})
				//购物车减
				$(".carList .cut").unbind().bind("click",function(){
					var val = $(this).next().val;
					if(val<1) return;
					cutCar($(this));
				})
				//购物车加
				$(".carList .add").unbind().bind("click",function(){
					var storages = $(this).attr("storages");
					addCar($(this),storages);
				})
				 //全选删除
				 alldele();
			}else{
				$("#carListDiv").empty();
				$("body").css("background","#fff")
				$("#carListDiv").append("<div style='display: block;margin: 5rem auto;text-align:center;width: 18rem;font-size:1.2rem;color:#aaa'>"
				+"<div style='height:8rem;overflow:hidden;text-align:center;'><img src='img/noGoods.jpg' style='height:10rem'></div>"
				+"<br>&nbsp;空空如也.....马上<a href='classfity.html' style='font-size:1.2rem;color:#646464'>【去逛逛】</a></div>")
			}
			showAllPrice();
		},
		error:function(a,b,c){
			alert("温馨提示3:"+JSON.stringify(c))
		}
	});
}
//反选
function reverseChoose(the,$this){
		var id = $this.attr("car-id");
		var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
		if($this.hasClass("checked")){
			$this.removeClass("checked");
			cancelChoose($this,id,datas);
		}else{
			$this.addClass("checked");
			choose($this,id,datas);
		}
		showAllPrice();
}
function allCheck(){
	var num = 0;
	var chooseGoods = [];//商品数量
	var checkboxs = $(".carList").find(".checkbox");
	checkboxs.each(function(i){
		if($(this).hasClass("checked")){
			num++;
			chooseGoods.push($(this));
		}else{
			num = num;
		}
	    if(num==checkboxs.size()){
	    	$(".allcheckbox").removeClass('checked').addClass('checked');
	    }else{
	    	$(".allcheckbox").removeClass('checked');
	    }
	})
}
//全选
function allChoose(){
	var checked = $(".allcheckbox").hasClass("checked");
	
	if(!checked){
		$(".allcheckbox").addClass("checked");
		$(".carList").find(".checkbox").addClass('checked');
	}else{
		$(".carList").find(".checkbox").removeClass('checked');
		$(".allcheckbox").removeClass('checked');
	}
	//if($("#edit").text()=="完成"){return;}
	isChoos(checked);
	showAllPrice();
}
function isChoos(checked){
	//是否为编辑模式 则返回   选中不加入购物清单
	var isModify = $(".allcheckbox").attr("isModify")=='1';
	if(isModify) {
		return;
	};
	var checkboxs = $(".carList .checkbox.checked");
	console.log(checkboxs.length);
	var ids = [];
	$.each(checkboxs, function(i) {    
		ids.push($(this).attr("car-id"));                                                          
	});
	var datas = '{datas:[{id:"openid",val:"'+localStorage.openID+'"}]}';
	$.ajax({
		type:"post",
		url:"../ShopCars.asp?__msgId=checked&id="+ids.join(',')+"&checked=" + (checked?0:1),
//		url:"../ShopCars.asp?__msgId=checked&id="+id="+ids.join(',')+"&checked=" + (checked?0:1),
//		url:"../ShopCars.asp?__msgId=checked&checked=" + (checked?0:1),
		contentType:"application/zsml",
		dataType:"text",
		data:datas,
		success:function(data){
			data = ("("+data+")"); 
		},error:function(a,b,c){
			console.log(a.responseText);
		}
	});
}
//购物车减
function cutCar($this){
	var val = $this.next().val().replace(/,/g,'');
	var dotNum = window.sysConfig.floatnumber;
	var num = FormatNumber(val,dotNum);
		num = FormatNumber(parseFloat(num)-1,dotNum);
		parseFloat(num)<=1?$this.next().val(FormatNumber(1,dotNum)):$this.next().val(num);
	var id = $("#"+$this[0].id.replace("cut","car")).attr("car-id");
 		showAllPrice();
 		changeNum(id,num,$this.next());
}
//购物车加
function addCar($this,strorage){
	var val = $this.prev().val().replace(/,/g,'');
		console.log(val);
	var dotNum = window.sysConfig.floatnumber;
	var num = FormatNumber(val,dotNum);
	var id = $("#"+$this[0].id.replace("add","car")).attr("car-id");
		if(parseFloat(num) >= 9999){
			return;
		}else{
			num = FormatNumber(parseFloat(num)+1,dotNum);
			$this.prev().val(num)
			showAllPrice();
		    changeNum(id,num,$this.prev());		
		}
	    
}
function showAllPrice(){
	var price = 0.00;
	var num = 0;
	var singlePrice;
	var dotNum = window.sysConfig.moneynumber;
	var goods = $(".carList").find(".checkbox");
	if(goods.size() != 0){
		var checkGoods = $(".carList").find(".checkbox.checked");
		if(checkGoods.size() != 0){
			$.each(checkGoods,function(i){
				try{
					num = $(this).parent().parent().find("input").val().replace(/,/g,'');
				}catch(e){
					num = 0;
				}
				singlePrice = $(this).attr("data-price");
				price += parseFloat(num*singlePrice);
			})
			$(".all-price").text(FormatNumber(price,2));
		}else{
			$(".all-price").text(0.00);
		}
	}else{
		$(".all-price").text(0.00);
	}
}
//左滑删除
function delGoods($this,i){
	var h = $(".goodsWrap")[0].offsetHeight;
	$(".del").eq(i).unbind().bind("click",function(){ 
		var $this = $(this);
		createConfirm("确定要删除该商品吗？",function(){
			var id = $this.attr("car-id");
			var o = $this.parent();
			var h = $(".goodsWrap")[0].offsetHeight;
			o.animate({"left":h+600+"px"},50,function(){
				$this.slideUp();
				$this.empty();
				var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
				$.ajax({
					type:"post",
					url:"../ShopCars.asp?__msgId=delete&id="+id,
					contentType:"application/zsml",
					data:datas,
					success:function(data){
					  data = eval("("+data+")");
					  init();
					  getCarNum();
					}
				});
			})
			
		},function(){})
//		if(confirm("确定要删除吗？")){
//		}else{
//			return false;
//		}
	})
}
//控制小数位数
function checkDot($this,num_dot,int_dot){
		if (typeof(num_dot) == "undefined") {
			num_dot = _numDot;
		}
		if(typeof(int_dot) == "undefined"){
			int_dot = 5;	//整数位最大长度默认为5
		}
		var txtvalueObj = $this;
		//正则获取的是数字
		var re = /[^\d.]/g;
		if(re.test(txtvalueObj.value)){
			txtvalueObj.value = txtvalueObj.value.replace(/[^\d\.]/g,'');
		}else{
			var txtvalue = txtvalueObj.value;
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
function checkStorage(strorage,num,index,oldVal){
	if(parseFloat(num)>parseFloat(strorage)){
		alert("该商品库存最多购买"+strorage);
		$("input.list-num").eq(index).val(oldVal);
		return false;
	}else{
		return true;
	}
}

function changeNum(id,newNum,$this,callback){
	datas = '{datas:[{id:"newNum",val:"'+newNum+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
	//修改数量
	$.ajax({
		type:"post",
		url:"../ShopCars.asp?__msgId=changeNum&id="+id,
		data:datas,
		contentType:"application/zsml",
		dataType:"text",
//		async:false,
		success:function(data){
			if(callback) callback.call(this,[])
		}
	});
}

//取消选择
function cancelChoose($this,id,datas){
	$.ajax({
		type:"post",
		url:"../ShopCars.asp?__msgId=checked&id="+id+"&checked=0",
		contentType:"application/zsml",
		dataType:"text",
		data:datas,
		success:function(data){
			data = ("("+data+")");
		}
	});
}
//选择
function choose($this,id,datas){
	$.ajax({
		type:"post",
		url:"../ShopCars.asp?__msgId=checked&id="+id+"&checked=1",
		contentType:"application/zsml",
		dataType:"text",
		data:datas,
		success:function(data){
			data = ("("+data+")"); 
			console.log($this.parent().next());
			num = $this.parent().next().find("input").val();
//			changeNum(id,num);
		}
	});
}

function errpic(img) {
	if(img.getAttribute("iserror")!="1") {
		img.setAttribute("iserror","1");
		img.src = "img/nopic100.jpg";
		img.style.height = "60px";
		img.style.width = "55px";
	}
}

//创建订单失效页面
function createLose($div,rows,o,i,msg){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	//取消原来的选择状态
	var dot = window.sysConfig.SalesPriceDotNum;
	money = rows[i][o["price"]].replace(/,/g,"");
	$div = $('<ul class="goodsWrap lose4 notShow" id="goodsWrap_' + i + '">'+	
				'<li class="carCheck">'+
					'<span class="lose1">失效</span>'+
					'<span class="lose3" style="display:none;" id="car_span_' + i + '" car-id="'+rows[i][o["id"]]+'" data-goodid="'+rows[i][o["goodsId"]]+'"data-price="'+money+'"></span>'+
				'</li>'+
				'<li data-src="detail.html" class="goodsImg" data-goodid="'+rows[i][o["goodsId"]]+'">'+
					'<img onerror="errpic(this)" src="../../../../Edit/upimages/shop/'+getImgPath(rows[i][o["photo"]]).middle+'">'+
				'</li>'+
				'<li class="goodsInfo">'+
					'<p class="intro"><span class="name" data-goodid="'+rows[i][o["goodsId"]]+'">'+rows[i][o["name"]]+'</span></p>'+
					'<div class="cb">'+
						'<p class="carGoodsPrice" >￥'+FormatNumber(money,dot)+'</p>'+
						'<div class="calcuDiv"  data-storage="'+rows[i][o["storage"]]+'">'+
							'<span id="goodsWrap_' + i + '_lose2" class="lose2">'+msg+'</span>'+
						'</div>'+
					'</div>'+
				'</li>'+
				'<div class="del" id="goodsWrap_' + i + '_del"  car-id='+rows[i][o["id"]]+'>删除</div>' + 
			'</ul>');
	$("#carListDiv").append($div);
	var h = $("#goodsWrap_" + i)[0].offsetHeight;
	$("#goodsWrap_" + i + "_del").css({"height":h+"px","width":h+"px","line-height":h+"px","right":"-"+h+"px"});
	$("#goodsWrap_" + i + "_lose2").parent().css("border","none");
}
//创建正常订单
function createList(data,$div,rows,o,i){
    var dot = window.sysConfig.SalesPriceDotNum;
	//attributes属性
	money = rows[i][o["price"]].replace(/,/g,"");
	$div = $('<ul class="goodsWrap carList" id="goodsWrap_' + i + '" numer="'+rows[i][o["num1"]]+'" isCheck="'+data.body.source.table.rows[i][o["checked"]]+'">'+	
				'<li class="carCheck"><span class="checkbox" id="car_span_' + i + '" car-id="'+rows[i][o["id"]]+'" data-goodid="'+rows[i][o["goodsId"]]+'"data-price="'+money+'"></span></li>'+
				'<li data-src="detail.html" class="goodsImg" data-goodid="'+rows[i][o["goodsId"]]+'">'+
					'<img onerror="errpic(this)" src="../../../../Edit/upimages/shop/'+getImgPath(rows[i][o["photo"]]).middle+'">'+
				'</li>'+
				'<li class="goodsInfo">'+
					'<p class="intro"><span class="name" data-goodid="'+rows[i][o["goodsId"]]+'">'+rows[i][o["name"]]+'</span></p>'+
					 '<p class="attributes">'+rows[i][o["attributes"]]+'</p>'+
					'<div class="cb">'+
						'<p class="carGoodsPrice" >￥'+FormatNumber(money,dot)+'</p>'+
						'<div class="calcuDiv"  data-storage="'+rows[i][o["storage"]]+'">'+
							'<span class="cut" id="cut_span_' + i + '"></span>'+
							'<input  dataType="number" type="number" value="'+rows[i][o["num1"]].replace(/,/g,"")+'" class="list-num" style="width:4rem;border:1px solid #ccc" id="input_span_' + i + '"/>'+
							'<span class="add" id="add_span_' + i + '" storages="'+rows[i][o["storage"]]+'"></span>'+
						'</div>'+
					'</div>'+
				'</li><li class="del" id="goodsWrap_' + i + '_del" car-id='+rows[i][o["id"]]+'>删除</li>'+
			'</ul>');
	$("#carListDiv").append($div);
	var h = $("#goodsWrap_" + i)[0].offsetHeight;
	var ulWidth = window.screen.width+h;
	$("#goodsWrap_" + i + "_del").css({"height":h+"px","width":h+"px","line-height":h+"px","right":"-"+h+"px","display":"none"});
}

function oncreateListEnd() {
	var inputs = $("input[type='number']");
	var dot =window.sysConfig.floatnumber;
	$.each(inputs, function(i) {   
		checkDot(this,dot,4);                                                         
	});
	$.each($(".carList"),function(i){
		//是否选中状态
		var checked = $(this).attr("isCheck");
		if(checked=="1"){
			$(this).find(".checkbox").addClass("checked");
			showAllPrice();
		}else{
			$(this).find(".checkbox").removeClass("checked");
		}
	})
	allCheck();
	window.onbeforeunload = function(e){
		$("input[type='number'][isSaved='0']").trigger('blur');
	}

	//对数量加减号相关操作
	$("input[type='number']").attr('isSaved','1')
	.unbind().bind("keydown",function(){
		$(this).attr("oldVal",$(this).val()).attr('isSaved','0');
		var id = $("#"+this.id.replace("input","car")).attr("car-id");
		checkDot(this,dot,4);
	}).bind("keyup",function(){
		var index = $(this).index("input");
		var stor = $(this).parent().attr("data-storage");
		var id = $("#"+this.id.replace("input","car")).attr("car-id");
		checkDot(this,dot,4);
	}).blur(function(){
		$(this).attr('isSaved','1');
		$(this).val()==''?$(this).val("1.00"):$(this).val();
		$(this).val()==0?$(this).val("1.00"):$(this).val();
		showAllPrice();
		var id = $("#"+this.id.replace("input","car")).attr("car-id");
		var stor = $(this).parent().attr("data-storage");
		changeNum(id,$(this).val(),$(this));
		checkDot(this,dot,4);
	}).focus(function(){
		  var me=this;setTimeout(function(){(me.select())},10);
	})
}

//左滑删除 右滑取消
function leftOrRinght(){
	var h = $(".goodsWrap")[0].offsetHeight;
	$(".goodsWrap").swipe({
		swipeLeft: function() { 
			var i = $(this).index(".goodsWrap");
			$(".del").eq(i).show();
			$(this).css({"background":"#F8F8F8"}).animate({"left":"-"+h+"px"},100);
			delGoods($(this),i);
		},
	  	swipeRight: function() { 
	  		var i = $(this).index(".goodsWrap");
			$(this).css({"background":"#fff"}).animate({"left":0},100,function(){
				$(".del").eq(i).hide();
			})
	  	}
	});
}