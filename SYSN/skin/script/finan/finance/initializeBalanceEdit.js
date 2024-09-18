var arrRowIndexs = null;
var cidx_direction = -1;
function lvw_tbodybg_withlvw_change(_target) {
    var inputbox = _target || window.event.target || window.event.srcElement;
    var v = inputbox.value;
    var sv = inputbox.id.split("_");
    var rowindex = sv[sv.length - 3];
    var cellindex = sv[sv.length - 2];
    var lvwid = sv[0].replace("@", "");
    //var lvwid, rowindex, cellindex, v;

    updatePartnerVal(lvwid, rowindex, cellindex, v);//根据当前节点的变动同步更新同类型不同币种值
    arrRowIndexs = [];//每次触发事件先清空用来记录的数组
    var lvw = window["lvw_JsonData_" + lvwid];
    if (lvw.id != 'withlvw') {
        return;
    }

    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "showBalanceDirection") {
            cidx_direction = i; break;
        }

    }
    //判断当前节点是不是根节点(如果是跟节点还能触发事件证明它没有子节点,因为父节点不能编辑)
    if ((lvw.rows[rowindex][lvw.TreeNodeCellIndex].deepData || -1) == -1) {
        updatePartnerVal(lvwid, rowindex, cellindex, v);//根据当前节点的变动同步更新同类型不同币种值
        ___RefreshListViewByJson(lvw_JsonData_withlvw);//刷新树
        return;//是根结点不需要计算当前列
    }
    for (var i = rowindex - 1; i > -1; i--) {//当前行向上一直找到根节点
        var _deep = lvw.rows[i][lvw.TreeNodeCellIndex].deepData || -1;
        if (_deep.length > 0) {
            continue;
        }
        var _val = getChildrenTatal(lvw, _deep, i, cellindex);//遍历子节点,返回子节点合计值
        __lvw_je_updateCellValue(lvw.id, i, cellindex, _val, true);//给当前节点更新值(值来源:子节点合计)
        updatePartnerVal(lvw.id, i, cellindex, _val);//根据当前节点的变动同步更新同类型不同币种值
        break;
    }

    ___RefreshListViewByJson(lvw_JsonData_withlvw);//刷新树


}

//遍历子节点,返回子节点合计值
function getChildrenTatal(lvw, deep, rowindex2, cellindex2) {
    var cellindex = parseInt(cellindex2);
    var rowindex = parseInt(rowindex2);
    var result = 0;
    var cellidxs = [];//用于存放借方余额/贷方余额的列下标
    for (var i = 0; i < lvw.headers.length; i++) {
        //如果是借方余额或者贷方余额,直接返回true,因为它们不需要判断方向
        if ("money2_y,money2_b,money3_y,money3_b,Num2,Num3".indexOf(lvw.headers[i].dbname) >= 0) {
            cellidxs.push(i);
        }
    }
    for (var i = rowindex + 1; i < lvw.rows.length; i++) {
        var _deep = lvw.rows[i][lvw.TreeNodeCellIndex].deepData || -1;

        if (_deep <= deep) {//同级或高级直接结束循环(因为是向下循环找,如果遇到同级或高级证明子节点已经遍历结束)
            break;
        }
        //非空判断用于处理删除辅助核算项时调用本方法(平时不受影响)
        if (arrRowIndexs != null && arrRowIndexs.indexOf(i) > -1) {//已经计算过的节点直接跳过
            continue;
        }
        if (hasChild(lvw, _deep, i)) {
            var _val = getChildrenTatal(lvw, _deep, i, cellindex);
            __lvw_je_updateCellValue(lvw.id, i, cellindex, _val, true);//给当前节点更新值(值来源:子节点合计)
            updatePartnerVal(lvw.id, i, cellindex, _val);//根据当前节点的变动同步更新同类型不同币种值
            if (arrRowIndexs != null)//非空判断用于处理删除辅助核算项时调用本方法(平时不受影响)
                arrRowIndexs.push(i);
            //判断当前节点跟父级节点的余额方向是否一样,一样的做+处理,否则做-处理
            if (equalThatParentDirection(lvw, i) || cellidxs.indexOf(cellindex) > -1)
                result += Number(_val);
            else
                result -= Number(_val);
            continue;
        }
        //判断当前节点跟父级节点的余额方向是否一样,一样的做+处理,否则做-处理
        if (equalThatParentDirection(lvw, i) || cellidxs.indexOf(cellindex) > -1)
            result += Number(lvw.rows[i][cellindex] || 0);
        else
            result -= Number(lvw.rows[i][cellindex] || 0);
        if (arrRowIndexs != null)//非空判断用于处理删除辅助核算项时调用本方法(平时不受影响)
            arrRowIndexs.push(i);
    }
    return result;
}

