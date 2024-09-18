LeftPage.SsTableTDClick = function (id, index, len) {
    LeftPage.OnPageResizeExec();//切换时计算对应的树的高度避免出现纵向滚动条
    var title = $ID("reportlefttopbar_" + id + "_" + index).innerText;
    if (title.indexOf("整单委外") >= 0 && title.indexOf("工序委外")>=0) {
        window.location.href = "?index=" + index;
    }
    if (title.indexOf("整单委外") >= 0 && title.indexOf("工序委外")<0) {
        window.location.href = "?index=" + 0;
    }
    if (title.indexOf("整单委外") < 0 && title.indexOf("工序委外") >= 0) {
        window.location.href = "?index=" + 1;
    }
}

window.OnBillLoad = function () {
    var index = window.location.href.indexOf("?index=1") > 0 ? 1 : 0;
    var len = 2;
    var id = "sdksyscoreLeftpage";
    for (var i = 0; i < len; i++) {
        var dispay = index == i ? "" : "none";
        if ($ID("reportlefttopbar_" + id + "_" + i)) {
            $ID("reportlefttopbar_" + id + "_" + i).style.display = dispay;
            if ($ID("jsdiv_" + id + "_" + i)) { $ID("jsdiv_" + id + "_" + i).style.display = dispay; }
            $ID("leftpgtreebar_" + id + "_" + i).style.display = dispay;
            $ID("treebox_" + id + "_" + i).style.display = dispay;
            var daysbox = $ID("daysdiv_" + id + "_" + i);
            if (daysbox) { daysbox.style.display = dispay; }
        }
    }
}




function QTModeChangeFun(v) {
    var val = v.value;
    var obj = Bill.Data;
    var lvw;
    for (var i = 0; i < obj.groups.length; i++) {
        if (obj.groups[i].dbname == "HashQtDetail") {
            lvw = obj.groups[i].fields[0].listview;
        }
    }
    var cpindex = -1;
    var snindex = -1;
    var cfindex = -1;
    var nbindex = -1;
    var qrindex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "NumTesting") { cpindex = i; }
        if (lvw.headers[i].dbname == "SerialNumber") { snindex = i; }

        if (lvw.headers[i].dbname == "NumBF") { nbindex = i; }
        if (lvw.headers[i].dbname == "QTConform") { cfindex = i; }
        if (lvw.headers[i].dbname == "QTResult") { qrindex = i; }
    }
    for (var i = 0; i < lvw.rows.length; i++) {

        if (val == 0) {
            __lvw_je_updateCellValue(lvw.id, i, cpindex, lvw.rows[i][snindex]);
            __lvw_je_updateCellValue(lvw.id, i, nbindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, cfindex, lvw.rows[i][snindex]);
            __lvw_je_updateCellValue(lvw.id, i, qrindex, "0");
        }
        else {
            __lvw_je_updateCellValue(lvw.id, i, cpindex, 0)
            __lvw_je_updateCellValue(lvw.id, i, nbindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, cfindex,0);
            __lvw_je_updateCellValue(lvw.id, i, qrindex, "1");
        }
    }
}
function NumTestingCellChange(box, cell) {
    var id = box.id;
    var td = $(box).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var tb = tr.parentNode.parentNode;
    var jlvw = window[tb.id.replace('lvw_dbtable_', 'lvw_JsonData_')];
    var colindex = td.getAttribute('dbcolindex');
    var rowindex = tr.getAttribute('pos');
    var certIndex = parseInt(colindex) + 1;
    var uncertIndex = parseInt(colindex) + 2;
    var resultIndex = parseInt(colindex) + 3;
    var seriIndex = parseInt(colindex) - 1;
    jlvw.rows[rowindex][certIndex] = 0;
    jlvw.rows[rowindex][uncertIndex] = 0;
    jlvw.rows[rowindex][resultIndex] = "1";
    jlvw.rows[rowindex][colindex] = box.value;
    var seri = parseFloat(jlvw.rows[rowindex][seriIndex]);
    var curNum = parseFloat(jlvw.rows[rowindex][colindex]);
    if (curNum > seri)
        jlvw.rows[rowindex][colindex] = jlvw.rows[rowindex][seriIndex];

    ___RefreshListViewByJson(jlvw);
    var t = $("#" + id).val();
    $("#" + id).val("").focus().val(t);


}
function SerialNumberCellChange(box) {
    var orinum = 0, num = 0;

    if (box.defaultValue == "" || box.defaultValue == null) {
    } else {
        orinum = parseFloat(box.defaultValue);
    }
    if (box.value == "" || box.value == null) {
    } else {
        num = parseFloat(box.value);
    }

    var td = $(box).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var tb = tr.parentNode.parentNode;
    var jlvw = window[tb.id.replace('lvw_dbtable_', 'lvw_JsonData_')];
    var colindex = parseInt(td.getAttribute('dbcolindex'));
    var rowindex = parseInt(tr.getAttribute('pos'));
    var cpindex = -1; ocpindex = -1; idindex = -1;
    for (var i = 0; i < jlvw.headers.length; i++) {
        if (jlvw.headers[i].dbname == "xlhList") { cpindex = i; }
        if (jlvw.headers[i].dbname == "orgNum") { ocpindex = i; }
        if (jlvw.headers[i].dbname == "id") { idindex = i; }
    }
    var isExcess = parseInt($ID("isExcess").value);
    var supNum = parseFloat(jlvw.rows[rowindex][ocpindex])
    var totalNum = 0;
    for (var i = 0; i < jlvw.rows.length; i++) {
        if (i != rowindex)
            totalNum = totalNum + parseFloat(jlvw.rows[i][colindex]);

    }
    totalNum += num;
    if (orinum <= num) {
        for (var i = 0; i < 6; i++) {
            var index = colindex + i;
            if (i <= 2) {
                jlvw.rows[rowindex][index] = (isExcess == 0 && totalNum > supNum) ? orinum : num;
            } else if (i > 2 && i <= 4) {
                jlvw.rows[rowindex][index] = 0;
            } else {
                jlvw.rows[rowindex][index] = "1";
            }
        }
        ___RefreshListViewByJson(jlvw);
        return;
    }
    if (orinum > 0) {
        for (var i = 0; i < 6; i++) {
            var index = colindex + i;
            if (i <= 2) {
                jlvw.rows[rowindex][index] = num;
            } else if (i > 2 && i <= 4) {
                jlvw.rows[rowindex][index] = 0;
            } else {
                jlvw.rows[rowindex][index] = "0";
            }
        }


        var newrow = app.CloneObject(jlvw.rows[rowindex]);
        for (var j = 0; j < 6; j++) {
            var index = colindex + j;
            if (j <= 2) {
                newrow[index] = orinum - num;
            } else if (j > 2 && j <= 4) {
                newrow[index] = 0;
            } else {
                newrow[index] = "1";
            }
        }
        newrow[idindex] = '';
        jlvw.rows.splice(rowindex + 1, 0, newrow);
        window.ListView.ReCreateVRows(false, jlvw, null);
         var updateCols = window.ListView.GetNeedReChangeCols(jlvw, colindex);
        window.ListView.ApplyCellSumsData(jlvw, updateCols);
    	___RefreshListViewByJson(jlvw);
    	var sumNum = 0;
    	for (var i = 0; i < jlvw.rows.length; i++) {
    	    sumNum = sumNum + parseFloat(jlvw.rows[i][colindex]);
    	}
    	$ID("SerialNumber1_0").value = sumNum;
    	$ID("SerialNumber1_0").nextSibling.value = sumNum;
    }
}

