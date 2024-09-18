$(function () {
    //重写是为了提示先选择供应商
    //JSON模式编辑.插入新行
    __lvw_je_addNew = function (id, disrefresh) {
        if (id == "caigoulist" && $("#Company_tit").val() == "" && (Bill.GetField("Company").value == undefined || Bill.GetField("Company").value == "0")) {
            alert("请先选择供应商");
            return;
        }
        var lvw = window["lvw_JsonData_" + id];
        if (id == "payoutlist") {
            var payFPMoney = $("#Money1_0").val();
            if (parseFloat(payFPMoney.replace(/,/g, '')) <= parseFloat(lvw.currsums[1])) {
                alert("没有需要分配的金额，无法增加新的期次");
                return;
            }
        }
        var lastrow = lvw.rows[lvw.rows.length - 1];
        var isnullrow = lastrow[0] == window.ListView.NewRowSignKey;
        var newpos = lvw.rows.length - (isnullrow ? 1 : 0);
        lvw.rows[newpos] = new Array();
        lvw.page.recordcount++;
        var headers = lvw.headers;
        var colidx = -1;
        for (var i = 0; i < headers.length; i++) {
            var jheader = headers[i];
            if (jheader.dbname == "@indexcol") { colidx = i; }
            if (jheader.display == "space") { jheader.defvalue = ""; jheader.value = ""; }
            var defdata = "";
            if (jheader.uitype == "selectbox" || jheader.uitype == "selectcheckbox") { //更新值数据层option中value的取值
                var _source = Bill.HandleSelectSource(jheader, jheader.defvalue || "");
                var ops = _source.options;
                if (jheader.uitype == "selectbox") {
                    defdata = (!jheader.defvalue ? (ops && ops[0] ? ops[0].v : "") : jheader.defvalue);
                } else {
                    defdata = (!jheader.defvalue ? "" : jheader.defvalue);
                }
            } else {
                defdata = (jheader.defvalue == undefined ? "" : jheader.defvalue);
            }
            if (lvw.existsFiltered == true) {
                if (jheader.filterinfo && jheader.filterinfo.keys) {
                    defdata = jheader.filterinfo.keys[0].v;
                }
            }
            if (app.isObject(defdata)) {
                defdata = app.CloneObject(defdata, 2, "parentNode,lvwobject");
            }
            __lvw_je_setcelldatav(lvw, newpos, i, defdata);
            if (jheader.ztlrV) { jheader.ztlrV = null; }//添加行后清空整体录入
            if (jheader.uitype == "treenode") {		//维护树节点关系
                var obj = __lvw_tn_computeTreeNodeDeepDate(lvw, newpos, i);
                __lvw_tn_SortNodesDeep(obj, "", obj, lvw, i);
                lvw.currTreeOperateState = "";				//清空当前状态标识
                lvw.currRemTreeRowIndx = [];				//清空对于树节点对应行标识记录
                lvw.copyTreePosIndex = 0;					//清空存放移动前节点的起始idx
            }
        }
        AddFyhk(id, newpos);
        if (window.OnListViewInsertNewRow) {
            window.OnListViewInsertNewRow(lvw, newpos, "__lvw_je_addNew");
        }
        for (var i = 0; i < lvw.rows.length; i++) { lvw.rows[i][colidx] = i; }
        lvw.page.selpos = newpos;
        if ((newpos + 1) >= lvw.page.pagesize) { lvw.page.startpos = (newpos + 2) - lvw.page.pagesize }
        if (isnullrow == true) {
            lvw.rows.push([window.ListView.NewRowSignKey]);
            lvw.VRows.push(newpos + 1);
        }
        lvw.page.IsApplyFormuled = 0;
        if (disrefresh != true) {
            ___ReSumListViewByJsonData(lvw);
            ___RefreshListViewByJson(lvw);
            var result = ___RefreshListViewselPos(lvw);
            if (window.onListViewRowAfterAdd) { window.onListViewRowAfterAdd(lvw, newpos + 1); }
            return result;
        }
    }

    //JSON模式编辑.每行功能按钮
    __lvw_je_btnhandle = function (btn, ht) {
        var tr = $(btn).parents('tr').first()[0]//app.getParent(btn, 2);
        var tb = $(tr).parents('table').first()[0]//app.getParent(tr, 2);
        var id = tb.id.replace("lvw_dbtable_", "");
        var lvw = window["lvw_JsonData_" + id];
        var pos = tr.getAttribute("pos") * 1;
        var td = $(btn).parents('td').first()[0];
        var rowspan = td.getAttribute("rowspan") ? td.getAttribute("rowspan") : 1;
        /*********** lvw:listview Object   pos:当前行index   ht:按钮标识  */
        /*********** window.__lvw_btnhandle_override 该方法返回值为Boolean类型  为true时，属于完全接管，以下框架代码将不会执行 */
        if (window.__lvw_btnhandle_override) { if (window.__lvw_btnhandle_override(lvw, pos, ht)) { return; } }
        switch (ht) {
            case 1: //在当前行之前插入新纪录
                if (id == "payoutlist") {
                    var payFPMoney = $("#Money1_0").val();
                    if (parseFloat(payFPMoney.replace(/,/g, '')) <= parseFloat(lvw.currsums[1])) {
                        alert("没有需要分配的金额，无法增加新的期次");
                        return;
                    }
                    var lastrow = lvw.rows[lvw.rows.length - 1];
                    var isnullrow = lastrow[0] == window.ListView.NewRowSignKey;
                    var newpos = lvw.rows.length - (isnullrow ? 1 : 0);
                    AddFyhk(id, newpos);
                }
                else {
                    __lvw_je_insertNewRow(lvw, pos + 1)
                }
                ___ReSumListViewByJsonData(lvw);
                ___RefreshListViewselPos(lvw);
                lvw.page.IsApplyFormuled = 0; //Tan:此处可能存在性能问题，只需计算新增行即可，后期优化
                ___RefreshListViewByJson(lvw);
                if (window.onListViewRowAfterAdd) { window.onListViewRowAfterAdd(lvw, pos + 1); }
                break;
            case 2: //删除当前行
                if (window.onListViewRowBeforeDelete) {
                    if (window.onListViewRowBeforeDelete(lvw, pos) == true) return;
                }
                for (var i = pos; i <= (rowspan * 1 + pos - 1) ; i++) {
                    __lvw_je_deleteCurRow(lvw, pos);
                    //删除完之后做特殊处理
                    if (id == "payoutlist") {
                        for (var i = 0; i < lvw.rows.length - 1; i++) {
                            lvw.rows[i][0] = "第" + (i + 1) + "期";
                        }
                    }
                    ___ReSumListViewByJsonData(lvw);
                    ___RefreshListViewselPos(lvw);
                    lvw.page.IsApplyFormuled = 0;
                    ___RefreshListViewByJson(lvw);
                    __lvw_clearAllCheckedState(lvw.id);
                    ListView.AutoExecLvwFormula(lvw, 0);
                    if (window.onListViewRowAfterDelete) { window.onListViewRowAfterDelete(lvw, pos); }
                    if (lvw.ui && lvw.ui.rowsmergesstyle == "merge" && lvw.ui.rowmerges && lvw.ui.rowmerges.length) { continue } else { break; }
                }
                break;
            case 3: //上移
                __lvw_je_rowmove(lvw, pos, -1); break;
            case 4:	//下移
                __lvw_je_rowmove(lvw, pos, 1); break;
        }
    }


    ListView.nulldataRowClickEvent = function (lvwid, DBName, cellIndex, type) {
        if (lvwid == "caigoulist" && $("#Company_tit").val() == "" && (Bill.GetField("Company").value == undefined || Bill.GetField("Company").value == "0")) {
            alert("请先选择供应商");
            return;
        }
        __lvw_je_addNew(lvwid);
        var lvw = window["lvw_JsonData_" + lvwid];
        var srcId = "@" + lvwid + "_" + DBName + "_" + (type == "addrow" ? lvw.rows.length - 2 : 0) + "_" + cellIndex;
        setTimeout(function () {
            var srcDom = $("div[fordbname='" + srcId + "']")[0];
            Bill.TiggerAutoComplete(srcDom, 1);
        }, 300);
    }

    Date.prototype.format = function (fmt) {
        var o = {
            "M+": this.getMonth() + 1, //月份
            "d+": this.getDate(), //日
            "h+": this.getHours(), //小时
            "m+": this.getMinutes(), //分
            "s+": this.getSeconds(), //秒
            "q+": Math.floor((this.getMonth() + 3) / 3), //季度
            "S": this.getMilliseconds() //毫秒
        };
        if (/(y+)/.test(fmt)) {
            fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
        }
        for (var k in o) {
            if (new RegExp("(" + k + ")").test(fmt)) {
                fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
            }
        }
        return fmt;
    }
});

