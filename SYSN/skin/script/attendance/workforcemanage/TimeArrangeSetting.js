$(function () {
    //绑定计时班次事件
    $(document).on("change",
        ":checkbox[name*='ReckonByTime']",
        function () {
            var $this = $(this);
            //触发事件的group上listindex属性值
            var listindex = $this.parents("tr[listindex]").attr("listindex");
            onReckonByTimeClick(listindex, $this);
        });

    //绑定弹性打卡事件
    $(document).on("change",
        ":checkbox[name*='IsOpenElastic']",
        function () {
            var listindex = $(this).parents("tr[listindex]").attr("listindex");
            var ruleLateDoc = $("tr[listindex='" + listindex + "'] div[dbname*='RuleLateMinute']");
            var RuleLeaveEarlyDoc = $("tr[listindex='" + listindex + "'] div[dbname*='RuleLeaveEarlyMinute']");

            var tds = $(this).parents("td").first().siblings();
            if ($(this).prop("checked") && confirm("确认启用吗？\r确认后已设置的【规则约束】将被取消,两种规则只能选择一种")) {
                tds.show();
                ruleLateDoc.parent().hide();
                RuleLeaveEarlyDoc.parent().hide();
                return;
            }
            $(this).prop("checked", false);
            tds.hide();
            ruleLateDoc.parent().show();
            RuleLeaveEarlyDoc.parent().show();
        });

    //绑定下班晚走变动事件
    $(document).on("change",
        ":radio[name*='DelayedForOffWork']",
        function () {
            var val = $(this).val();
            var trs = $(this).parents("tr").first().siblings();
            trs.hide();
            if (val == 3)
                return;
            trs.eq(val - 1).show();

            if (val == 1) {
                //触发事件的group上listindex属性值
                var listindex = $(this).parents("tr[listindex]").attr("listindex");
                var tableName = $("tr[listindex=" + listindex + "] .listview[id*='lvw_delayedRules']").prop("id").substring(4);
                var lvw = ListView.GetListViewById(tableName);
                if (lvw.rows.length == 0) {
                    var newRow = [
                        0,
                        "<div type='button' onclick='__lvw_je_addNew(\"delayedRules\")' class='fieldadd'></div>", "规则",
                        1,
                        1
                    ];
                    lvw.rows.push(newRow);

                    setTimeout(function () {
                        ___RefreshListViewByJson(lvw);
                    }, 200)

                }
            }
        });

    //绑定按1:N调休是否开启变动事件
    $(document).on("change",
        ":checkbox[name*='IsOpenOneByN']",
        function () {
            var val = $(this).val();
            var tr = $(this).parents("tr").first().next();
            if ($(this).prop("checked")) {
                tr.show();
                return;
            }
            tr.hide();
        });
    //绑定调休作废点击事件
    $(document).on("click",
        "[name^='Abolish']:radio",
        function () {
            var radios = $(this).parents("tr").first().find("[name^='Abolish']:radio");
            radios.prop("checked", false);
            $(this).prop("checked", true);
        });

    var maxIndex = $("tr[listindex]").last().attr("listindex");
    showOrHideHandler(maxIndex);
    //处理"添加"group的按钮增加批量处理字段显示
    $("a[onclick='Bill.addListGroup(\"pb_1\")']").attr("onclick",
        "Bill.addListGroup(\"pb_1\");showOrHideHandler($(\"tr[listindex]\").last().attr(\"listindex\"))");

    //本页面无需要录入负值的数字框,所以把负值或非数字处理为0
    $(document).on("change",
        ":input[uitype=\"intbox\"],:input[uitype=\"numberbox\"]",
        function () {
            if (isNaN($(this).val()) || $(this).val() < 0)
                $(this).val("0");
        });

});

//根据group的listindex处理其中多个字段的显示与否
var onReckonByTimeClick = function (_listindex, _this) {
    if (!_this)
        _this = $("tr[listindex='" + _listindex + "'] :checkbox[name*='ReckonByTime']");

    var isChecked = _this.prop("checked");

    if (Bill.Data.uistate == "details")
        isChecked = $("tr[listindex='" + _listindex + "'] div[dbname='ReckonByTime'] :hidden").val() == "1";

    $("tr[listindex='" + _listindex + "']").find("td").first().prop("rowspan", isChecked ? "2" : "6");

    objShowOrHide($("td[dbname='ReckonHtml']").parents("tr[listindex='" + _listindex + "']"), isChecked);//计时班次
    objShowOrHide($("td[dbname*='ClockDetail']").parents("tr[listindex='" + _listindex + "']"), !isChecked);//规则约束
    objShowOrHide($("td[dbname='RuleHtml']").parents("tr[listindex='" + _listindex + "']"), !isChecked);//规则约束
    objShowOrHide($("td[dbname='ElasticHtml']").parents("tr[listindex='" + _listindex + "']"), !isChecked);//弹性打卡
    objShowOrHide($("td[dbname='DelayedHtml']").parents("tr[listindex='" + _listindex + "']"), !isChecked);//下班晚走
    objShowOrHide($("td[dbname='AbsenteeismHtml']").parents("tr[listindex='" + _listindex + "']"), !isChecked);//严重旷工
    objShowOrHide($("td[dbname='HowLongHtml']").parents("tr[listindex='" + _listindex + "']"), !isChecked);//工作总时长
};

