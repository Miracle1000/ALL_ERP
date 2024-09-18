window.lvwRedrawCellAfterEvent = function (lvw, h, rowindex, NumberIndex) {
    var num = lvw.rows[rowindex][NumberIndex];
    SplitRow(lvw, num, NumberIndex, rowindex);
}

function SerialNumberCellChange(box) {
    if (!box) { return; }
    var td = $(box).parents('td[dbcolindex]:eq(0)')[0];
    if (typeof (td) == "undefined") { return; }
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));
    var tb = tr.parentNode.parentNode;
    var jlvw = window[tb.id.replace('lvw_dbtable_', 'lvw_JsonData_')];
    var colindex = parseInt(td.getAttribute('dbcolindex'));
    var num = 0;
    num = parseFloat(box.value == "" ? 0 : box.value);

    if ($("#CkPageType_0").val() == '1')
    {
        app.ajax.regEvent("UpdateScankuout2");
        app.ajax.addParam("ScanID", jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "ScanID").i]);
        app.ajax.addParam("num", num);
        var r = app.ajax.send();
        //if (parseInt(jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "ku").i]) > 0 && parseInt(jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "cktype").i])==2) {
        //    updatelvwcellzd(num, rowindex)
        //}
        return;
    }
    if (num == 0) { return; }
    var hds = jlvw.headers;
    for (var i = 0; i < hds.length; i++) { if (hds[i].dbname == "maxnum") { maxcol = i; break; } }
    /*var defnum = jlvw.rows[rowindex][maxcol];
    if (num >= defnum) { 				//禁止超量
        box.value = defnum;
        $(box).keyup();
        return;
    }*/
    SplitRow(jlvw, num, colindex, rowindex);
}

function SplitRow(jlvw, num, colindex, rowindex) {
    var maxcol = -1;
    var hds = jlvw.headers;
    for (var i = 0; i < hds.length; i++) { if (hds[i].dbname == "maxnum") { maxcol = i; break; } }
    var idindex = -1, zd = -1, sjnumpos = -1, kuoutinx = -1, cktype = -1,zdInx=-1, jsinx = -1, ckin = -1;
    var defnum = jlvw.rows[rowindex][maxcol];

    /*if (num >= defnum) { 				//禁止超量
        box.value = defnum;
        $(box).keyup();
        return;
    }*/
    if (defnum < 0) { return; }
    for (var i = 0; i < jlvw.headers.length; i++) {
        switch (jlvw.headers[i].dbname.toLowerCase()) {
            case 'id': idindex = i; break;
            case 'num1': sjnumpos = i; break;
            case 'inx': kuoutinx = i; break;
            case 'm2num1': zd = i; break;
            case 'cktype': cktype = i; break;
            case 'zdnum': zdInx = i; break;
            case 'js': jsinx = i; break;
            case 'ck': ckin = i; break;
        }
    }
    if ($("#CkPageType_0").val() == '1') {
        lvwid = "Scanflist";
    }
    else {
        lvwid = "kuoutlist2";
    }
    //修改原行值
    var js = $($ID("@" + lvwid + "_js_" + rowindex + "_" + jsinx + "_0")).val();
    //修改原行值
    jlvw.rows[rowindex][sjnumpos] = num;
    jlvw.rows[rowindex][jsinx] = (js / defnum) * num;
    //修改原行值
    jlvw.rows[rowindex][zd] = 0;
    //修改原行值
    jlvw.rows[rowindex][cktype] = 1;
    jlvw.rows[rowindex][zdInx] = "";
    //  jlvw.rows[rowindex][maxcol] = defnum - num;
    //维护老行的maxnum
    jlvw.rows[rowindex][maxcol] = num;

    if (defnum - num > 0)
    {
        var newrow = app.CloneObject(jlvw.rows[rowindex]);
        newrow[sjnumpos] = defnum - num;
        newrow[kuoutinx] = getInx();
        newrow[jsinx] = (js / defnum) * (defnum - num);
        newrow[zdInx] = "";
        //维护新行的maxnum
        newrow[maxcol] = app.FormatNumber((parseFloat(defnum) - parseFloat(num)), "numberbox");
        jlvw.rows.splice(rowindex + 1, 0, newrow);
        window.ListView.ReCreateVRows(false, jlvw, null);
    }
    var updateCols = window.ListView.GetNeedReChangeCols(jlvw, colindex);
    window.ListView.ApplyCellSumsData(jlvw, updateCols);
    deletekuoutlit2byID(jlvw.rows[rowindex][kuoutinx], jlvw.rows[rowindex][idindex]);
    //app.ajax.regEvent("deletekuoutlit2");
    //app.ajax.addParam("rowindex", jlvw.rows[rowindex][kuoutinx]);
    //app.ajax.addParam("kuoutlistID", jlvw.rows[rowindex][idindex]);
    //var r = app.ajax.send();
    ___RefreshListViewByJson(jlvw);

    $($ID("@" + lvwid + "_num1_" + (parseInt(rowindex) + 1) + "_" + sjnumpos + "_0")).keyup();
}
//
function deletekuoutlit2byID(rowindex, kuoutlistID)
{
    app.ajax.regEvent("deletekuoutlit2");
    app.ajax.addParam("rowindex", rowindex);
    app.ajax.addParam("kuoutlistID", kuoutlistID);
    var r = app.ajax.send();
}


