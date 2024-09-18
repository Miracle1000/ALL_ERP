$(function(){
		init();
		$("#back").click(function(){
			window.history.back();
		})
		//收货地址新建
		$(".newAddress").click(function(event){
			var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
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
						window.location = "newAddress.html?chooseAddr=chooseAddr&"+Math.random();
					}else{
						$(".alert").show();
						//输入手机号验证
						$("#tel").blur(function(){
							checkTel($(this));
						})
						$("#tel2").blur(function(){
							checkTel2();
						})
						//提交
						$("#submit").click(function(){
							doSubmit();
						})
						//返回
						$("#return").click(function(){
							$(".alert").hide();
						})
					}
				}
			});
		})	
})
function doSubmit(){
	if(checkTel($("#tel"))&&checkTel2()){
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
				window.location = "newAddress.html?chooseAddr=chooseAddr";
			}
		});
	}else{
		return false;
	}
}
function init(){
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
					var $ul = $('<ul  data-ord='+rows[i][o["addrId"]]+'>'+
								'<li>'+
									'<span class="col-xs-6">'+rows[i][o["receiver"]]+'</span>'+
									'<span class="col-xs-6 ">'+rows[i][o["mobile"]]+'</span>'+
								'</li>'+
								'<li class="addrLi">'+
									'<span class="col-xs-2 text-center" data-name="default">默认</span>'+
									'<span class="col-xs-9 text-center">'+rows[i][o["address"]]+'</span>'+
								'</li>'+
								'<li>'+
									'<div class="col-xs-offset-7">'+
										'<em class="glyphicon glyphicon-edit" data-ord="'+rows[i][o["addrId"]]+'"><em>编辑</em></em>'+
										'<em class="glyphicon glyphicon-trash" data-ord="'+rows[i][o["addrId"]]+'"><em>删除</em></em>'+
									'</div>'+
								'</li>'+
								'</ul>');
					//遍历收货地址
					$ul.click(function(event){
						if(event.target.tagName != "EM"){
							window.location = "order.html?ord="+$(this).attr("data-ord");
						}
					})
					$("#addressList").append($ul);
					//添加默认地址
					if(rows[i][o["isDefault"]]==1){
						$(".addrLi").eq(i).find("span:first-child").addClass("default");
					}else{
						$(".addrLi").eq(i).find("span:first-child").removeClass("default");
					}
					//编辑地址修改收货地址
					$(".glyphicon-edit").unbind().bind("click",function(event){
						if(event.target.tagName == "EM"){
							window.location = "editAddress.html?choose=choose&addrld="+$(this).attr("data-ord");
						}
						
					})
					
					//删除
					$(".glyphicon-trash").unbind().bind("click",function(event){
						if(event.target.tagName == "EM"){
							var flag = confirm("确认要删除地址么？");
							if(flag){
								var addrld = $(this).attr("data-ord");
								console.log(addrld);
								var o = $(this).parent().parent().parent();
								o.animate({"height":"0"},function(){
									$(this).hide();	
								})
								doDel(addrld)
							}else{
								return false;
							}
						}
					})
				});
			}else{
				$("#addressList").empty();
				$("#addressList").append('<figure class="noAddr">'+
						                 ' <img src="../img/noAddr.jpg" style="width: 8rem;">'+
						                 ' <figcaption>还没有收货地址</figcaption>'+
					                   ' </figure>');
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
//			window.location = "address.html";
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
//获取字段
function getPro(arr){
	var o = {};	
	for(var k=0;k<arr.length;k++){
		o[arr[k].id] = k;
	}
	return o;
} 
//获取text
function getAttr(arr){
	var o = {};	
	for(var k=0;k<arr.length;k++){
		o[arr[k].id] = arr[k].text || '';
	}
	return o;
} 