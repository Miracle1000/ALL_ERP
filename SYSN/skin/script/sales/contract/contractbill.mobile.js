window.KDsumv = 0;
window.setMorePay = function() {
    var morepay = $('#morepay').val()*1;
    if(morepay=='0') $('#morepay').val('1');
    var trs = $("tr[for*='hkmoney']").css("display","");
}

//页面绑定回调呈现方式
app.addMessageEvent("childpageclose", function (data, closeWinhwnd) { 
	if(closeWinhwnd.indexOf("_contractbillscan")==-1 && closeWinhwnd.indexOf("geproductbilllistasp")==-1 && closeWinhwnd.indexOf("_contractmxedit")==-1) {return;}
	$ID("childrefreshEventbox").value = 0;
	bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
});

//继承处理开单结算弹层样式呈现
window.procLayerUiForSpePage = function(bd,lay){
	var gps = lay.groups;
	bd.push("<div id='layerPar'  onclick='$(this).remove()'>"); 
	bd.push("<div class='layer' style='display:" + (lay.visible||lay.ui.visible ? "" : "none") + ";width:100%;height:100%;top:0px;border:none;top:-1px;'>"); 
	bd.push("<div class='lay_tit' style='position:absolute;top:0px;left:0px;width:100%;height:50px;line-height:50px;background-color: #075387;color:#FFF;font-size:16px;border:none;'><div class='lay_back' onclick='$(this).parent().parent().parent().remove()'></div>" + lay.title + "</div>"); 
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
	bd.push("<div class='lay_btns' style='position:fixed;bottom:0px;left:0px;z-index:999;width:100%;border-top:1px solid #EEEEEE;'>");
	bd.push("<table><colgroup><col width='50%'><col width='50%'></colgroup><tr>");
	var btns=lay.commandbuttons;
	for(var z=0;z<btns.length;z++){
		bd.push("<td  align='center' valign='middle'> ");
		var btn=btns[z];
		var cmdKey=btn.cmdkey;
		switch(cmdKey){
			case "bill.dosave":bd.push("<button ico='sure' class='r sure' onclick=\"window.SaveAndPrint(this);\" action='SysBillSave' tag='"+ btn.tag +"'  target='_none' method='post'>"+btn.title+"</button>");break;
			case "app.closeWindow('billlayer_approver', true);":bd.push("<button ico='sure' class='r' onclick=\""+cmdKey+"\" >"+btn.title+"</button>");break;
		}
		bd.push("</td>");
	}
	bd.push("</tr></table>");
	bd.push("</div>");
	bd.push("</div>");
	bd.push("</div>");
} 

//保存并打印
window.SaveAndPrint = function(el){
	var tag = el.getAttribute("tag");
	if(tag == "saveprint"){
		var parms = new Object();
		parms["__cmdtag"] = tag;
		ui.CZSMLPage(el,null,0,"",parms);
	}else{
		ui.CZSMLPage(el);
	}
}

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
	el.setAttribute("url","ContractBillScan.ashx?fromtype=contractbill&company="+company+"&invoiceType="+invoiceType);
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
	el.setAttribute("url",info.hosturl +"/mobilephone/salesManage/product/billlist.asp?fromtype=contractbill&company="+company+"&invoiceType="+invoiceType);
	ui.CZSMLPage(el);
}

//选择地址按钮
window.chooseAddr = function(el){
	var company = "";
	app.getPostDatas(function(dbname, v){    
		if(dbname == "company"){ company = v;}
	},"post");
	var url = el.getAttribute("url");
	if(url.indexOf("&company") == -1){ el.setAttribute("url",url + "&company="+company); }
	ui.CZSMLPage(el);
}