//判断当前节点跟其父节点余额方向是否一样
function equalThatParentDirection(lvw, ridx) {
    var _thisDeep = lvw.rows[ridx][lvw.TreeNodeCellIndex].deepData || -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "showBalanceDirection") {
            cidx_direction = i; break;
        }

    }
    for (var i = ridx - 1; i > -1; i--) {//当前行向上一直找到父节点
        var _deep = lvw.rows[i][lvw.TreeNodeCellIndex].deepData || -1;
        if (_deep >= _thisDeep) {//大于等于当前节点Deep值的全部跳过,一直到找到比当前节点Deep值低的节点
            continue;
        }
        return lvw.rows[i][cidx_direction] == lvw.rows[ridx][cidx_direction] ? true : false;
    }
}

//判断是否有子节点
function hasChild(lvw, deep, rowindex) {
    var result = false;
    if (rowindex >= lvw.rows.length - 1) {
        return result;
    }
    var _deep = lvw.rows[rowindex + 1][lvw.TreeNodeCellIndex].deepData || -1;
    if (deep < _deep) {
        result = true;
    }
    return result;
}

//根据当前节点的变动同步更新同类型不同币种值
function updatePartnerVal(lvwid, rowindex, cellindex, v) {
    var lvw = window["lvw_JsonData_" + lvwid];
    var _thisheader = lvw.headers[cellindex].dbname;//当前节点的head
    var _sel_bz = $("#bz_0");
    var _sel_bz_options = _sel_bz.find("option");
    var _bzs = [];
    var _sel_bz_value = _sel_bz.val();//选中的币种
    var _hl = 1;//默认汇率为1
    for (var i = 0; i < _sel_bz_options.length; i++) {
        _bzs.push(_sel_bz_options[i].value);
    }

    if (_bzs.indexOf(_sel_bz_value) < 1) {
        return;//币种第一个选项是综合本位币，不予计算;
    }//第二个选项是本位币,默认汇率为1.00(不操作)
    else {
        _hl = $("#ExchangeRate_0").val() || 1;
    }

    var _cidx_partner = "";
    var money_y = 0.00;
    var money_partner = 0.00;
    var headers = [];
    for (var i = 0; i < lvw.headers.length; i++) {
        headers.push(lvw.headers[i].dbname);
    }
    var _id_partner = "";
    switch (_thisheader) {
        case "money4_b":
            money_b = v;
            _cidx_partner = headers.indexOf("money4_y");
            money_partner = lvw.rows[rowindex][cellindex] / _hl;
            _id_partner = "@withlvw_money4_y_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "money4_y":
            money_y = v;
            _cidx_partner = headers.indexOf("money4_b");
            money_partner = lvw.rows[rowindex][cellindex] * _hl;
            _id_partner = "@withlvw_moneyb_y_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "money2_b":
            money_b = v;
            _cidx_partner = headers.indexOf("money2_y");
            money_partner = lvw.rows[rowindex][cellindex] / _hl;
            _id_partner = "@withlvw_money2_y_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "money2_y":
            money_y = v;
            _cidx_partner = headers.indexOf("money2_b");
            money_partner = lvw.rows[rowindex][cellindex] * _hl;
            _id_partner = "@withlvw_money2_b_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "money3_b":
            money_b = v;
            _cidx_partner = headers.indexOf("money3_y");
            money_partner = lvw.rows[rowindex][cellindex] / _hl;
            _id_partner = "@withlvw_money3_y_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "money3_y":
            money_y = v;
            _cidx_partner = headers.indexOf("money3_b");
            money_partner = lvw.rows[rowindex][cellindex] * _hl;
            _id_partner = "@withlvw_money3_b_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "money1_b":
            money_b = v;
            _cidx_partner = headers.indexOf("money1_y");
            money_partner = lvw.rows[rowindex][cellindex] / _hl;
            _id_partner = "@withlvw_money1_y_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "money1_y":
            money_y = v;
            _cidx_partner = headers.indexOf("money1_b");
            money_partner = lvw.rows[rowindex][cellindex] * _hl;
            _id_partner = "@withlvw_money1_b_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "Num4":
            money_y = v;
            _cidx_partner = headers.indexOf("Num4");
            money_partner = lvw.rows[rowindex][cellindex];
            _id_partner = "@withlvw_Num4_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "Num2":
            money_y = v;
            _cidx_partner = headers.indexOf("Num2");
            money_partner = lvw.rows[rowindex][cellindex];
            _id_partner = "@withlvw_Num2_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "Num3":
            money_y = v;
            _cidx_partner = headers.indexOf("Num3");
            money_partner = lvw.rows[rowindex][cellindex];
            _id_partner = "@withlvw_Num3_" + rowindex + "_" + _cidx_partner + "_0";
            break;
        case "Num1":
            money_y = v;
            _cidx_partner = headers.indexOf("Num1");
            money_partner = lvw.rows[rowindex][cellindex];
            _id_partner = "@withlvw_Num1_" + rowindex + "_" + _cidx_partner + "_0";
            break;
    }

    if (isNaN(money_partner)) {
        return;
    }

    if (lvw.rows[rowindex][_cidx_partner] == null || isNaN(lvw.rows[rowindex][_cidx_partner]) || lvw.rows[rowindex][_cidx_partner] == 0 || lvw.rows[rowindex][_cidx_partner] != money_partner)
        lvw.rows[rowindex][_cidx_partner] = money_partner;
    updatemoney1(lvwid, rowindex);

}

