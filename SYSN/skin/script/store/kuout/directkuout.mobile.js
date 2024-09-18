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
	if(closeWinhwnd.indexOf("_directkuoutscan")==-1 && closeWinhwnd.indexOf("geproductbilllistasp")==-1 && closeWinhwnd.indexOf("_directkuoutedit")==-1) {return;}
	$ID("childrefreshEventbox").value = 0;
	bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
});

function curPageDatesSave() {
    $ID("childrefreshEventbox").value = 1;
    bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
}

window.SaveDatesBeforeAtuoCom = function () {
    curPageDatesSave();
}
//仓库扫描添加按钮
window.getIntoCkScanfPage = function (el) {
    el.setAttribute("url", "../CkScan.ashx?Billtype=kuout");
    ui.CZSMLPage(el);
}
//仓库扫描数据回调
app.addMessageEvent("returnCkData", function (data, closeWinhwnd) {
    if (data) {
        $ID("ck").value = data.ckName;
        $ID("ck_h").value = data.id;
    }
});
//扫描添加按钮
window.getIntoScanfPage = function (el) {
    var company = "";
    var invoiceType = "";
    app.getPostDatas(function (dbname, v) {
        if (dbname == "company") { company = v; }
        if (dbname == "invoiceType") { invoiceType = v; }
    }, "post");
    curPageDatesSave();
	el.setAttribute("url","DirectKuoutScan.ashx?fromtype=kuoutbill");
	ui.CZSMLPage(el);
}

//手动添加产品按钮 
window.getIntoChooseProcPage = function (el) {
    var company = "";
    var invoiceType = "";
    app.getPostDatas(function (dbname, v) {
        if (dbname == "company") { company = v; }
        if (dbname == "invoiceType") { invoiceType = v; }
    }, "post");
    curPageDatesSave();
	el.setAttribute("url",info.hosturl +"/mobilephone/salesManage/product/billlist.asp?fromtype=kuoutbill&company="+company+"&invoiceType="+invoiceType);
	ui.CZSMLPage(el);
}

//采购添加底部结算按钮
window.onBeforePageInit = function(){
    var currweb = plus.webview.currentWebview();
    var vendor = plus.device.vendor == "alps";    //判断PDA标识
	var zsml = currweb.zsml;
	var jbill = zsml.body.bill;
	var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonBG");
	scanfbtn.formathtml = "<div style='width:80%;margin:0 auto;text-align:center;'>"
	                         + "<div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>"
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
		if(hds[i].dbname=="price1"){ pidx = i; }
	}
	if(hds[dbi].dbname == "price1"){
		lvw.rows[rowindex][pidx] = v;
		lvw.rows[rowindex][midx] = v*1*(lvw.rows[rowindex][nidx]*1);
	}
	if(hds[dbi].dbname == "num1"){
	    lvw.rows[rowindex][nidx] =bill.FormatNumber(v, __currwin.zsml.header.numberbit) ;
	    lvw.rows[rowindex][midx] = bill.FormatNumber(v * 1 * (lvw.rows[rowindex][pidx] * 1), __currwin.zsml.header.moneybit);
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

//序列号选择更新
app.addMessageEvent("kuoutlistxlhsaved", function (dat) {     
    if (dat.recid.indexOf("_directkuout") > -1 && dat.recid.indexOf("_directkuoutedit") == -1) {
        curPageDatesSave();
        /*
		var srcbox = window.CurrActiveAutoCompleteBox; 
		var pbox = $(srcbox).parents("table[dbsign][pos]")[0]; //.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		var dbsign = pbox.getAttribute("dbsign");
		var pos = pbox.getAttribute("pos")*1;
		var jlvw = window[dbsign];
		var ibox1 = document.createElement("input");
		var ibox2 = document.createElement("input");
		ibox1.id = "num1";
		ibox2.id = "xlh";
		ibox1.value = info.FormatNumber(dat.sumv, __currwin.zsml.header.numberbit);
		ibox2.value = dat.xlhs;
		bill.updateListViewValue(dbsign, pos, "num1", ibox1);
		bill.updateListViewValue(dbsign, pos, "xlh", ibox2);
		bill.RefreshListRowHTML(jlvw, pos);
        */
	}
});

window.AddExtraParams = function(params){
	var ck = "";
	app.getPostDatas(function(dbname, v){    
		if(dbname == "ck"){ ck = v;}
	},"post");
	params["ck"] = ck;
	return params;
}

//挂接PDA
window.OnMachineScanfRec = function (dbname, codev) {
    try{

        window.setInputXlhForBill(codev);
    } catch (e) {
        alert(e.message)
    }
}

window.setInputXlhForBill = function (codev) {
    if (codev.length == 0) { return; }
    var __currwin = plus.webview.currentWebview();
    bill.PageScanfEventRec({
        hwnd: __currwin.id,
        dbname: "sys_global_pages",
        code: codev
    });
    setTimeout(function () {
        $ID("childrefreshEventbox").value = 0;
        bill.triggerFieldEvent($ID("childrefreshEventbox"), "change");
    })
};

window.AddScanfItem = function(){}