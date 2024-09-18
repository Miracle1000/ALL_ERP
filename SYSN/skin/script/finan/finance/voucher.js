$(function () {
    bindIntroFocus();
});

function bindIntroFocus() {
    $(document).off("focus").on("focus", "input[id*='voucherlvw_intro_']", function () {
        var id = this.id;
        var splited = id.split('_');
        if (splited.length >= 3) {
            var rowIndex = splited[2];
            var cellIndex = splited[3];

            if (rowIndex > 0 && this.value == '') {
                VoucherIntroClick(rowIndex, cellIndex);
                //var lvw = window["lvw_JsonData_voucherlvw"];
                //window.OnListViewInsertNewRow(lvw, rowIndex, '__lvw_je_addNew');
            }
        }
    });
}

//新增一行时，自动计算借方金额或贷方金额
window.OnListViewInsertNewRow=function(lvw,pos,srcform)
{
    var moneyJ = 0;
    var moneyD = 0;
    var cellJindex = -1;
    var cellDindex = -1;
    var currcellindex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "money_J") { cellJindex = i; }
        if (lvw.headers[i].dbname == "money_D") { cellDindex = i; }
    }
    for (var j = 0; j < lvw.rows.length; j++) {
        if (j != pos) {
            if (lvw.rows[j][cellJindex]) { moneyJ += parseFloat(lvw.rows[j][cellJindex]); }
            if (lvw.rows[j][cellDindex]) { moneyD += parseFloat(lvw.rows[j][cellDindex]); }
        }
    }    
    phval = moneyD - moneyJ;
    if (phval > 0) {
        currcellindex = cellJindex;
    } else {
        phval = moneyJ - moneyD;
        currcellindex = cellDindex;
    }
    if (!isNaN(phval)) {
        //window.event.srcElement.value = phval;
        __lvw_je_updateCellValue(lvw.id, pos, currcellindex, phval);
        __lvw_je_setcelldatav(lvw, pos, currcellindex, phval);
    }
}

//摘要点击触发
function VoucherIntroClick(rowindex, cellindex) {
    //获取到上一行的值
    var lvw = window["lvw_JsonData_voucherlvw"];
    var lastval = lvw.rows[rowindex - 1][cellindex];
    __lvw_je_setcelldatav(lvw, rowindex, cellindex, lastval);
    $ID("@voucherlvw_intro_" + rowindex + "_" + cellindex + "_0").value = lastval;
}

var clock = null;
//添加页面点击科目图标
function ShowSubBalance(obj, type, ord) {
    if (type == 0) {
        clock = setInterval(function () {
            $("#SubBalanceDialog").hide()
        }, 1000);
        return;
    }
    clearInterval(clock);
    app.ajax.regEvent("GetSubBalanceDialogData");
    app.ajax.addParam("ord", ord);
    var result = app.ajax.send();

    var e = window.event;
    app.showServerPopo(e, "SubBalanceDialog", eval("(" + result + ")"), 0, 223);

    $("#SubBalanceDialog").unbind().bind("mouseover",
        function () {
            clearInterval(clock);
            $("#SubBalanceDialog").show();
        });

    $("#SubBalanceDialog").bind("mouseout",
        function () {
            clock = setInterval(function () {
                $("#SubBalanceDialog").hide()
            }, 1000);
        });
}