//function getwidth()
//{
//    $(".kuinformation").parent("td").css('position', 'relative');
//    var a = 0;
//    var b = $(".ckqb").width();
//    $(".kuinformation").each(function () {
//        a = $(this).width();
//        a = a == '0' ? 167 : a;
//        $(this).nextAll('div.ckqb').css('margin-left', a + 10);
//        $(this).nextAll('div.cf').css('margin-left', a + b + 10);
//    });
//}
function getInx() {
    app.ajax.regEvent('GetRowInx')
    var newInx = app.ajax.send();
    return parseInt(newInx);
}

//切换出库模式
window.OnGroupTabChange = function (index, dbsign) {
    var isSuc = true;

    var isCanChange = false;
    if (index == 1 && lvw_JsonData_Scanflist.rows.length == 0) isCanChange = true;
    if (index == 1) {
        if (isCanChange || confirm("切换后将清空已输入的信息，是否切换？")) {
            $("#CkPageType_0").val(0);
            var event = document.createEvent("HTMLEvents");
            event.initEvent("change", true, true);
            document.querySelector("#CkPageType_0").dispatchEvent(event);
            $("#btnForStoreScanf").css("display", "none");
        } else {
            isSuc = false;
        }
    } else {
        $("#btnForStoreScanf").css("display", "block");
        $("#CkPageType_0").val(1);
    }
    return isSuc;
}

window.onload = function () {
    if ($("#CkPageType_0").val() == '1') {
        var event = document.createEvent("HTMLEvents");
        event.initEvent("click", true, true);
        document.querySelector("#kuoutlist_2").dispatchEvent(event);
        //设置图片可见
        $("#btnForStoreScanf").css("display", "block");
    }
    //查看全部样式在zlib.comm.css中
    //getwidth();
    //$("#lvw_dbtable_kuoutlist2").on("DOMNodeInserted", function () {
    //    getwidth();
    //}); 
    //$("#lvw_dbtable_Scanflist").on("DOMNodeInserted", function () {
    //    getwidth();
    //});
    $(document).keydown(function (event) {
        if ($("#sys_win_fldiv_ShowHanderInput").css("display") == "block" && $("#handertxm_0").is(":focus")) {
            if (event.keyCode == 13) {
                $("#qd").click();
            }
        }
    });
    //移除默认事件
    $("#lvwbtmtooldiv_Scanflist").find("div").eq(3).find("input[type=button]").removeAttr("onclick");//jQuery1.7+
    //添加新事件
    $("#lvwbtmtooldiv_Scanflist").find("div").eq(3).find("input[type=button]").on("click", bathdeletebyinx);
}
function bathdeletebyinx() {
    var id = getlvwid();
    var lvw = window["lvw_JsonData_" + id];
    var rows = lvw.rows;
    var headers = lvw.headers;
    var rowidx = [];
    var chooseLine = false;
    var isTree = false;
    var _sindex = 0;
    var _tindex = 0;
    var _kuoutlis2ID = -1;
    var _inxID = -1;
    var _ScanID = -1;
    //获取选择列idx
    for (var i = 0; i < headers.length; i++) {
        var h = headers[i];
        if (h.dbname == "@allselectcol") {
            _sindex = i;
        }
        if (h.dbname == "id") {
            _kuoutlis2ID = i;
        }
        if (h.dbname == "ScanID") {
            _ScanID = i;
        }
        if (h.dbname == "inx") {
            _inxID = i;
        }
        if (h.uitype == "treenode") {
            isTree = true;
            _tindex = i;
        }
    }
    //被选中行
    var selected = [];
    //扫描明细ID
    var ScanIDS = [];
    var inxs = [];
    //出库明细ID
    var kuoutlists = [];

    for (var i = 0; i < rows.length; i++) {
        if (lvw.rows[i][0] == window.ListView.NewRowSignKey) { continue; }
        if (rows[i][_sindex] == "1") {
            chooseLine = true;
            selected.push(i);
            //添加出库明细ID
            ScanIDS.push(lvw.rows[i][_ScanID]);
            kuoutlists.push(lvw.rows[i][_kuoutlis2ID]);
            inxs.push(lvw.rows[i][_inxID]);
        }
    }
    if (!chooseLine) { alert("未选中需要操作的行"); return; }
    //删除数据以及页面刷新
    if (isTree) {
        //要判断是否存在子节点
        var hsChild = false;
        for (var i = 0; i < selected.length; i++) {
            if (rows[selected[i]][_tindex].count > 0) {
                hsChild = true;
                break;
            }
        }
        var canProcTreeData = false;
        if (hsChild) {
            if (confirm("所选项下方存在子节点，是否删除？")) {
                canProcTreeData = true;
            } else {
                return;
            }
        } else {
            if (confirm("确定要删除吗？")) {
                canProcTreeData = true;
            } else {
                return;
            }
        }
        if (canProcTreeData) {
            for (var i = selected.length - 1; i >= 0; i--) {
                __lvw_tn_delOldTreeNode(lvw, selected[i], _tindex);
                var obj = __lvw_tn_computeTreeNodeDeepDate(lvw, selected[i], _tindex);
                __lvw_tn_SortNodesDeep(obj, "", obj, lvw, _tindex);
                ___ReSumListViewByJsonData(lvw);
                ___RefreshListViewByJson(lvw);
                ___RefreshListViewselPos(lvw);
            }
        }
    } else {
        if (confirm("确定要删除吗？")) {
            //调用服务端删除明细
            if (id=="Scanflist")
            {
                app.ajax.regEvent("deletekuoutlit2");
                app.ajax.addParam("rowindex", inxs.join(","));
                app.ajax.addParam("kuoutlistID", kuoutlists.join(","));
                app.ajax.addParam("ScanID", ScanIDS.join(","));
                var r = app.ajax.send();
            }
            var fdbname = window["lvw_parentObjectID_" + lvw.id];
            if (fdbname && window["LeftField_JsonData_" + fdbname]) {
                var key = lvw.ui.checkboxdbname;   //PS:构建维护左侧导航中已选节点结构
                var hds = lvw.headers;
                var ordId = -1;
                for (var i = 0; i < hds.length; i++) { if (hds[i].dbname == key) { ordId = i; break; } }
                var delnds = [];
                for (var i = selected.length - 1; i >= 0; i--) { delnds.push(lvw.rows[selected[i]][ordId]) }
                window.TreeView.UpdateLeftpageState(fdbname, delnds);
            }
            for (var i = selected.length - 1; i >= 0; i--) {
                if (i == lvw.page.selpos) { lvw.page.selpos = 0 }
                lvw.rows.splice(selected[i], 1);
                if (lvw.VerifyfailInfo && lvw.VerifyfailInfo[selected[i]]) { lvw.VerifyfailInfo.splice(selected[i], 1) };
                if (lvw.lockedInfos && lvw.lockedInfos[selected[i]]) { lvw.lockedInfos.splice(selected[i], 1) };
                lvw.page.recordcount--;
            }
            ListView.ResetFilterCacheData(lvw);
            ___ReSumListViewByJsonData(lvw);
            ___RefreshListViewByJson(lvw);
            ___RefreshListViewselPos(lvw);
        } else {
            return;
        }
    }
    __lvw_clearAllCheckedState(id);

    //判断当前页面是否存在批量删除后置时间,如果有则执行
    if (typeof (window.__lvw_je_batchDeleteAfter) == 'function')
        window.__lvw_je_batchDeleteAfter(lvw);

}