//根据当前行的变动计算年初余额
function updatemoney1(lvwid, ridx) {
    var lvw = window["lvw_JsonData_" + lvwid];
    var _money4_b = 0;
    var _money4_y = 0;
    var _money2_b = 0;
    var _money2_y = 0;
    var _money3_b = 0;
    var _money3_y = 0;
    var _money1_b = 0;
    var _money1_y = 0;
    var _num4 = 0;
    var _num2 = 0;
    var _num3 = 0;
    var _num1 = 0;
    var _cidx_Num1 = "";
    var _cidx_money1_b = "";
    var _cidx_money1_y = "";
    var _direction = 1;

    //必要数据收集
    for (var i = 0; i < lvw.headers.length; i++) {
        switch (lvw.headers[i].dbname) {
            case "money4_b":
                _money4_b = Number(lvw.rows[ridx][i]);
                break;
            case "money4_y":
                _money4_y = Number(lvw.rows[ridx][i]);
                break;
            case "money2_b":
                _money2_b = Number(lvw.rows[ridx][i]);
                break;
            case "money2_y":
                _money2_y = Number(lvw.rows[ridx][i]);
                break;
            case "money3_b":
                _money3_b = Number(lvw.rows[ridx][i]);
                break;
            case "money3_y":
                _money3_y = Number(lvw.rows[ridx][i]);
                break;
            case "money1_b":
                _cidx_money1_b = i;
                break;
            case "money1_y":
                _cidx_money1_y = i;
                break;
            case "Num4":
                _num4 = Number(lvw.rows[ridx][i]);
                break;
            case "Num2":
                _num2 = Number(lvw.rows[ridx][i]);
                break;
            case "Num3":
                _num3 = Number(lvw.rows[ridx][i]);
                break;
            case "Num1":
                _cidx_Num1 = i;
                break;
            case "balanceDirection":
                _direction = lvw.rows[ridx][i];
                break;
        }
    }

    //根据余额方向计算年初余额
    //借方余额：年初余额=期初余额-（本年累计借方发生额-本年累计贷方发生额）
    //贷方余额：年初余额=期初余额-（本年累计贷方发生额-本年累计借方发生额）
    if (_direction == 1) {
        _money1_b = (_money4_b - _money2_b).toFixed(window.SysConfig.MoneyBit) * 1 + _money3_b.toFixed(window.SysConfig.MoneyBit) * 1;
        _money1_y = (_money4_y - _money2_y).toFixed(window.SysConfig.MoneyBit) * 1 + _money3_y.toFixed(window.SysConfig.MoneyBit) * 1;
        _num1 = _num4 - _num2 + _num3;
    } else if (_direction == 2) {
        _money1_b = (_money4_b + _money2_b).toFixed(window.SysConfig.MoneyBit) * 1 - _money3_b.toFixed(window.SysConfig.MoneyBit) * 1;
        _money1_y = (_money4_y + _money2_y).toFixed(window.SysConfig.MoneyBit) * 1 - _money3_y.toFixed(window.SysConfig.MoneyBit) * 1;
        _num1 = _num4 + _num2 - _num3;
    }

    //更新值
    lvw.rows[ridx][_cidx_money1_b] = _money1_b;
    lvw.rows[ridx][_cidx_money1_y] = _money1_y;
    lvw.rows[ridx][_cidx_Num1] = _num1;
}

