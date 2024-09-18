//继承处理采购结算弹层样式呈现
window.procLayerUiForSpePage = function(bd,lay){
	var gps = lay.groups;
	bd.push("<div id='layerParForSpe'  onclick='$(this).remove()'>"); 
	bd.push("<div class='layer' style='display:" + (lay.visible || lay.ui.visible ? "" : "none") + ";width:100%;height:100%;top:0px;border:none;top:-1px;'>");
	if (window.appconfig && window.appconfig.appName == "MoziBox") {
	    bd.push("<div class='lay_tit' style='position:absolute;top:0px;left:0px;width:100%;height:40px;line-height:40px;background-color:#3B3E50;color:#FFF;font-size:16px;border:none;'><div class='lay_back' onclick='$(this).parent().parent().parent().remove()'></div>" + lay.title + "</div>");
	}
	else {
	    bd.push("<div class='lay_tit' style='position:absolute;top:0px;left:0px;width:100%;height:40px;line-height:40px;background-color: #075387;color:#FFF;font-size:16px;border:none;'><div class='lay_back' onclick='$(this).parent().parent().parent().remove()'></div>" + lay.title + "</div>");
	}
	bd.push("<div id='lay_cont' style='height:"+ (ui.clientHeight - 100) +"px'>")
	bd.push("<table class='bill_table'>"); 
	bd.push("<colgroup><col style='width:25%'></col><col style='width:2px'></col><col></col></colgroup>");
	for(var q=0;q<gps.length;q++){
		var fds=gps[q].fields;
		for(var w=0;w<fds.length;w++){
			bill.GetItemFieldHtml(fds[w]);
		} 
	}
	bd.push("</table>");
	bd.push("</div>"); 
	bd.push("<div class='caigouBtmArea' style='width:100%;height:50px;position: fixed;bottom: 0;left:0px;background: #FFF;'>");
	bd.push("<div style='width:60%;display:block;float:left;height:100%;line-height:50px;overflow:hidden;position:relative;visibility:hidden;' id='lay_area'>"
		+ "  	<span style='float:left;display:inline-block;margin-left:15px;height:50px;line-height:50px;'>优惠后总额：</span>"
		+"		<span style='float:left;display:inline-block;margin-left:5px;height:50px;color:red;line-height:50px;' id='lay_money1'></span>"
		+" 	</div>"
		+" 	<div onclick='ui.CZSMLPage(this)' target='none' method='post' action='SysBillSave' style='width:40%;display:block;float:left;height:50px;line-height:50px;color:#FFF;overflow:hidden;background-color:#ff6411;text-align:center'>保存</div>")
	bd.push("</div>")
	bd.push("</div>");
	bd.push("</div>");
	setTimeout(function(){
		SetCaiGouMoneyVal()
	},300)
} 

function SetCaiGouMoneyVal(){
	var money1 = 0;
	var power = "";
	app.getPostDatas(function(dbname, v){
		if(dbname == "money1"){ money1 = v;}
		if(dbname == "power"){ power = v;}
	},"post");
	$('#lay_money1').html(bill.FormatNumber(money1,__currwin.zsml.header.moneybit));
	$('#lay_area').css("visibility",(power=="1"?"visible":"hidden"));
}

//优惠方式 回调方法
window.HandleSaleType = function(){
	var yhval = $("input[name='yhtype']:checked").val();
	if(window.ytypeValue == undefined){ window.ytypeValue = 0;}
	if(yhval!=window.ytypeValue){
		window.ytypeValue = yhval;
		if(window.ytypeValue == 1){
			$("#yhmoney").parent().parent().parent().parent().hide();
			$("#zk").parent("div").show();
	        var premoney = $("#premoney").val();
	        var zk = $("#zk").val();
	        $("#money1").val(bill.FormatNumber((premoney * 1 * zk * 1) + "",(__currwin.zsml.header.moneybit?__currwin.zsml.header.moneybit:bill.dot.money)));
	        $("#lay_money1").html(bill.FormatNumber((premoney * 1 * zk * 1) + "",(__currwin.zsml.header.moneybit?__currwin.zsml.header.moneybit:bill.dot.money)));
		}else{
			$("#yhmoney").parent().parent().parent().parent().show();
			$("#zk").parent("div").hide();
	        var premoney = $("#premoney").val();
	        var yhmoney = $("#yhmoney").val();
	        $("#money1").val(bill.FormatNumber((premoney*1 - yhmoney*1)+"",(__currwin.zsml.header.moneybit?__currwin.zsml.header.moneybit:bill.dot.money)));
	        $("#lay_money1").html(bill.FormatNumber((premoney*1 - yhmoney*1)+"",(__currwin.zsml.header.moneybit?__currwin.zsml.header.moneybit:bill.dot.money)));
		}
	}
}