//打开添加辅助核算项页面
function VoucherAssistDialog(subid, ridx, hfzhs, ismust, hfzhssub,isnumscheck,fzhscount,prounit,pronum,proprice,moneyj,moneyd,voucherdate,ispre,voucher) {
    var vheight = 110 + (isnumscheck ? 140 : 0) + fzhscount*40;
    var win = app.createWindow("Assists", "辅助核算", { closeButton: true, height: vheight, width: 424, bgShadow: 30, canMove: 0 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/Voucher/AssistAdd.ashx?ridx=" + ridx +
        "&subid=" + subid + "&hfzhs=" + hfzhs + "&ismust=" + ismust + "&hfzhssub=" + hfzhssub +
        "&prounit=" + prounit + "&pronum=" + pronum + "&proprice=" + proprice + "&moneyj=" + moneyj + "&moneyd=" + moneyd +
        "&voucherdate=" + voucherdate + "&ispre=" + ispre + "&voucher=" + voucher + "' width=\"400\" height=\"" + vheight + "\"> ";
    win.style.overflow = "hidden";
}

//添加辅助核算项页面回调赋值
function VoucherAsistSetVal(rowindex, ids, subids, prounit, pronum, proprice, moneyj, moneyd, ispre, indexs, isdefs) {
    var idarr = ids.split(",");
    var subarr = subids.split(",");
    var indexarr = indexs.split(",");
    var isdefsarr = isdefs.split(",");
    var sel = 0;
    var inx = -1;
    var fztxt = "";
    for (var i = 0; i < subarr.length; i++) {
        var asisVal = "";
        if (subarr[i] == "") continue;
        if (isdefsarr[i] == "0") {
            fztxt += $("#fz" + indexarr[i] + "_0").find("option[value=" + idarr[i] + "]").text().trim() + ",";
        }
        else {
            fztxt += $("#fz" + indexarr[i] + "_tit").val() + ",";
        }
    }
    fztxt = fztxt.replace(/^,+/, "").replace(/,+$/, "");
    var lvw = parent.window["lvw_JsonData_voucherlvw"];
    var fzhsidx = -1;
    var hfzhsidx = -1;
    var hfzhssubidx = -1;
    var prounitidx = -1;
    var prounittxtidx = -1;
    var openunit = -1;
    var pronumidx = -1;
    var propriceidx = -1;
    var moneyjidx = -1;
    var moneydidx = -1;
    var money1 = -1;
    var fxidx = -1;
    var openbz = 0;

    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "fx") { fxidx = i; }
        if (lvw.headers[i].dbname == "fzhs") { fzhsidx = i; }
        if (lvw.headers[i].dbname == "hfzhs") { hfzhsidx = i; }
        if (lvw.headers[i].dbname == "hfzhssub") { hfzhssubidx = i; }
        if (lvw.headers[i].dbname == "unitint") { prounitidx = i; }
        if (lvw.headers[i].dbname == "openunit") { openunit = i; }
        if (lvw.headers[i].dbname == "unit") { prounittxtidx = i; }
        if (lvw.headers[i].dbname == "nums") { pronumidx = i; }
        if (lvw.headers[i].dbname == "price") { propriceidx = i; }
        if (lvw.headers[i].dbname == "money_J" && moneyj > 0) { moneyjidx = i; }
        if (lvw.headers[i].dbname == "money_D" && moneyd > 0) { moneydidx = i; }
        if (lvw.headers[i].dbname == "money1") { money1 = i; }
        if (lvw.headers[i].dbname == "openbz") { lvw.rows[rowindex][i]; }
    }

    parent.__lvw_je_updateCellValue(lvw.id, rowindex, fxidx, moneydidx > 0 ? "2" : "1");
    parent.__lvw_je_updateCellValue(lvw.id, rowindex, fzhsidx, fztxt);
    parent.__lvw_je_setcelldatav(lvw, rowindex, hfzhsidx, ids);
    parent.__lvw_je_setcelldatav(lvw, rowindex, hfzhssubidx, subids);
    if (ispre == 0) {
        if (prounitidx > 0) {
            parent.__lvw_je_updateCellValue(lvw.id, rowindex, prounitidx, prounit);
            parent.__lvw_je_updateCellValue(lvw.id, rowindex, openunit, 1);
            var unittxt = "";
            if (prounit&&$("#prounit_0").length > 0) {
                unittxt = $("#prounit_0").find("option[value=" + prounit + "]").text().trim();
            }
            parent.__lvw_je_updateCellValue(lvw.id, rowindex, prounittxtidx, unittxt);
        }
        if (openbz > 0) {
            parent.__lvw_je_updateCellValue(lvw.id, rowindex, money1, moneyj+moneyd);
        }
        else {
            if (moneyjidx > 0)
                parent.__lvw_je_updateCellValue(lvw.id, rowindex, moneyjidx, moneyj);
            if (moneydidx > 0)
                parent.__lvw_je_updateCellValue(lvw.id, rowindex, moneydidx, moneyd);
        }
        if (pronumidx > 0)
            parent.__lvw_je_updateCellValue(lvw.id, rowindex, pronumidx, pronum);
        if (propriceidx > 0)
            parent.__lvw_je_updateCellValue(lvw.id, rowindex, propriceidx, proprice);
    }
    parent.app.closeWindow('Assists');
}