//汇率变动,重新计算所有值
function updateAllMoneyByHlChanged() {
    var lvw = window["lvw_JsonData_withlvw"];
    var _money4_y = 0;
    var _money2_y = 0;
    var _money3_y = 0;
    var _money1_y = 0;

    //必要数据收集
    if (lvw.rows.length == 0) {
        return;
    }
    for (var i = 0; i < lvw.headers.length; i++) {
        switch (lvw.headers[i].dbname) {
            case "money4_y":
                _money4_y = i;
                break;
            case "money2_y":
                _money2_y = i;
                break;
            case "money3_y":
                _money3_y = i;
                break;
            case "money1_y":
                _money1_y = i;
                break;
        }
    }

    //遍历行
    for (var i = 0; i < lvw.rows.length; i++) {
        updatePartnerVal(lvw.id, i, _money4_y, isNaN(lvw.rows[i][_money4_y]) ? 0 : lvw.rows[i][_money4_y]);
        updatePartnerVal(lvw.id, i, _money2_y, isNaN(lvw.rows[i][_money2_y]) ? 0 : lvw.rows[i][_money2_y]);
        updatePartnerVal(lvw.id, i, _money3_y, isNaN(lvw.rows[i][_money3_y]) ? 0 : lvw.rows[i][_money3_y]);
        updatePartnerVal(lvw.id, i, _money1_y, isNaN(lvw.rows[i][_money1_y]) ? 0 : lvw.rows[i][_money1_y]);
    }

    ___RefreshListViewByJson(lvw_JsonData_withlvw);//刷新树
}

//删除辅助核算项,重新计算父节点值
function afterDeleteAssistFunc(pridx) {
    var lvw = window["lvw_JsonData_withlvw"];
    var _money4_y = 0;
    var _money2_y = 0;
    var _money3_y = 0;
    var _money1_y = 0;
    var _num4 = 0;
    var _num2 = 0;
    var _num3 = 0;
    var _num1 = 0;
    //必要数据收集
    if (lvw.rows.length == 0) {
        return;
    }
    for (var i = 0; i < lvw.headers.length; i++) {
        switch (lvw.headers[i].dbname) {
            case "money4_y":
                _money4_y = i;
                break;
            case "money2_y":
                _money2_y = i;
                break;
            case "money3_y":
                _money3_y = i;
                break;
            case "money1_y":
                _money1_y = i;
                break;
            case "Num4":
                _num4 = i;
                break;
            case "Num2":
                _num2 = i;
                break;
            case "Num3":
                _num3 = i;
                break;
            case "Num1":
                _num1 = i;
                break;
        }
    }
    var _deep = lvw.rows[pridx][lvw.TreeNodeCellIndex].deepData || -1;
    arrRowIndexs = [];
    var _val = getChildrenTatal(lvw, _deep, pridx, _money4_y);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _money4_y, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _money4_y, _val);//根据当前节点的变动同步更新同类型不同币种值

    arrRowIndexs = [];
    _val = getChildrenTatal(lvw, _deep, pridx, _money2_y);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _money2_y, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _money2_y, _val);//根据当前节点的变动同步更新同类型不同币种值

    arrRowIndexs = [];
    _val = getChildrenTatal(lvw, _deep, pridx, _money3_y);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _money3_y, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _money3_y, _val);//根据当前节点的变动同步更新同类型不同币种值

    arrRowIndexs = [];
    _val = getChildrenTatal(lvw, _deep, pridx, _money1_y);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _money1_y, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _money1_y, _val);//根据当前节点的变动同步更新同类型不同币种值

    arrRowIndexs = [];
    var _val = getChildrenTatal(lvw, _deep, pridx, _num4);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _num4, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _num4, _val);//根据当前节点的变动同步更新同类型不同币种值

    arrRowIndexs = [];
    _val = getChildrenTatal(lvw, _deep, pridx, _num2);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _num2, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _num2, _val);//根据当前节点的变动同步更新同类型不同币种值

    arrRowIndexs = [];
    _val = getChildrenTatal(lvw, _deep, pridx, _num3);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _num3, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _num3, _val);//根据当前节点的变动同步更新同类型不同币种值

    arrRowIndexs = [];
    _val = getChildrenTatal(lvw, _deep, pridx, _num1);//遍历子节点,返回子节点合计值
    __lvw_je_updateCellValue(lvw.id, pridx, _num1, _val, true);//给当前节点更新值(值来源:子节点合计)
    updatePartnerVal(lvw.id, pridx, _num1, _val);//根据当前节点的变动同步更新同类型不同币种值
}

