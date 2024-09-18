function searchLogisticsList(){
	$("#showerr").html("");
	var Logistics_Company =$("#ecid").val() ;

	var Logistics_BillNumber=$("#waybillnumber").val();
	if (Logistics_BillNumber==""){
		$("#showerr").html("请输入要查询的快递单号!");
		return;
	}

	getLogisticsInfo(Logistics_Company,Logistics_BillNumber);

	ajax.regEvent("onSearchLogistics")
	ajax.addParam("Logistics_Company", Logistics_Company);
	ajax.addParam("Logistics_BillNumber", Logistics_BillNumber);
	var r = ajax.send();
	$("#LogisticsListDIV").html(r);
}

//创建MSXML组件
function createXMLHttpRequest() {
	var request = false;
	if(window.XMLHttpRequest) {
		request = new XMLHttpRequest();
		if(request.overrideMimeType) {
			request.overrideMimeType('text/xml');
		}
	} else if(window.ActiveXObject) {
		var versions = ['Microsoft.XMLHTTP', 'MSXML.XMLHTTP', 'Microsoft.XMLHTTP', 'Msxml2.XMLHTTP.7.0', 'Msxml2.XMLHTTP.6.0', 'Msxml2.XMLHTTP.5.0', 'Msxml2.XMLHTTP.4.0', 'MSXML2.XMLHTTP.3.0', 'MSXML2.XMLHTTP'];
		for(var i=0; i<versions.length; i++) {
			try {
				request = new ActiveXObject(versions[i]);
				if(request) {
					return request;
				}
			} catch(e) {}
		}
	}
	return request;
};


//获取快递信息
function getLogisticsInfo(Logistics_Company,Logistics_BillNumber){
	var str_back;
	ajax.regEvent("onGetLogisticsUrl")
	ajax.addParam("Logistics_Company", Logistics_Company);
	ajax.addParam("Logistics_BillNumber", Logistics_BillNumber);
	var r = ajax.send();

	str_back = r.split("|");

	SetSelectChecked("#ecid", str_back[0])

	if (str_back[1] == "OK")
	{
		return true;
	}

	var url = str_back[1] ;
	var xmlhttp = createXMLHttpRequest();
	// 设置超时时间，注意参数顺序
	//xmlhttp.setTimeouts(2000, 2000, 2000, 10000);
	xmlhttp.open("GET", url, false);
	try {
		xmlhttp.send("");
		return true;
	}
	catch(e) {
		// 判断是否为超时错误
		if(e.number == -2147012894) {
			var step = "";
			// 判断超时错误发生所在的阶段
			switch(xmlhttp.readyState) {
				case 1:
					step = "解析域名或连接远程服务器"
					break;
				case 2:
					step = "发送请求";
					break;
				case 3:
					step = "接收数据";
					break;
				default:
					step = "未知阶段";
			}
			alert("发生异常：" + e.message + "<br/>在" + step + "时发生超时错误！");
		}
		return false;
	}
	xmlhttp = null;
}

function SetSelectChecked(selectId, checkValue){
	var select = $(selectId);
	for(var i=0; i<select.get(0).options.length; i++){
		if(select.get(0).options[i].value == checkValue){
			select.get(0).options[i].selected = true;
			break;
		}
	}
}