function QTNumChange() {
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("certNum_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    var QTMode0 = $ID("QTMode_0check");
    var QTMode1 = $ID("QTMode_1check");
    if (NumTesting >= SerialNum) {
        $ID("NumTesting_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("certNum_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = true;
        QTMode1.checked = false;
    } else {
        $ID("certNum_0").value = NumTesting.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = false;
        QTMode1.checked = true;
    }
    if (SerialNum == 0) {
        $ID("OTRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("OTRate_0").previousSibling.innerText = (NumTesting * 100 / SerialNum).toFixed(window.SysConfig.RateBit);
    }

    $ID("certRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
    $ID("uncertRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit)
    QTResult0.checked = true;
    QTResult1.checked = false;
}

function SerialNumberchange() {
    var isExcess = parseFloat($ID("isExcess").value);
    var orgNum = parseFloat($ID("orgNum_0").value);
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("certNum_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    var QTMode0 = $ID("QTMode_0check");
    var QTMode1 = $ID("QTMode_1check");
    if (orgNum < SerialNum && isExcess == 0) {
        $ID("SerialNumber_0").value = orgNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumTesting_0").value = orgNum.toFixed(window.SysConfig.NumberBit);
        $ID("certNum_0").value = orgNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
    } else {
        $ID("NumTesting_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("certNum_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
    }
    if (SerialNum == 0) {
        document.getElementById("OTRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);

    } else {
        document.getElementById("OTRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);

    }
    $ID("certRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
    $ID("uncertRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    QTResult0.checked = true;
    QTResult1.checked = false;
    QTMode0.checked = true;
    QTMode1.checked = false;
}

function CertNumchange() {
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("certNum_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    if (certNum > NumTesting - NumBF) {
        $ID("certNum_0").value = (NumTesting - NumBF).toFixed(window.SysConfig.NumberBit);
        certNum = NumTesting - NumBF;
    }
    if (certNum == NumTesting) {
        QTResult0.checked = true;
        QTResult1.checked = false;
    }
    if (NumTesting == 0) {
        $ID("certRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("certRate_0").previousSibling.innerText = (certNum * 100 / NumTesting).toFixed(window.SysConfig.RateBit);
    }
}
function NumBFChange() {
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("certNum_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    if (NumBF > NumTesting - certNum) {
        $ID("NumBF_0").value = (NumTesting - certNum).toFixed(window.SysConfig.NumberBit);
        NumBF = NumTesting - certNum;
    }
    if (NumBF == NumTesting) {
        QTResult0.checked = false;
        QTResult1.checked = true;
    }

    if (NumTesting == 0) {
        $ID("uncertRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("uncertRate_0").previousSibling.innerText = (NumBF * 100 / NumTesting).toFixed(window.SysConfig.RateBit);
    }
}

function QTModeChange() {
    var QTMode0 = $ID("QTMode_0check");
    var QTMode = QTMode0.checked ? 0 : 1;
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("certNum_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    var QTMode0 = $ID("QTMode_0check");
    var QTMode1 = $ID("QTMode_1check");
    if (QTMode == 0) {
        $ID("NumTesting_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("certNum_0").value = SerialNum;
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = true;
        QTMode1.checked = false;
        $ID("OTRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
        $ID("certRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
        $ID("uncertRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("NumTesting_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("certNum_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = false;
        QTMode1.checked = true;
        $ID("OTRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
        $ID("certRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
        $ID("uncertRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    }
}

