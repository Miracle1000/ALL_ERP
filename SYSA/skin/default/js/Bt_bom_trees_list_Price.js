//--lockedTrees:数组，被锁定的树的ord数组

var bomTree = {};
//--切换节点版本，获取节点数据，刷新树
bomTree.changeVer = function (obj, rowindex, proord, protype, tType, treeord, mxid, mark) {
    var id = obj.getAttribute("treeid");
    var lvw = eval("window.lvw_JsonData_" + id);
    var cellindex = 7,textindex,rows,row;
    var h = lvw.headers;
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "num1") {
            cellindex = i;
        }
        if (h[i].dbname == "text") { textindex = i; }
    }
    rows = lvw.rows;
    var currDeepLen = rows[rowindex][textindex].deeps.length;
    for (var i = rowindex; i < lvw.rows.length; i++) {
        row = rows[i];
        if (i > rowindex && rows[i][textindex].deeps.length <= currDeepLen) { break; }
        if (row[textindex].expand == 0) {
            lvw_je_Expnode(id, i, 1,true)
        }
    }
    var v = lvw.rows[rowindex][cellindex];

    _lvw_je_RefreshListTreeNode(obj.getAttribute("treeid"), rowindex, true, function () {
        ajax.addParam("proord", proord);
        ajax.addParam("bomord", obj.value);
        ajax.addParam("protype", protype);
        ajax.addParam("currCode", obj.getAttribute("currCode"));
        ajax.addParam("tType", tType);
        ajax.addParam("treeord", treeord);
        ajax.addParam("mxid", mxid);
        ajax.addParam("mark", mark);
    });
    lvw.rows[rowindex][cellindex] = v;
    __lvw_je_redrawCell(lvw, lvw.headers[cellindex], rowindex, cellindex - 1);
    window.onlvwUpdateCellValue(id, rowindex, cellindex, v, 0, true);
}

//--单选框点击事件
bomTree.radioClick = function (obj) {
    var ck = obj.getAttribute("ck");
    var name = obj.getAttribute("name");
    $("input[type='radio'][name='" + name + "']").attr("ck", "0");
    if (ck == "1") {
        obj.checked = false;
        obj.setAttribute("ck", "0");
    }
    else {
        obj.checked = true;
        obj.setAttribute("ck", "1");
    }
    if (!obj.onpropertychange) { bomTree.radioChange(obj); }
    return false;
}
//--更新选中值
var lastradio = {}
bomTree.radioChange = function (obj) {
    var rowindex = obj.getAttribute("rowindex");
    var name = obj.getAttribute("name");
    var type = obj.getAttribute("type");
    var id = obj.getAttribute("treeid");
    var lvw = eval("window.lvw_JsonData_" + id);
    var rows = lvw.rows;
    var h = lvw.headers;
    var sindex = -1;
    var SLIndex = -1;
    var tIndex = -1;
    var sstypeIndex = -1;
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "SL") SLIndex = i
        if (h[i].dbname == "selected") sindex = i;
        if (h[i].dbname == "text") tIndex = i;/*树结构产品名称列下标*/
        if (h[i].dbname == "stype") sstypeIndex = i;/*树结构UI列下标*/
    }
    if (type == "radio") {
        if (!lastradio.isinit) { bomTree.radioObjInit(lvw) }
        var lasto = lastradio[name];
        if (lasto) {
            rows[lasto.r][lasto.c] = 0;
        }
    }
    rows[rowindex][sindex] = (obj.checked) ? 1 : 0;
    lastradio[name] = { r: rowindex, c: sindex }
    window.onlvwUpdateCellValue(id, rowindex, SLIndex, rows[rowindex][SLIndex], 0, true);
}
bomTree.radioObjInit = function (lvw) {
    var rows = lvw.rows;
    if (!rows || !rows.length) { return; }
    var treecode2, mxid, name, stype, selected, row, h, hs = lvw.headers, c = 0;
    for (var i = 0; i < hs.length; i++) {
        h = hs[i];
        if (h.dbname == "treecode2") { treecode2 = i; c++ }
        if (h.dbname == "mxid") { mxid = i; c++ }
        if (h.dbname == "stype") { stype = i; c++ }
        if (h.dbname == "selected") { selected=i; c++ }
        if (c >= 4) { break }
    }
    for (var i = 0; i < rows.length; i++) {
        row = rows[i];
        if (row[stype] == 1 && row[selected]==1) {
            name = "radio_" + row[treecode2] + "_" + row[mxid];
            lastradio[name] = { r: i, c: selected};
        }
    }
    lastradio.isinit = true;
}
//--复选框点击事件
bomTree.checkboxClick = function (obj) {
    if (!obj.onpropertychange) { bomTree.radioChange(obj); }
}

//function _lvw_je_RefreshListTreeNode(id, rowindex, isRefreshCurrNode, fun) {
//ajax.regEvent("sys_lvw_callback");
//ajax.addParam("cmd","refreshTreeNode");
//ajax.addParam("backdata",$ID("__viewstate_lvw_" + id).value);
//ajax.addParam("lvwid",id);
//if(fun) {fun();}
//var data = ajax.send();
//confirm(data)
//}

function updateHtmlField(dom, id, v) {
    var parent = $(dom).parents("div.lvw_treecell").eq(0);
    var rowindex = parent.attr("rowindex");
    var cellindex = parent.attr("cellindex");
    var text = dom.outerHTML;
    text = text ? text.split("valpossign") : "";
    if (!text || text.length < 3) { return }
    var arr = [text[0], " value=" + v + " ", text[2]];
    var value = arr.join("valpossign");
    if (dom.tagName == "TEXTAREA") { dom.innerHTML = v; value = dom.outerHTML; }
    __lvw_je_updateCellValue(id, rowindex, cellindex, value)
}