window.showYHlayer = function(el){
	var yharea = document.getElementById("layer_yhcopy");
	var zkmax = $("#zk").attr("max");
	if(!yharea){
		var yhfield = new Object();
		yhfield = {
			uitype:"htmlfield",
			type:"htmlfield",
			formathtml:"<table><colgroup><col width='55%'><col width='45%'></colgroup><tr><td style='padding-left:10px;'>@c_yhtype</td><td>@c_yhmoney@c_zk</td></tr></table>",
			display:"editable",
			dbname:"",
			visible:true,
			nshow:true,
			children:[
				{
					uitype:"radioboxs",defvalue:"0",value:"0",drformat:"array",dbname:"c_yhtype",dbtype:"none",display:"editable",nshow:true,visible:true,
					callback:[
						{
							eventtype:"change",
							procname:"client:HandleSaleType()",
							posttype:"mainfields"
						}
					],
					source:{
						structtype:"default",
						type:"options",
						title:"",
						options:[
							{v:0,n:"金额"},
							{v:1,n:"折扣"},
						]
					}
				},
				{
					uitype:"moneybox",dbtype:"money",display:"editable",defvalue:bill.FormatNumber(0,__currwin.zsml.header.moneybit),value:bill.FormatNumber(0,__currwin.zsml.header.moneybit),drformat:"text",dbname:"c_yhmoney",max:(window.KDsumv>0?window.KDsumv:99999999),disnegative:true,
					callback:[
						{
							eventtype:"keyup",
							procname:"client:HandleFieldFormul(\"c_yhmoney\","+ __currwin.zsml.header.moneybit +")",
							posttype:"mainfields"
						}
					]
				},
				{
					uitype:"discntbitbox",dbtype:"none",display:"hidden",defvalue:bill.FormatNumber(1,__currwin.zsml.header.discountbit),value:bill.FormatNumber(1,__currwin.zsml.header.discountbit),drformat:"text",dbname:"c_zk",disnegative:true,min:0,max:zkmax||1,
					callback:[
						{
							eventtype:"keyup",
							procname:"client:HandleFieldFormul(\"c_zk\","+ __currwin.zsml.header.discountbit +")",
							posttype:"mainfields"
						}
					]
				}
			]
		}
		bill.ConvertFieldForNet(yhfield);
		var cssText = "style='position:absolute;height:45px;width:100%;bottom:51px;border-top:1px solid #aaa;background:#fefefe;padding-top:10px;display:table-cell;'";
		var dmtxt = "<div id='layer_yhcopy' "+ cssText +">"+ fieldUILib.GetFieldHtml(yhfield) +"</div>";
		$("body").append(dmtxt);
		bill.bind();
		$(el).attr("hs",1);
	}else{
		var hs = $(el).attr("hs");
		if(hs == undefined){ 
			if($("#layer_yhcopy").css("visibility") == "visible"){
				hs = 1;
			}else{
				hs = 0;
			}
		}
		if(hs == 0){
			$(el).attr("hs",1);
		}else{
			$(el).attr("hs",0);
		}
		$("#layer_yhcopy").css("visibility",(hs==0?"visible":"hidden"));
	}
}


//销售开单底部结算 样式
window.onBeforePageInit = function(){ 
	var currweb = plus.webview.currentWebview();
	var vendor = plus.device.vendor == "alps";    //判断PDA标识
	var zsml = currweb.zsml;
	var jbill = zsml.body.bill;
	var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonBG");
	scanfbtn.formathtml = "<div style='width:100%;height:36px;border-bottom:1px solid #bbb;background:#EFEFEF;'><span id='money1sumv' style='height:36px;line-height:36px;color:#666;float:right;margin-right:10px;'></span><span style='height:36px;line-height:36px;color:#666;float:right;'>开单金额：</span></div>"
							 + "<div style='width:80%;margin:0 auto;text-align:center;'>"
							 + 		(vendor?"":"<div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>")
                             + 		"<div id='AddButtonBody' class='sales_lvw_btmbtn' onclick='getIntoChooseProcPage(this)' target='_blank' action='_url'><dl></dl></div>"
                             + "</div>";
	setTimeout(function () {
	    var h = document.documentElement.offsetHeight;
	    $("#page-content").css("height", h - 100);
	}, 300)
}