/* 加载开始扫码按钮 */
window.AddSpecOperationIntoLvw = function (lvw) {
    if (lvw.id== 'Scanflist')
        return "<div style='width:100%;float:left;display:none;cursor:pointer;' class='lvwSpecOperation_" + lvw.id + "' id='btnForStoreScanf'><img id='scanpng' style='margin-left:45%;margin-top:20px;margin-bottom:10px;width:100px;cursor:pointer;' src='../../../../SYSN/skin/default/img/scanbig.png' title='扫一扫' onclick='ShowScanDiv(" + Bill.Data.ord + ")'/></div>";

}

function OpenStoreDialog(callbackName, attrs, resultproc) {
    var ShowDivProc = function () {
        app.ajax.regEvent(callbackName);
        if (attrs) { for (var n in attrs) { app.ajax.addParam(n, attrs[n]); } }
        var r = app.ajax.send();
        resultproc(r);
    }
    ShowDivProc();
}


//扫码弹层UI
function ShowScanDiv(billid) {
    var sType = $("#scanType").val();
    OpenStoreDialog("ShowKuoutScanfPage", { BillID: billid, scanType: sType }, function (r) {
        var mWidth = 770;
        var mHeight = 490;
        // result为json 格式是bill单据 包含主题和2个字段
        var divTitle = "";
        var result = eval("(" + r + ")");
        if (result == "" || result == undefined) { return; }
        var html = GetStoreScanfLayerHtml(result.groups[0], billid);

        var win = createStoreScanfWindow("fldiv_ShowKuoutScanfPage", {
            width: mWidth,
            height: mHeight,
            closeButton: true,
            maxButton: false,
            minButton: false,
            canMove: false,
            sizeable: false,
            bgShadow: 30
        });
        win.innerHTML = html;
        win.style.zIndex = app.GetCurrBoundingBoxMaxZIndex()+1; 
    });
}
//获取扫描弹层HTML
function GetStoreScanfLayerHtml(Data, billid) {
    var htm = [];
    htm.push("<div class='store_scanf_top'>"
				+ "<span class='store_scanf_title'>" + Data.title + "</span>"
				+ GetTopCheckAreaHtml(Data.fields[0])
				+ "<span class='top_hand' onclick='HanderInput(\"" + billid + "\")'><span class='top_hand_txt'>无法扫描，手动录入</span><span class='top_hand_btn'></span></span>"
			+ "</div>");
    htm.push("<div class='store_scanf_cont'>" + GetScanfContArea(Data) + "</div>");
    htm.push("<div class='store_scanf_btm'><div class='store_scanf_btn' onclick='app.closeWindow(\"fldiv_ShowKuoutScanfPage\");document.getElementById(\"btnForStoreScanf\").scrollIntoView();'>完成扫码</div></div>");
    return htm.join("");
}

