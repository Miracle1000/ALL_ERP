function QTNumChange(srcType) {
	var numQC = ($ID('NumTesting_0').value || 0) * 1;
	var numSJ = ($ID('SerialNumber_0').value || 0) * 1;
	if (numQC >= numSJ) {
		$ID('NumTesting_0').value = numSJ;
		$ID('QTMode_0check').click();
	}
	else {
		var isAllJ = $ID('QTMode_0check').checked;  //是否是全检
		if (srcType == 1 && isAllJ) {
			$ID('NumTesting_0').value = numSJ;
		} else {
			if (isAllJ) { $ID('QTMode_1check').click(); }
		}
	}
};

window.OnListViewInsertNewRow = function (jlvw, rowindex, srcfrom) {
	var posi = rowindex - 1;
	if (posi < 0) { return;}
	for (var i = 0; i < jlvw.headers.length; i++) {
		switch (jlvw.headers[i].dbname.toLowerCase()) {
			case "id":
			case "xlh": 
			case "serialnumber":
			case "numtesting": 
			case "oknum":
			case "failnum": 
			case "qtresult":
				break;
			default:
				jlvw.rows[rowindex][i] = jlvw.rows[posi][i];
		}
	}
}

function SerialNumberCellChange(box) {
	var defnum = 0, num = 0;
	if (!box) { return; }
	if ( !(box.defaultValue == "" || box.defaultValue == null) ) {
		defnum = parseFloat(box.defaultValue);
	}
	num = parseFloat(box.value);
	if (num == 0) { return; }
	if (num >= defnum) { box.value = defnum; return; }  //禁止超量
	if (defnum < 0) { return; }
	var td = $(box).parents('td[dbcolindex]:eq(0)')[0];
	var tr = td.parentNode;
	var rowindex = parseInt(tr.getAttribute('pos'));
	var tb = tr.parentNode.parentNode;
	var jlvw = window[tb.id.replace('lvw_dbtable_', 'lvw_JsonData_')];
	var colindex = parseInt(td.getAttribute('dbcolindex'));
	var idindex = -1, xlhpos = -1, sjnumpos = -1, qcnumpos = -1, oknumpos = -1, failnumpos = -1, qtresultpos = -1;
	for (var i = 0; i < jlvw.headers.length; i++) {
		switch (jlvw.headers[i].dbname.toLowerCase()) {
			case "id":	idindex = i; break;
			case "xlh":   xlhpos = i; break;
			case "serialnumber": sjnumpos = i; break;
			case "numtesting":  qcnumpos = i; break;
			case "oknum": oknumpos = i; break;
			case "failnum": failnumpos = i; break;
			case "qtresult": qtresultpos = i; break;
		}
	}
	//修改原行值
	jlvw.rows[rowindex][sjnumpos] = num;
	jlvw.rows[rowindex][qcnumpos] = num;
	jlvw.rows[rowindex][oknumpos] = num;
	jlvw.rows[rowindex][failnumpos] = 0;
	jlvw.rows[rowindex][qtresultpos] = 0;
	//拆出新行的
	var newrow = app.CloneObject(jlvw.rows[rowindex]);
	newrow[sjnumpos] = defnum - num;
	newrow[qcnumpos] = newrow[sjnumpos];
	newrow[oknumpos] = newrow[sjnumpos];
	newrow[failnumpos] = 0;
	newrow[xlhpos] = "";
	newrow[idindex] = 0;
	jlvw.rows.splice(rowindex + 1, 0, newrow);
	window.ListView.ReCreateVRows(false, jlvw, null);
	var updateCols = window.ListView.GetNeedReChangeCols(jlvw, colindex);
	window.ListView.ApplyCellSumsData(jlvw, updateCols);
	___RefreshListViewByJson(jlvw);
}