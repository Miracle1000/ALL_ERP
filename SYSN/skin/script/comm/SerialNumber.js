var lvw_JsonData_lvw_Datas = [];
var billSerialNumberRuleEnum = [
    { key: 0, value: '手动选择' },
    { key: 1, value: '手动录入' },
    { key: 2, value: '自动生成' },
    { key: 3, value: '自动匹配' }
]

$(function () {
    //手动选择绑定事件
    $("#btn_lvw1").click(function () {
        linkType1_PushOrRemove(true);
    });

    $("#btn_lvw2").click(function () {
        if (confirm("是否确认删除"))
            linkType1_PushOrRemove(false);
    });

    //手动录入绑定事件
    $("#push").click(function () {
        linkType2_PushClick();
    });

    $("#reset").click(function () {
        $("#pushArea_0").val("");
    });

    $("#clear").click(function () {
        $("#serialNumber").val("");
        $("#showNumber").html("");
        $("#group_title_base span").eq(2).html("已选择：0");
    });

    $("#search1").click(function () {
        var key = $("#serialNumber1_0").val();
        linkType1_SearchBySeriNum(lvw_JsonData_lvw1, key);
    });

    $("#search2").click(function () {
        var key = $("#serialNumber2_0").val();
        linkType1_SearchBySeriNum(lvw_JsonData_lvw2, key);
    });

    $("#empty").click(function () {
        if (confirm("是否确认清空"))
            linkType1_ClearAll();
    });

    if (window && window.lvw_JsonData_lvw1) {//页面渲染完毕备份listView的rows,以便后续的加入和删除
        var rightbox = {};
        for (var i = 0; i < lvw_JsonData_lvw2.rows.length; i++)
        {
            rightbox[lvw_JsonData_lvw2.rows[i][3]] = 1;
        }
        for (var i = 0; i < lvw_JsonData_lvw1.rows.length; i++) {
            var mrow = lvw_JsonData_lvw1.rows[i];
            var used = rightbox[lvw_JsonData_lvw1.rows[i][3]] == 1;
            lvw_JsonData_lvw_Datas.push({ 'row': app.CloneObject(mrow, 2), 'used': used, 'searched': true });
        }
        //自动调整两个listView高度统一
        linkType1_AutoListViewHeight();
    }

    $("#sure_btn").click(function () {
        var tempv = $("#linkType_div :radio:checked").attr("onclick");
        var rule = tempv.substr(tempv.length - 2, 1);
        var datas = { 'CreateType': rule, 'IDs': null, 'SerialNumbers': null, 'RuleID': null, 'Num': 0, 'IsInherit': false, 'InheritBillType': null, 'InheritlistType': "0", 'InheritBillIDs': '0', 'InheritListIDs': '0' };
        if (window && window.datasFromServer) {
            var vdatas = JSON.parse(window.datasFromServer);
            datas.IsInherit = vdatas.IsInherit;
            datas.InheritBillType = vdatas.InheritBillType;
            datas.InheritlistType = vdatas.InheritlistType;
            datas.InheritBillIDs = vdatas.InheritBillIDs;
            datas.InheritListIDs = vdatas.InheritListIDs;
        }
        switch (rule) {
            case '1': datas = getDatas_rule1(datas); break;
            case '2': datas = getDatas_rule2(datas); break;
            case '3': datas = getDatas_rule3(datas); break;
            case '4': datas = getDatas_rule4(datas); break;
        }

        if (!datas)
            return false;
        var id = dbname.replace(/\@/g, '\\\@');

        var _this = window.parent.$("#" + id);
        var islvw = _this.parent().parent().attr("islvw");
        var disEdit = true;
        var v
        $.each(billSerialNumberRuleEnum, function (inx) {
            var item = billSerialNumberRuleEnum[inx];
            if (item.key + 1 == datas.CreateType)
                if (item.key == 1) {
                    v = datas.SerialNumbers == null ? "" : datas.SerialNumbers.lastIndexOf(',') > 0 ? datas.SerialNumbers.substring(datas.SerialNumbers.lastIndexOf(',') + 1) : datas.SerialNumbers.toString();
                    disEdit = false;
                } else {
                    v = item.value;
                }
        });

        if (islvw) {
            var dt = _this.parents("td").eq(0);
            var tr = _this.parents("tr").eq(0);
            var rowindex = tr.attr('pos');
            var cellindex = dt.attr('dbcolindex');

            window.parent.__lvw_je_updateCellValue(dt.attr('lvw_id'), rowindex, cellindex, "__json:" + app.GetJSON(datas), false);
        } else {
            var _this_show = window.parent.$("#" + id + "_0");
            _this_show.val(v);
            _this.val(JSON.stringify(datas));
            var img = _this.siblings("img[name='serial']");
            var imgs = img.attr("onclick").split(',');

            var inx_this = 27;//默认下标
            var inx = 30;//默认下标
            for (var i = 0; i < imgs.length; i++) {
                if (imgs[i].indexOf('$(this)') == 0) {
                    inx_this = i
                    continue;
                }
                if (imgs[i].indexOf('{"CreateType":') == 0) {
                    inx = i;
                    break;
                }
            }
            imgs[inx_this + 1] = datas.CreateType;
            imgs[inx_this + 3] = datas.Num ? '"' + datas.Num + '"' : '"0"';
            imgs.splice(inx, imgs.length - inx);//删除最后的Json字符串

            //重新追加Json字符串
            imgs.push('{"CreateType":' + datas.CreateType);
            imgs.push(datas.IDs ? '"IDs":"' + datas.IDs + '"' : '"IDs":' + datas.IDs);
            imgs.push(datas.SerialNumbers ? '"SerialNumbers":"' + datas.SerialNumbers + '"' : '"SerialNumbers":' + datas.SerialNumbers);
            imgs.push('"RuleID":' + datas.RuleID);
            imgs.push('"Num":' + datas.Num + '})');
            img.attr("onclick", imgs.join(','));

            var usedCount = datas.Num | 0;
            var bl = (needCount == 0 ? 0 : usedCount / needCount) * 100;
            var bl_floor = bl - (bl % 10);
            img.attr("src", parent.getImgSrc(bl_floor));

            if (disEdit) {
                _this_show.attr("readonly", "true");
            }
            window.parent.Bill.SerialNumberDatas = datas;
        }
        //刷新桶 是否刷新数量
        if (window.parent.NoNeedRefreshNum != true) {
            var countObjs = window.parent.$("[name*='" + window.parent.temptypejson.countdbname + "']");
            for (var i = 0; i < countObjs.length; i++) {
                if (countObjs[i].value != "" && !isNaN(countObjs[i].value)) {
                    //window.parent.$(countObjs[i]).change();
                    window.parent.app.FireEvent(countObjs[i], "onchange");
                }
            }
        }
        //关闭窗口
        closeWindow(window);
    });

    ShowDefaultValue();
});