//弹框
function BalanceEditClick(subid, ridx, SetCount) {
    var width = SetCount * 100 + 24;
    if (width < 624) { width = 624; }
    var win = app.createWindow("Assists", "辅助核算", { closeButton: true, height: 240, width: width, bgShadow: 30, canMove: 0 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/InitializeAndTerminal/AssistAdd.ashx?ridx=" + ridx + "&subid=" + subid + "' width=\"" + (width - 24) + "\" height=\"208\"> ";
    win.style.overflow = "hidden";
}

window.ListViewSetRow = function (title, ridx, astsbs, astids, unit, numscheck) {
    var lvw = window["lvw_JsonData_withlvw"];
    var cellindex = lvw.TreeNodeCellIndex;
    var deep = lvw.rows[ridx][cellindex].deepData || -1;
    __lvw_tn_insertNewTreeNode(lvw, ridx, cellindex, lvw.id, "newText");//添加子节点

    var lastridx = getLastChildrenRidx(lvw, deep, ridx);
    title = title.replace(/re_ridx/, lastridx);
    updateRow(lvw, lastridx, title, astsbs, astids, ridx, unit, numscheck);

}

//获取最后一个子节点
function getLastChildrenRidx(lvw, deep, ridx) {
    var childDeep = 0;
    var childridx = 0;
    for (var i = ridx + 1; i < lvw.rows.length; i++) {
        if (childDeep == 0) {
            childDeep = lvw.rows[i][lvw.TreeNodeCellIndex].deepData || -1;//记录子节点的deepData(只取第一个,用来后边做判断)
            childridx = i;
        }

        if ((lvw.rows[i][lvw.TreeNodeCellIndex].deepData || -1) == deep) {//找到同级别节点,结束循环
            break;
        }

        if ((lvw.rows[i][lvw.TreeNodeCellIndex].deepData || -1) == childDeep) {//是正常的子节点,记录行号
            childridx = i;
        }
    }
    return childridx;//返回最后一次记录的子节点行号
}

window.deleteRow = function (ridx) {
    var lvw = window["lvw_JsonData_withlvw"];
    var cidx = lvw.TreeNodeCellIndex;
    if (confirm("确认要删除节点吗？")) {
        var _thisDeep = lvw.rows[ridx][lvw.TreeNodeCellIndex].deepData || -1;
        __lvw_tn_delOldTreeNode(lvw, ridx, cidx);
        var obj = __lvw_tn_computeTreeNodeDeepDate(lvw, ridx, cidx);
        __lvw_tn_SortNodesDeep(obj, "", obj, lvw, cidx);
        ___RefreshListViewByJson(lvw);//刷新树
        for (var i = ridx - 1; i > -1; i--) {//当前行向上一直找到父节点
            var _deep = lvw.rows[i][lvw.TreeNodeCellIndex].deepData || -1;
            if (_deep >= _thisDeep) {//大于等于当前节点Deep值的全部跳过,一直到找到比当前节点Deep值低的节点
                continue;
            }
            _thisDeep = _deep;
            afterDeleteAssistFunc(i);
        }
        ___RefreshListViewByJson(lvw);//刷新树
    }
}

window.RefreshListView = function () {
    var lvw = window["lvw_JsonData_withlvw"];
    ___RefreshListViewByJson(lvw);//刷新树
    app.closeWindow('Assists');
}

window.updateRow = function (lvw, ridx, title, astsbs, astids, prdix, unit, numscheck) {
    var _row = lvw.rows[ridx];//找到当前行的row对象

    var _idx_indexcol = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "@indexcol") _idx_indexcol = i; break;
    }

    for (var i = 0; i < lvw.headers.length; i++) {
        switch (lvw.headers[i].dbname) {
            case "balanceDirection": lvw.rows[ridx][i] = lvw.rows[prdix][i]; break;
            case "showBalanceDirection": lvw.rows[ridx][i] = lvw.rows[prdix][i]; break;
            case "bz": lvw.rows[ridx][i] = lvw.rows[prdix][i]; break;
            case "path": lvw.rows[ridx][i] = lvw.rows[prdix][i]; break;
            case "AssistSubject": lvw.rows[ridx][i] = astsbs; break;
            case "AssistID": lvw.rows[ridx][i] = astids; break;
            case "index": lvw.rows[ridx][i] = lvw.rows[prdix][_idx_indexcol]; break;
            case "@indexcol": lvw.rows[ridx][i] = ridx; break;
            case "Unit": lvw.rows[ridx][i] = unit; break;
            case "NumsCheck": lvw.rows[ridx][i] = numscheck; break;
        }

    }
    cidx = lvw.TreeNodeCellIndex;
    var obj = lvw.rows[ridx][cidx];
    obj.text = title;
    obj.count = 0;

    var obj = __lvw_tn_computeTreeNodeDeepDate(lvw, ridx, cidx);
    __lvw_tn_SortNodesDeep(obj, "", obj, lvw, cidx);
}