var objShowOrHide = function (_obj, _isShow) {
    if (_isShow) {
        _obj.show();
        return;
    }

    _obj.hide();
}

//批量处理group中各字段的显示与否
var showOrHideHandler = function (cnt) {
    var lvw = null;
    for (var i = 1; i <= cnt; i++) {
        onReckonByTimeClick(i);
        hideOrShowElasticHtml(i, null, true);
        //setNeedClockCheckedAndDisabled(i);
    }
    $(".lvw_nulldata_addbtn_txt").text("添加打卡时段");
}

//根据打卡时段行数判断是否隐藏/显示弹性打卡
//页面加载时调用只有可能显示的情况下隐藏弹性打卡,所以_canadd传false
//页面动态隐藏显示时候_canadd传true
var hideOrShowElasticHtml = function (_listindex, _lvw, _canadd) {
    if (!_lvw) {
        _lvw = Bill.GetListViewFromCollectionGroup("pb", _listindex, "ClockDetail");
    }
    //详情模式下最少行数为1行,添加/修改/复制模式下因为存在"添加行"所以多一行
    var rowMinCnt = Bill.Data.uistate == "details" ? 1 : 2;
    var isShowElasticHtml = _lvw.rows.length <= rowMinCnt;
    var elasticHtmlNode = $("td[dbname='ElasticHtml']").parents("tr[listindex='" + _listindex + "']");
    var elasticHtmlNodeIsHide = elasticHtmlNode.is(':hidden')
    var isChecked = $("tr[listindex='" + _listindex + "'] :checkbox[name*='ReckonByTime']").prop("checked");
    if (Bill.Data.uistate == "details")
        isChecked = $("tr[listindex='" + _listindex + "'] div[dbname='ReckonByTime'] :hidden").val() == "1";
    objShowOrHide(elasticHtmlNode, isShowElasticHtml && !isChecked);//弹性打卡
    //lvw中只有一条数据时候要隐藏/显示弹性打卡字段,所以调整前一列合并字段的rowspan值
    var groupNum = $("tr[listindex='" + _listindex + "']").find("td").first();
    var groupNumRowSpan = groupNum.prop("rowspan");

    //弹性打卡原本隐藏,本次显示,则rowSpan+1
    if (elasticHtmlNodeIsHide && isShowElasticHtml && !isChecked)
        groupNum.prop("rowspan", groupNumRowSpan + 1)
        //弹性打卡原本显示,本次隐藏,则rowSpan-1
    else if (!elasticHtmlNodeIsHide && !isShowElasticHtml && !isChecked)
        groupNum.prop("rowspan", groupNumRowSpan - 1)

    //groupNum.prop("rowspan", groupNum.prop("rowspan") + 1 * (_lvw.rows.length == rowMinCnt ? (_canadd ? 1 : (isChecked ? 1 : 0)) : (_lvw.rows.length == 1 + rowMinCnt ? -1 : 0)));
}

//设置第一个是否打卡选中且不可修改
var setNeedClockCheckedAndDisabled = function (_listindex) {
    var _lvw = Bill.GetListViewFromCollectionGroup("pb", _listindex, "ClockDetail");

    var index = -1;
    for (var i = 0; i < _lvw.headers.length; i++) {
        if (_lvw.headers[i].dbname == 'StartNeedClock') {
            index = i;
            break;
        }
    }
    if (index >= 0 && _lvw.rows.length > 0)
        _lvw.rows[0][index] = 1

    $("tr[listindex='" + _listindex + "'] :checkbox[ftext='打卡']").eq(0).prop('checked', true);
    $("tr[listindex='" + _listindex + "'] :checkbox[ftext='打卡']").eq(0).prop('disabled', 'disabled');
}

/*
 * 工作时长运算
 * signIn:签到时间
 * signOut:签退时间
 * signInTomorrow:签到跨天
 * signOutTomorrow:签退跨天
 * rest:中午休息时间
 */
