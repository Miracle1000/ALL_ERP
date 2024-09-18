LeftPage.SsTableTDClick = function (id, index, len) {
    LeftPage.OnPageResizeExec();//切换时计算对应的树的高度避免出现纵向滚动条
    var title = $ID("reportlefttopbar_" + id + "_" + index).innerText;
    if (title.indexOf("派工") >= 0 && title.indexOf("返工") >= 0) {
        window.location.href = "?index=" + index;
    }
    if (title.indexOf("派工") >= 0 && title.indexOf("返工") < 0) {
        window.location.href = "?index=" + 0;
    }
    if (title.indexOf("派工") < 0 && title.indexOf("返工") >= 0) {
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
    var nsindex = -1;
    var nbindex = -1;
    var qrindex = -1;
    var xlindex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "NumTesting") { cpindex = i; }
        if (lvw.headers[i].dbname == "SerialNumber") { snindex = i; }
        if (lvw.headers[i].dbname == "NumScrap") { nsindex = i; }
        if (lvw.headers[i].dbname == "NumBF") { nbindex = i; }
        if (lvw.headers[i].dbname == "QTConform") { cfindex = i; }
        if (lvw.headers[i].dbname == "QTResult") { qrindex = i; }
        if (lvw.headers[i].dbname == "xlhList") { xlindex = i; }
    }
    var lvwlen = lvw.rows.length - 1;
    for (var i = 0; i < lvwlen; i++) {
        if (val == 0) {
            __lvw_je_updateCellValue(lvw.id, i, cpindex, lvw.rows[i][snindex]);
            __lvw_je_updateCellValue(lvw.id, i, nsindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, nbindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, cfindex, lvw.rows[i][snindex]);
            __lvw_je_updateCellValue(lvw.id, i, qrindex, "0");
        }
        else {
            __lvw_je_updateCellValue(lvw.id, i, cpindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, nsindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, nbindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, cfindex, 0);
            __lvw_je_updateCellValue(lvw.id, i, qrindex, "1");
        }
    }
}

function NumBFBtn(box) {
    var td = $(box).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var tb = tr.parentNode.parentNode;
    var jlvw = window[tb.id.replace('lvw_dbtable_', 'lvw_JsonData_')];
    var colindex = td.getAttribute('dbcolindex');
    var rowindex = tr.getAttribute('pos');
    var cpindex = -1;
    for (var i = 0; i < jlvw.headers.length; i++) {
        if (jlvw.headers[i].dbname == "xlhList") { cpindex = i; }
    }
    var valText = '@detaillvf_NumBF_' + rowindex + "_" + colindex + "_0";
    var xlhList = '@detaillvf_xlhList_' + rowindex + "_" + cpindex + "_0";
    var t = $ID(xlhList);
    var json = $ID(xlhList).value;
    if (json.length > 2) {
        app.closeWindow("xlhPage");
        var url = window.SysConfig.VirPath + "SYSN/view/produceV2/xlh/QualityTestXlh.ashx?valText=" + valText + "&&xlhList=" + xlhList + "&&type=bf";
        var win = app.createWindow("xlhPage", "选择序列号", { closeButton: 'true', height: '555', width: '540', bgShadow: '30', canMove: '1' });
        win.innerHTML = "<iframe frameborder='0' scrolling=0  src='" + url + "' width=\"510\" height=\"560\"> ";
        win.style.overflow = "hidden";
    }
}

function NumScrapBtn(box) {
    var td = $(box).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var tb = tr.parentNode.parentNode;
    var jlvw = window[tb.id.replace('lvw_dbtable_', 'lvw_JsonData_')];
    var colindex = td.getAttribute('dbcolindex');
    var rowindex = tr.getAttribute('pos');
    var cpindex = -1;
    for (var i = 0; i < jlvw.headers.length; i++) {
        if (jlvw.headers[i].dbname == "xlhList") { cpindex = i; }
    }
    var valText = '@detaillvf_NumScrap_' + rowindex + "_" + colindex + "_0";
    var xlhList = '@detaillvf_xlhList_' + rowindex + "_" + cpindex + "_0";
    var json = $ID(xlhList).value;
    if (json.length > 2) {
        app.closeWindow("xlhPage");
        var url = window.SysConfig.VirPath + "SYSN/view/produceV2/xlh/QualityTestXlh.ashx?valText=" + valText + "&&xlhList=" + xlhList + "&&type=fg";
        var win = app.createWindow("xlhPage", "选择序列号", { closeButton: 'true', height: '555', width: '540', bgShadow: '30', canMove: '1'});
        win.innerHTML = "<iframe frameborder='0' scrolling=0  src='" + url + "' width=\"510\" height=\"560\"> ";
        win.style.overflow = "hidden";
    }
}