//处理字段的公式运算
window.HandleFieldFormul = function (currDBName, mBit) {
	console.log(currDBName)
    switch(currDBName){   
		case "priceAfterDiscountTax":
        case "num1":
			var priceAfterTax = $("#priceAfterDiscountTax").val() * 1;
            var num1 = $("#num1").val() * 1;
            var money1 = priceAfterTax * num1;
            $("#money1").val(bill.FormatNumber(money1 + "", mBit));
        	$("#lay_money1").html(bill.FormatNumber(money1 + "", mBit));
            break;
        case "yhmoney":
            var premoney = $("#premoney").val();
            var yhmoney = $("#yhmoney").val();
	        if(yhmoney == ""){ bill.input.currValue['yhmoney'] = bill.FormatNumber(0,(__currwin.zsml.header.moneybit?__currwin.zsml.header.moneybit:bill.dot.money)); }
            $("#money1").val(bill.FormatNumber((premoney*1 - yhmoney*1)+"",mBit));
        	$("#lay_money1").html(bill.FormatNumber((premoney*1 - yhmoney*1)+"",mBit));
            break;
        case "zk":
            var premoney = $("#premoney").val();
            var zk = $("#zk").val();
            $("#money1").val(bill.FormatNumber((premoney * 1 * zk * 1)+"",mBit));
            $("#lay_money1").html(bill.FormatNumber((premoney * 1 * zk * 1)+"",mBit));
            break;
    }
}

//处理展开收缩按钮
window.clickmore = function(el){
	var ismore = $(el).attr("ismore");
	if(ismore == "0"){
		$(el).attr("ismore","1");
		$(".cg-btn-txt").html("收缩");
		$(".cg-arrow").removeClass("cg-down");
		$(".cg-arrow").addClass("cg-up");
		$ID("ismore").value = 1;
		bill.triggerFieldEvent($ID("ismore"), "change");
	}else{
		$(el).attr("ismore","0");
		$(".cg-btn-txt").html("更多");
		$(".cg-arrow").addClass("cg-down");
		$(".cg-arrow").removeClass("cg-up");
		$ID("ismore").value = 0;
		bill.triggerFieldEvent($ID("ismore"), "change");
	}
}

//页面绑定回调呈现方式
app.addMessageEvent("childpageclose", function (data, closeWinhwnd) { 
	if(closeWinhwnd.indexOf("_caigoubillscan")==-1 && closeWinhwnd.indexOf("geproductbilllistasp")==-1 && closeWinhwnd.indexOf("_caigoumxedit")==-1) {return;}
	$ID("childrefreshEventbox").value = 0;
	bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
});

//扫描添加按钮
window.getIntoScanfPage = function(el){ 
	var company = "";
	var invoiceType = "";
	app.getPostDatas(function(dbname, v){    
		if(dbname == "company"){ company = v;}
		if(dbname == "invoiceType"){ invoiceType = v; }
	},"post");
	$ID("childrefreshEventbox").value = 1;  
	bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
	el.setAttribute("url","CaiGouBillScan.ashx?fromtype=caigoubill&company="+company+"&invoiceType="+invoiceType);
	ui.CZSMLPage(el);
}

//手动添加产品按钮
window.getIntoChooseProcPage = function(el){
	var company = "";
	var invoiceType = "";
	app.getPostDatas(function(dbname, v){    
		if(dbname == "company"){ company = v;}
		if(dbname == "invoiceType"){ invoiceType = v; }
	},"post");
	$ID("childrefreshEventbox").value = 1;
	bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
	el.setAttribute("url",info.hosturl +"/mobilephone/salesManage/product/billlist.asp?fromtype=caigoubill&company="+company+"&invoiceType="+invoiceType);
	ui.CZSMLPage(el);
}