function ClearWindowField(rowindex) {
    var lvw = parent.window["lvw_JsonData_voucherlvw"];
    var fzhsidx = -1;
    var hfzhsidx = -1;
    var hfzhssubidx = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "fzhs") { fzhsidx = i; }
        if (lvw.headers[i].dbname == "hfzhs") { hfzhsidx = i; }
        if (lvw.headers[i].dbname == "hfzhssub") { hfzhssubidx = i; }
    }
    parent.__lvw_je_updateCellValue(lvw.id, rowindex, fzhsidx, "");
    parent.__lvw_je_setcelldatav(lvw, rowindex, hfzhsidx, "");
    parent.__lvw_je_setcelldatav(lvw, rowindex, hfzhssubidx, "");
}

//选择科目后根据借贷方向给文本框获取焦点
function GetFocusByDBName(rowindex, dbname) {
    var lvw = window["lvw_JsonData_voucherlvw"];
    var cellindex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == dbname) { cellindex = i; }
    }
    app.stopDomEvent();
    setTimeout(function () {
        var targetInput = $ID('@voucherlvw_' + dbname + '_' + rowindex + '_' + cellindex + '_0');
        var parentType = $(targetInput).parent().attr("class").indexOf("f_fmoneybox editable")
        if (parentType == -1) {
            parentType = $(targetInput).parent().attr("class").indexOf("f_numberbox editable")
        }
        if (parentType >= 0) { //空格键支持金额分栏字段
            app.FireEvent(targetInput, "onmouseup")
        } else {
            //targetInput.select();
            openSel($(targetInput));
        }
    }, 50)
}

//焦点在借贷方金额时按下空格抬起时
function MoneyKeyUpCallBack() {
    var keyCode = window.event.keyCode;
    var yxKey = (keyCode >= 48 && keyCode <= 57) || (keyCode >= 96 && keyCode <= 105) || keyCode == 110 || keyCode == 190 || keyCode == 32 || keyCode == 187 || window.event.code == "Equal" || window.event.code == "Space";
    if (yxKey == false) return;
    var e = window.event.target || window.event.srcElement;
    var lvw = window["lvw_JsonData_voucherlvw"];
    var cellindex = -1;
    var fx = -1;
    var currrowindex = e.id.split('_')[3] * 1;
    var currcellindex = e.id.split('_')[4] * 1;
    var value = lvw.rows[currrowindex][currcellindex];
    var isSpace = window.event.code == "Space" || keyCode == 32;
    var isEqual = window.event.code == "Equal" || keyCode == 187;
    //$(e).attr("fmoneyneg")
    if (isEqual) {
        var txtboxid = window.event.srcElement.id;
        var phval = 0;
        var moneyJ = 0;
        var moneyD = 0;
        var cellJindex = -1;
        var cellDindex = -1;
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "money_J") { cellJindex = i; }
            if (lvw.headers[i].dbname == "money_D") { cellDindex = i; }
        }
        for (var j = 0; j < lvw.rows.length; j++) {
            if (j != currrowindex) {
                if (lvw.rows[j][cellJindex]) { moneyJ += parseFloat(lvw.rows[j][cellJindex]); }
                if (lvw.rows[j][cellDindex]) { moneyD += parseFloat(lvw.rows[j][cellDindex]); }
            }
        }
        if (e.id.indexOf('money_J') > -1) {
            phval = moneyD - moneyJ;
        }
        else {
            phval = moneyJ - moneyD;
        }
        if (!isNaN(phval)) {
            window.event.srcElement.value = phval;
            __lvw_je_updateCellValue(lvw.id, currrowindex, currcellindex, phval);
            __lvw_je_setcelldatav(lvw, currrowindex, currcellindex, phval);
        }
        if (txtboxid) {
            setTimeout(function () { $ID(txtboxid).focus(); }, 100);
        }
    }
    if (e.id.indexOf('money_J') > -1) {
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "money_D") { cellindex = i; }
            if (lvw.headers[i].dbname == "fx") { fx = i; }
        }
        var ptcellindex = isSpace ? cellindex : currcellindex;//通过事件源获取应该规避的列号(该列号需要保持获取焦点的状态)
        __lvw_je_updateCellValue(lvw.id, currrowindex, cellindex, isSpace ? value : "", true, ptcellindex,true);//最后一个参数是指该列不重绘
        __lvw_je_setcelldatav(lvw, currrowindex, fx, isSpace ? "2" : "1");
        __lvw_je_redrawCell(lvw, lvw.headers[fx], currrowindex, fx);
        if (isSpace) {
            __lvw_je_updateCellValue(lvw.id, currrowindex, currcellindex, "");
            GetFocusByDBName(currrowindex, 'money_D');//获取焦点
        }
    }
    else {
        for (var i = 0; i < lvw.headers.length; i++) {
            if (lvw.headers[i].dbname == "money_J") { cellindex = i; }
            if (lvw.headers[i].dbname == "fx") { fx = i; }
        }
        var ptcellindex = isSpace ? cellindex : currcellindex;//通过事件源获取应该规避的列号(该列号需要保持获取焦点的状态)
        __lvw_je_updateCellValue(lvw.id, currrowindex, cellindex, isSpace ? value : "", true, ptcellindex,true);//最后一个参数是指该列不重绘
        __lvw_je_setcelldatav(lvw, currrowindex, fx, isSpace ? "1" : "2");
        __lvw_je_redrawCell(lvw, lvw.headers[fx], currrowindex, fx);
        if (isSpace) {
            __lvw_je_updateCellValue(lvw.id, currrowindex, currcellindex, "");
            GetFocusByDBName(currrowindex, 'money_J');//获取焦点

        }
    }
    $("#lvw_dbtable_voucherlvw").find("input.billfieldbox[uitype='fmoneybox']").unbind("blur input propertychange", app.InputVerifyAtOnce).bind("blur input propertychange", app.InputVerifyAtOnce);
}

