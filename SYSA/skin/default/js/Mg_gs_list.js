
// 追加商品数量对话框
var $dlg;
function addGoodsNum(gID){
	$(function(){
		var cur = $("#mlistvw_ckv_" + gID).parent().siblings("td"),
			gname = cur.eq(2).text(),
			gattr = cur.eq(4).text(),
			gnum = cur.eq(6).text(),
			gunit = cur.eq(3).text();

		// 创建对话框
		btns = [
				{
					text: '保存',
					iconCls: 'icon-save',
					handler: function () {
						$('#editForm').form({
								url:"?__msgId=saveGoodsNum&goodsID="+ gID +"",
								onSubmit:function(){
									var chk = true;
									$("input[type=text][require=true]").each(function(){
										var v = $(this).val();
										if(v.length == 0){
											chk = false;
											return false;
										};
									});

									if(!chk){										
										return false 
									};

									// 表单验证
									return Validator.Validate(this,2);									
								},
								success:function(data){
									$dlg.dialog('close');
									lvw_refresh("mlistvw");
								},
								error:function(){
									alert('error');
								}
							}).submit();
					}
				}
		];

		if(!$dlg){			
			$dlg = $('<div>').appendTo(document.body);
		};
		var hp = xmlHttp();
		$dlg.dialog({
			title: "追加商品数量",
			width:500,
			//height:300,
			top: "20%",
			href:"?__msgId=addNumPage&goodsName="+ hp.UrlEncode(gname) +"&goodsAttr="+ hp.UrlEncode(gattr) +"&goodsNum="+ hp.UrlEncode(gnum) +"&goodsUnit="+ hp.UrlEncode(gunit) +"",
			buttons: btns
		}).dialog();

	});	

};



	


window.onReportExtraHandle = function(innerText, values){
	var hasTiming = false;

	if(innerText == '批量上架'){
		$(function(){
			$.each(values, function(index, value) {
				var t = $("#mlistvw_ckv_" + value).parent().siblings("td").eq(8).text();
				if(t.indexOf("定时上架") >= 0){
					hasTiming = true;
					return false;
				}
			});	
		});
	};

	if(hasTiming){
		if (window.confirm("选择内容包含定时上架商品，点击确定将立即上架")==false) { return; }
	}else{
		if (window.confirm("您确定要进行" + innerText + "吗？")==false) { return; }
	}

	ajax.regEvent("__doBatHandle")
	ajax.addParam("command", innerText);
	ajax.addParam("checkvalues", values.join(","));
	ajax.exec();
};

// 处理翻页后事件失效问题
window.onReportListRefresh = function(){
	$(function(){
		setTimeout(function(){
			selectGoods()
		},300);
	});

};

// 检索后触发的事件 onReportRefresh
window.onReportRefresh = window.onReportListRefresh;

$(function(){
	setTimeout(function(){
		selectGoods()			
	},500);
});

// 选择微信商城首页设置商品
function selectGoods(){
	var btn = $(".select-goods-btn");
	btn.unbind("click");
	btn.bind("click",function(){
		var that = $(this);
		var gid = that.attr("gid"),
			groupid = that.attr("groupid");
		$.post("ajax.asp",{act:"goodsSelect",gid:gid,groupid:groupid},function(data){
			that.remove();
//			if(data >= 12){
//				app.Alert('最多可以添加12个商品');
//				window.close();
//			};			
			window.opener.goods_refresh();
			window.opener.goods_dealAddBtn(data);
		});
	});
};


// 选择商品生成二维码
function selectGoodsToCode2(){
	var url = "../../code2/inc/getCode2.asp?c2type=4";
	var arr = [];
	$("input[name=sys_lvw_ckbox]:checked").each(function(){
		var v = $(this).val();
		arr.push(v);
	});

	//
	showProcDiv();
	$("#showProcDivDom").find("td").eq(1).html("正在生成二维码，请稍候...");
	$.post(url,{selectid:arr.join()},function(data){
		hideProcDiv();		
		if(data.indexOf("ok") >= 0){			
			window.location.href='../../code2/list.asp?category=30';
		}else{
			app.Alert('二维码生成失败！');	
		};
	});

};