function setParentsPrice(lvw, rowindex, sindex, obj) {
    var i, iBL, iSL, iDJ, iZJ, iBZDJ, itreeCode, istype, iselected, itreeCode2, addSubNodes;
    var BL, SL, DJ, ZJ, BZDJ, treeCode, treeCode1, treeCode2;
    iBL = 0; iSL = 0; iDJ = 0; iZJ = 0; iBZDJ = 0; itreeCode = 0; istype = 0; iselected = 0; itreeCode2 = 0; addSubNodes = 1;
    BL = 0; SL = 0; DJ = 0; ZJ = 0; BZDJ = 0; treeCode = ""; treeCode2 = "";
    for (i = 0; i < lvw.headers.length ; i++) {
        switch (lvw.headers[i].dbname) {
            case "num1":
                iBL = i; break;
            case "SL":
                iSL = i; break;
            case "DJ":
                iDJ = i; break;
            case "BZDJ":
                iBZDJ = i; break;
            case "ZJ":
                iZJ = i; break;
            case "treecode":
                itreeCode = i; break;
            case "treecode2":
                itreeCode2 = i; break;
            case "stype":
                istype = i; break;
            case "selected":
                iselected = i; break;
        }
    }
    if (iDJ == 0 && iBZDJ == 0) {
        return;
    }
    treeCode2 = lvw.rows[rowindex][itreeCode2];
    if (typeof (obj) == 'undefined') {
        treeCode = lvw.rows[rowindex][itreeCode];
        if (treeCode2 != "") { treeCode = treeCode2; }
    } else {
        if (obj.name != "") {
            treeCode = obj.name.replace("radio_", "").replace("checkbox_", "");
        } else {
            treeCode = obj.getAttribute("currcode");
        }
    }
    updaPriceXSByTreeCode(lvw, treeCode, itreeCode, itreeCode2, iBL, iSL, iDJ, iZJ, iBZDJ, iselected, istype, addSubNodes);

}

function updaPriceXSByTreeCode(lvw, treeCode, itreeCode, itreeCode2, iBL, iSL, iDJ, iZJ, iBZDJ, iselected, istype, addSubNodes) {
    var i, pid_rowIndex, sumPriceXS, selected, SL, DJ, BZDJ, sumBZDJ, BL, isShowPriceXS, isShowMoneyXS, isShowBZDJ;
    var theTreeCode, arr_theTreeCode, arr_treeCode;
    pid_rowIndex = 0; sumPriceXS = 0; sumBZDJ = 0; DJ = 0; SL = 0; BL = 0; rowindex1 = 0; theTreeCode = "";
    isShowPriceXS = jQuery("#isShowPriceXS").val();
    isShowMoneyXS = jQuery("#isShowMoneyXS").val();
    isShowBZDJ = jQuery("#isShowBZDJ").val();
    arr_treeCode = treeCode.split("_");
    for (i = 0; i < lvw.rows.length ; i++) {
        theTreeCode = lvw.rows[i][itreeCode];
        arr_theTreeCode = theTreeCode.split("_");
        if (lvw.rows[i][itreeCode].indexOf(treeCode) > -1 && arr_theTreeCode.length <= arr_treeCode.length + 1) {
            if (lvw.rows[i][itreeCode] == treeCode) {
                pid_rowIndex = i;
            } else {
                if (iBL > 0) { BL = Number(lvw.rows[i][iBL].toString().replace(/,/g, "")); } else { BL = 0; }
                if (iDJ > 0) { DJ = Number(lvw.rows[i][iDJ].toString().replace(/,/g, "")); } else { DJ = 0; }
                if (iBZDJ > 0) { BZDJ = Number(lvw.rows[i][iBZDJ].toString().replace(/,/g, "")); } else { BZDJ = 0; }
                selected = lvw.rows[i][iselected] + "";
                //console.log("[i="+i+"][istype="+lvw.rows[i][istype]+"][addSubNodes="+addSubNodes+"][selected="+selected+"][itreeCode2="+lvw.rows[i][itreeCode2]+"][treeCode="+treeCode+"]")
                switch (lvw.rows[i][istype] + "") {
                    case "":
                    case "0":
                        if (addSubNodes == 1) {
                            sumPriceXS += DJ * BL;
                            sumBZDJ += BZDJ * BL;
                        } else {
                            if (lvw.rows[i][itreeCode2] == treeCode) {
                                sumPriceXS += DJ * BL;
                                sumBZDJ += BZDJ * BL;
                            }
                        }
                        break;
                    case "1":
                    case "2":
                        if ((lvw.rows[i][itreeCode2] == treeCode || addSubNodes == 1) && selected == "1") {
                            sumPriceXS += DJ * BL;
                            sumBZDJ += BZDJ * BL;
                        }
                        break;
                }
            }
        }
    }
    //console.log("[sumPriceXS="+sumPriceXS+"]");
    if (iSL > 0) { SL = Number(lvw.rows[pid_rowIndex][iSL].toString().replace(/,/g, "")); } else { SL = 0; }
    if (iDJ > 0) { lvw.rows[pid_rowIndex][iDJ] = FormatNumber(sumPriceXS, window.sysConfig.moneynumber); }
    if (iZJ > 0) { lvw.rows[pid_rowIndex][iZJ] = FormatNumber(SL * sumPriceXS, window.sysConfig.moneynumber); }
    if (iBZDJ > 0) { lvw.rows[pid_rowIndex][iBZDJ] = FormatNumber(sumBZDJ, window.sysConfig.moneynumber); }
    if (isShowPriceXS == "1") {
        if (iDJ > 0) { __lvw_je_redrawCell(lvw, lvw.headers[iDJ], pid_rowIndex, iDJ - 1); }
    }
    if (isShowMoneyXS == "1") {
        if (iZJ > 0) { __lvw_je_redrawCell(lvw, lvw.headers[iZJ], pid_rowIndex, iZJ - 1); }
    }
    if (isShowBZDJ == "1") {
        if (iBZDJ > 0) { __lvw_je_redrawCell(lvw, lvw.headers[iBZDJ], pid_rowIndex, iBZDJ - 1); }
    }
    var arr_treeCode, newCode;
    newCode = "";
    //console.log("[treeCode="+treeCode+"]");
    if (treeCode.indexOf("_") > -1) {
        arr_treeCode = treeCode.split("_");
        for (i = 0; i < arr_treeCode.length - 1; i++) {
            newCode += (newCode == "" ? "" : "_") + arr_treeCode[i];
        }
        if (newCode != "") {
            updaPriceXSByTreeCode(lvw, newCode, itreeCode, itreeCode2, iBL, iSL, iDJ, iZJ, iBZDJ, iselected, istype, 0);
        }
    }
}