//扫码执行结果
window.ScanfResult = function (mType, msg, ListID, currnum, oscanfnum, dscanfnum, type, num1, ScanID,ku) {
    //ShowScanDiv(Bill.Data.ord);
    var showText = "";
    if (msg.length > 25) { showText = msg.substr(0, 25) + "..."; }
    if (mType == "err") {
        var htm = "<div class='store_cont_operatearea fail'>"
        				+ (msg.length > 0 ? "<div class='ot_bg'></div>" : "")
        				+ "<div class='ot_cont'>" + msg + "</div>"
        			+ "</div>";
        $("#ScanfResult").html(htm);
        if (window.KuinKuoutScanfFailRemindSound == 1) app.playMedia(window.SysConfig.VirPath + "SYSN/skin/default/media/fail.MP3");
    } else if (mType == "ok") {
        $("#scanpng").attr('src', window.SysConfig.VirPath + 'SYSN/skin/default/img/jixuscan.png');
        var htm = "<div class='store_cont_operatearea success'>"
            + "<div class='ot_bg'></div>"
            + "<div class='ot_cont'>"
                + "<span class='ot_txt'  title='" +msg + "'>产品【" + (showText.length > 0 ? showText: msg) + "】，数量</span>"
                + "<span class='ot_num'>"
                    + "<span class='ot_num_txt' id='ot_num_txt'>" + app.FormatNumber(currnum, "numberbox") + "</span>"
            + "<span class='modify_btn' id='modify_btn' onclick='modifyNum()'></span>"
            + "<input type='text' class='ot_ipt' xynum='" + app.FormatNumber(num1.toString().replace(/,/g, ""), "numberbox") + "' id='ot_ipt' uitype='numberbox' disnegative='1' value='" + app.FormatNumber(currnum, "numberbox") + "'>"
            + "<button class='zb-button modify_confirm' id='modify_confirm' onclick='confirmNum(" + ListID + "," + type + "," + num1.toString().replace(/,/g, "") + "," + ScanID + "," + ku + ")'>确定</button>"
                + "</span>"
            + "</div>"
        + "</div>";
        $("#ScanfResult").html(htm);
        var v = app.FormatNumber(oscanfnum, "numberbox");
        $(".scanfnum_v_2").html(v.split(".")[0]);
        $(".scanfnum_m_2").html(v.indexOf(".")!=-1?"." + v.split(".")[1]:"");
        v = app.FormatNumber(dscanfnum, "numberbox");
        $(".scanfnum_v_3").html(v.split(".")[0]);
        $(".scanfnum_m_3").html(v.indexOf(".")!=-1?"." + v.split(".")[1]:"");
        var event = document.createEvent("HTMLEvents");
        event.initEvent("change", true, true);
        document.querySelector("#childrefreshEventbox_0").dispatchEvent(event);
        if (window.KuinKuoutScanfSuccessRemindSound == 1) app.playMedia(window.SysConfig.VirPath + "SYSN/skin/default/media/success.MP3");
    } else if (mType == "refresh") {
        var event = document.createEvent("HTMLEvents");
        event.initEvent("change", true, true);
        document.querySelector("#childrefreshEventbox_0").dispatchEvent(event)
    } else if (mType == "other") {
        app.PopMessage(msg, 1);
    }
}

//修改扫描结果数量
function modifyNum() {
    var num = $("#ot_num_txt").text();
    $("#ot_ipt").val(num);
    $("#ot_num_txt").css("display", "none");
    $("#modify_btn").css("display", "none");
    $("#ot_ipt").css("display", "inline-block");
    $("#modify_confirm").css("display", "inline-block");
    $("#ot_ipt").unbind("blur input propertychange", app.InputVerifyAtOnce).bind("blur input propertychange", app.InputVerifyAtOnce);
}