ShowDefaultValue = function () {
    if (!(window && window.datasFromServer)) return;
    var datas = JSON.parse(datasFromServer);
    $(':radio[onclick$="' + CreateType + '\'"]').attr("checked", "checked")
    switch (parseInt(CreateType)) {
        case 1:
            if (!datas.IDs) break;
            var ids = datas.IDs.split(',');
            var lvw = lvw_JsonData_lvw1;
            var headers = lvw.headers;
            var rows = lvw.rows;
            var inx_selcol = 0;
            var inx_id = 0;
            for (var i = 0; i < headers.length; i++) {
                if (headers[i].dbname == '@allselectcol') {
                    inx_selcol = i;
                    continue;
                }
                if (headers[i].dbname == 'id') {
                    inx_id = i;
                    continue;
                }
            }
            for (var i = 0; i < rows.length; i++) {
                if (ids.indexOf(rows[i][inx_id]) > -1)
                    rows[i][inx_selcol] = "1";
            }
            $("#btn_lvw1").trigger("click");
            break;
        case 2:
            var serialNumbers = datas.SerialNumbers;
            if (serialNumbers == null) break;
            serialNumbers = serialNumbers.toString().replace(/,/g, '\n');
            $("#pushArea_0").val(serialNumbers);
            $("#push").trigger("click");
            break;
        case 3:
            var ruleid = datas.RuleID;
            var option = $("#Rules_0 option[value='" + ruleid + "']");
            option.attr('selected', true);
            $(".select_dom").text(option.text());
            break;
    }

}