function lvw_input_keyDown() {
    var keycode = window.event.keyCode
    if (keycode == 38 || keycode == 40) {
        var inputbox = window.event.target || window.event.srcElement;
        var id = $(inputbox).attr("id")
        var idArr = id.split("_");
        if (keycode == 38) idArr[3] = Number(idArr[3]) - 1;
        else idArr[3] = Number(idArr[3]) + 1;
        id = idArr.join("_");
        setTimeout(function () {
            lvw_tbodybg_withlvw_change(inputbox);
            if ($ID(id)) $ID(id).focus();
        }, 100);
    }
    if (keycode != 13) return;

    var inputbox = window.event.target || window.event.srcElement;
    var sv = inputbox.id.split("_");
    var rowindex = sv[sv.length - 3];
    var cellindex = sv[sv.length - 2];
    var lvwid = sv[0].replace("@", "");
    var lvw = window["lvw_JsonData_" + lvwid];

    var dbname = lvw.headers[cellindex].dbname;
    var dbnames = ["money4_y", "money4_b", "money2_y", "money2_b", "money3_y", "money3_b", "Num4", "Num2", "Num3"];
    var dbindex = [0, 0, 0, 0, 0, 0];
    var thisindex = dbnames.indexOf(dbname);

    var header = null;
    for (var i = 0; i < dbnames.length; i++) {
        for (var ii = 0; ii < lvw.headers.length; ii++) {
            header = lvw.headers[ii];
            if (header.dbname == dbnames[i]) {
                dbindex[i] = header.index;
                break;
            }
        }
    }

    if (dbnames.length - 1 == thisindex) {
        thisindex = 0;
        rowindex++;
    }
    else {
        thisindex++;
    }

    var display = "editable";

    for (var i = thisindex; i < dbnames.length; i++) {
        display = lvw.headers[dbindex[thisindex]].display;
        var thisObj = $ID("@" + lvwid + "_" + dbnames[thisindex] + "_" + rowindex + "_" + dbindex[thisindex] + "_0")
        if (thisObj && thisObj.type == "hidden") {
            rowindex++;
            i--;
            continue;
        }

        if (display == "editable") break;

        if (dbnames.length - 1 == thisindex) {
            thisindex = 0;
            i = 0;
            rowindex++;
        }
        else {
            thisindex++;
        }

    }

    if (rowindex == lvw.rows.length && thisindex == 0) return;
    this.blur();
    $ID("@" + lvwid + "_" + dbnames[thisindex] + "_" + rowindex + "_" + dbindex[thisindex] + "_0").focus();
    $ID("@" + lvwid + "_" + dbnames[thisindex] + "_" + rowindex + "_" + dbindex[thisindex] + "_0").select();
}