window.OnListViewFormualUpdateCell = function (lvw, rowindex, cellindex, newv) {
    if (lvw.headers[cellindex].dbname != "taxRate") { return; }
    window.onlvwUpdateCellValue(lvw, rowindex, cellindex, newv, 0, 0, 0);
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) { return; }
    if (oldvalue == v) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    var taxRate = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "TaxRate").i];
    if (taxRate == undefined || taxRate == null || taxRate == "") { taxRate = 0 }
    var num1 = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "Num1").i];
    taxRate = taxRate * 0.01;
    if (v == undefined || v == null || v == "") { v = 0 }
    switch (dbname) {
        case "djprice1"://单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "djprice1 * (1 + TaxRate * 0.01)");//含税单价
            ListView.EvalCellFormula(lvw, rowindex, "MoneyBeforeTax", "djprice1 * Num1");//金额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "price1 * Num1 - price1 * Num1 / (1 + TaxRate * 0.01)");//税额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "price1 * Num1");//总价
            ___ReSumListViewByJsonData(lvw)
            window.ListView.RefreshCellUI(lvw, rowindex, "price1,MoneyBeforeTax,taxValue,money1", 100);
            break;
        case "price1"://含税单价
            ListView.EvalCellFormula(lvw, rowindex, "djprice1", "price1 / (1 + TaxRate * 0.01)");//含税单价
            ListView.EvalCellFormula(lvw, rowindex, "MoneyBeforeTax", "djprice1 * Num1");//金额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "price1 * Num1 - price1 * Num1 / (1 + TaxRate * 0.01)");//税额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "price1 * Num1");//总价
            ___ReSumListViewByJsonData(lvw)
            window.ListView.RefreshCellUI(lvw, rowindex, "djprice1,MoneyBeforeTax,taxValue,money1", 100);
            break;
        case "MoneyBeforeTax"://金额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "MoneyBeforeTax * (1 + TaxRate * 0.01)");//总价
            ListView.EvalCellFormula(lvw, rowindex, "djprice1", "money1 / Num1 / (1 + TaxRate * 0.01)");//单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "money1 / Num1");//含税单价
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "money1 - MoneyBeforeTax");//税额
            ___ReSumListViewByJsonData(lvw)
            window.ListView.RefreshCellUI(lvw, rowindex, "djprice1,price1,taxValue,money1", 100);
            break;
        case "money1"://总价
            ListView.EvalCellFormula(lvw, rowindex, "djprice1", "money1 / Num1 / (1 + TaxRate * 0.01)");//单价
            ListView.EvalCellFormula(lvw, rowindex, "price1", "money1 / Num1");//含税单价
            ListView.EvalCellFormula(lvw, rowindex, "MoneyBeforeTax", "money1 / (1 + TaxRate * 0.01)");//金额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "money1 - MoneyBeforeTax");//税额
            ___ReSumListViewByJsonData(lvw)
            window.ListView.RefreshCellUI(lvw, rowindex, "djprice1,price1,MoneyBeforeTax,taxValue", 100);
            break;
        case "Num1"://数量
            ListView.EvalCellFormula(lvw, rowindex, "MoneyBeforeTax", "djprice1 * Num1");//金额
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "price1 * Num1 - price1 * Num1 / (1 + TaxRate * 0.01)");//税额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "price1 * Num1");//总价
            ___ReSumListViewByJsonData(lvw)
            window.ListView.RefreshCellUI(lvw, rowindex, "MoneyBeforeTax,taxValue,money1", 100);
            CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", num1);
            break;
        case "TaxRate"://税率
            ListView.EvalCellFormula(lvw, rowindex, "price1", "djprice1 * (1 + TaxRate * 0.01)");//含税单价
            ListView.EvalCellFormula(lvw, rowindex, "taxValue", "price1 * Num1 - price1 * Num1 / (1 + TaxRate * 0.01)");//税额
            ListView.EvalCellFormula(lvw, rowindex, "money1", "price1 * Num1");//总价
            ___ReSumListViewByJsonData(lvw)
            window.ListView.RefreshCellUI(lvw, rowindex, "price1,taxValue,money1", 100);
            break;
    }
}
$(function () {
    //执行快速检索(重写是为了添加一个表单基本信息字段)
    LeftPage.SearchSumbmit = function (dbname, fieldDBName) {
        LeftPage.CurrAdSearchDatas = [];
        var defname = $("#leftpgsearchkey_" + dbname).attr("dfname");
        var value = $("#leftpgsearchkey_" + dbname).val();
        var data = { "text": value, "title": "" }
        LeftPage.CurrAdSearchDatas.push({ "n": defname, "v": value, "t": "", "data": data, uitype: "textbox", "obj": null });
        var companyvalue = $("input[name='Company']").val();
        var bz = $("input[name='bz']").val();
        if (bz == undefined) {
            bz = $("select[name='bz']").val();
        }
        var date3 = $("input[name='date3']").val();
        LeftPage.CurrAdSearchDatas.push({ "n": "company", "v": companyvalue, "t": "", "data": { "text": companyvalue, "title": "" }, uitype: "textbox", "obj": null })
        LeftPage.CurrAdSearchDatas.push({ "n": "bz", "v": bz, "t": "", "data": { "text": bz, "title": "" }, uitype: "textbox", "obj": null })
        LeftPage.CurrAdSearchDatas.push({ "n": "date3", "v": date3, "t": "", "data": { "text": date3, "title": "" }, uitype: "textbox", "obj": null })
        LeftPage.Searchkeylist(1, dbname, "search", fieldDBName);
    }
    //执行高级检索  判断检索关闭框/高级检索字段(重写是为了添加一个表单基本信息字段)
    LeftPage.AdSearchSumbmit = function (dbname, fieldDBName) {
        LeftPage.CurrAdSearchDatas = [];
        var tb = $("#lft_adsearch_tb_" + dbname);
        var cells = $(tb).find("td[adsearchitemcell=1]");
        for (var i = 0; i < cells.length; i++) {
            Bill.getBillDataItem(cells[i], bbb);
            function bbb(dbname, value, obj) {
                var dbtype = obj ? (obj.drfomat || obj) : "";
                LeftPage.CurrAdSearchDatas.push({ "n": dbname, "v": value, "t": dbtype, "data": bbb.data, uitype: cells[i].getAttribute("uitype"), "obj": obj });
            }
        }
        var companyvalue = $("input[name='Company']").val();
        var bz = $("input[name='bz']").val();
        if (bz == undefined) {
            bz = $("select[name='bz']").val();
        }
        var date3 = $("input[name='date3']").val();
        LeftPage.CurrAdSearchDatas.push({ "n": "company", "v": companyvalue, "t": "", "data": { "text": companyvalue, "title": "" }, uitype: "textbox", "obj": null })
        LeftPage.CurrAdSearchDatas.push({ "n": "bz", "v": bz, "t": "", "data": { "text": bz, "title": "" }, uitype: "textbox", "obj": null })
        LeftPage.CurrAdSearchDatas.push({ "n": "date3", "v": date3, "t": "", "data": { "text": date3, "title": "" }, uitype: "textbox", "obj": null })
        var lshow = $("#lft_pgsearch_checkbtn_" + dbname)[0].checked;
        if (!lshow) { app.CloseLftLayer(dbname) }
        LeftPage.Searchkeylist(1, dbname, "adsearch", fieldDBName);
    }

    //控件点击事件
    Bill._DCBack = function (box, callname, posttype, virf, virffields) {
        if (box.name == "btnSearch") {
            if ($("#company").val() == "") {
                alert("供应商不能为空");
                return;
            }
            if ($("#bz_0").val() == "") {
                alert("币种不能为空");
                return;
            }
            if ($("#date3").val() == "") {
                alert("退货日期不能为空");
                return;
            }
            if (lvw_JsonData_caigouthlist.rows.length > 1 && !confirm("筛选后将清空退货明细，确定筛选？")) {
                return;
            }
        }
        if (callname.indexOf("client:") == 0) { eval(callname.replace("client:", "")); return; }
        var td = $(box).parents("td.fcell[billfield=1]")[0];
        var dbname = td.getAttribute("dbname");
        var uitype = td.getAttribute("uitype");
        if (virf == 1) {
            if (Bill.DataVerification(document.body, virffields) == false)  //单据数据校验
            {
                return false; //校验失败
            }
        }
        if (Bill.OnFieldCallBack) {
            if (Bill.OnFieldCallBack(box, callname) == false) { return false; }
        }
        var FireObjectID = (window.event && window.event.srcElement) ? window.event.srcElement.id : "";
        if (window.BillSysCallBackObj && window.callbackCurrEventCache) {
            if (window.event.type == "blur") {
                if ((new Date()).getTime() - window.lastDCBackTime < 1000) {
                    //此分支很有可能是  focus - blur 触发了 回调并发冲突， 只能牺牲，不然单据界面抢着重绘可能崩溃
                    return;
                }
            }
        }
        window.BillSysCallBackObj = null;
        window.lastDCBackTime = (new Date()).getTime();
        try {
            window.callbackCurrEventCache = app.CloneObject(window.event, 1);
        } catch (ex) { }
        app.ajax.regEvent("SYSBillFieldCallBack");
        app.ajax.addParam("__sys_msgid", window.RuntimeInfo.SystemMessageKey);
        app.ajax.addParam("callname", callname);
        app.ajax.addParam("__uilayout", Bill.getFiledsLayout());
        app.ajax.addParam("__uilayers", Bill.getBillLayers());
        app.ajax.addParam("__billuiinfo", app.GetJSON(Bill.Data.ui));
        app.ajax.addParam("__cmdtag", dbname);
        app.ajax.addParam("__billtagdata", app.GetJSON(Bill.Data.tag));
        app.ajax.addParam("__fireObjectID", FireObjectID);
        Bill._DCBack_FillSrcElementObject(box);
        var callback = function (key, value) {
            switch (posttype) {
                case 0: if (key == dbname) { app.ajax.addParam("b_f_sv_" + key, value); break; } break;
                case 1: if (callback.islistview != true) { app.ajax.addParam("b_f_sv_" + key, value); break; } break;
                default: app.ajax.addParam("b_f_sv_" + key, value); break;
            }
        };
        if (Bill.MainFieldsFormulaHandleProc2) { Bill.MainFieldsFormulaHandleProc2(); }
        Bill.getBillData(callback);
        app.ajax.send(function (r) {
            if (FireObjectID && window.BillSysCallBackObj) {
                var IDOBJ = $ID(FireObjectID);
                try {
                    if (IDOBJ && IDOBJ.tagName == "INPUT") {
                        if (!box.onblur && !box.onchange)
                            IDOBJ.focus();
                        if (!IDOBJ.onpropertychange) {  //防止光标全选中，导致连续输入不方便
                            var v = IDOBJ.value;
                            IDOBJ.value = "";
                            setTimeout(function () { IDOBJ.value = v; }, 10);
                        }
                    }
                } catch (ex) { }
            }
            setTimeout(function () { window.callbackCurrEventCache = null; }, 10);
        });
    };

    //重写是为了提示先选择供应商，币种，退货日期
    //JSON模式编辑.插入新行
    __lvw_je_addNew = function (id, disrefresh) {
        if ($("#Company_tit").val() == "") {
            alert("请先选择供应商");
            return;
        }
        if ($("#bz_0").val() == "") {
            alert("请先选择币种");
            return;
        }
        if ($("#date3").val() == "") {
            alert("请先选择退货日期");
            return;
        }
        var lvw = window["lvw_JsonData_" + id];
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
});