function doOrgsSel(id, nodetxt) {
    Report.FieldAutoCompleteCallBack(id, window.event.srcElement.innerHTML, { "nodetxt": nodetxt });
}

function GetSelHtml(NodeText, NodeId, NodeTxt, BaseID) {
    if (BaseID == '1') {
        return ("<a href='javascript:void(0)' onclick='doOrgsSel(" + NodeId + ",\"" + NodeTxt + "\")'>" + NodeText + "<a>");
    } else {
        return ("<span style='color:#aaa'>" + NodeText + "</span>");
    }
}

//模拟鼠标点击下拉框
function openSel(elem) {
    var e = document.createEvent("MouseEvents");
    if (document.createEvent) {
        e.initMouseEvent("mousedown");
        elem[0].dispatchEvent(e);
    } else if (element.fireEvent) {
        elem[0].fireEvent("onmousedown");
    }
}

function QuoteTempLate(ord) {
    $("#quote_0").val(ord);
    $("#quote_0").change();
}

window.existsBZCol = false;
window.IsExistsBZCol = function () {
    return ListView.GetHeaderByDBName(lvw_JsonData_voucherlvw, "bz").display != "hidden";
}
function showBzColumns() {
    if (window.IsExistsBZCol()) { return; }

    //未显示的则进行呈现
    var jlvw = window["lvw_JsonData_voucherlvw"];
    var bz = ListView.GetHeaderByDBName(jlvw, "bz");
    var money1 = ListView.GetHeaderByDBName(jlvw, "money1");
    var hl = ListView.GetHeaderByDBName(jlvw, "hl");
    var fzhs = ListView.GetHeaderByDBName(jlvw, "fzhs");
    bz.display = "editable";
    hl.display = "editable";
    money1.display = "editable";

    var columnsIndex = 5;
    if (fzhs.display == "editable")
        columnsIndex++;
    if (ListView.GetHeaderByDBName(jlvw, "unit").display == "editable")
        columnsIndex++;
    if (ListView.GetHeaderByDBName(jlvw, "nums").display == "editable")
        columnsIndex++;
    if (ListView.GetHeaderByDBName(jlvw, "price").display == "editable")
        columnsIndex++;

    lvw_JsonData_voucherlvw.showmaps.splice(columnsIndex, 0, bz.index);
    lvw_JsonData_voucherlvw.vheaders[0].splice(columnsIndex, 0, { text: bz.title, colindex: bz.index, vindex: ++columnsIndex });
    lvw_JsonData_voucherlvw.showmaps.splice(columnsIndex, 0, hl.index);
    lvw_JsonData_voucherlvw.vheaders[0].splice(columnsIndex, 0, { text: hl.title, colindex: hl.index, vindex: ++columnsIndex });
    lvw_JsonData_voucherlvw.showmaps.splice(columnsIndex, 0, money1.index);
    lvw_JsonData_voucherlvw.vheaders[0].splice(columnsIndex, 0, { text: money1.title, colindex: money1.index, vindex: ++columnsIndex });

    for (var i = 0; i < lvw_JsonData_voucherlvw.vheaders[0].length; i++) {
        lvw_JsonData_voucherlvw.vheaders[0][i].vindex = i + 1;
    }
    for (var i = 0 ; i < lvw_JsonData_voucherlvw.headers.length; i++) {
        for (var ii = 0; ii < lvw_JsonData_voucherlvw.showmaps.length; ii++) {
            if (i == lvw_JsonData_voucherlvw.showmaps[ii]) {
                lvw_JsonData_voucherlvw.headers[i].showindex = ii;
            }
        }
    }

    var gp = Bill.Data.groups[0];
    var jlvwobj = ListView.Create(jlvw.id, jlvw, gp.fields[gp.fields.length - 1], gp);
    var jlvwhtml = jlvwobj.GetHtml();
    $ID("voucherlvw_fbg").innerHTML = jlvwhtml;
    //隐藏显示列会导致listview刷新,同时已绑定在dom上的事件也会丢失,所以需要重新绑定一下事件
    bindIntroFocus();
}