//销售开单单行明细删除按钮回调事件
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

//处理lvw底部区域 接管  合计处理
window.procSumvForSpecPage = function(dbname,sumv){
	if(dbname == "num1"){ return sumv; }
	window.KDsumv = sumv;
	$("#c_yhmoney").attr("max",(sumv==0?"0.000001":sumv));
	$("#premoney").val(bill.FormatNumber(sumv,__currwin.zsml.header.moneybit));
	$("#money1sumv").html(bill.FormatNumber(sumv,__currwin.zsml.header.moneybit));
	var yhval = $("input[name='c_yhtype']:checked").val() || 0;
   	var yhmoney = $("#c_yhmoney").val() || 0;
    var zk = $("#c_zk").val() || 0;
	if(yhval == 0){
		sumv = bill.FormatNumber(sumv*1 - yhmoney*1,__currwin.zsml.header.moneybit)
	}else{
		sumv = bill.FormatNumber(sumv*1 * zk*1,__currwin.zsml.header.moneybit)
	}
	return sumv;
}


//处理字段的公式运算
window.HandleFieldFormul = function (currDBName, mBit) {
	console.log(currDBName)
    switch(currDBName){   
        case "c_yhmoney":
            var money1sumv = $("#money1sumv").text();
            var c_yhmoney = $("#c_yhmoney").val();
            $("#yhmoney").val(bill.FormatNumber(c_yhmoney*1,mBit));
            $("#xs_yhsum").html(bill.FormatNumber(money1sumv*1 - c_yhmoney*1,mBit));
            break;
        case "c_zk":
            var money1sumv = $("#money1sumv").text();
            var c_zk = $("#c_zk").val();
            $("#zk").val(bill.FormatNumber(c_zk*1,mBit));
            $("#xs_yhsum").html(bill.FormatNumber(money1sumv * 1 * c_zk * 1,mBit));
            break;
        case "money1":
        	var premoney = $("#premoney").val()*1;
        	var money1 = $("#money1").val()*1;
        	if($("#zk").is(":hidden")){
           	 	$("#yhmoney").html(bill.FormatNumber(premoney - money1 +"",mBit));
        	}else{
        		$("#zk").val(bill.FormatNumber(money1/premoney+"",mBit));
        	}
        	break;
    }
}

//优惠方式 回调方法
window.HandleSaleType = function(){
	var yhval = $("input[name='c_yhtype']:checked").val();
	if(window.ytypeValue == undefined){ window.ytypeValue = 0;}
	if(yhval!=window.ytypeValue){
		window.ytypeValue = yhval;
		if(window.ytypeValue == 1){
			$("#c_yhmoney").parent().parent().parent().parent().hide();
			$("#yhmoney").parent().parent().parent().parent().hide();
			$("#c_zk").parent("div").show();
			$("#zk").parent("div").show();
			$("input[name='yhtype'][value=1]")[0].checked = true; 
			$("input[name='yhtype'][value=0]")[0].checked = false;  
			$("#yhtype").val(1);
	        var money1sumv = $("#money1sumv").text();
	        var zk = $("#c_zk").val();
	        $("#xs_yhsum").html(bill.FormatNumber((money1sumv * 1 * zk*1) + "",__currwin.zsml.header.moneybit))
		}else{
			$("#c_yhmoney").parent().parent().parent().parent().show();
			$("#yhmoney").parent().parent().parent().parent().show();
			$("#c_zk").parent("div").hide();
			$("#zk").parent("div").hide();
			$("input[name='yhtype'][value=0]")[0].checked = true;  
			$("input[name='yhtype'][value=1]")[0].checked = false;  
			$("#yhtype").val(0);
	        var money1sumv = $("#money1sumv").text();
	        var c_yhmoney = $("#c_yhmoney").val();
	        $("#xs_yhsum").html(bill.FormatNumber((money1sumv*1 - c_yhmoney*1)+"",__currwin.zsml.header.moneybit))
		}
	}
}