//确认修改数量
function confirmNum(ListID, type, num1, ScanID,ku) {
    if (parseInt(ScanID) > 0) { window.sid = ScanID }//大于库存数量不走服务端会导致扫描临时表ID没有
    if (parseInt(ku) > 0) { window.kuID = ku }
    if (isNaN(parseInt(ScanID))) { ScanID = window.sid };
    if (isNaN(parseInt(ku))) { ku = window.kuID };
    num1 = $("#ot_ipt").attr("xynum");
    var num = $("#ot_ipt").val();//手动修改数量
    if (num.replace(" ", "").length == 0) { alert("请录入数量！"); return};
    if (isNaN(num)) return;
    var oNum = $("#ot_num_txt").text();//扫码返回数量
    var leftNum = parseFloat(num) - parseFloat(oNum);
    //修改数量不能大于现有数量
    if (parseFloat(num) > parseInt(num1) > 0 && type == 1) {
        alert("不能大于所选批号、序列号数量！")
        return;
    }
    if (parseFloat(num) == 0) {
        alert("必须大于0！")
        return;
    }
    if (parseFloat(num) - parseInt(num) > 0 && type == 1) {
        alert("不能为小数！")
        return;
    }
    if (parseFloat(leftNum) == 0) {
        $("#ot_num_txt").text(num);
        $("#ot_num_txt").css("display", "");
        $("#modify_btn").css("display", "inline-block");
        $("#ot_ipt").css("display", "none");
        $("#modify_confirm").css("display", "none");
        return;
    }
    if (parseFloat(leftNum) != 0) {
        app.ajax.regEvent("HanderInputScanfNum");
        app.ajax.addParam("kuoutlistid", ListID);
        app.ajax.addParam("leftNum", leftNum);
        app.ajax.addParam("CurrNum", num); 
        app.ajax.addParam("xynum", num1);
        app.ajax.addParam("type", type);
        app.ajax.addParam("ScanID", ScanID);
        app.ajax.addParam("ku", ku);
        var r = app.ajax.send();
        if (r.indexOf("ok") > 0) {
            $("#ot_num_txt").text(num);
            $("#ot_num_txt").css("display", "");
            $("#modify_btn").css("display", "inline-block");
            $("#ot_ipt").css("display", "none");
            $("#modify_confirm").css("display", "none");
        }
        if (r.length > 0) eval(r);
    }
}


//获取顶部单选区域
function GetTopCheckAreaHtml(fd) {
    var htm = [];
    htm.push("<div class='store_scanf_top_checkarea'>");
    var sc = fd.source.options;
    for (var i = 0; i < sc.length; i++) {
        htm.push("<div class='checkarea_item " + (sc[i].v == fd.defvalue ? "haschecked" : "") + "' ck='" + (sc[i].v == fd.defvalue ? 1 : 0) + "' onclick='changeItemStage(this ," + i + ")'>"
					+ "<span class='checkarea_item_btn'></span>"
					+ "<span class='checkarea_item_tle'>" + sc[i].n + "</span>"
				+ "</div>");
    }
    htm.push("</div>");
    return htm.join("");
}

//单选区域点击事件
function changeItemStage(s, ScanType) {
    var ck = $(s).attr("ck");
    if (ck != 1) {
        $(s).attr("ck", 1);
        $(s).addClass("haschecked");
        $(s).siblings().removeClass("haschecked");
        $(s).siblings().attr("ck", 0);
    }
    $("#scanType").val(ScanType);
}

//获取扫描弹层内容区域
function GetScanfContArea(data) {
    var htm = [];
    var fds = data.fields;
    htm.push("<div class='store_cont_look'>")
    for (var i = 1; i <= 3; i++) {
        var v = app.FormatNumber(fds[i].defvalue, "numberbox");
        htm.push("<div class='cont_item it_" + i + "'>"
					+ "<dl class='cont_item_dl'>"
						+ "<dt>" + fds[i].title + "</dt>"
						+ "<dd><span class='num_front scanfnum_v_" + i + "'>" + v.split(".")[0] + "</span><span  class='num_behind scanfnum_m_" + i + "'>" +(v.indexOf(".")!=-1?"."+ v.split(".")[1]:"" )+ "</span></dd>"
					+ "</dl>"
					+ "<div class='cont_item_btmline'></div>"
				+ "</div>");
    }
    htm.push("</div>");
    htm.push("<div id='ScanfResult'>");
    htm.push("</div>");
    return htm.join("");
}