function handleVer(proord, protype, treecode, rowindex, treeid, tType, bomord, treeord, mxpxid,mark) {
    var p = "opts_" + proord + "_" + protype + "_" + treeord + "_" + mxpxid;
    var s = "";
    if (bomOpts[p]) {
        var lvw = eval("window.lvw_JsonData_" + treeid);
        var h = lvw.headers;
        var unitIndex = -1;
        var mxidIndex = -1;
        var mxid = "";
        for (var i = 0; i < h.length; i++) {
            if (h[i].dbname == "unit") {
                unitIndex = i;
            } else if (h[i].dbname == "mxid") {
                mxidIndex = i;
            }
        }
        var disabled = "";				//--整棵树被锁定时，将下拉框锁住
        if (lockedTrees && lockedTrees.length > 0) {
            for (var i = 0; i < lockedTrees.length; i++) {
                if (lockedTrees[i] == treeord) {
                    disabled = " disabled='disabled'";
                }
            }
        }
        var rows = lvw.rows;
        var deeps = rows[rowindex][1].deeps;
        var unit = rows[rowindex][unitIndex];
        mxid = rows[rowindex][mxidIndex];
        var s = "<select " + disabled + " currCode='" + treecode + "' treeid='" + treeid + "' onchange='bomTree.changeVer(this," + rowindex + "," + proord + "," + protype + "," + tType + "," + treeord + "," + mxid + ",\"" + mark + "\")'>";
        var n = 0;
        var o = bomOpts[p];
        for (var i = 0; i < o.length; i++) {
            if (o[i].u == unit || (o[i].u == "" && unit == "0"))			//--只能选择对应单位的版本
            {
                var opt = [];
                opt.push("<option ");
                if (bomord == o[i].v) {
                    opt.push(" selected='selected' ");
                }
                opt.push(" value='" + o[i].v + "'>");
                opt.push(o[i].t);
                opt.push("</option>");
                s = s + opt.join(" ");
                n += 1;
            }
        }
        s = s + "</select>";
        if (n <= 1) {
            s = "";
        }
    }
    return s;
}

function handleCaoZuo(ismain, bomord, rowindex, treeord, treecode, treetype, sqlstr,id) {
    if (!window.treetype) {
        window.treetype = treetype;
    }
    if (!window.sqlstr) {
        window.sqlstr = sqlstr;
    }
    var disabled = "";				//--整棵树被锁定时，将链接锁住
    if (lockedTrees && lockedTrees.length > 0) {
        for (var i = 0; i < lockedTrees.length; i++) {
            if (lockedTrees[i] == treeord) {
                disabled = " disabled='disabled'"
            }
        }
    }
    var treeid, mxid, imxid;
    mxid = 0; imxid = 0;
    treeid = $("#treeid").val();
    var lvw = eval("window.lvw_JsonData_" + treeid);
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "mxid") {
            imxid = i;
        }
    }
    var rows = lvw.rows;
    mxid = rows[rowindex][imxid];

    if (ismain == "1") {
        if (disabled.length > 0) {
            return "<a " + disabled + " href='javascript:void(0)' title='添加子件'>添加</a>";
        }
        else {
            return "<a onclick='openSubWindow(\"" + bomord + "\",\"" + rowindex + "\",\"" + treeord + "\",\"" + treecode + "\"," + mxid + ",\"" + id + "\""+")' href='javascript:void(0)' title='添加子件'>添加</a>";
        }
    }
    else {
        return "";
    }
}

function openSubWindow(bomord, rowindex, treeord, treecode, mxid,lvwid) {
    if (!window.subWin) {
        window.subWin = {};
    }
    window.currRowindex = rowindex;
    //展开树节点
    var textindex, rows, row, id = lvwid;
    var lvw = eval("window.lvw_JsonData_" + id);
    var h = lvw.headers;
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "text") { textindex = i; break }
    }
    rows = lvw.rows;
    for (var i = rowindex*1; i < lvw.rows.length; i++) {
        row = rows[i];
        if (row[textindex].expand == 0) {
            lvw_je_Expnode(id, i, 1, true)
        }
    }
    document.body.onunload = function () { closeSubWindow() }
    window.TeLiAddSaveCurrTreeCode = treecode;
    window.subWin[bomord] = window.open('../bomList/add1_top.asp?bomord=' + bomord + '&treeord=' + treeord + '&mxid=' + mxid, 'bom_list_add_top', 'width=1300,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=0,top=100');
}

//--关闭子窗口
function closeSubWindow() {
    var subWin = window.subWin;
    for (var i in subWin) {
        var winID = subWin[i];
        if (winID && winID.open && !winID.closed) {
            winID.close();
        }
    }
}
//--库存查看
bomTree.showStore = function (id) {
    var lvw = eval("window.lvw_JsonData_" + id);
    if (!lvw) {
        app.Alert("没有可以查看库存的产品！");
        return;
    }
    var h = lvw.headers;
    var rows = lvw.rows;
    //--获取对应列下标
    var mainIndex = -1;			//--ismain
    var num1Index = -1;			//--num1
    var tordIndex = -1;			//--treeord
    var blordIndex = -1;		//--bl_ord
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "ismain") {
            mainIndex = i;
        }
        if (h[i].dbname == "num1") {
            num1Index = i;
        }
        if (h[i].dbname == "treeord") {
            tordIndex = i;
        }
        if (h[i].dbname == "bl_ord") {
            blordIndex = i;
        }
    }
    var rows = lvw.rows;
    var data = [];
    for (var i = 0; i < rows.length; i++) {
        if (rows[i][mainIndex] == "0") {
            data.push(rows[i][blordIndex] + String.fromCharCode(2) + rows[i][num1Index] + String.fromCharCode(2) + rows[i][tordIndex]);
        }
    }
    var json = {};
    json.__msgid = "beforeShowStore";
    json.data = data.join(String.fromCharCode(1));
    var aj = $.ajax({
        type: 'post',
        url: '../bomlist/Bom_Trees_List.asp',
        cache: false,
        dataType: 'html',
        data: json,
        success: function (data) {
            //app.Alert(data);return;
            //eval(data);
            if (data == "true") {
                if (!window.subWin) {
                    window.subWin = {};
                }
                document.body.onunload = function () { closeSubWindow() }
                window.subWin[id] = window.open('../bomList/showStore.asp?stype=1', 'bom_list_add_showStore', 'width=900,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,top=100');
            }
            else {
                app.Alert("数据不正确，请刷新页面！")
            }
        },
        error: function (data) {

        }
    });
}