closeWindow = function (window) {
    if (window.$(".createWindow_closeBtn").length == 0)
        closeWindow(window.parent);
    else
        window.$(".createWindow_closeBtn").trigger('click');
};

//获取手动选择数据
getDatas_rule1 = function (datas) {
    $("#serialNumber2_0").val("");
    $("#search2").trigger("click");
    var lvw = lvw_JsonData_lvw2;
    var rows = lvw.rows;
    var headers = lvw.headers;
    var inx_id = null;
    var inx_seriNum = null;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname.toLowerCase() == 'id')
            inx_id = i;
        if (headers[i].dbname.toLowerCase() == 'serinum')
            inx_seriNum = i;
    }

    if (rows.length == 0) return datas;

    var ids = "";
    var seriNums = "";
    for (var i = 0; i < rows.length; i++) {
        ids += rows[i][inx_id] + ",";
        seriNums += rows[i][inx_seriNum] + ",";
    }

    datas.IDs = ids.substr(0, ids.length - 1);
    datas.SerialNumbers = seriNums.substr(0, seriNums.length - 1);
    datas.Num = rows.length;
    return datas;
}

//获取手动录入数据
getDatas_rule2 = function (datas) {
    var seriNums = $("#serialNumber").val();
    if (seriNums == "") seriNums = null;
    datas.SerialNumbers = seriNums;
    datas.Num = seriNums == null ? 0 : seriNums.split(',').length;
    return datas;
}

//自动生成
getDatas_rule3 = function (datas) {
    var obj = $("#Rules_0");
    if (obj.val() == "") {
        alert("请先选择规则");
        return false;
    }
    datas.RuleID = obj.val();
    datas.Num = (window && window.needCount) ? parseInt(window.needCount) : 0;
    return datas;
}

//自动匹配
getDatas_rule4 = function (datas) {
    var obj = $("#CanUseCnt_0");
    var objValue = obj.val().replace(/\,/g, "");

    datas.Num = parseInt(objValue) > needCount ? needCount : parseInt(objValue);
    return datas;
}



/*手动选择视图相关函数↓*/
window.addSpecBtnForLvwBtmTool = function (lvw) {
    return "<div class='lvw_btmtoolbtn'><button class='zb-button' id='btn_" + lvw.id + "' type='button' >" + (lvw.id == 'lvw1' ? '批量加入' : '批量删除') + "</button></div>"
}

//批量加入/批量删除
//isPush: true 为"批量加入"操作;false 为"批量删除"操作
linkType1_PushOrRemove = function (isPush) {
    var rows = isPush ? lvw_JsonData_lvw1.rows : lvw_JsonData_lvw2.rows;
    var headers = isPush ? lvw_JsonData_lvw1.headers : lvw_JsonData_lvw2.headers;

    var inx_allselectcol = null;
    var inx_seriNum = null;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname == '@allselectcol')
            inx_allselectcol = i;
        if (headers[i].dbname.toLowerCase() == 'id')
            inx_seriNum = i;
    }

    if (inx_allselectcol && inx_seriNum) {
        var row = null;
        var flag = "";
        for (var i = 0; i < rows.length; i++) {
            row = rows[i];
            //未选中的行直接跳过
            if (row[inx_allselectcol] == 0) { continue; }

            //选中行设置used为true
            flag = linkType1_UpdateUsedStatus(row, inx_seriNum, isPush);
            if (flag != true) {
                if (flag.length > 0) {
                    alert(flag);
                    break;
                }
            }
        }
        linkType1_RefreshListView();  //刷新ListView
        //if (flag == "") alert("您没有选择任何内容，请选择后再操作！");
    }

    //加入或删除操作后重置筛选状态
    $("#search1").trigger("click");
    $("#search2").trigger("click");
}