SerialNumberCellChange = function (box) {
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
                jlvw.rows[rowindex][index] = "0";
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
                newrow[index] = "0";
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
            if (jlvw.rows[i][colindex])
                sumNum = sumNum + parseFloat(jlvw.rows[i][colindex]);
        }
        $ID("SerialNumber1_0").value = sumNum;
        $ID("SerialNumber1_0").nextSibling.value = sumNum;
    }
}
compare = function (obj1, obj2) {
    var val1 = obj1.xlh;
    var val2 = obj2.xlh;
    if (val1 < val2) {
        return -1;
    } else if (val1 > val2) {
        return 1;
    } else {
        return 0;
    }
}
function QTNumChange() {
 
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("QTConform_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var NumScrap = parseFloat($ID("NumScrap_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    var QTMode0 = $ID("QTMode_0check");
    var QTMode1 = $ID("QTMode_1check");
    if (NumTesting >= SerialNum) {

        $ID("NumTesting_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("QTConform_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumScrap_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = true;
        QTMode1.checked = false;
    } else {
        $ID("QTConform_0").value = NumTesting.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumScrap_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = false;
        QTMode1.checked = true;
    }
    if (SerialNum == 0) {
        $ID("OTRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("OTRate_0").previousSibling.innerText = (NumTesting * 100 / SerialNum).toFixed(window.SysConfig.RateBit);
    }

    $ID("certRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
    $ID("NFRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    $ID("ScrapRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    QTResult0.checked = true;
    QTResult1.checked = false;
}

function SerialNumberchange() {
    var isExcess = parseFloat($ID("isExcess").value);
    var orgNum = parseFloat($ID("orgNum_0").value);
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("QTConform_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var NumScrap = parseFloat($ID("NumScrap_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    var QTMode0 = $ID("QTMode_0check");
    var QTMode1 = $ID("QTMode_1check");
    if (orgNum < SerialNum && isExcess == 0) {
        $ID("SerialNumber_0").value = orgNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumTesting_0").value = orgNum.toFixed(window.SysConfig.NumberBit);
        $ID("QTConform_0").value = orgNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumScrap_0").value = (0).toFixed(window.SysConfig.NumberBit);
    } else {
        $ID("NumTesting_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("QTConform_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumScrap_0").value = (0).toFixed(window.SysConfig.NumberBit);
    }
    if (SerialNum == 0) {
        document.getElementById("OTRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);

    } else {
        document.getElementById("OTRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);

    }
    $ID("certRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
    $ID("NFRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    $ID("ScrapRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    QTResult0.checked = true;
    QTResult1.checked = false;
    QTMode0.checked = true;
    QTMode1.checked = false;
}
function CertNumchange() {
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("QTConform_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var NumScrap = parseFloat($ID("NumScrap_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    if (certNum > NumTesting - NumBF) {
        $ID("QTConform_0").value = NumTesting - NumBF;
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
function NumScrapChange() {
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("QTConform_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var NumScrap = parseFloat($ID("NumScrap_0").value);

    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    if (NumScrap > NumTesting - certNum - NumBF) {
        $ID("NumScrap_0").value = (NumTesting - certNum - NumBF).toFixed(window.SysConfig.NumberBit);
        NumScrap = NumTesting - certNum - NumBF;
    }
    if (NumBF + NumScrap == NumTesting) {
        QTResult0.checked = false;
        QTResult1.checked = true;
    }

    if (NumTesting == 0) {
        $ID("ScrapRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("ScrapRate_0").previousSibling.innerText = (NumScrap * 100 / NumTesting).toFixed(window.SysConfig.RateBit);
    }
}
function NumBFChange() {
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("QTConform_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var NumScrap = parseFloat($ID("NumScrap_0").value);

    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    if (NumBF > NumTesting - certNum - NumScrap) {
        $ID("NumBF_0").value = (NumTesting - certNum - NumScrap).toFixed(window.SysConfig.NumberBit);
        NumBF = NumTesting - certNum - NumScrap;
    }
    if (NumBF + NumScrap == NumTesting) {
        QTResult0.checked = false;
        QTResult1.checked = true;
    }

    if (NumTesting == 0) {
        $ID("NFRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("NFRate_0").previousSibling.innerText = (NumScrap * 100 / NumTesting).toFixed(window.SysConfig.RateBit);
    }
}
function QTModeChange() {
    var QTMode0 = $ID("QTMode_0check");
    var QTMode = QTMode0.checked ? 0 : 1;
    var NumTesting = parseFloat($ID("NumTesting_0").value);
    var SerialNum = parseFloat($ID("SerialNumber_0").value);
    var certNum = parseFloat($ID("QTConform_0").value);
    var NumBF = parseFloat($ID("NumBF_0").value);
    var NumScrap = parseFloat($ID("NumScrap_0").value);
    var QTResult0 = $ID("QTResult_0check");
    var QTResult1 = $ID("QTResult_1check");
    var QTMode0 = $ID("QTMode_0check");
    var QTMode1 = $ID("QTMode_1check");
    if (QTMode == 0) {
        $ID("NumTesting_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("QTConform_0").value = SerialNum.toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumScrap_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = true;
        QTMode1.checked = false;
        $ID("OTRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
        $ID("certRate_0").previousSibling.innerText = (100).toFixed(window.SysConfig.RateBit);
        $ID("ScrapRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
        $ID("NFRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    } else {
        $ID("NumTesting_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("QTConform_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumBF_0").value = (0).toFixed(window.SysConfig.NumberBit);
        $ID("NumScrap_0").value = (0).toFixed(window.SysConfig.NumberBit);
        QTMode0.checked = false;
        QTMode1.checked = true;
        $ID("OTRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
        $ID("certRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
        $ID("ScrapRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
        $ID("NFRate_0").previousSibling.innerText = (0).toFixed(window.SysConfig.RateBit);
    }
}