function handleText(text, stype, code, notNull, rowindex, treeid) {
    var lvw = eval("window.lvw_JsonData_" + treeid);
    var h = lvw.headers;
    var ckindex = -1;
    var treeordIndex = -1;
    var mxidIndex = -1;
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "selected") { ckindex = i; }
        if (h[i].dbname == "treeord") { treeordIndex = i; }
        if (h[i].dbname == "mxid") { mxidIndex = i; }
    }
    var ck = lvw.rows[rowindex][ckindex];
    if (ck == "1") {
        var ckText = " checked='checked' ";
    }
    else {
        var ckText = " ";
    }
    var treeord = lvw.rows[rowindex][treeordIndex];
    var disabled = "";				//--整棵树被锁定时，将单选框和复选框锁住
    if (lockedTrees && lockedTrees.length > 0) {
        for (var i = 0; i < lockedTrees.length; i++) {
            if (lockedTrees[i] == treeord) {
                disabled = " disabled='disabled'";
            }
        }
    }
    var space = "";
    code = code + "";
    stype = stype + "";
    notNull = notNull + "";
    if (code.lastIndexOf("_") > 0) {
        var preCode = code.substr(0, code.lastIndexOf("_"));
        switch (stype) {
            case "1":
                space += "<input " + disabled + " type='radio' id='' ck='" + ck + "' " + ckText + " name='radio_" + preCode + "_" + lvw.rows[rowindex][mxidIndex] +"' value='1' rowindex='" + rowindex + "' notnull='" + notNull + "' treeid='" + treeid + "' onclick='bomTree.radioClick(this)' onpropertychange='bomTree.radioChange(this)' />";
                break;
            case "2":
                space += "<input " + disabled + " type='checkbox' id='' ck='" + ck + "' " + ckText + " name='checkbox_" + preCode + "' value='1' rowindex='" + rowindex + "' notnull='" + notNull + "' treeid='" + treeid + "' onclick='bomTree.checkboxClick(this)' onpropertychange='bomTree.radioChange(this)' />";
                break;
        }
    }
    var notnull = "";
    //notnull = '<input title="必填" onclick="showRowsData(\'' + treeid + '\',' + rowindex + ')" style="color:red;border:0px;background-color:transparent;padding-left:0px;padding-right:0px;" type="button" value="*"/>';
    if (stype != 0 && notNull == "1") {
        notnull = '<input title="必填" style="color:red;border:0px;background-color:transparent;padding-left:0px;padding-right:0px;" type="button" value="*"/>';
    }
    return (space + text + notnull);
}

