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
	if(closeWinhwnd.indexOf("_directkuinscan")==-1 && closeWinhwnd.indexOf("geproductbilllistasp")==-1 && closeWinhwnd.indexOf("_directkuinedit")==-1) {return;}
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
    el.setAttribute("url", "../CkScan.ashx?Billtype=kuin");
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
	el.setAttribute("url","DirectKuinScan.ashx?fromtype=kuinbill");
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
	el.setAttribute("url",info.hosturl +"/mobilephone/salesManage/product/billlist.asp?fromtype=kuinbill&company="+company+"&invoiceType="+invoiceType);
	ui.CZSMLPage(el);
}

//直接入库底部结算按钮
window.onBeforePageInit = function(){
	var currweb = plus.webview.currentWebview();
	var zsml = currweb.zsml;
	var jbill = zsml.body.bill;
	var buttonf = bill.NetVerGetFieldByDBName(jbill, "handlemenuButton");
	var buttoncss = "float:left;color:white;width:50%;height:100%;border:0px;text-align:center;line-height:60px;overflow:hidden"
	buttonf.formathtml = "<div style='background-color:#eee'>"
						+ "<div style='border-bottom:2px solid #eee;padding:3px 0px;text-align:center;background-color:white'>"
						+ "<span>如需编辑批次、序列号，</span> "
						+ "<span style='color:#3576AC' onclick='window.hiddenOrShowPHXLH(this)'>请点击>></span>"
						+ "</div>"
						+ "</div>";

	var vendor = plus.device.vendor == "alps";    //判断PDA标识
	var scanfbtn = bill.NetVerGetFieldByDBName(jbill, "ScanfButtonBG");
	scanfbtn.formathtml = "<div style='width:80%;margin:0 auto;text-align:center;'>"
                            + (vendor ? "" : "<div id='ScanfButtonBody' class='sales_lvw_btmbtn' onclick='getIntoScanfPage(this)' target='_blank' action='_url'><dl></dl></div>")
                            + "<div id='AddButtonBody' class='sales_lvw_btmbtn' onclick='getIntoChooseProcPage(this)' target='_blank' action='_url'><dl></dl></div>"
                          +"</div>";
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

//序列号选择更新
app.addMessageEvent("kuinlistxlhsaved", function(dat){
	if(dat.recid && dat.recid.indexOf("_directkuin")>-1 && dat.recid.indexOf("_directkuinedit") == -1){
		var srcbox = window.CurrActiveAutoCompleteBox;
		var pbox = $(srcbox).parents("table[dbsign][pos]")[0]; //.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		var dbsign = pbox.getAttribute("dbsign");
		var pos = pbox.getAttribute("pos")*1;
		var jlvw = window[dbsign];
		var ibox2 = document.createElement("input");
		ibox2.id = "xlh";
		ibox2.value = dat.xlhs; 
		bill.updateListViewValue(dbsign, pos, "xlh", ibox2);
        bill.RefreshListRowHTML(jlvw, pos);
        bill.bind();
	}
});


//**************** 展示序列号编号编辑
window.hiddenOrShowPHXLH = function () {
    var sort=$("#sort1_0").val()
    var lvws = [];
    var currlvw = null;
	for(var n in window){
		if(n.indexOf("LVW")==0){
			var lvw = window[n];
			var lvwid = lvw.id.toLowerCase();
			if (lvwid == "kuinlist") { currlvw = lvw; }
		}
	}
	var h = bill.getlistviewHeaderByDBName(currlvw, "ph");
	var h2 = bill.getlistviewHeaderByDBName(currlvw, "xlh");
	h.display = sort == 2 && h.display != "disedit" ? "disedit" : h.display == "hidden" ? "editable" : "hidden";
	h.visible = h.display!="hidden";
	h2.display =h2.display=="hidden"?"disedit":"hidden";
	h2.visible = h.visible;
	if(h.visible==true){ 
		currlvw.showmaps.push(h.i); 
		currlvw.showmaps.push(h2.i); 
	}
	else { 
		var index = currlvw.showmaps.indexOf(h.i);
		if(index>-1){
			currlvw.showmaps.splice(index, 1); 
		}
		index = currlvw.showmaps.indexOf(h2.i);
		if(index>-1){
			currlvw.showmaps.splice(index, 1); 
		}
	}
	bill.RefreshListviewByJSON(currlvw);
}

//挂接PDA
window.OnMachineScanfRec = function (dbname, codev) {
    window.setInputXlhForBill(codev);
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
    },1000)
};

window.AddScanfItem = function () { }