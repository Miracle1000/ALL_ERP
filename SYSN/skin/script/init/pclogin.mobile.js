
window.onBeforePageInit = function (zsml) {
	var btncss = "margin:8px;border:1px solid #ccccdc;width:70%;padding:15px;border-radius:6px;display:none";
	var bill = zsml.body.bill;
	var frm = bill.groups[0].fields[0].formathtml;
	if (frm.indexOf("errortext") > 0) {
		var err = frm.split("errortext='")[1].split("'")[0];
		bill.groups[0].fields[0].formathtml = "<div id='sanfbody' style='position:absolute;top:0px;left:0px;width:100%;height:100%;background-color:white'>"
															+ "<div style='position:absolute;width:100%;height:450px;text-align:center;top:50%;margin-top:-230px'>"
															+ "<img src='../skin/default/img/PC.png' style='min-height:80px;width:120px;margin-top:50px;'>"
															+ "<div style='text-align:center;color:red;padding-top:5px;font-size:14px' id='scanfmsglabel'>" + err + "</div>"
															+ "</div>"
															+ "<div style='position:absolute;bottom:150px;text-align:center;width:100%'>"
															+ "<button style='" + btncss.replace("display:none", "background-color:#333388;color:white") + "'  id='cancelbutton' onclick='ui.close()'>关闭</button>"
															+ "</div>"
															+ "</div>";
		return;
	}
	bill.ui.title = "<span id=headertitle >扫一扫</span>"
	bill.groups[0].fields[0].formathtml = "<div id='sanfbody' style='position:absolute;top:0px;left:0px;width:100%;height:100%;background-color:white'>"
															+ "<div style='position:absolute;width:100%;height:450px;text-align:center;top:50%;margin-top:-230px'>"
															+ "<img src='../skin/default/img/PC.png' style='min-height:80px;width:120px;margin-top:50px;'>"
															+ "<div style='text-align:center;color:red;padding-top:5px;font-size:14px' id='scanfmsglabel'></div>"
															+ "</div>"
															+ "<div style='position:absolute;bottom:150px;text-align:center;width:100%'>"
															+ "<button style='" + btncss + ";background-color:#333388;color:white' id='rescanfbutton' onclick='window.ReStartScanf()'>重新扫描</button><br>"
															+ "<button style='" + btncss + ";background-color:#333388;color:white' id='surebutton' onclick='window.doSureLogin(2)'>确认登录</button><br>"
															+ "<button style='" + btncss + "'  id='cancelbutton' onclick='ui.close()'>取消登录</button>"
															+ "</div>"
															+ "</div>";
	window.OnPageLoadEnd();
};

window.ReStartScanf = function () {
	if (window.ReStartScanfing == 1) {
		return;
	}
	window.ReStartScanfing = 1;
	setTimeout(function () { window.ReStartScanfing = 0; }, 3000);
	window.OnPageLoadEnd();
}

window.OnPageLoadEnd = function () {
	var h = document.documentElement.offsetHeight;
	var t = 50;
	h = parseInt((h - t) * 100.00 / h) + "%";
	var createtype = 0;
	setTimeout(function () {
		if (!$ID("barconnbg")) {
			var w = document.body.offsetWidth;
			var div = document.createElement("div");
			div.id = "barconnbg";
			div.style.cssText = "position:absolute;top:50px;left:0px;width:65%;height:" + (document.documentElement.offsetHeight - t)
				+ "px;";
			document.body.appendChild(div);
		}
	}, 10);
	setTimeout(function () {
		try {
			if (plus.barcode.create) {
				window.barcodeobj = plus.barcode.create('barcode', [plus.barcode.QR], {
					top: (t + 'px'),   left: '0px',
					width: '100%',  height: h,  position: 'static'
				});
				createtype = 1;
			} else {
				window.barcodeobj = new plus.barcode.Barcode('barconnbg',  [plus.barcode.QR]);
			}
			barcodeobj.onmarked = window.RecScanfCode;
			if (createtype == 1) {
				plus.webview.currentWebview().append(barcodeobj);
			}
			barcodeobj.start();
			try { $ID("headertitle").innerHTML = "扫一扫"; } catch (ex) { }
		}
		catch (ex) {
			alert(ex.message);
		}
	}, 50);
};

window.RecScanfCode = function (type, result) {
	barcodeobj.onmarked = null;
	barcodeobj.close();
	$("#barconnbg").remove();
	if (result.indexOf("?ZBMOBPCLGT") > 0) {
		window.currcode = result;
		app.RegEvent("PCLoginReg", {
			code: result
		}, function (r) {});
	} else {
		window.LoginReg('请扫描正确的二维码');
	}
};

window.LoginReg = function (reg) {
    if (reg == "OK") {
        if (window.appconfig && window.appconfig.appName == "MoziBox")
        {
            $ID('scanfmsglabel').innerHTML = "<span style='color:#000000;font-size:14px'>信湖ERP系统登录确认</span>";
        }
        else
        {
            $ID('scanfmsglabel').innerHTML = "<span style='color:#000000;font-size:14px'>智邦国际企业管理系统登录确认</span>";
        }
		$ID('rescanfbutton').style.display = "none";
		$ID('surebutton').style.display = "";
		$ID('cancelbutton').style.display = "";
	} else {
		$ID('scanfmsglabel').innerHTML = reg;
		$ID('rescanfbutton').style.display = "";
		$ID('surebutton').style.display = "none";
		$ID('cancelbutton').style.display = "none";
	}
	$ID("headertitle").innerHTML = "扫码登录";
}

window.doSureLogin = function ( stype) {
	app.RegEvent("PCLoginSure", {
		code: window.currcode,
		suretype: stype
	}, function (r) { });
}

window.LoginSureResult = function (result) {
	if (result == 2) {
		$ID('scanfmsglabel').innerHTML = "<span style='color:#000000;font-size:14px'>登录成功。</span>";
		$ID('surebutton').style.display = "none";
		$ID('cancelbutton').style.display = "none";
		$ID('rescanfbutton').style.display = "none";
		setTimeout(function () {
				window.currcode = "";
				localStorage["disAutoLoginMessage"] = "您的账号成功在电脑登录，祝您办公愉快！";
				setTimeout(function () { plus.runtime.restart(); }, 100);
		},100);
	}
}


ui.addCloseLister(function () {
	if (window.currcode) {
		window.doSureLogin(0);
	}
});