window.existsAssistCol = false;
//当前列表辅助核算列是否为显示状态
window.IsExistsAssistCol = function () {
    return ListView.GetHeaderByDBName(lvw_JsonData_voucherlvw, "fzhs").display != "hidden";
}

//当前列表某列是否为显示状态
window.IsExistsAssistCol = function (DbName) {
    return ListView.GetHeaderByDBName(lvw_JsonData_voucherlvw, DbName).display != "hidden";
}

//是否存在开启辅助核算的行
window.IsExistsAssistRow = function () {
    var inx = lvw_JsonData_voucherlvw.headers.indexOf(ListView.GetHeaderByDBName(lvw_JsonData_voucherlvw, "openfzhs"));
    for (var i = 0; i < lvw_JsonData_voucherlvw.rows.length; i++) {
        if (lvw_JsonData_voucherlvw.rows[i][inx] == "1")
            return true;
    }
    return false;
}

//是否存在开启某行
window.IsExistsAssistRow = function (DbName) {
    var openDbName = "";
    if (DbName == "fzhs") openDbName = "openfzhs";
    if (DbName == "unit") openDbName = "openunit";
    if (DbName == "nums"||DbName == "price") openDbName = "opennum";
        var inx = lvw_JsonData_voucherlvw.headers.indexOf(ListView.GetHeaderByDBName(lvw_JsonData_voucherlvw, openDbName));
    for (var i = 0; i < lvw_JsonData_voucherlvw.rows.length; i++) {
        if (lvw_JsonData_voucherlvw.rows[i][inx] == "1")
            return true;
    }
    return false;
}

//isShow:1=显示;0=隐藏
function showAssistColumns(isShow) {
    if (window.IsExistsAssistCol("fzhs") && isShow == 1) { return; }
    if (window.IsExistsAssistRow("fzhs") && isShow == 0) { return; }
    //未显示的则进行呈现
    var jlvw = window["lvw_JsonData_voucherlvw"];
    var fzhs = ListView.GetHeaderByDBName(jlvw, "fzhs");
    if (isShow == 1) {
        fzhs.display = "editable";
        lvw_JsonData_voucherlvw.showmaps.splice(5, 0, fzhs.index);
        lvw_JsonData_voucherlvw.vheaders[0].splice(5, 0, { text: fzhs.title, colindex: fzhs.index, vindex: 6 });
    } else if (fzhs.display != "hidden") {
        fzhs.display = "hidden";
        lvw_JsonData_voucherlvw.showmaps.splice(5, 1);
        lvw_JsonData_voucherlvw.vheaders[0].splice(5, 1);
    } else
        return;

    for (var i = 0; i < lvw_JsonData_voucherlvw.vheaders[0].length; i++) {
        lvw_JsonData_voucherlvw.vheaders[0][i].vindex = i + 1;
    }
    for (var i = 0 ; i < lvw_JsonData_voucherlvw.headers.length; i++) {
        for (var ii = 0; ii < lvw_JsonData_voucherlvw.showmaps.length; ii++) {
            if (i == lvw_JsonData_voucherlvw.showmaps[ii]) {
                lvw_JsonData_voucherlvw.headers[i].showindex = ii;
            }
        }
    }
    if (jlvw.currJEScrollXHideCol) { jlvw.currJEScrollXHideCol = 0; }//滚动条引起的隐藏列数清除；
    var gp = Bill.Data.groups[0];
    var jlvwobj = ListView.Create(jlvw.id, jlvw, gp.fields[gp.fields.length - 1], gp);
    var jlvwhtml = jlvwobj.GetHtml();
    $ID("voucherlvw_fbg").innerHTML = jlvwhtml;
    //隐藏显示列会导致listview刷新,同时已绑定在dom上的事件也会丢失,所以需要重新绑定一下事件
    bindIntroFocus();
}


