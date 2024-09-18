function SetNum1ByParentNumlvw(pRowindex, ForKuinID) {
    //获取登记数量，比例，可用数量，明细ID,父级Id的列位
    var numindex = -1;
    var blindex = -1;
    var kyindex = -1;
    var ListIDindex = -1;
    var bidindex = -1;
    var kuinIDIndex = -1;
    var NeedWastAgeindex = -1;
    var lvw = window['lvw_JsonData_rglvw'];
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'num1') { numindex = i; }
        if (lvw.headers[i].dbname == 'bl') { blindex = i; }
        if (lvw.headers[i].dbname == 'ky') { kyindex = i; }
        if (lvw.headers[i].dbname == 'ListID') { ListIDindex = i; }
        if (lvw.headers[i].dbname == 'bid') { bidindex = i; }
        if (lvw.headers[i].dbname == 'ForKuinID') { kuinIDIndex = i; }
        if (lvw.headers[i].dbname == 'NeedWastAge') { NeedWastAgeindex = i; }
    }

    //获取父件的登记数量，明细ID的值
    var num1vl = parseFloat(lvw.rows[pRowindex][numindex]);
    var listIdVL = parseInt(lvw.rows[pRowindex][ListIDindex]);

    //循环更新子件登记数量
    for (var i = 0; i < lvw.rows.length; i++) {
        if (parseInt(lvw.rows[i][bidindex]) == listIdVL && parseInt(lvw.rows[i][kuinIDIndex]) == ForKuinID) {
            var newNum1 = num1vl * parseFloat(lvw.rows[i][blindex]) * (1 + parseFloat(lvw.rows[i][NeedWastAgeindex])/100);
            __lvw_je_updateCellValue(lvw.id, i, numindex, newNum1);
        }
    }
    ___RefreshListViewByJson(plvw);
}


window.OnListViewInsertNewTreeNode = function (lvw, newnodeRowIndex, parentNodeRowIndex, handleCellIndex) {
    var kuinIDIndex = -1;
    var ListIDindex = -1;
    var bidindex = -1;
    var lvw = window['lvw_JsonData_rglvw'];
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == 'ForKuinID') { kuinIDIndex = i; }
        if (lvw.headers[i].dbname == 'ListID') { ListIDindex = i; }
        if (lvw.headers[i].dbname == 'bid') { bidindex = i; }
    };
    lvw.rows[newnodeRowIndex][kuinIDIndex] = lvw.rows[parentNodeRowIndex][kuinIDIndex];
    lvw.rows[newnodeRowIndex][bidindex] = lvw.rows[parentNodeRowIndex][ListIDindex];
}

window.SetFromTypeId = function (fromType, formId) {
	window.OnBillLoad = function () {
		var jtvw = TreeView.objects[fromType == 1 ? 0 : (TreeView.objects.length - 1)];
		for (var i = 0; i < jtvw.nodes.length; i++) {
			var nd = jtvw.nodes[i];
			if (nd.id == formId) {
				var htmlid = TreeView.GetHtmlIdByJNode(nd, jtvw);
				$ID("ztn_"+htmlid + "_ck").click();
				break;
			}
		}
	}
}