//创建弹层
function createStoreScanfWindow(id, attrs) {
    if (!attrs) { attrs = {}; }
    if (attrs.srcElement != null) {
        var pos = app.GetObjectPos(attrs.srcElement);
        attrs.left = pos.left + attrs.srcElement.offsetWidth;
        attrs.top = pos.top;
        attrs.position = "absolute";
    }
    var borderwidth = attrs.borderwidth == undefined ? 10 : attrs.borderwidth;
    var height = attrs.height || 300;
    var width = attrs.width || 500;
    if (attrs.align == "center") {
        attrs.top = parseInt(($(window).height() - height) * 0.8 / 2) + document.documentElement.scrollTop;
        attrs.left = parseInt(($(window).width() - width) / 2) + document.documentElement.scrollLeft;
    }
    var ico = attrs.ico || "",//图标
	cancopy = attrs.cancopy == 1;
    closeModel = attrs.closeModel || "close";
    position = attrs.position || "fixed",
    bgShadow = attrs.bgShadow || 0,
    bgcolor = attrs.bgcolor || "#ffffff",
    canMove = attrs.canMove,
    bzIndex = attrs.bzIndex || 10000,
    mzIndex = attrs.mzIndex || 9998,
    __minh = attrs.minHeight,
    __minW = attrs.minWidth,
    leftv = (attrs.left == undefined ? (($(window).width() - width) / 2) : attrs.left),
    topv = (attrs.top == undefined ? (($(window).height() - (height == "auto" ? 1 : height)) / 2) : attrs.top);
    var showtool = attrs.toolbar === false ? false : true;
    var height1 = (showtool ? (borderwidth + 19) : borderwidth);
    var height2 = (showtool ? (borderwidth + 35) : borderwidth);
    //图标，允许最大化，允许最小化, 允许关闭，是否显示工具栏，是否存在背景阴影，背景阴影程度，是否允许移动
    //onclose : 自定义的窗口关闭回调函数
    //创建弹窗
    var dwin = $ID('sys_win_' + id);
    if (dwin != null) {
        dwin.style.display = "block";
        if ($ID('sys_winbg_' + id)) { 
        	$ID('sys_winbg_' + id).style.display = "block"; 
        	$ID('sys_winbg_' + id).style.zindex = app.GetCurrBoundingBoxMaxZIndex()+1; 
        }
        return document.getElementById("sys_win_" + id);
    }
    var html = new Array();
    html.push('<div class="createWindow_boundingBox" id="sys_win_' + id + '"></div>');

    //创建主窗口
    var win = $(html.join(""));
    var div = win[0];
    win.appendTo('body');
    mzIndex = app.GetCurrBoundingBoxMaxZIndex();
    bzIndex = app.GetCurrBoundingBoxMaxZIndex()+1;
    win.css({ "position": position, "width": width + "px", "height": (height == "auto" ? "auto" : height + "px"), "left": leftv + "px", "top": topv + "px", "z-index": bzIndex });
    win.click(function () {
        var sys_dialog_index = app.GetCurrBoundingBoxMaxZIndex();
        sys_dialog_index++;
        win.css({ zIndex: sys_dialog_index });
    });
    //计算内容区域的高度
    //******************计算边框和内容区域大小
    if (height != "auto") {
        $("#sys_wincont_" + id).css({ height: (div.offsetHeight - height1) + "px" });
        $("#sys_winbody_" + id).css({ height: (div.offsetHeight - height2 + 2 - borderwidth) + "px", width: (div.offsetWidth - borderwidth * 2) + "px" });
    } else {
        var bw = parseInt(borderwidth / 2);
        $("#sys_wincont_" + id).css({ padding: "0px " + bw + "px " + bw + "px " + bw + "px" });
    }
    //创建蒙层
    var mark = null;
    var minBtn = null;
    mark = $('<div class="createWindow_mark" id="sys_winbg_' + id + '"></div>');
    mark.appendTo('body');
    mark.css({ opacity: bgShadow / 100, zIndex: mzIndex })
    //返回内容
    return document.getElementById("sys_win_" + id);
}

//手动录入弹层UI
function HanderInput(billid) {
    window.event ? window.event.cancelBubble = true : e.stopPropagation();
    OpenStoreDialog("ShowHanderInput", { BillID: billid }, function (r) {
        var mWidth = 400;
        var mHeight = 120;
        // result为json 格式是bill单据 包含主题和2个字段
        var divTitle = "";
        var result = eval("(" + r + ")");
        if (result == "" || result == undefined) { return; }
        var html = GetInputForHandHtml(result.groups[0]);

        var win = createStoreScanfWindow("fldiv_ShowHanderInput", {
            width: mWidth,
            height: mHeight,
            closeButton: true,
            maxButton: false,
            minButton: false,
            canMove: false,
            sizeable: false,
            bzIndex: 10002,
            mzIndex: 10001,
            bgShadow: 10
        });
        win.innerHTML = html;
        win.style.zIndex = app.GetCurrBoundingBoxMaxZIndex() + 1;
        setTimeout(function () { $("#handertxm_0").focus(); }, 100);
    });
}

function GetInputForHandHtml(data) {
    var htm = [];
    htm.push("<div class='hand_tle'><span class='hand_tle_txt'>" + data.title + "</span><div class='hand_clbtn' onclick='app.closeWindow(\"fldiv_ShowHanderInput\")'></div></div>");
    htm.push("<div  class='hand_ipt'>" + Bill.GetFieldHtml(data.fields[0]) + "<button id='qd' class='zb-button' onclick='HanderInputTxm(" + Bill.Data.ord + ")'>确定</button></div>");
    return htm.join("");
}