//单个加入/单个删除
linkType1_SinglePush = function (isPush, _this) {
    var rows = isPush ? lvw_JsonData_lvw1.rows : lvw_JsonData_lvw2.rows;
    var headers = isPush ? lvw_JsonData_lvw1.headers : lvw_JsonData_lvw2.headers;
    var rowindex = _this.parents("tr").eq(0).attr("pos");

    var inx_seriNum = null;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname.toLowerCase() == 'id')
            inx_seriNum = i;
    }

    if (inx_seriNum) {
        var row = null;
        var flag = "";
        row = rows[rowindex];

        //选中行设置used为true
        flag = linkType1_UpdateUsedStatus(row, inx_seriNum, isPush);
        if (flag != true) {
            if (flag.length > 0) {
                alert(flag);
                return;
            }
        }
        //刷新ListView
        linkType1_RefreshListView();
    }
}

//操作选中行使用状态
//row:操作比较对象,index: 对象中用来比较列的下标,isUsed:即将改成的结果
linkType1_UpdateUsedStatus = function (row, index, isUsed) {
    if (!lvw_JsonData_lvw_Datas) {
        return "未找到表格对象";
    }
    var cnt = 0;
    for (var i = 0; i < lvw_JsonData_lvw_Datas.length; i++) {
        if (lvw_JsonData_lvw_Datas[i].used == isUsed)
            cnt++;
    }

    if (isUsed && cnt == needCount) return "已加入足够序列号";

    for (var i = 0; i < lvw_JsonData_lvw_Datas.length; i++) {
        if (lvw_JsonData_lvw_Datas[i].row[index] == row[index])
            lvw_JsonData_lvw_Datas[i].used = isUsed;
    }

    $("#group_title_base span").eq(2).html("已选择：" + (isUsed ? cnt + 1 : lvw_JsonData_lvw_Datas.length - cnt - 1));

    return true;
}

//检索
linkType1_SearchBySeriNum = function (lvw, key) {
    var headers = lvw.headers;

    var inx_seriNum = null;
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].dbname.toLowerCase() == 'serinum') {
            inx_seriNum = i;
            break;
        }
    }
    //用于判断检索哪个ListView
    var used = lvw.id == 'lvw2';
    key = $.trim(key);
    //是否有效检索
    var isSearch = key.length > 0;
    var isHas = false;
    for (var i = 0; i < lvw_JsonData_lvw_Datas.length; i++) {
        //如果非有效检索,则全部设置为检索状态(出全部数据)
        if (!isSearch && lvw_JsonData_lvw_Datas[i].used == used) {
            lvw_JsonData_lvw_Datas[i].searched = true;
            continue;
        }

        if (lvw_JsonData_lvw_Datas[i].used == used) {
            if (lvw_JsonData_lvw_Datas[i].row[inx_seriNum].indexOf(key) > -1) {
                lvw_JsonData_lvw_Datas[i].searched = true;
                isHas = true;
                continue;
            }
            lvw_JsonData_lvw_Datas[i].searched = false;
        }
    }

    if (isSearch && !isHas) {
        for (var i = 0; i < lvw_JsonData_lvw_Datas.length; i++) {
            if (lvw_JsonData_lvw_Datas[i].used == used) {
                //如果未检索到相应数据,则全部设置为未检索状态(无数据)
                lvw_JsonData_lvw_Datas[i].searched = false;
            }
        }
    }

    //刷新ListView
    linkType1_RefreshListView();
}

//一键清空
linkType1_ClearAll = function () {
    for (var i = 0; i < lvw_JsonData_lvw_Datas.length; i++) {
        if (lvw_JsonData_lvw_Datas[i].used) {
            lvw_JsonData_lvw_Datas[i].used = false;
        }
    }

    //刷新列表
    linkType1_RefreshListView();
    $("#group_title_base span").eq(2).html("已选择：0");

    //加入或删除操作后重置筛选状态
    $("#search1").trigger("click");
    $("#search2").trigger("click");
}