//--数量变更联动改变下级节点数量
window.onlvwUpdateCellValue = function (id, rowindex, cellindex, v, isztlr, islength) {
    var lvw = eval("window.lvw_JsonData_" + id);
    var h = lvw.headers;
    var hTitle = h[cellindex].dbname;
    var rows = lvw.rows;
    var SLIndex = -1;
    var codeIndex = -1;
    var code2Index = -1;
    var numIndex = -1;
    var num1Index = -1;
    var num2Index = -1;
    var ZJIndex = -1;
    var DJIndex = -1;
    var BZIndex = -1;
    var StyleIndex = -1;
    var SelectIndex = -1;
    var LastInx = -1;
    var mxidIndex = -1;
    var TitleIndex = -1;
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "SL") SLIndex = i;//数量
        if (h[i].dbname == "treecode") codeIndex = i;//当前节点
        if (h[i].dbname == "treecode2") code2Index = i;//父级节点
        if (h[i].dbname == "num") numIndex = i;
        if (h[i].dbname == "num1") num1Index = i;//父子比例列
        if (h[i].dbname == "num2") num2Index = i;//原始比例
        if (h[i].dbname == "ZJ") ZJIndex = i;
        if (h[i].dbname == "DJ") DJIndex = i;
        if (h[i].dbname == "BZDJ") BZIndex = i;
        if (h[i].dbname == "stype") StyleIndex = i;
        if (h[i].dbname == "selected") SelectIndex = i;
        if (h[i].dbname == "mxid") mxidIndex = i;
        if (h[i].dbname == "text") TitleIndex = i;
    }

    var attrOffset = 0;
    if (!window.isOpenProductAttr) { attrOffset = 2; }

    var code = rows[rowindex][codeIndex];
    var code2 = rows[rowindex][code2Index];
    var currNodeDeep = rows[rowindex][TitleIndex].deeps.length;
    switch (hTitle) {
        case "num1":
            if (codeIndex >= 0) {
                //当前行数量
                var currNum = rows[rowindex][SLIndex];
                if (code2.length > 0) {
                    for (var i = rowindex * 1 - 1 ; i >= 0; i--) {
                        if (rows[i][codeIndex] == code2) {
                            var pn = rows[i][SLIndex];
                            var pbli = rows[i][num1Index] ? rows[i][num1Index] : 1;
                            currNum = FormatNumber(pn * v/pbli , window.sysConfig.floatnumber);
                            rows[rowindex][SLIndex] = currNum;
                            break;
                        }
                    }
                } else {
                    currNum = FormatNumber(v, window.sysConfig.floatnumber);
                    rows[rowindex][SLIndex] = currNum;
                }
                __lvw_je_redrawCell(lvw, h[SLIndex], rowindex, SLIndex - 1 - attrOffset);

                var bNum = currNum;
                for (var i = (rowindex * 1 + 1); i < rows.length; i++) {
                    if (!currNodeDeep && rows[i][TitleIndex].deeps.length == currNodeDeep) { break; }
                    LastInx = i;
                    if (rows[i][codeIndex].indexOf(code) != 0) break;
                    var bli = 1,orignBli;
                    code2 = rows[i][code2Index];
                    for (var ii = i * 1 - 1 ; ii >= 0; ii--) {
                        if (rows[ii][codeIndex] == code2) {
                            bNum = rows[ii][SLIndex];
                            bli = rows[ii][num1Index] * 1
                            bli = bli ? bli : 1;
                            orignBli = rows[ii][num2Index];
                            rows[i][num1Index] = rows[ii][num1Index] * 1 / (orignBli ? orignBli : 1) * rows[i][num2Index];
                            __lvw_je_redrawCell(lvw, h[num1Index], i, num1Index - 1 - attrOffset);
                            break;
                        }
                    }
                    rows[i][SLIndex] = FormatNumber(rows[i][cellindex] * bNum / bli, window.sysConfig.floatnumber);
                    __lvw_je_redrawCell(lvw, h[SLIndex], i, SLIndex - 1 - attrOffset);
                }
                if (rowindex == rows.length - 1) {
                    LastInx = rowindex * 1;
                }
            }
            break;
        case "SL":
            var bNum = v;
            for (var i = (rowindex * 1 + 1) ; i < rows.length; i++) {
                if (!currNodeDeep && rows[i][TitleIndex].deeps.length == currNodeDeep) { break; }
                LastInx = i;
                if (rows[i][codeIndex].indexOf(code) != 0) break;
                var bli = 1;
                code2 = rows[i][code2Index];
                for (var ii = i * 1 - 1 ; ii >= 0; ii--) {
                    if (rows[ii][codeIndex] == code2) {
                        bNum = rows[ii][SLIndex];
                        bli = rows[ii][num1Index]*1?rows[ii][num1Index]:1;
                        break;
                    }
                }
                rows[i][SLIndex] = FormatNumber(rows[i][num1Index] * bNum / bli, window.sysConfig.floatnumber);
                __lvw_je_redrawCell(lvw, h[SLIndex], i, SLIndex - 1 - attrOffset);
            }
            if (rowindex == rows.length - 1) {
                LastInx = rowindex * 1;
            }
            break;
    }
    //金额的计算
    for (var i = LastInx * 1 ; i >= 0; i--) {
        code = rows[i][codeIndex];
        var arr = code.split("|");
        var price = (rows[i][DJIndex] + "").replace(/,/g, "");//单价
        var num = (rows[i][SLIndex] + "").replace(/,/g, "");//数量
        var mxid = rows[i][mxidIndex];
        if (arr[arr.length - 1].indexOf("_") > 0) {
            //叶子节点 单价*数量
            rows[i][ZJIndex] = FormatNumber(price * num, window.sysConfig.moneynumber);
        } else {
            var allMoney = 0;
            var bzAllPrice = 0;
            var mxid1 = 0;
            var bzBli_p = rows[i][num1Index] ? rows[i][num1Index] : 1, bzBli_c;
            for (var ii = (i * 1 + 1); ii < rows.length; ii++) {
                mxid1 = rows[ii][mxidIndex];
                if (rows[ii][code2Index] + "_" + mxid1 == code + "_" + mxid) {//code需要相同，并且是同一产品下的才可以进行累加
                    if (rows[ii][StyleIndex] == "0" || rows[ii][StyleIndex] == "" || rows[ii][SelectIndex] == "1") {
                        bzBli_c = rows[ii][num1Index];
                        allMoney += parseFloat((rows[ii][ZJIndex] + "").replace(/,/g, ""));
                        bzAllPrice += parseFloat((rows[ii][BZIndex] * bzBli_c / bzBli_p + "").replace(/,/g, ""));
                    }
                }
            }
            rows[i][ZJIndex] = FormatNumber(allMoney, window.sysConfig.moneynumber);
            rows[i][DJIndex] = FormatNumber(allMoney / num, h[DJIndex].dbtype == "storeprice" ? window.sysConfig.StorePriceDotNum : window.sysConfig.SalesPriceDotNum);
            rows[i][BZIndex] = FormatNumber(bzAllPrice, h[DJIndex].dbtype == "storeprice" ? window.sysConfig.StorePriceDotNum : window.sysConfig.SalesPriceDotNum);
            __lvw_je_redrawCell(lvw, h[DJIndex], i, DJIndex - 1 - attrOffset);
            __lvw_je_redrawCell(lvw, h[BZIndex], i, BZIndex - 1 - attrOffset);
        }
        __lvw_je_redrawCell(lvw, h[ZJIndex], i, ZJIndex - 1 - attrOffset);
    }
}
//--树保存
bomTree.saveTree = function (id) {
    if (bomTree.beforeSaveTree(id)) {
        var lvw = eval("window.lvw_JsonData_" + id);
        var h = lvw.headers;
        var rows = lvw.rows;
        //--获取对应列下标
        var nnIndex = -1;			//--notnull
        var stypeIndex = -1;		//--stype
        var codeIndex = -1;			//--treecode
        var codeIndex2 = -1;			//--treecode2
        var selectedIndex = -1;		//--selected
        var mainIndex = -1;			//--ismain
        var blordIndex = -1;		//--bl_ord
        var num2Index = -1;			//--num2
        var num1Index = -1;			//--num1
        var tordIndex = -1;			//--treeord
        var SLindex = -1;
        var JHRQIndex = -1;
        var BZIndex = -1;
        var mxidindex = -1;
        var hTasindex = -1;
        var DJIndex = -1;
        var protypeIndex = -1;
        var markIndex = -1;
        var treeType = jQuery("#treeType").val();
        for (var i = 0; i < h.length; i++) {
            if (h[i].dbname == "notnull") {
                nnIndex = i;
            }
            if (h[i].dbname == "stype") {
                stypeIndex = i;
            }
            if (h[i].dbname == "protype") {
                protypeIndex = i;
            }
            if (h[i].dbname == "treecode") {
                codeIndex = i;
            }
            if (h[i].dbname == "treecode2") {
                codeIndex2 = i;
            }
            if (h[i].dbname == "selected") {
                selectedIndex = i;
            }
            if (h[i].dbname == "ismain") {
                mainIndex = i;
            }
            if (h[i].dbname == "bl_ord") {
                blordIndex = i;
            }
            if (h[i].dbname == "num2") {
                num2Index = i;
            }
            if (h[i].dbname == "num1") {
                num1Index = i;
            }
            if (h[i].dbname == "treeord") {
                tordIndex = i;
            }
            if (h[i].dbname == "SL") {
                SLIndex = i;
            }
            if (h[i].dbname == "JHRQ") {
                JHRQIndex = i;
            }
            if (h[i].dbname == "BZ") {
                BZIndex = i;
            }
            if (h[i].dbname == "mxid") {
                mxidIndex = i;
            }
            if (h[i].dbname == "includeTax") {
                hTasindex = i;
            }
            if (h[i].dbname == "DJ") {
                DJIndex = i;
            }
            if (h[i].dbname == "mark") {
                markIndex = i;
            }
        }
        var mark = "";
        var saveLvw = {};
        saveLvw.headers = h;
        saveLvw.rows = [];
        var nodeSelected = {};
        //var selected = [];		//--被选中的必选节点【前面有复选框或单选框且被选中的】
        //var finnal = [];		//--被选定的最终产品数组
        //var treeord = 0;		//--当前树ORD
        //var changedNum = [];	//--变化的产品数量
        var data = {};
        var ymxid = "-1";
        var mxids = "";
        var protype = "";
        var ySelectTreecode = ""; var treecode2 = "";
        var mxid, SL, JHRQ, BZ, arr_mxid;
        for (var i = 0; i < rows.length; i++) {
            if (mark == "") {
                mark = rows[i][markIndex];
            }
            var treeord = rows[i][tordIndex];		//--当前树ORD
            var code = rows[i][codeIndex] + "";
            protype = rows[i][protypeIndex];
            if (!data[treeord]) {
                nodeSelected = {};
                data[treeord] = {};
                data[treeord].selected = [];	//--被选中的必选节点【前面有复选框或单选框且被选中的】
                data[treeord].finnal = [];		//--被选定的最终产品数组
                data[treeord].changedNum = [];	//--变化的产品数量
                data[treeord].SL = [];		//数量
                data[treeord].JHRQ = [];		//交货日期
                data[treeord].BZ = [];		//备注
                data[treeord].mxid = [];		//mxid
                data[treeord].includeTax = [];		//includeTax
                data[treeord].PriceXS = [];		//PriceXS
                rows[i][nnIndex] = "1";
                rows[i][stypeIndex] = "0";
                rows[i][selectedIndex] = "1";
                nodeSelected[code] = rows[i][selectedIndex];
            } else {
                if (protype == "0") {
                    if (rows[i][stypeIndex] == "1" || rows[i][stypeIndex] == "2") {
                        //rows[i][selectedIndex] = "0";
                        //nodeSelected[code] = "0";
                    } else {
                        rows[i][selectedIndex] = "1";
                        nodeSelected[code] = "1";
                    }
                }
            }
            //console.log("i="+(i+1) +"   code="+code+"      protype="+protype+"      stype="+rows[i][stypeIndex]+"   rows[i][selectedIndex]="+rows[i][selectedIndex]);
            if (String(rows[i][num1Index]).replace(/,/g, "") != String(rows[i][num2Index]).replace(/,/g, "")) {
                data[treeord].changedNum.push(String(rows[i][blordIndex]).replace(/,/g, "") + "," + String(rows[i][num1Index]).replace(/,/g, "") + "," + rows[i][codeIndex]);
            }
            if (rows[i][SLIndex] && rows[i][SLIndex].length > 0 && parseFloat(rows[i][SLIndex]) > '9999999999') {
                alert("第" + (i + 1) +"行数量列不能大于9999999999")
                return
            }
            data[treeord].SL.push(String(rows[i][SLIndex]).replace(/,/g, ""));
            data[treeord].includeTax.push(String(rows[i][hTasindex]).replace(/,/g, ""));
            data[treeord].PriceXS.push(String(rows[i][DJIndex]).replace(/,/g, ""));
            mxid = String(rows[i][mxidIndex]).replace(/,/g, "");
            data[treeord].mxid.push(mxid);
            data[treeord].BZ.push($(rows[i][BZIndex]).eq(0).val() || "");
            data[treeord].JHRQ.push($(rows[i][JHRQIndex]).eq(0).val() || "");

            if (rows[i][selectedIndex] == "1") {
                data[treeord].selected.push(rows[i][blordIndex] + "#$9527$#" + rows[i][codeIndex]);
            }
            //var code = rows[i][codeIndex] + "";confirm(rows[i][nnIndex])
            if (rows[i][nnIndex] == "") {
                rows[i][nnIndex] = "1";
                rows[i][stypeIndex] = "0";
                if (protype == "0") {
                    if (rows[i][selectedIndex] == "1") {
                        rows[i][selectedIndex] = "1";
                    }
                } else {
                    rows[i][selectedIndex] = "1";
                }
                nodeSelected[code] = rows[i][selectedIndex];
            }
            else {
                var preCode = code.substr(0, code.lastIndexOf("_"));
                //console.log("i="+(i+1) +"   code="+code+"    preCode="+preCode+"    selected="+nodeSelected[preCode]);
                if (nodeSelected[preCode] == "1") {
                    if (rows[i][stypeIndex] == "0") {
                        nodeSelected[code] = "1";
                    }
                    else {
                        nodeSelected[code] = rows[i][selectedIndex];
                    }
                }
                else {
                    if (nodeSelected[preCode]) {
                        nodeSelected[code] = "0";
                    }
                }
                if (nodeSelected[code] == "1" && rows[i][mainIndex] == "0") {
                    saveLvw.rows.push(rows[i]);
                    data[treeord].finnal.push(rows[i][blordIndex] + "#$9527$#" + rows[i][codeIndex]);
                }
            }
        }
        //return false;
        var json = {};
        var treeord = [];
        var finnal = [];
        var selected = [];
        var changedNum = [];
        var arrSL = [];
        var arrJHRQ = [];
        var arrBZ = [];
        var arrmxid = [];
        var arrhTax = [];
        var arrPriceXS = [];
        var isIe = isIE()
        for (var i in data) {
            treeord.push(i);
            finnal.push(data[i].finnal.join(","));
            selected.push(data[i].selected.join(","));
            changedNum.push(data[i].changedNum.join("^&*9527*&^"));
            arrSL.push(data[i].SL.join(","));
            arrJHRQ.push(data[i].JHRQ.join(String.fromCharCode(3)));
            arrBZ.push(data[i].BZ.join(String.fromCharCode(3)));
            arrmxid.push(data[i].mxid.join(","));
            arrhTax.push(data[i].includeTax.join(","));
            arrPriceXS.push(data[i].PriceXS.join(","));
            opener.updatelvwtreord(data[i].mxid[0], data[i].SL[0], data[i].BZ ? data[i].BZ[0] : "", data[i].JHRQ?data[i].JHRQ[0] :"", i, data[i].PriceXS[0])
        }
        //confirm("[changedNum =" + changedNum.join(",") + "][treeord=" + treeord.join(",") + "][finnal=" + finnal.join(",") + "][selected=" + selected.join(",") + "][changedNum=" + changedNum.join(",") + "]");return;
        json.__msgid = "saveTree";
        json.treeord = treeord.join(",");//confirm(treeord);return;
        json.finnal = finnal.join(String.fromCharCode(1));
        json.selected = selected.join(String.fromCharCode(1));
        json.changedNum = changedNum.join(String.fromCharCode(1));
        json.arrSL = arrSL.join(String.fromCharCode(1));
        json.arrJHRQ = arrJHRQ.join(String.fromCharCode(1));
        json.arrBZ = arrBZ.join(String.fromCharCode(1));
        json.arrmxid = arrmxid.join(String.fromCharCode(1));
        json.arrhTax = arrhTax.join(String.fromCharCode(1));
        json.mark = mark;
        var aj = $.ajax({
            type: 'post',
            url: '../bomlist/Bom_Trees_List_Price.asp',
            cache: false,
            dataType: 'html',
            data: json,
            success: function (data) {
                //confirm(data);return;
                //eval(data);
                if (data == "true") {
                    try {
                        var arr_SL, arr_JHRQ, arr_BZ, arr_hTax, iJHRQ, iBZ;
                        var PriceXS = 0;
                        iJHRQ = 0; iBZ = 0;
                        for (var i = 0; i < lvw.headers.length ; i++) {
                            switch (lvw.headers[i].dbname) {
                                case "JHRQ":
                                    iJHRQ = i; break;
                                case "BZ":
                                    iBZ = i; break;
                            }
                        }
                        for (var i = 0; i < arrmxid.length; i++) {
                            arr_mxid = arrmxid[i].split(",");
                            arr_SL = arrSL[i].split(",");
                            arr_JHRQ = arrJHRQ[i].split(String.fromCharCode(3));
                            arr_BZ = arrBZ[i].split(String.fromCharCode(3));
                            arr_hTax = arrhTax[i].split(",");
                            arr_PriceXS = arrPriceXS[i].split(",");
                            ymxid = "-1";
                            for (var ii = 0; ii < arr_mxid.length; ii++) {
                                mxid = arr_mxid[ii]
                                if (ymxid != mxid && mxid != "" && mxid != "0") {
                                    SL = arr_SL[ii];
                                    JHRQ = arr_JHRQ[ii];
                                    BZ = arr_BZ[ii];
                                    PriceXS = arr_PriceXS[ii];
                                    //console.log("mxid="+mxid+"][PriceXS="+PriceXS);
                                    jQuery("input[name='num1_" + mxid + "']", window.parent.opener.document).val(SL);
                                    if (treeType + "" == "2") {
                                        if (arr_hTax[ii] + "" == "0") {
                                            jQuery("input[name='price1_" + mxid + "']", window.parent.opener.document).val(PriceXS);
                                            if (isIe == false) {
                                                if (window.parent.opener.refreshPrices) { window.parent.opener.refreshPrices(treeType, mxid, "price1_" + mxid); }
                                            }
                                        } else {
                                            jQuery("input[name='priceIncludeTax_" + mxid + "']", window.parent.opener.document).val(PriceXS);
                                            if (isIe == false) {
                                                if (window.parent.opener.refreshPrices) { window.parent.opener.refreshPrices(treeType, mxid, "priceIncludeTax_" + mxid); }
                                            }
                                        }
                                    } else {
                                        jQuery("input[name='price1_" + mxid + "']", window.parent.opener.document).val(PriceXS);
                                        if (isIe == false) {
                                            if (window.parent.opener.refreshPrices) { window.parent.opener.refreshPrices(treeType, mxid, "price1_" + mxid); }
                                        }
                                    }
                                    if (iJHRQ > 0) { jQuery("input[name='date1_" + mxid + "']", window.parent.opener.document).val(JHRQ); }
                                    if (iBZ > 0) { jQuery("textarea[name='intro_" + mxid + "']", window.parent.opener.document).val(BZ); }
                                    var viewBom = jQuery("#viewBom_" + mxid + "", window.parent.opener.document);
                                    viewBom.removeClass("ico5");
                                    viewBom.addClass("ico5");
                                }
                                if (mxid != "" && mxid != "0") { ymxid = mxid; }
                            }
                        }

                        parent.document.body.onunload = function () { refreshOpener() }
                        parent.window.close();
                    }
                    catch (e) {
                    }
                }
            },
            error: function (data) {

            }
        });
    }
}
//--必填的单选或复选产品验证
bomTree.beforeSaveTree = function (id) {
    var lvw = eval("window.lvw_JsonData_" + id);
    if (!lvw) {
        app.Alert("产品没有设置组装清单！");
        return false;
    }
    var h = lvw.headers;
    var rows = lvw.rows;
    var nnIndex = -1;
    var stypeIndex = -1;
    var codeIndex = -1;
    var selectedIndex = -1;
    var numIndex = -1;
    var treeordIndex = -1;
    for (var i = 0; i < h.length; i++) {
        if (h[i].dbname == "notnull") {
            nnIndex = i;
        }
        if (h[i].dbname == "stype") {
            stypeIndex = i;
        }
        if (h[i].dbname == "treecode") {
            codeIndex = i;
        }
        if (h[i].dbname == "selected") {
            selectedIndex = i;
        }
        if (h[i].dbname == "num1") {
            numIndex = i;
        }
        if (h[i].dbname == "treeord") {
            treeordIndex = i;
        }
    }
    //confirm("["+nnIndex+"]["+stypeIndex+"]["+codeIndex+"]["+selectedIndex+"]")
    var notnull = {};
    for (var i = 0; i < rows.length; i++) {
        var num = rows[i][numIndex];
        if (num <= 0 || num > 999999999) {
            lvw.selpos = i;
            ___RefreshListViewselPos(lvw);
            app.Alert("产品数量必须在0~99999999之间！")
            return false;
            break;
        }
        var code = rows[i][codeIndex] + "";
        var treeord = rows[i][treeordIndex] + "";
        if (rows[i][nnIndex] == "1" && rows[i][stypeIndex] != "0" && code.lastIndexOf("_") > 0) {
            var preCode = code.substr(0, code.lastIndexOf("_"));
            preCode = treeord + "_" + preCode + '_' + rows[i][stypeIndex];
            if (!notnull[preCode]) {
                notnull[preCode] = {};
                notnull[preCode].title = [];
                notnull[preCode].checked = rows[i][selectedIndex];
                notnull[preCode].title.push(rows[i][1].txt);
                notnull[preCode].stype = rows[i][stypeIndex];
                notnull[preCode].index = i;

            }
            else {
                notnull[preCode].title.push(rows[i][1].txt);
                if (notnull[preCode].checked != "1") {
                    notnull[preCode].checked = rows[i][selectedIndex];
                    //notnull[preCode].index = i;
                }
            }
        }
    }
    for (var i in notnull) {
        if (notnull[i].checked == "0") {
            var stype = notnull[i].stype + "";
            switch (stype) {
                case "0":
                    var typetext = "固定";
                    break;
                case "1":
                    var typetext = "单选";
                    break;
                case "2":
                    var typetext = "复选";
                    break;
            }
            lvw.selpos = notnull[i].index;
            ___RefreshListViewselPos(lvw);
            app.Alert(notnull[i].title.join(",") + "为必选产品，请至少选择其中之一！");
            return false;
        }
    }
    return true;
}

