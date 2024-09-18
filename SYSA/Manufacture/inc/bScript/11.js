var oexec = 0
function bill_onLoad(){
	if(oexec==0){
		oexec = 1
		Bill.RefreshDetail(true)
	}
}

Bill.onScanComplete = function(data){
	var rows = data.split("\r\n");
	if (rows.length>1){
		for(var i=0 ; i<rows.length;i++){
			if (rows[i].indexOf("流水号：")==0){
				data = "YGDA:" + rows[i].replace("流水号：","");
				break;
			}
		}
	}else if (data.indexOf("view.asp?V")>0){
		data = "YGDA:QrUrl="+ data.split("view.asp?")[1];
	}
	var ajaxHttp = Bill.ScriptHttp();
	ajaxHttp.regEvent("onScanComplete");
	ajaxHttp.addParam("data",data);
	ajaxHttp.addParam("oid",11);
	var r = ajaxHttp.send();
	var result = eval("o=" + r + "");
	if (result.msg == 'true'){
		switch (result.datatype)
		{
		case "SCPG": //生产派工
			var td = $("#M_Field_5_1")[0];
			var tb = td.parentElement.parentElement.parentElement;
			Bill.mFieldSelReturn(tb,td,result.rows);
			break;
		case "CLDJ": //产量登记
			var div = document.getElementById('listview_53');
			var rw = result.rows;
			for(var i = 0 ; i < rw.length ; i++){
				if(rw[i].length>1){
					div.hdataArray[div.hdataArray.length] = ("+%;$++%;$+" + rw[i].join("+%;$+")).split("+%;$+");
				}
			}
			div.PageStartIndex = div.hdataArray.length - div.PageSize + 1;
			div.PageStartIndex = div.PageStartIndex > 0 ? div.PageStartIndex : 1
			div.PageEndIndex = div.hdataArray.length;
			lvw.UpdateScrollBar(div);
			lvw.Refresh(div);
			break;
		}
	}
}