var whenlongFormula = function (signIn, signOut, signInTomorrow, signOutTomorrow, rest, rowNumber) {
    signIn = signIn.toString();
    signOut = signOut.toString();
    signInTomorrow = signInTomorrow.toString();
    signOutTomorrow = signOutTomorrow.toString();
    rest = rest.toString();
    if (signIn == 0 || signOut == 0)
        return "0";

    if (signIn.indexOf(':') == -1 || signOut.indexOf(':') == -1)
        return "0";

    var defaultYear = 2020;
    var defaultMonth = 03;
    var defaultDay = 10;

    signIn = new Date(defaultYear.toString() + '/' + defaultMonth.toString() + '/' + (defaultDay + signInTomorrow).toString() + ' ' + signIn);
    signOut = new Date(defaultYear.toString() + '/' + defaultMonth.toString() + '/' + (defaultDay + signOutTomorrow).toString() + ' ' + signOut);
    var totalTime = signOut - signIn;
    if (totalTime > 0) {
        var days =  Math.floor(totalTime / (24 * 3600 * 1000))
        var leave1 = totalTime % (24 * 3600 * 1000); //计算天数后剩余的毫秒数  
        var hours = days * 24 + leave1 / (3600 * 1000);
    }

    var restArr = null;
    var rest1 = '';
    var rest2 = '';
    if ((""+rest).indexOf(',') > -1 && rowNumber == 0) {
        restArr = rest.split(',');
        if (restArr.length == 2) {
            rest1 = restArr[0];
            rest2 = restArr[1];
        }

        if (rest1.indexOf(':') > -1 && rest2.indexOf(':') > -1) {
            rest1 = new Date(defaultYear.toString() + '/' + defaultMonth.toString() + '/' + defaultDay.toString() + ' ' + rest1);
            rest2 = new Date(defaultYear.toString() + '/' + defaultMonth.toString() + '/' + (defaultDay + signOutTomorrow).toString() + ' ' + rest2);
            totalTime = rest2 - rest1;
            if (totalTime > 0 && signOut > rest1) {
                leave1 = totalTime % (24 * 3600 * 1000); //计算天数后剩余的毫秒数  
                hours = hours -leave1 / (3600 * 1000);
            }
        }
    }
    return hours;
}

window.onListViewRowAfterDelete = function (lvw, pos) {
    var listindex = 1;
    if (lvw.id.indexOf('____bgl___') > -1)
        listindex = $(".listview[id*='" + lvw.id + "']").parents("tr[listindex]").first().attr("listindex");
    if (lvw.rows.length <= (Bill.Data.uistate == "details" ? 1 : 2)) {
        lvw.rows[0][7] = '12:00:00,13:00:00';
        lvw.headers[7].value = '12:00:00,13:00:00';
        ListView.SetColsVisible(lvw.id, "Rest", true);
    }
    hideOrShowElasticHtml(listindex, lvw, true);
    //setNeedClockCheckedAndDisabled(listindex);
    $(".lvw_nulldata_addbtn_txt").text("添加打卡时段");
    setTimeout(function () { FormualLib.HandleFieldFormul(1, '上班签到', { 'lvw': lvw, 'updateCols': [10, 6, 14], 'rowindex': [0] }); }, 30);
}
window.onListViewRowAfterAdd = function (lvw, pos) {
    var listindex = 1;
    if (lvw.id.indexOf('____bgl___') > -1)
        listindex = $(".listview[id*='" + lvw.id + "']").parents("tr[listindex]").first().attr("listindex");

    if (lvw.rows.length > (Bill.Data.uistate == "details" ? 1 : 2)) {
        lvw.rows[0][7] = '';
        lvw.headers[7].value = '';
        ListView.SetColsVisible(lvw.id, "Rest", false);
    } else if (lvw.rows.length == (Bill.Data.uistate == "details" ? 1 : 2)) {
        lvw.rows[0][7] = '12:00:00,13:00:00';
        lvw.headers[7].value = '12:00:00,13:00:00';
        ListView.SetColsVisible(lvw.id, "Rest", true);
    }
    hideOrShowElasticHtml(listindex, lvw, true);
    //setNeedClockCheckedAndDisabled(listindex);
    $(".lvw_nulldata_addbtn_txt").text("添加打卡时段");
    setTimeout(function () { FormualLib.HandleFieldFormul(1, '上班签到', {'lvw':lvw,'updateCols':[10,6,14],'rowindex':[0]}); }, 30);
}
Bill.onAddListGroup = function (newgp) {
    var inx = 0;
    for (var i = 0; i < newgp.fields.length; i++) {
        if (newgp.fields[i].dbname == "DelayedHtml") {
            inx = i;
            break;
        }
    }
    newgp.fields[inx].formathtml = newgp.fields[inx].formathtml.replace("style=''","style='display:none;'");
}