function showRowsData(id, rowindex) {
    var lvw = eval("window.lvw_JsonData_" + id);
    var rows = lvw.rows;
    confirm(rows[rowindex]);
}

function refreshOpener() {
    if (parent && parent.opener) {
        if (parent.opener.window.refreshBomInfo) {
            parent.opener.window.refreshBomInfo();
        }
    }
}

//--特例添加保存后，页面关闭的回调事件
window.onTeLiAddSave = function (treeord, bomord, mxid) {
    //confirm(window.TeLiAddSaveCurrTreeCode);
    if (typeof (mxid) == "undefined") { mxid = 0 }
    var json = {};
    json.__msgid = "TreeListCallBack";
    json.treeord = treeord;
    json.bomord = bomord;
    json.currCode = window.TeLiAddSaveCurrTreeCode;
    json.tType = window.treetype;
    json.mxid = mxid;
    json.sqlstr = window.sqlstr;
    var rowindex = window.currRowindex;
    _lvw_je_RefreshListTreeNode("Bomtree", rowindex, true, function () {
        //ajax.addParam("proord",proord);
        ajax.addParam("bomord", json.bomord);
        //ajax.addParam("protype",protype);
        ajax.addParam("currCode", json.currCode);
        ajax.addParam("tType", json.tType);
        ajax.addParam("treeord", json.treeord);
        ajax.addParam("mxid", json.mxid);
        if (json.sqlstr && json.sqlstr.length > 0 && ajax.url.indexOf("__sys_LongUrlParamsID") == -1) {
            var url = ajax.url + (ajax.url.indexOf("?") == -1 ? "?" : "");
            if (url && url.length > 0) {
                var urlArr = url.split("?");
                ajax.url = url + (urlArr.length > 1 && urlArr[1].length > 0 ? "&" : "") + "__sys_LongUrlParamsID=" + json.sqlstr;
            }
        }
    });
}