//isShow:1=显示;0=隐藏
function showAssistColumns2(isShow,DbName) {
    if (window.IsExistsAssistCol(DbName) && isShow == 1) { return; }
    if (window.IsExistsAssistRow(DbName) && isShow == 0) { return; }

    //未显示的则进行呈现
    var jlvw = window["lvw_JsonData_voucherlvw"];
    var fzhs = ListView.GetHeaderByDBName(jlvw, "fzhs");
    var prounit = ListView.GetHeaderByDBName(jlvw, "unit");
    var pronum = ListView.GetHeaderByDBName(jlvw, "nums");
    var showIndex = 5;
    if (fzhs.display == "editable")
        showIndex++;
    if (DbName == "nums") {
        if (prounit.display == "editable")
            showIndex++;
    }
    else if (DbName == "price") {
        if (prounit.display == "editable")
            showIndex++;
        if (pronum.display == "editable")
            showIndex++;
    }

    var fzhs = ListView.GetHeaderByDBName(jlvw, DbName);
    if (isShow == 1) {
        fzhs.display = "editable";
        lvw_JsonData_voucherlvw.showmaps.splice(showIndex, 0, fzhs.index);
        lvw_JsonData_voucherlvw.vheaders[0].splice(showIndex, 0, { text: fzhs.title, colindex: fzhs.index, vindex: showIndex+1 });
    } else if (fzhs.display != "hidden") {
        fzhs.display = "hidden";
        lvw_JsonData_voucherlvw.showmaps.splice(showIndex, 1);
        lvw_JsonData_voucherlvw.vheaders[0].splice(showIndex, 1);
    } else
        return;

    for (var i = 0; i < lvw_JsonData_voucherlvw.vheaders[0].length; i++) {
        lvw_JsonData_voucherlvw.vheaders[0][i].vindex = i + 1;
    }
    for (var i = 0 ; i < lvw_JsonData_voucherlvw.headers.length; i++) {
        for (var ii = 0; ii < lvw_JsonData_voucherlvw.showmaps.length; ii++) {
            if (i == lvw_JsonData_voucherlvw.showmaps[ii]) {
                lvw_JsonData_voucherlvw.headers[i].showindex = ii;
            }
        }
    }
    if (jlvw.currJEScrollXHideCol) { jlvw.currJEScrollXHideCol = 0; }//滚动条引起的隐藏列数清除；
    var gp = Bill.Data.groups[0];
    var jlvwobj = ListView.Create(jlvw.id, jlvw, gp.fields[gp.fields.length - 1], gp);
    var jlvwhtml = jlvwobj.GetHtml();
    $ID("voucherlvw_fbg").innerHTML = jlvwhtml;
    //隐藏显示列会导致listview刷新,同时已绑定在dom上的事件也会丢失,所以需要重新绑定一下事件
    bindIntroFocus();
}