//采购添加底部结算按钮
window.onBeforePageInit = function(){
	var currweb = plus.webview.currentWebview();
	var zsml = currweb.zsml;
	var jbill = zsml.body.bill;
	var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonBG");
	scanfbtn.formathtml = "<div style='width:80%;margin:0 auto;'><div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>"
                             + "<div id='AddButtonBody' class='sales_lvw_btmbtn' onclick='getIntoChooseProcPage(this)' target='_blank' action='_url'><dl></dl></div></div>";
	setTimeout(function () {
	    var h = document.documentElement.offsetHeight;
	    $("#page-content").css("height", h - 100);
	}, 300)
}

//联动更新底部结算信息
window.updateSumForSpcFun = function(lvw,rowindex,dbi,v){
	var hds = lvw.headers;
	var midx = 0;
	var nidx = 0;
	var pidx = 0;
	for(var i = 0;i<hds.length; i++){
		if(hds[i].dbname=="money1"){ midx = i; }
		if(hds[i].dbname=="num1"){ nidx = i; }
		if(hds[i].dbname=="priceAfterTax"){ pidx = i; }
	}
	if(hds[dbi].dbname == "priceAfterTax"){
		lvw.rows[rowindex][pidx] = v;
		lvw.rows[rowindex][midx] = v*1*(lvw.rows[rowindex][nidx]*1);
	}
	if(hds[dbi].dbname == "num1"){
		lvw.rows[rowindex][nidx] = v;
		lvw.rows[rowindex][midx] = v*1*(lvw.rows[rowindex][pidx]*1);
	}
}

//采购明细单行明细删除按钮回调事件
window.deleteListviewRowForServer = function(lvw,pos){
	var len = lvw.headers.length;
	var rowData = {};
	var rows = lvw.rows;
	var keyfieldvalue = "";
	for (var i = 0; i < len; i++) {
		if (lvw.headers[i].dbname != ""){
			rowData[lvw.headers[i].dbname] = (lvw.rows[pos][i]!=null?lvw.rows[pos][i]:null);
			if(lvw.headers[i].dbname.toLowerCase()== (""+lvw.keyfield||"").toLowerCase()){
				keyfieldvalue = rowData[lvw.headers[i].dbname];
			}
		}
	}
	var parms = new Object();
	parms["buttontext"] = "删除";
	parms["listviewid"] = lvw.id;
	parms["currrowdata"] = app.GetJSON(rowData);
	parms["keyfieldvalue"] = keyfieldvalue;
	app.RegEvent("sys.listview.handlebtnclick",parms);
}

//清空按钮
window.createBtnForSpecGroup = function(btn){
	return "<div class='bill_txt' onclick='window.clearBtn(this);' action='SysBillCallBack' url='ClearAllCaiGouMxList'  target='" + (btn.target || "") +"' >"+ btn.title +"</div>"
}

window.clearBtn = function(el){
	var ev = window.event;
	ev.stopPropagation();
	ui.confirm("您确定要清空采购明细?",function(e){
		if(e.index == 1){
			var parms = new Object();
			ui.CZSMLPage(el);
		}
	},info.alertTitle,["取消","确定"])
}

window.clearLvwForCaigou = function(){
	var dbsign = $("#MobListView_caigoulist").attr("dbsign");
	bill.clearListViewRows(dbsign,true);
}

//更新LVW JSON 信息
window.updateSumForSpcFun = function(lvw,rowindex,dbi,v){
	console.log(v) 
	var hds = lvw.headers;
	var midx = 0;
	var nidx = 0;
	var pidx = 0;
	for(var i = 0;i<hds.length; i++){
		if(hds[i].dbname=="money1"){ midx = i; }
		if(hds[i].dbname=="num1"){ nidx = i; }
		if(hds[i].dbname=="priceAfterDiscountTax"){ pidx = i; }
	}
	if(hds[dbi].dbname == "priceAfterDiscountTax"){
		lvw.rows[rowindex][pidx] = v;
		lvw.rows[rowindex][midx] = v*1*(lvw.rows[rowindex][nidx]*1);
	}
	if(hds[dbi].dbname == "num1"){
		lvw.rows[rowindex][nidx] = v;
		lvw.rows[rowindex][midx] = v*1*(lvw.rows[rowindex][pidx]*1);
	}
}