function getSumPrice2(lvw, rowindex, treeCode1) {
    var i, iSL, iDJ, iZJ, iBL, itreeCode, ord, rowindex1;
    var BL, DJ, ZJ, SL1, SL, treeCode, treeCode2, isShowSL, isShowMoneyXS, iord, itreeCode2;
    iSL = 0; iDJ = 0; iZJ = 0; iBL = 0; itreeCode = 0; itreeCode2 = 0;
    BL = 0; DJ = 0; ZJ = 0; SL = 0; SL1 = 0; treeCode = ""; rowindex1 = 0; treeCode2 = "";
    isShowSL = jQuery("#isShowSL").val();
    isShowMoneyXS = jQuery("#isShowMoneyXS").val();
    setTimeout(function () {
        for (i = 0; i < lvw.headers.length ; i++) {
            switch (lvw.headers[i].dbname) {
                case "num1":
                    iBL = i; break;
                case "SL":
                    iSL = i; break;
                case "DJ":
                    iDJ = i; break;
                case "ZJ":
                    iZJ = i; break;
                case "treecode":
                    itreeCode = i; break;
                case "treecode2":
                    itreeCode2 = i; break;
                case "ord":
                    iord = i; break;
            }
        }
        try {
            treeCode2 = lvw.rows[rowindex][itreeCode2];
            rowindex1 = rowindex;
            if (treeCode2 != "") {
                for (i = rowindex; i >= 0; i--) {
                    treeCode2 = lvw.rows[i][itreeCode2];
                    if (treeCode2 + "" == "") {
                        rowindex1 = i;
                        break;
                    }
                }
            }
            SL1 = Number(lvw.rows[rowindex1][iSL].toString().replace(/,/g, ""));
        } catch (e) { }
        try {
            for (i = rowindex + 1; i < lvw.rows.length; i++) {
                treeCode = lvw.rows[i][itreeCode];
                if (treeCode.indexOf(treeCode1) > -1) {
                    BL = Number(lvw.rows[i][iBL].toString().replace(/,/g, ""));
                    if (iDJ > 0) { DJ = Number(lvw.rows[i][iDJ].toString().replace(/,/g, "")); } else { DJ = 0; }
                    SL = BL * SL1;
                    ZJ = SL * DJ;
                    if (iSL > 0) { lvw.rows[i][iSL] = FormatNumber(SL, window.sysConfig.floatnumber); }
                    if (iZJ > 0) { lvw.rows[i][iZJ] = FormatNumber(ZJ, window.sysConfig.moneynumber); }
                    if (isShowSL == "1") {
                        if (iSL > 0) { __lvw_je_redrawCell(lvw, lvw.headers[iSL], i, iSL - 1); }
                    }
                    if (isShowMoneyXS == "1") {
                        if (iZJ > 0) { __lvw_je_redrawCell(lvw, lvw.headers[iZJ], i, iZJ - 1); }
                    }
                } else {
                    break;
                }
            }
        } catch (e) { }
    }, 10);
}


