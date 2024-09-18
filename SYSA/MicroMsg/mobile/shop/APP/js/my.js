$(function(){
		doCheck();
		$("#loadDiv").show();
		init();
		getCarNum();
		//地址管理
		$("#addressSetting").click(function(){
			window.location = "html/address.html";
		})
		//未付款 未发货 收货列表
		$("#NEED_PAY,#NEED_SEND,#NEED_RECEIVE,#allList").bind("click",function(){
			window.location = "html/wait.html?id="+$(this).attr("id")+"&"+Math.random();
		})
		$("#back").unbind().bind("click",function(){
			window.history.back();
		})
		//个人信息管理
		$("#userSetting,#photo").click(function(){
			var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
			$.ajax({
				type:"post",
				data:datas,
				url:"../ShopOrderConfirm.asp?__msgId=checkBind",
				dataType:"text",
				contentType:"application/zsml",
				success:function(data){
					window.location = "html/manage.html";
				}
			});
		})
		$("#instructions").click(function(){
			$("#instructionsDiv").show();
		})
})


function init(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../UserCenter.asp",
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval("("+data+")");
			if(!data.body && data.success==false){
				createAlert(data.msg);
				return;
			}else if(data.header && data.header.status==1){
				createAlert(data.header.message);
				return;
			}
			var datas = getAttr(data.body.bill.groups[0].fields);
			$("#photo").find("img").attr("src","../../../../MicroMsg/"+datas["headimgpath"]);
			$("#username").text(htmlDecode(datas["nickname"]));
			datas["cntNeedPay"] == 0?$("#waitPayNum").hide():$("#waitPayNum").show();
			datas["cntNeedPay"] > 99?datas["cntNeedPay"]="99+":datas["cntNeedPay"]=datas["cntNeedPay"];
			$("#waitPayNum").text(datas["cntNeedPay"]);
			datas["cntNeedSend"] == 0?$("#waitSendNum").hide():$("#waitSendNum").show();
			datas["cntNeedSend"] >99?datas["cntNeedSend"]="99+":datas["cntNeedSend"] = datas["cntNeedSend"] ;
			$("#waitSendNum").text(datas["cntNeedSend"]);
			datas["cntNeedReceive"] == 0?$("#waitReceiveNum").hide():$("#waitReceiveNum").show();
			datas["cntNeedReceive"]>99?datas["cntNeedReceive"]="99+":datas["cntNeedReceive"]=datas["cntNeedReceive"];
			$("#waitReceiveNum").text(datas["cntNeedReceive"]);
			$("#instructionsDiv .words").empty().text(datas["@sendPriceInfo"]);
			$("#wordsback").unbind().bind("click",function(){
				$("#instructionsDiv").hide();
			})
			console.log(datas["@serviceLink"]);
			
			if(datas["@serviceLink"]){
				$("#serviceLink").show().unbind().bind("click",function(){
					window.location = datas["@serviceLink"];
				});
			}else{
				$("#serviceLink").hide();
			}
			
			//加载页面消失
			$("#loadDiv").hide();
		}
	})
}
function doSubmit(){
	if(checkTel($("#tel"))&&checkTel2()){
		var datas = '{datas:[{id:"mobile",val:"'+$("#tel").val()+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
		$.ajax({
			type:"post",
			url:"../ShopOrderConfirm.asp?__msgId=userBind",
			dataType:"text",
			data:datas,
			contentType:"application/zsml",
			success:function(data){
				data = eval("("+data+")");
				$(".alert").hide();
				window.location = "html/manage.html";
			}
		});
	}else{
		checkTel($("#tel"));
		checkTel2();
		return;
	}
}
function doCheck(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
			$.ajax({
				type:"post",
				data:datas,
				url:"../ShopOrderConfirm.asp?__msgId=checkBind",
				dataType:"text",
				contentType:"application/zsml",
				success:function(data){
					data = eval("("+data+")");
					if(!data.body && data.success==false){
						createAlert(data.msg);
						return;
					}else if(data.header && data.header.status==1){
						createAlert(data.header.message);
						return;
					}
					var status = data.body.message.text;
					if(status=="success"){
						$(".alert").hide();
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
							if(checkTel($("#tel"))&&checkTel2()){
								var datas = '{datas:[{id:"mobile",val:"'+$("#tel").val()+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
								$.ajax({
									type:"post",
									url:"../ShopOrderConfirm.asp?__msgId=userBind",
									dataType:"text",
									data:datas,
									contentType:"application/zsml",
									success:function(data){
										data = eval("("+data+")");
										$(".alert").hide();
									}
								});
							}else{
								return false;
							}
						})
						//返回
						$("#return").click(function(){
							window.history.back();
						})
					}
				}
			});
}
