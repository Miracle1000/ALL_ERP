$(function(){		
		window.RefreshAddress("address",0);
		//新建收货地址保存完
		$("#addressSave").click(function(){
			if(checkAllInput()){
				 var addrid = $("#address").find("select:last").children(":selected").val();
				 var name = $("#name").val();
				 var fixedTel = $("#fixedTel").val();
				 var tel = $("#tel").val();
				 var address = $("#writeAddress").val();
				 var postcode = $("#postcode").val();
				 var isCheck = $("#isCheck")[0].checked?1:0;
				 var datas = '{datas:[{id:"addrld",val:""},'+
				 			 '{id:"receiver",val:"'+name+'"},'+
				 			 '{id:"phone",val:"'+fixedTel+'"},'+
				 			 '{id:"mobile",val:"'+tel+'"},'+
				 			 '{id:"address",val:"'+address+'"},'+
						     '{id:"zip",val:"'+postcode+'"},'+
						      '{id:"areaId",val:"'+addrid+'"},'+
							'{id:"isDefault",val:"'+isCheck+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
				$.ajax({
					type:"post",
					url:"../../Shop_AddressAdd.asp?__msgId=__sys_dosave",
					dataType:"text",
					processData:false,
					contentType:"application/zsml",
					data:datas,
					success:function(data){
						data = eval("("+data+")");
						var flag = GetQueryString("chooseAddr");
						if(flag){
							window.location = "order.html?kind=address";	
						}else{
							window.location = "address.html";	
						}
						
					}
				})
			}else{
				console.log("failed...");
				return false;
				
			}
		})
			
			
			
		$("#name").blur(function(){
			checkInputData($(this), "varchar" , 1 , 50 ,"收货人", "不能为空哦");
		})
		$("#fixedTel").blur(function(){
			checkFixedTel($(this));
		})
		$("#tel").blur(function(){
			if(trim($(this).val())!=""){
				checkTel($(this));
			}
		})
		$("#address").blur(function(){
			checkInputData($(this), "selectid" , 1 , 0 ,"", "请选择所在区域");
		})
		$("#writeAddress").blur(function(){
			checkInputData($(this), "varchar" , 1 , 200 ,"详细地址", "不能为空哦");
		})
		$("#postcode").blur(function(){
			checkInputData($(this), "postcode" , 0, 6 ,"", "请输入6位有效的邮政编码");
		})	
})

function checkAllInput(){
	var canname =checkInputData($("#name"), "varchar" , 1 , 50 ,"收货人", "不能为空哦");
	var phone = trim($("#fixedTel").val())+"";
	var mobile = trim($("#tel").val())+"";	
	var canfixedTel = checkFixedTel($("#fixedTel"))
	var cantel = true;
	if (mobile!=""){
		checkTel($("#tel"))
	}
	if(phone=="" && mobile==""){
		$("#fixedTel").parent().next().text("请填写固话或手机");
		$("#fixedTel").parent().next().show();
		canfixedTel = false;
	}
	var canaddress = checkInputData($("#address"), "selectid" , 1 , 0 ,"", "请选择所在区域");
	var canwriteAddress = checkInputData($("#writeAddress"), "varchar" , 1 , 200 ,"详细地址", "不能为空哦");
	var canpostcode = checkInputData($("#postcode"), "postcode" , 0, 6 ,"", "请输入6位有效的邮政编码");
	return canname && canfixedTel && cantel && canaddress && canwriteAddress && canpostcode
}

function trim(str){return str.replace(/(^\s*)|(\s*$)/g, "");}