//刷新ListView
linkType1_RefreshListView = function () {
    var rows_lvw1 = [];
    var rows_lvw2 = [];
    for (var i = 0; i < lvw_JsonData_lvw_Datas.length; i++) {
        var item = lvw_JsonData_lvw_Datas[i];
        if (!item.searched) continue;

        var pusher = app.CloneObject(item.row, 2);
        if (item.used)
            rows_lvw2.push(pusher);
        else
            rows_lvw1.push(pusher);
    }

    //if (rows_lvw1.length > 0 || rows_lvw2.length > 0) {
    lvw_JsonData_lvw1.rows = rows_lvw1;
    lvw_JsonData_lvw2.rows = rows_lvw2;

    ___RefreshListViewByJson(lvw_JsonData_lvw1);
    ___RefreshListViewByJson(lvw_JsonData_lvw2);

    //自动调整两个listView高度统一
    linkType1_AutoListViewHeight();
    //}
}

//自动调整两个listView外部标签高度统一(目的使外部td高度统一,listView靠上)
linkType1_AutoListViewHeight = function () {
    var lvw1 = $("#lvw_lvw1").parent().parent();
    var lvw2 = $("#lvw_lvw2").parent().parent();

    if (lvw1 && lvw2) {
        var height_lvw1 = lvw1.css("height");
        var height_lvw2 = lvw2.css("height");

        if (height_lvw1 > height_lvw2) {
            lvw2.css("height", height_lvw1);
            return;
        }
        lvw1.css("height", height_lvw2);
    }
}

/*手动选择视图相关函数↑*/



/*手动选择视图相关函数↓*/
//手动录入内容加入右侧
var linkType2_PushClick = function () {
    var serialNumber = $("#serialNumber").val();
    var text = $("#pushArea_0").val();
    if (!text) {
        alert("请先输入要加入的序列号!");
        return;
    }
    var _list = serialNumber ? serialNumber.split(",") : [];//全部序列号集合
    var _thisList = text.split("\n");//本次即将加入的集合
    for (var i = 0; i < _thisList.length; i++) {
        if (_thisList[i]+""==''){_thisList.splice(i, 1);i--}    
    }
    //去重合并
    for (var i = 0; i < _thisList.length; i++) {
        if ($.inArray(_thisList[i], _list) < 0) {
            if (_list.length == needCount) {
                alert("已加入足够序列号");
                return;
            }
            _list.push(_thisList[i]);
        }
    }

    var cnt = 0;
    if (_list.length > 0) {
        $("#serialNumber").val(_list.join(','));
        var _div = $("#showNumber");
        _div.html("");
        for (var i = 0; i < _list.length; i++) {
            if (_list[i] == '')
                continue;
            cnt++;
            _div.append('<li style="width:100px;position:relative" onmouseover="linkType2_li_Del_show($(this))" onmouseout="linkType2_li_Del_hide($(this))" title="'+ _list[i] +'"><img style="width:10px; right:1px; top:1px; color:red; display:none; position:absolute;" onclick="linkType2_li_Del($(this),\'' + _list[i] + '\')" title="删除" src="' + window.SysConfig.VirPath + 'SYSN/skin/default/img/delete.jpg">' + _list[i] + '</div>');
        }
    }
    $("#group_title_base span").eq(2).html("已选择：" + cnt);

    $("#pushArea_0").val("");
}
//移除某个已加入的序列号
linkType2_li_Del = function (_this, number) {
    _this.parent("li").remove();

    var serialNumber = $("#serialNumber").val();
    var _list = serialNumber ? serialNumber.split(",") : [];//全部序列号集合

    var index = _list.indexOf(number);
    if (index > -1) {
        _list.splice(index, 1);
    }
    $("#group_title_base span").eq(2).html("已选择：" + _list.length);
    $("#serialNumber").val(_list.join(','));
}

//显示删除
linkType2_li_Del_show = function (_this) {
    _this.children("img").show();
}

//隐藏删除
linkType2_li_Del_hide = function (_this) {
    _this.children("img").hide();
}

/*手动选择视图相关函数↑*/
