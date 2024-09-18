
tvw.onitemclick = function(item) {
	if(top.onTreeNodeClick) {
		top.onTreeNodeClick(item);	
	}
}

top.onTreeNodeClick = function(node) {	
	var itemValue = node.value;
	var arr_item;
	var cpord, htord, htlId
	var mxCount=Number($ID("mxCount").value);
	if (itemValue!="" && itemValue!="-1")
	{
		if (itemValue.indexOf(";")==-1 && isNaN(itemValue)==false){
			itemValue = Number(itemValue);
			if (itemValue>0){
				cpord = itemValue;
				htord = 0;
				htlId = 0;
			}
		}else{
			arr_item = itemValue.split(";");
			cpord = arr_item[0];
			htord = arr_item[1];
			htlId = arr_item[2];
			kuoutlist2Id = arr_item[3];
		}
		ajax.regEvent("addProduct");
		$ap("cpord",cpord);
		$ap("htord",htord);
		$ap("htlId", htlId);
		$ap("k2ID", kuoutlist2Id);
		$ap("timestamp",new Date().getTime());	
		var r = ajax.send();
		if(r != ""){
			var newData
			var arr_res = r.split("\3\5");
			if (arr_res[0]=="1" && arr_res[1] != ""){
				var ArrDatalist = arr_res[1].split("\4\6");
				for (var i =0; i< ArrDatalist.length; i++ )
				{
					newData = ArrDatalist[i].split("\1\2");
					lvw_InsertRow("mlistvw", newData);
				}	
				mxCount += ArrDatalist.length;
				$ID("mxCount").value = mxCount;
				var arr_index = $(".lvw_index");
				var indexTab = "";
				var indexTd = ""
				for(var i = 0; i< arr_index.length; i++){
					indexTab = arr_index[i].childNodes[0];
					indexTd = indexTab.rows.item(0).cells[1];
					indexTd.innerHTML = i+1;
				}
			}else if(arr_res[0]=="2"){
				app.Alert("添加失败，可添加产品数超过系统设定数量");
			}else if(arr_res[0]=="3"){
				app.Alert("参数丢失，请重新登录");
			}else{
				app.Alert(r);//app.Alert("数据保存错误，请刷新后重试");
			}
		}
	}
}
function ajaxSubmit(sort1){
    var B=$ID("B").value;
    var C=$ID("txtKeywords").value;
	ajax.regEvent("htcls_ctree");
	$ap("B",B);
	$ap("C",C);
	$ap("sort1",sort1);
	$ID("treeHtml").innerHTML = "loading...";
	var r = ajax.send();
	if(r != ""){
		$ID("treeHtml").innerHTML = r;
	}else{
		app.Alert("未知错误，请重试");
		return;
	}
	
}

