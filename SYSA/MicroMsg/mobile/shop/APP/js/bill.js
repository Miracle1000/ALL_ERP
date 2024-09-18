$(function(){
		$(".back").bind("click",function(){
		window.history.back();
		})
		var $billKinds = $("input[name='bill']");
		addValue($billKinds);
		$(".bill_ok").bind("click",function(){
			window.location = "order.html";
		})
		billKinds();
})
//点击增值税出现文本框填写
function addValue($billKinds){
	$billKinds.bind("click",function(){
		if($("#bill2")[0].checked){
		$(".oneBill").slideDown();
	}
	else{
		$(".oneBill").slideUp();
	}
	for(i=0;i<$billKinds.length;i++){
		if($billKinds[i].checked){
			if(window.localStorage){
				localStorage.setItem("billKinds",$billKinds[i].value);
			}
		}
		
	}
	
	})
}

//发票类型
function billKinds(){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		url:"../../ShopOrderConfirm.asp?__msgId=pageload",
		dataType:"text",
		data:datas,
		contentType:"application/zsml",//用网址访问时 加上这句话
		success:function(data){
			data = eval('('+data+')');
			var billData = data.body.bill.groups[4].fields;
			if(billData.length != 0){
				var dataa = data.body.bill.groups[4].fields[0].source.table.rows;
				createBill(dataa);
				chooseBill(dataa);
			}else{
				$(".bill_kinds").html("<p style='tect-align:center; font-size:0.14rem; padding:0.3rem 0 0.1rem 0'>无可用票据类型...</p>")
			}	
		}
	});
}
//创建页面基本结构
function createBill(dataa){
	for(i=0;i<dataa.length;i++){
		var $billkinds = $('<li class="billClasify"><span><input type="radio" name="bill" value="'+dataa[i][1]+'" id="'+dataa[i][0]+'"><label for="'+dataa[i][0]+'">'+dataa[i][1]+'</label></span><ul class="oneBill"></ul></li>');
		$(".bill_kinds").append($billkinds);
	}
	return $billkinds;
}
//点击选择发票类型
function chooseBill(data){
	$(".billClasify span").unbind().bind("click",function(ev){
		var $target = $(this).parent();
		if($target.attr('isClicked') == '1'){
			$target.find(".oneBill").slideDown().parent().siblings().find(".oneBill").slideUp();
			return;
		}
		$target.attr('isClicked','1');
		var $nowBillId = data[$target.index()][0];
		var $nowBillVal = data[$target.index()][1];
		getBill($nowBillId,$nowBillVal,$target);
		$target.find(".oneBill").slideDown().parent().siblings().find(".oneBill").slideUp();
		if(window.localStorage){
			window.localStorage.setItem("val",$nowBillVal);
			console.log(window.localStorage.getItem("val"));
		}
		clickBill($(this),$nowBillId);
		console.log($nowBillId)
	})
}



//将发票信息存入后台接口
function getBill(id,val,index){
	var datas="{datas:[{id:'openid',val:'"+localStorage.openID+"'}]}";
	$.ajax({
		type:"post",
		data:datas,
		url:"../../ShopInvoiceFields.asp?__msgId=pageload&invoiceType="+id,
		dataType:"text",
		contentType:"application/zsml",
		success:function(data){
			data = eval('('+data+')');
			var billInfo = data.body.bill.groups[1].fields;
			createBillInfo(billInfo,index);
			window.localStorage.setItem("taxValue",data.body.bill.groups[0].fields[0].text)
		}
	});
}

//创建发票内容填写
function createBillInfo(billInfo,obj){
	var $oneBill = obj.find(".oneBill");
		for(i=0;i<billInfo.length;i++){
			var billI = billInfo[i].type;
			console.log(billI)
			switch(billI){
				case "text":
				var $billInfo = $('<li><span class="fl billin">'+billInfo[i].caption+':</span><input type="text" class="fl txt1" id="'+billInfo[i].id+'"></li>');
				break;
				case "textarea":
				var $billInfo = $('<li><span class="fl billin">'+billInfo[i].caption+':</span><textarea class="fl txt1" id="'+billInfo[i].id+'"></textarea></li>');
				break;
				case "date":
				var $billInfo = $('<li><span class="fl billin">'+billInfo[i].caption+':</span><input type="date" class="fl txt1" id="'+billInfo[i].id+'" name=""></li>');
				break;
				case "webbox":
				var $billInfo = $('<li><span class="fl billin">'+billInfo[i].caption+':</span><textarea class="fl txt1" id="'+billInfo[i].id+'"></textarea></li>');
				break;
				case "select":
				var $billInfo = $('<li><span class="fl billin">'+billInfo[i].caption+':</span><select class="billSel txt1" id="'+billInfo[i].id+'"></select></li>');
				var $billOptions = billInfo[i].source.options;
				for(j=0;j<$billOptions.length;j++){
					var $option = $('<option value="'+$billOptions[j].v+'">'+$billOptions[j].n+'</option>');	
					$billInfo.find("select").append($option);
				}
				break;
			}
			$oneBill.append($billInfo);
		}
}

//点击确认
function clickBill($target,$nowBillId){
	$(".bill_ok").bind("click",function(){
		saveBillInfo($target,$nowBillId);
	})
}

//存储数据
function saveBillInfo($target,$nowBillId){
	var $input = $target.siblings().find(".txt1");
	var datas = ['{id:"invoiceType",val:"'+$nowBillId+'"}'];
	for(i=0;i<$input.length;i++){
		datas.push('{id:"'+$input.eq(i).attr("id")+'",val:"'+$input.eq(i).val()+'"}');
	}
	alldata = datas.join(",")
	if(window.localStorage){
		window.localStorage.setItem("alldata",alldata);
	}
}