function AddFyhk(id, newpos) {
    if (id == "payoutlist") {
        var lvw = window["lvw_JsonData_" + id];
        var payFPMoney = $("#Money1_0").val().replace(/,/g, '');
        var planDateType = 2;
        if ($("#PlanType_0check")[0].checked == true) {
            planDateType = 1;
        }
        else if ($("#PlanType_0check")[0].checked == true) {
            planDateType = 2;
        }
        var syFPMoney = app.FormatNumber(parseFloat(payFPMoney),"moneybox");
        var prePlanDate = new Date();
        var bfb = 100;
        var curPlanDate = new Date();
        if (newpos > 0) {
            syFPMoney = app.FormatNumber(parseFloat(payFPMoney) - parseFloat(lvw.currsums[1]),"moneybox");
            bfb -= parseFloat(lvw.currsums[2]);
            prePlanDate = lvw.rows[newpos - 1][3];
        }
        if (planDateType == 1) {
            prePlanDate = new Date(prePlanDate);
            curPlanDate = prePlanDate.setYear(prePlanDate.getFullYear() + 1);
        }
        else if (planDateType == 2) {
            prePlanDate = new Date(prePlanDate);
            curPlanDate = prePlanDate.setMonth(prePlanDate.getMonth() + 1);
        }
        lvw.rows[newpos][0] = "第" + (newpos + 1) + "期";
        lvw.rows[newpos][1] = syFPMoney;
        lvw.rows[newpos][2] = bfb;
        lvw.rows[newpos][3] = new Date(curPlanDate).format("yyyy-MM-dd");
        lvw.rows[newpos][4] = "";
    }
}