//SerialID = 序列号ID
function CheckScanfResult(kuinid, scanType, kuoutlistid, kuid, ck, num2, SerialID) {
    app.ajax.regEvent("ScanKuoutlist");
    app.ajax.addParam("kuoutid", kuinid);
    app.ajax.addParam("scanType", scanType);
    app.ajax.addParam("kuoutlistid", kuoutlistid);
    app.ajax.addParam("ku", kuid);
    app.ajax.addParam("ck", ck);
    app.ajax.addParam("num2", num2);
    app.ajax.addParam("SerialID", SerialID);
    var r = app.ajax.send();
    if (r.length > 0) eval(r);
}

//手动录入条形码代替扫码
function HanderInputTxm(kuoutid) {
    var lrstr = $("#handertxm_0").val();
    if (lrstr.length == 0) {
        alert("请输入条形码！");
        return;
    }
    var scanType = $("#scanType").val();
    var event = document.createEvent("HTMLEvents");
    event.initEvent("change", true, true);
    var v = kuoutid + ',' + scanType + ',' + lrstr;
    $("#sourse_0").val(v);
    document.querySelector("#xlhfreshEventbox_0").dispatchEvent(event);



    //app.ajax.regEvent("HanderInputKuoutlist");
    //app.ajax.addParam("kuoutid", kuinid);
    //app.ajax.addParam("scanType", scanType);
    //app.ajax.addParam("lrstr", lrstr);
    //var r = app.ajax.send();
    //if (r.length > 0) eval(r);
    app.closeWindow("fldiv_ShowHanderInput", true);
    if ($("#systextlengthlayer"))
    {
        $("#systextlengthlayer").css("display", "none");

    }
}



function OpenUrlSplit(ord,unit,ck,inx,moreunit , attr1 ,attr2,obj)
{
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));

    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var num1cellindex = ListView.GetHeaderByDBName(jlvw, "num1").i;
    var attr1inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr1").i;
    var attr2inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr2").i;
    attr1 = jlvw.rows[rowindex][attr1inx];
    attr2 = jlvw.rows[rowindex][attr2inx];
    var num1 = jlvw.rows[rowindex][num1cellindex]
    app.OpenUrl("../../../SYSN/view/store/kuout/KuAppointSplit.ashx?productid=" + app.pwurl(ord) + "&unit=" + app.pwurl(unit) + "&ck=" + ck + "&inx=" + rowindex + "&moreunit=" + moreunit + "&attr1=" + attr1 + "&attr2=" + attr2 + "&cfnum1=" + num1 + "", 'cf');
}

window.CheckCK = function (lvwid, ck, inx) {
    lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var rowindex = inx;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    jlvw.rows[rowindex][CKcellindex].fieldvalue = ck;
    __lvw_je_redrawCell(jlvw, jlvw.headers[CKcellindex], rowindex, jlvw.headers[CKcellindex].showindex);
    $($ID("@" + lvwid + "_ck_" + rowindex + "_" + CKcellindex + "_0")).change();
    $(".createWindow_popoBox").remove()
}

function KuinfoChooseck(ck,obj)
{
    var lvwid = getlvwid();
   
    var jlvw = window['lvw_JsonData_' + lvwid];
    var cellindex = ListView.GetHeaderByDBName(jlvw, "inx").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));
    jlvw.rows[rowindex][CKcellindex].fieldvalue = ck;
    __lvw_je_redrawCell(jlvw, jlvw.headers[CKcellindex], rowindex, jlvw.headers[CKcellindex].showindex);
    $($ID("@" + lvwid + "_ck_" + rowindex + "_" + CKcellindex + "_0")).change();
}

function updatelvwcellzd(num1,inx)
{
    var rowindex = inx;
    var lvwid = getlvwid();
   
    var jlvw = window['lvw_JsonData_' + lvwid];
    var idindex = ListView.GetHeaderByDBName(jlvw, "id").i;
    var cellindex = ListView.GetHeaderByDBName(jlvw, "inx").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "cktype").i;
    var zdnumindex = ListView.GetHeaderByDBName(jlvw, "zdnum").i;
    var zdnumv = "已指定：" + app.FormatNumber(num1, "numberbox") + "";
    zdnumv = num1 == "" ? "" : zdnumv;
    if (num1==="") {
        //点击随机inx就是当前行号
        app.ajax.regEvent("deletekuoutlit2");
        app.ajax.addParam("rowindex", jlvw.rows[inx][cellindex]);
        app.ajax.addParam("kuoutlistID", jlvw.rows[inx][idindex]);
        var r = app.ajax.send();
    }
    else {
        for (var i = 0; i < jlvw.rows.length; i++) {
            if (jlvw.rows[i][cellindex] == inx) rowindex = i;
        }
    }

    $($ID("@" + lvwid + "_cktype_" + rowindex + "_" + CKcellindex + "_div")).nextAll('div').text(zdnumv)
    jlvw.rows[rowindex][zdnumindex] = zdnumv;
    
}