window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (lvw.id != "voucherlvw") { return; }
    if (window.___Refreshinglvw == true) return;
    if (window.IsListviewAddRows == true) return;
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    var fx=lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw,"fx"))]
    var bd = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "bd"))]
    var pronum = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "nums"))]
    var proprice = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "price"))]
    var hl = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "hl"))]
    var money1 = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "money1"))]
    var openbz = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "openbz"))]
    var moneyJ = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "money_J"))]
    var moneyD = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, "money_D"))]
    var direction = 1;
    if (fx == 2 || (bd == 2 && fx != 1)) {
        direction = 2;
    }
    var moneyDbName = direction == 1 ? "money_J" : "money_D";
    var moneyNull = direction == 1 ? "money_D" : "money_J";
    var moneyB = lvw.rows[rowindex][lvw.headers.indexOf(ListView.GetHeaderByDBName(lvw, moneyDbName))]
    //1.汇率为空时按1计算，同时更新成1；
    //2.
    var updateDbName = "";
    switch (dbname) {
        case "nums":    //数量
            //有单价时算原币金额或本币金额
            if (proprice) {
                updateDbName = moneyDbName;
                if (openbz > 0) {
                    updateDbName += ",money1";
                    //开启外币时，数量*单价=原币金额
                    ListView.EvalCellFormula(lvw, rowindex, "money1", "app.FormatNumber(nums * price,'fmoneybox',true)", "", true);
                    if (hl) {
                        ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(nums * price*hl,'fmoneybox',true)", "", true);
                    }
                    else
                        ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(nums * price,'fmoneybox',true)", "", true);
                }
                else
                    ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(nums * price,'fmoneybox',true)", "", true);
            }           
            window.ListView.RefreshCellUI(lvw, rowindex, updateDbName, 100);
            break;
        case "price":    //单价
            //借贷方金额
            if (pronum)
                if (openbz > 0) {
                    //开启外币时，数量*单价=原币金额
                    ListView.EvalCellFormula(lvw, rowindex, "money1", "app.FormatNumber(nums * price,'fmoneybox',true)","",true);
                    if (hl) {
                        ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(nums * price*hl,'fmoneybox',true)", "", true);
                    }
                    else
                        ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(nums * price,'fmoneybox',true)", "", true);
                }
                else
                    ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(nums * price,'fmoneybox',true)", "", true);

            window.ListView.RefreshCellUI(lvw, rowindex, moneyDbName + ",money1", 100);
            break;
        case "hl":    //汇率
            //借贷方金额
            if (money1)
                if(hl)
                    ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(money1 * hl,'fmoneybox',true)", "", true);
                else
                    ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(money1,'fmoneybox',true)", "", true);
            window.ListView.RefreshCellUI(lvw, rowindex, moneyDbName, 100);
            break;
        case "money1":    //原币金额
            //借贷方金额
            if (hl)
                ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(money1 * hl,'fmoneybox',true)", "", true);
            else
                ListView.EvalCellFormula(lvw, rowindex, moneyDbName, "app.FormatNumber(money1,'fmoneybox',true)", "", true);
            ListView.EvalCellFormula(lvw, rowindex, moneyNull, "''", true);
            //单价
            if (pronum)
                ListView.EvalCellFormula(lvw, rowindex, "price", "app.FormatNumber(money1 / nums,'financeprice',true)", "", true);
            window.ListView.RefreshCellUI(lvw, rowindex, moneyDbName + ","+moneyNull+",price", 100);
            break;
        case "money_J":    //借贷方金额
            //单价
            if (moneyJ) {
                if (pronum)
                    if (openbz == 0)
                        ListView.EvalCellFormula(lvw, rowindex, "price", "app.FormatNumber(money_J / nums,'financeprice',true)", "", true);
                //汇率
                //if (money1)
                //    ListView.EvalCellFormula(lvw, rowindex, "hl", "app.FormatNumber((money_J+money_D) / money1,'hlratebox')");
                ListView.EvalCellFormula(lvw, rowindex, "money_D", "''", true);
                window.ListView.RefreshCellUI(lvw, rowindex, "money_D,price", 100);
            }
            break;
        case "money_D":    //借贷方金额
            //单价
            if (moneyD) {
                if (pronum)
                    if (openbz == 0)
                        ListView.EvalCellFormula(lvw, rowindex, "price", "app.FormatNumber(money_D / nums,'financeprice',true)", "", true);
                //汇率
                //if (money1)
                //    ListView.EvalCellFormula(lvw, rowindex, "hl", "app.FormatNumber((money_J+money_D) / money1,'hlratebox')");
                ListView.EvalCellFormula(lvw, rowindex, "money_J", "''", true);
                window.ListView.RefreshCellUI(lvw, rowindex, "money_J,price", 100);
            }
            break;
    }
    ListView.ApplyCellSumsData(lvw, [ListView.GetHeaderByDBName(lvw, moneyDbName).i]);
}