function getSumPrice(lvw) {
    var i, iSL, iDJ, iZJ, iBL;
    var BL, DJ, ZJ, SL1, SL;
    iSL = 0; iDJ = 0; iZJ = 0; iBL = 0;
    BL = 0; DJ = 0; ZJ = 0; SL = 0; SL1 = 0;
    setTimeout(function () {
        for (i = 0; i < lvw.headers.length ; i++) {
            switch (lvw.headers[i].dbname) {
                case "num1":
                    iBL = i; break;
                case "SL":
                    iSL = i; break;
                case "DJ":
                    iDJ = i; break;
                case "ZJ":
                    iZJ = i; break;
            }
        }
        try { SL1 = Number(lvw.rows[0][iSL].toString().replace(/,/g, "")); } catch (e) { }
        try {
            for (i = 1; i < lvw.rows.length; i++) {
                BL = Number(lvw.rows[i][iBL].toString().replace(/,/g, ""));
                if (iDJ > 0) { DJ = Number(lvw.rows[i][iDJ].toString().replace(/,/g, "")); } else { DJ = 0; }
                SL = BL * SL1;
                ZJ = SL * DJ;
                if (iSL > 0) { lvw.rows[i][iSL] = FormatNumber(SL, window.sysConfig.floatnumber); }
                if (iZJ > 0) { lvw.rows[i][iZJ] = FormatNumber(ZJ, window.sysConfig.moneynumber); }
            }
            ___RefreshListViewByJson(lvw);
        } catch (e) { }
    }, 10);
}

function isIE() { //ie?
    if (!!window.ActiveXObject || "ActiveXObject" in window)
        return true;
    else
        return false;
}
