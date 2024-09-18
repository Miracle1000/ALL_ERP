$(function(){
		$("body").css("background","#f4f4f5");
		$("#addrback").unbind().bind("click",function(){
			window.history.back();
		})
		init();
		//点击收货地址新建
		$(".newAddress").click(function(event){
			var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
			$.ajax({
				type:"post",
				url:"../../ShopOrderConfirm.asp?__msgId=checkBind",
				dataType:"text",
				data:datas,
				contentType:"application/zsml",
				success:function(data){
					data = eval("("+data+")");
					window.location = "newAddress.html?1";
				},error:function(a,b,c){
					alert(c)
				}
			});
		})	
})

function init(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		url:"../../Shop_AddressList.asp?__msgId=refresh",
		dataType:"text",
		data:datas,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(data.body.source.table.rows.length != 0){
				$("#addressList").empty();
				var o = getPro(data.body.source.table.cols);
				var rows = data.body.source.table.rows;
				$.each(rows, function(i) {    
					var $ul = $('<ul style="clear:both;overflow:hidden;">'+
								'<li style="clear:both;overflow:hidden" class="haveAddr">'+
									'<span class="receiver"><i class="userI"></i> '+rows[i][o["receiver"]]+'</span>'+
									'<span class="photoImg text-right"><i class="phoneI"></i> '+rows[i][o["mobile"]]+'</span>'+
								'</li>'+
								'<li style="line-height: 2;clear:both;overflow:hidden;">'+
									'<span style="color:#646869" class="col-xs-12 text-left">'+rows[i][o["address"]]+'</span>'+
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
											'<span class="glyphicon glyphicon-trash" ></span><em class="editWords">删除</em>'+
										'</span>'+								
									'</div>'+
								'</li>'+
								'</ul>');
					$("#addressList").css("background","#fff").append($ul);
					//添加默认地址
					if(rows[i][o["isDefault"]]==1){
						$(".defaultBtn").eq(i).addClass("default");
					}else{
						$(".defaultBtn").eq(i).removeClass("default");
					}
				});
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
					//编辑地址修改收货地址
					$(".glyphicon-edit1").click(function(){
						window.location = "editAddress.html?2&addrld="+$(this).attr("data-ord");
					})
					//新建收货地址是否固定在底部
					var clientH = $(window).height();//
					var addrListH = $("#addressList").height();
//					alert("$(window).height()---"+$(window).height()+"clientH---"+clientH);
//					alert('$("#addressList").height()-----'+addrListH)
//					alert((addrListH - addrListH) >= 100)
					if((addrListH - addrListH) >= 100){
						$("#addressList").css({"margin-bottom":"12rem"})
						$("#addrWrap").addClass("newAddressFix");
					}else{
						console.log(clientH - addrListH);
						$("#addressList").css({"margin-bottom":"0rem"})
						$("#addrWrap").removeClass("newAddressFix");
					}
					//删除
					$(".glyphicon-trash1").unbind().bind("click",function(){
						var $this = $(this);
						createConfirm("确定要删除吗？",function(){
							var addrld = $this.attr("data-ord");
							var o = $this.parent().parent();
							o.animate({"height":"0"},300,function(){
								$this.hide();	
							})
							doDel(addrld);							
						},function(){});
					})                                                          
					
				
			}else{
				$("#addressList").empty();
				var div = $('<figure class="noAddr">'+
								'<img src="../img/noAddr.jpg" style="width: 8rem;">'+
								'<figcaption>还没有收货地址</figcaption>'+
							'</figure>');
				$("#addressList").css("background","#f4f4f5").append(div);
				return false;
			}
		}
	})
}
function doDel(addrld,i){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		url:"../../Shop_AddressAdd.asp?__msgId=delete&ord="+addrld,
		dataType:"text",
		processData:false,
		data:datas,
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			init();
		}
	})
}
function isCheck(){
	if(checkFixedTel&&checkName&&checkTel&&checkPostcode&&checkAddress){
			console.log("success");
		}
}
function doEdit(){
	var info ={
		sex:$("#editSex"),
		birth:$("#editBirth"),
		sex:$("#editEmail"),
		sex:$("#editTel"),
		sex:$("#editLike")
	};
	var str = JSON.stringify(info); 
	//存入 
	localStorage.info = str; 
	$("#info").show();
	$("#editInfo").hide();
}