//查看更多库存信息点击拆分
function OpenUrlToKuAppointSplit(ck, unit, moreunit, ord, inx) {
    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var num1cellindex = ListView.GetHeaderByDBName(jlvw, "num1").i;
    var attr1inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr1").i;
    var attr2inx = ListView.GetHeaderByDBName(jlvw, "ProductAttr2").i;
    attr1 = jlvw.rows[inx][attr1inx];
    attr2 = jlvw.rows[inx][attr2inx];
    var num1 = jlvw.rows[inx][num1cellindex]
    app.OpenUrl("../../../SYSN/view/store/kuout/KuAppointSplit.ashx?productid=" + app.pwurl(ord) + "&unit=" + app.pwurl(unit) + "&ck=" + ck + "&inx=" + inx + "&moreunit=" + moreunit + "&attr1=" + attr1 + "&attr2=" + attr2 + "&cfnum1=" + num1 + "", 'cf');
}


window.aa = function (lvwid, ck, inx) {

   var a = $(".kuinformation").width();
    var b = $(".ckqb").width();
    $(".ckqb").css('margin-left', a+10);
    $(".cf").css('margin-left', a + b + 10);

}


function lvwchangekuinfobyck(inx) {
    //加载行库存
    var rowindex = inx;
    var lvwid = getlvwid();   
    var jlvw = window['lvw_JsonData_' + lvwid];
    var cellindex = ListView.GetHeaderByDBName(jlvw, "inx").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    $($ID("@" + lvwid + "_ck_" + rowindex + "_" + CKcellindex + "_0")).change();
    $(".createWindow_popoBox").remove();
    try {
        var date5 = $("#date5").val();
        if (date5.length >= 10 ) {
            date5 = date5.substring(0, 10) + " " + ((new Date()).toTimeString()).substring(0, 8);
            $("#date5").val(date5);
        }
    } catch (e) { }
}

function iframchoosck(ord, unit, attr1, attr2 , obj)
{
    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var cellindex = ListView.GetHeaderByDBName(jlvw, "inx").i;
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "ck").i;
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));

    app.OpenServerFloatDiv("ZBServices.view.SYSN.mdl.sales.ProductModule.ShowStoreInfo", { DivWidth: 765, productid: ord, inx: rowindex, unit: unit, ProductAttr1: attr1, ProductAttr2: attr2}, "", 1);
}

function getlvwid()
{
    var lvwid = "";
    if ($("#CkPageType_0").val() == '1') {
        lvwid = "Scanflist";
    }
    else {
        lvwid = "kuoutlist2";
    }
    return lvwid
}
//组装
function zz(id,obj)
{
    var td = $(obj).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));
    app.OpenUrl("../../../SYSA/packaging/add_CK.ASP?listOrd=" + app.pwurl(id) + "&listType=2&inx=" + rowindex + "");
}
function cenldisplaynoe(obj)
{
    $("tr").each(function () {
        if ($(this).attr('dbname') == 'kuoutlists' || $(this).attr('dbname') == 'addresses' || $(this).attr('dbname') == 'scanlist')
        {
            if (obj.value == 2) {
                $(this).css('display', 'none');
            }
            else {
                if ($(this).attr('dbname') == 'scanlist') {
                    if ($("#CkPageType_0").val() == '1')
                    {
                        $(this).css('display', '');
                    }

                }
                else if ($(this).attr('dbname') == 'kuoutlists')
                {

                    if ($("#CkPageType_0").val() == '0') {
                        $(this).css('display', '');
                    } else { if ($("#CkPageType_0").val() == '1' && $(this).attr('listindex') != '1') $(this).css('display', ''); }

                }
                else {
                    $(this).css('display', '');
                }
            }
           
        }
    });

}

function deletemxbyinx(obj)
{
    var lvwid = getlvwid();
    var jlvw = window['lvw_JsonData_' + lvwid];
    var hds = jlvw.headers;
    var idindex = -1,kuoutinx = -1
    for (var i = 0; i < hds.length; i++) {
            switch (hds[i].dbname.toLowerCase()) {
                case 'id': idindex = i; break;
                case 'inx': kuoutinx = i; break;
            }
    }
    var tr = $(obj).parents('tr').first()[0]//app.getParent(btn, 2);
    var tb = $(tr).parents('table').first()[0]//app.getParent(tr, 2);
    var rowindex = parseInt(tr.getAttribute('pos')) * 1;
    app.ajax.regEvent("deletekuoutlit2");
    app.ajax.addParam("rowindex", jlvw.rows[rowindex][kuoutinx]);
    app.ajax.addParam("kuoutlistID", jlvw.rows[rowindex][idindex]);
    app.ajax.addParam("ScanID", jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "ScanID").i]);
    var r = app.ajax.send();
}

window.onRecTime = function (timeLogoDisplay) {
    if (window.event && window.event.srcElement.tagName != "BODY") { return; }
    var htm = "";
    if (timeLogoDisplay) {
        var htm = "<div class='store_cont_operatearea load'>"
            + "<div class='ot_bg '></div>"
            + "<div class='ot_cont'>" + "正在识别" + "</div>"
        + "</div>";
    }
    $("#ScanfResult").html(htm);
}
