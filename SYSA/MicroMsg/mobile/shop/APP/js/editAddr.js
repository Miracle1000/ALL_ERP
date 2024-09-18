$(function(){
		$("#back").unbind().bind("click",function(){
			window.history.back();
		})
		var addrld = GetQueryString("addrld");
		var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
		$.ajax({
			type:"post",
			data:datas,
			url:"../../Shop_AddressAdd.asp?ord="+addrld,
			dataType:"text",
			contentType:"application/zsml",
			success:function(data){
				data = eval("("+data+")");
				$("#addrForm").empty();
				var rows =  getAttr(data.body.bill.groups[0].fields);
				createList(rows,data.body.bill.groups[0].fields);
			},error:function(a,b,c){
				console.log(c);
			}
	});
	//点击保存按钮保存
	$("#saveChange").click(function(){
		if(checkAllInput()){
			var addrid = $("#address").find("select:last").children(":selected").val();
			 var name = $("#name").val();
			 var fixedTel = $("#fixedTel").val();
			 var tel = $("#tel").val();
			 var address = $("#writeAddress").val();
			 var postcode = $("#postcode").val();
			 var isCheck = $("#isCheck")[0].checked?1:0;
			 var datas = '{datas:[{id:"addrld",val:"'+addrld+'"},{id:"receiver",val:"'+name+'"},{id:"phone",val:"'+fixedTel+'"},{id:"mobile",val:"'+tel+'"},{id:"address",val:"'+address+
					  '"},{id:"zip",val:"'+ postcode +'"},{id:"areaId",val:"'+ addrid +'"},{id:"isDefault",val:"'+isCheck+'"},{id:"openid",val:"'+localStorage.openID+'"}]}';
			$.ajax({
				type:"post",
				url:"../../Shop_AddressAdd.asp?__msgId=__sys_dosave&ord="+addrld,
				dataType:"text",
				processData:false,
				contentType:"application/zsml",
				data:datas,
				success:function(data){
					data = eval("("+data+")");
					var choose = GetQueryString("choose");
					if(choose){
						window.location = "order.html?kind=address";
					}else{
						window.location = "address.html";
					}
					
				}
			})
		}else{
			return false;
		}
	})
})
function createList(rows,areadata){
	var $list = $('<div class="form-group">'+
				    '<label for="name" class="col-sm-2 control-label" style="padding-top:10px" notNull="'+rows.notnull+'" maxL="'+rows.maxl+'">收货人(必填):</label>'+
				    '<div class="col-sm-10">'+
				      '<input type="input" class="form-control" id="name" value="'+rows.receiver+'">'+
				    '</div>'+
				    '<p class="erroTg">不能为空哦</p>'+
				  '</div>'+
				  '<div class="form-group">'+
				    '<label for="fixedTel" class="col-sm-2 control-label">固定电话(选填):</label>'+
				    '<div class="col-sm-10">'+
				    '  <input type="number" dataType="number" class="form-control" id="fixedTel" placeholder="固定电话" value="'+rows.phone+'">'+
				    '</div>'+
				    '<p class="erroTg">请输入有效的固定电话，如0103125394</p>'+
				  '</div>'+
				  '<div class="form-group">'+
				    '<label for="tel" class="col-sm-2 control-label">手机(选填):</label>'+
				    '<div class="col-sm-10">'+
				      '<input type="number" dataType="number" class="form-control" id="tel" value="'+rows.mobile+'">'+
				    '</div>'+
				   '<p class="erroTg">请输入有效的11位手机号码</p>'+
				  '</div>'+
				  '<div class="form-group">'+
				   '<label for="address" class="col-sm-2 control-label">所在区域(必填):</label>'+
				    '<div class="col-sm-10">'+
				      '<div id="address" style="height: auto !important;"></div>'+
				    '</div>'+
				    '<p class="erroTg">请选择收货地址</p>'+
				  '</div>'+
				  '<div class="form-group">'+
				    '<label for="writeAddress" class="col-sm-2 control-label">详细地址(必填):</label>'+
				    '<div class="col-sm-10">'+
				      '<input  class="form-control" id="writeAddress" value="'+rows.address+'">'+
				    '</div>'+
				    '<p class="erroTg">地址不能为空哦</p>'+
				  '</div>' +
				  '<div class="form-group">' +
				    '<label for="postcode" class="col-sm-2 control-label">邮编(选填):</label>' +
				    '<div class="col-sm-10">' +
				    '  <input type="number" dataType="number" class="form-control" id="postcode" placeholder="邮编"  value="'+rows.zip+'">' +
				    '</div>' +
				   ' <p class="erroTg">请输入6位有效的邮政编码</p>' +
				  '</div>'+
				  '<div class="form-group">'+
					  '<div class="col-sm-offset-2 col-sm-10">'+
					      '<div class="checkbox">'+
					        '<label>'+
					          '<input type="checkbox" id="isCheck" '+ (rows.isDefault=='1'?'checked' : '') +'>设置为默认地址'+
					        '</label>'+
					      '</div>'+
					  '</div>'+
				  '</div>');
	$("#addrForm").append($list);
	$("#address").attr("_jsl",areadata[4].text);
	var list = eval("(" + areadata[4].text + ")");
	var li = list.length-1;
	var currv = 0;
	for(i=0; i<list[li].length;i++) {
		if(list[li][i][2]==1){
			currv = list[li][i][1];
			break;
		}
	}
	window.RefreshAddress("address", currv, li);
	//验证部分
	$("#name").blur(function(){
		checkInputData($(this), "varchar" , 1 , 50 ,"收货人", "不能为空哦");
	});
	$("#fixedTel").blur(function(){
			checkFixedTel($(this));
		})
	$("#tel").blur(function(){
		if(trim($(this).val())!=""){
			checkTel($(this));
		}
	});
	$("#address").blur(function(){
		checkInputData($(this), "selectid" , 1 , 0 ,"", "请选择所在区域");
	})
	$("#writeAddress").blur(function(){
		checkInputData($(this), "varchar" , 1 , 200 ,"详细地址", "不能为空哦");
	})
	$("#postcode").blur(function(){
		checkInputData($(this), "postcode" , 0, 6 ,"", "请输入6位有效的邮政编码");
	})	
}

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