//结算方式 回调方法
window.HandleBackType = function(){
	var btval = $("input[name='backType']:checked").val();
	if(window.backtypeValue == undefined){ window.backtypeValue = 0;}
    var morepay = $('#morepay').val()*1;
    if(btval != window.backtypeValue){
		window.backtypeValue = btval;
		if(window.backtypeValue == 1){
			var trs = $("tr[for*='hkmoney']").css("display","none");
			$("tr[for='dateYs']").css("display","");
			$("tr[for='bankin2']").css("display","none");
			$("tr[for='leftinfo']").css("display","none");
		}else{
			if(morepay == 0){
				var trs = $("tr[for*='hkmoney']");
				$(trs[0]).css("display","");
			}else{
				var trs = $("tr[for*='hkmoney']").css("display","");
			}
			$("tr[for='bankin2']").css("display","");
			$("tr[for='dateYs']").css("display","none");
			$("tr[for='leftinfo']").css("display","");
		}
	}
}

window.FormulaForBankin = function(currDBName){
	/*
	 * 应收总额		money1
	 * 预收抵扣		DKMoney
	 * 剩余			leftskmoney
	 * 找零			zlmoney
	 */
	console.log(currDBName);
	setTimeout(function(){
		var morepay = $('#morepay').val()*1;
		var hks = $("input[dbname*='hkmoney']");
		var money1 = $("#money1").val()*1;
		var DKMoney = $("#DKMoney").val()*1;
		if(morepay == 0){
			switch(currDBName){
				case "DKMoney":
					if(DKMoney <= money1){
						$(hks[0]).val(bill.FormatNumber(money1 - DKMoney,__currwin.zsml.header.moneybit));
						var hkv = $(hks[0]).val()*1;
						$("#leftskmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
						$("#zlmoney").html(bill.FormatNumber(DKMoney + hkv - money1,__currwin.zsml.header.moneybit));
					}else{
						$(hks[0]).val(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
						var hkv = $(hks[0]).val()*1;
						$("#leftskmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
						$("#zlmoney").html(bill.FormatNumber(DKMoney + hkv - money1,__currwin.zsml.header.moneybit));
					}
					break;
				default:
					var hkv = $("#" + currDBName).val()*1;
					var dip = money1 - DKMoney - hkv;
					if(dip >= 0){
						$("#leftskmoney").html(bill.FormatNumber(dip,__currwin.zsml.header.moneybit));
						$("#zlmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
					}else{
						$("#leftskmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
						$("#zlmoney").html(bill.FormatNumber(dip*(-1),__currwin.zsml.header.moneybit));
					}
					break;
			}
		}else{
			switch(currDBName){
				case "DKMoney":
					if(DKMoney <= money1){
						$(hks[0]).val(bill.FormatNumber(money1 - DKMoney,__currwin.zsml.header.moneybit));
						for(var i = 1; i<hks.length; i++){
							$(hks[i]).val(bill.FormatNumber(0,__currwin.zsml.header.moneybit))
						}
						$("#leftskmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
						$("#zlmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
					}else{
						for(var i = 0; i<hks.length; i++){
							$(hks[i]).val(bill.FormatNumber(0,__currwin.zsml.header.moneybit))
						}
						$("#leftskmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
						$("#zlmoney").html(bill.FormatNumber(DKMoney - money1,__currwin.zsml.header.moneybit));
					}
					break;
				default:
					var hkv = $("#currDBName").val()*1;
					var hksum = 0;
					var dip = 0;
					for(var i = 0; i<hks.length; i++){
						var dbname = $(hks[i]).attr("dbname");
						if(dbname != currDBName){
							hksum += $(hks[i]).val()*1;
						}
						if(dbname == currDBName){
							var thkv = $(hks[i]).val()*1;
							dip = money1 - DKMoney - hksum - thkv;
							if(dip > 0){
								if($(hks[i+1])[0]){
									$(hks[i+1]).val(bill.FormatNumber(dip,__currwin.zsml.header.moneybit));
									$("#leftskmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
									$("#zlmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
									for(var ii = i+2;ii<hks.length; ii++){
										if($(hks[ii]))$(hks[ii]).val(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
									}
								}else{
									$("#leftskmoney").html(bill.FormatNumber(dip,__currwin.zsml.header.moneybit));
									$("#zlmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
								}
							}else{
								$("#leftskmoney").html(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
								$("#zlmoney").html(bill.FormatNumber(dip*(-1),__currwin.zsml.header.moneybit));
								for(var ii = i+1;ii<hks.length; ii++){
									if($(hks[ii]))$(hks[ii]).val(bill.FormatNumber(0,__currwin.zsml.header.moneybit));
								}
							}
							break;
						}
					}
					break;
			}
		}
	},100)
}


//开单结算地址选择自动完成
app.addMessageEvent("NetAutoCompleteSelected", function(data){
	if(__currwin.id!=data.recid) { return; }
	var o = data.data;
	$("#chooseAddrDom").html("<div style='height:100px;width:85%;float:left;'>"
            + "<div style='width:100%;height:50px;float:left;'>"
                + "<div style='width:25%;height:50px;line-height:50px;float:left;margin-left:5%;overflow: hidden;white-space:nowrap;text-overflow:ellipsis;'>"+ o.receiver +"</div>"
                + "<div style='width:60%;height:50px;line-height:50px;float:left;margin-left:5%;overflow: hidden;white-space:nowrap;text-overflow:ellipsis;'>"+ o.mobile +"</div>"
            + "</div>"
            + "<div style='width:90%;height:50px;float:left;margin-left:5%;overflow: hidden;white-space:nowrap;text-overflow:ellipsis;''>"+ o.AllAddress +"</div>"
      + "</div>"
      + "<div style='float:right;height:100px;width:10%;background:url(../skin/default/img/me_left.png) center center no-repeat;background-size:12px auto;' onclick='window.chooseAddr(this)'"
      + "url='"+ __currwin.zsml.header.virpath +"SYSN/view/store/sent/sendaddresslist.ashx?__fielddbname=addressgroup&fromtype=1&__displayuitype=urlpage' target='_blank' action='_url'></div>")
})

window.updateSumForSpcFun = function(lvw,rowindex,dbi,v){
	console.log(v) 
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
	    v = bill.FormatNumber(v, __currwin.zsml.header.pricebit.sale);
		lvw.rows[rowindex][pidx] = v;
		lvw.rows[rowindex][midx] = bill.FormatNumber(v*1*(lvw.rows[rowindex][nidx]*1),__currwin.zsml.header.moneybit);
	}
	if(hds[dbi].dbname == "num1"){
		v = bill.FormatNumber(v,__currwin.zsml.header.numberbit);
		lvw.rows[rowindex][nidx] = v;
		lvw.rows[rowindex][midx] = bill.FormatNumber(v*1*(lvw.rows[rowindex][pidx]*1),__currwin.zsml.header.numberbit);
	}
}

//币种切换触发的回调事件
window.__setSelectValueCallBack = function(o){
	var input = document.getElementById(o.id);
	input.value = o.val;
	input.parentNode.innerHTML = o.val + input.outerHTML;
}

//挂接PDA
window.OnMachineScanfRec = function(dbname, codev){
	window.setInputXlhForBill(codev);
}

window.setInputXlhForBill = function(codev){
	if(codev.length==0) { return; }
	var __currwin = plus.webview.currentWebview();
	var company = "";
	var invoiceType = "";
	app.getPostDatas(function(dbname, v){    
		if(dbname == "company"){ company = v;}
		if(dbname == "invoiceType"){ invoiceType = v; }
	},"post");
	bill.PageScanfEventRec({
		hwnd: __currwin.id,
		dbname: "sys_global_pages",
		code: codev,
		params:{
			company:company,
			invoiceType:invoiceType
		}
	});
	setTimeout(function(){
		$ID("childrefreshEventbox").value = 0;
		bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
	},1000)
};