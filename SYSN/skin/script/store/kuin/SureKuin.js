
window.onload = function () {
	if ($("#CkPageType_0").val() == '1') {
		if (document.createEvent) {
			var event = document.createEvent("HTMLEvents");
			event.initEvent("click", true, true);
			document.querySelector("#kuinlist_2").dispatchEvent(event);
		} else {
			document.getElementById("kuinlist_2").click();
		}
        //设置图片可见
        $("#btnForStoreScanf").css("display", "block");
    }
    $(document).keydown(function (event) {
        if (event.keyCode == 13) {
            if ($("#sys_win_fldiv_ShowHanderInput").css("display") == "block" && $("#handertxm_0").is(":focus")) {
                $("#qd").click();
            }
        }
    });
}
//删除扫描明细
function deletemxbyinx(obj) {
    if ($("#CkPageType_0").val() == '1') {
        var jlvw = window['lvw_JsonData_Scanflist'];
        var tr = $(obj).parents('tr').first()[0]//app.getParent(btn, 2); 
        var rowindex = parseInt(tr.getAttribute('pos')) * 1;
        app.ajax.regEvent("DeleteScankuinlist");
        app.ajax.addParam("ScanID", jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "ScanID").i]);
        app.ajax.addParam("Num1", jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "num1").i]);
        var r = app.ajax.send();
    }
}

window.OnGroupTabChange = function (index, dbsign) {
	var isSuc = true
    var isCanChange = false;
    if (index == 1 && lvw_JsonData_Scanflist.rows.length == 0) isCanChange = true;
    if (index==1){
    	if(isCanChange || confirm("切换后将清空已输入的信息，是否切换？")) {
    		$("#CkPageType_0").val(0);
    		if (document.createEvent) {
    			var event = document.createEvent("HTMLEvents");
    			event.initEvent("change", true, true);
    			document.querySelector("#CkPageType_0").dispatchEvent(event);
    		} else {
    			document.getElementById("CkPageType_0").click();
    		}
	        $("#btnForStoreScanf").css("display", "none");
      	}else{		
       		isSuc=false;
     	}
    }else{
    	$("#btnForStoreScanf").css("display", "block");
    	$("#CkPageType_0").val(1);
    }
    $("tr").each(function () {
        if ($(this).attr('collectionssign') == 'kuinlist') {
            if (index == 1) {
                $(this).attr("oldDisplay", $(this).attr('dbname') == 'kuinlists'? "" :"none");
            } else {
                $(this).attr("oldDisplay", $(this).attr('dbname') == 'kuinlists' ? "none" : "");
            }
        }
    });
    return isSuc;
}

/* 加载开始扫码按钮 */
window.AddSpecOperationIntoLvw = function (lvw) {
    return lvw.id=="kuinlist" ? "": "<div style='width:100%;float:left;display:none;' class='lvwSpecOperation_"+ lvw.id +"'  id='btnForStoreScanf'><img id='scanpng' style='margin-left:45%;margin-top:20px;margin-bottom:10px;width:100px;cursor:pointer;' src='../../../../SYSN/skin/default/img/scanbig.png' title='扫一扫' onclick='ShowScanDiv(" + Bill.Data.ord + ")'/></div>";
}

//扫码弹层UI
function ShowScanDiv(billid) {
    var sType = $("#scanType").val();
    OpenStoreDialog("ShowKuinScanfPage", { BillID: billid, scanType:sType }, function (r) {
        var mWidth = 770;
        var mHeight = 490;
        // result为json 格式是bill单据 包含主题和2个字段
        var divTitle = "";
        var result = eval("(" + r + ")");
        if (result == "" || result == undefined) { return; }
        var html = GetStoreScanfLayerHtml(result.groups[0], billid);

        var win = createStoreScanfWindow("fldiv_ShowKuinScanfPage", {
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

function OpenStoreDialog(callbackName, attrs, resultproc) {
    var ShowDivProc = function () {
        app.ajax.regEvent(callbackName);
        if (attrs) { for (var n in attrs) { app.ajax.addParam(n, attrs[n]); } }
        var r = app.ajax.send();
        resultproc(r);
    }
    ShowDivProc();
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
    htm.push("<div class='store_scanf_btm'><div class='store_scanf_btn' onclick='__lvw_posgoto(\"Scanflist\",3);app.closeWindow(\"fldiv_ShowKuinScanfPage\");document.getElementById(\"btnForStoreScanf\").scrollIntoView();'>完成扫码</div></div>");
    return htm.join("");
}

//扫码执行结果
window.ScanfResult = function (mType, msg, ListID, currnum, oscanfnum, dscanfnum) {
    ShowScanDiv(Bill.Data.ord);
    var showText = "";
    if (msg.length > 25) {showText = msg.substr(0, 25) + "..."; }
    if (mType == "err") {
        var htm = "<div class='store_cont_operatearea fail'>"
        				+ "<div class='ot_bg'></div>"
        				+ "<div class='ot_cont'>" + msg + "</div>"
        			+ "</div>";
        $("#ScanfResult").html(htm);
        if (window.KuinKuoutScanfFailRemindSound == 1) app.playMedia(window.SysConfig.VirPath + "SYSN/skin/default/media/fail.MP3");
    } else if (mType == "ok") {
        $("#scanpng").attr('src', window.SysConfig.VirPath + 'SYSN/skin/default/img/jixuscan.png');
        var htm = "<div class='store_cont_operatearea success'>"
            + "<div class='ot_bg'></div>"
            + "<div class='ot_cont'>"
                + "<span class='ot_txt' title='" + msg + "'>产品【" + (showText.length > 0 ? showText : msg) + "】，数量</span>"
                + "<span class='ot_num'>"
                    + "<span class='ot_num_txt' id='ot_num_txt'>" + app.FormatNumber(currnum, "numberbox") + "</span>"
                    + "<span class='modify_btn' id='modify_btn' onclick='modifyNum()'></span>"
                    + "<input type='text' class='ot_ipt' id='ot_ipt' uitype='numberbox' disnegative='1' value='" + app.FormatNumber(currnum, "numberbox") + "'>"
                    + "<button class='zb-button modify_confirm' id='modify_confirm' onclick='confirmNum(" + ListID + ")'>确定</button>"
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
        if(window.KuinKuoutScanfSuccessRemindSound==1) app.playMedia(window.SysConfig.VirPath + "SYSN/skin/default/media/success.MP3");
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
function confirmNum(ListID) {
    var num = $("#ot_ipt").val();
    if (Number(num) == 0)
    { window.ScanfResult('other', '请输入大于0的数字!'); return; }
    if (num.replace(" ", "").length == 0) return;
    if (isNaN(num)) return;
    var oNum = $("#ot_num_txt").text();
    var leftNum = parseFloat(num) - parseFloat(oNum);
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
        app.ajax.addParam("kuinlistid", ListID);
        app.ajax.addParam("leftNum", leftNum);
        app.ajax.addParam("CurrNum", num);
        var r = app.ajax.send();
        if (r.indexOf("ok")>0) {
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
        htm.push("<div class='checkarea_item " + (sc[i].v == fd.defvalue ? "haschecked" : "") + "' ck='" + (sc[i].v == fd.defvalue ? 1 : 0) + "' onclick='changeItemStage(this ,"+ i +")'>"
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
						+ "<dd><span class='num_front scanfnum_v_" + i + "'>" + v.split(".")[0] + "</span><span  class='num_behind scanfnum_m_" + i + "'>" + (v.indexOf(".") != -1 ? "." + v.split(".")[1] : "") + "</span></dd>"
					+ "</dl>"
					+(window.top.SysConfig.SystemType==3?"": "<div class='cont_item_btmline'></div>")
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
    htm.push("<div class='hand_ipt'>" + Bill.GetFieldHtml(data.fields[0]) + "<button id='qd' class='zb-button' onclick='HanderInputTxm(" + Bill.Data.ord + ")'>确定</button></div>");
    return htm.join("");
}

//手动录入条形码代替扫码
function HanderInputTxm(kuinid) {
    var lrstr = $("#handertxm_0").val();
    if (lrstr.length == 0) {
        alert("请输入条形码！");
        return;
    }
    var scanType = $("#scanType").val();
    var event = document.createEvent("HTMLEvents");
    event.initEvent("change", true, true);
    var v = kuinid + ',' + scanType + ',' + lrstr;
    $("#sourse_0").val(v);
    document.querySelector("#xlhfreshEventbox_0").dispatchEvent(event);
    app.closeWindow("fldiv_ShowHanderInput");
    if ($("#systextlengthlayer")) {
        $("#systextlengthlayer").css("display", "none");

    }
}

function CheckScanfResult(kuinid, scanType, kuinlistid, scrq, yxrq, date2, intro, zdy1, zdy2, zdy3, zdy4, zdy5, zdy6, bz,js,ord,unit,xlh,ph,num1) {
    app.ajax.regEvent("ScanKuinlist");
    app.ajax.addParam("kuinid", kuinid);
    app.ajax.addParam("scanType", scanType);
    app.ajax.addParam("kuinlistid", kuinlistid);
    app.ajax.addParam("scrq", scrq);
    app.ajax.addParam("yxrq", yxrq);
    app.ajax.addParam("date2", date2);
    app.ajax.addParam("intro", intro);
    app.ajax.addParam("zdy1", zdy1);
    app.ajax.addParam("zdy2", zdy2);
    app.ajax.addParam("zdy3", zdy3);
    app.ajax.addParam("zdy4", zdy4);
    app.ajax.addParam("zdy5", zdy5);
    app.ajax.addParam("zdy6", zdy6);
    app.ajax.addParam("bz", bz);
    app.ajax.addParam("js", js);
    app.ajax.addParam("pord", ord);
    app.ajax.addParam("unit", unit);
    app.ajax.addParam("xlh", xlh);
    app.ajax.addParam("ph", ph);
    app.ajax.addParam("num1", num1);
    var r = app.ajax.send();
    if (r.length > 0) eval(r);
}

//录入数量考虑拆分入库明细
window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true) { return; }
    if (window.event && window.event.type != "change") { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    switch (dbname) {
        case "num1":
            var num1 = lvw.rows[rowindex][cellindex];
            if (num1.length == 0 || parseFloat(num1) == 0) return;
            var initInx = ListView.GetHeaderByDBName(lvw, "initnum").i;
            var asNumH = ListView.GetHeaderByDBName(lvw, "AssistNum");
            if (asNumH) { var asNumInx = ListView.GetHeaderByDBName(lvw, "AssistNum").i; }
            var asUnitH = ListView.GetHeaderByDBName(lvw, "AssistUnit");
            if (asUnitH) { var asUnitInx = ListView.GetHeaderByDBName(lvw, "AssistUnit").i; }
            var unitAsBLH = ListView.GetHeaderByDBName(lvw, "AssistUnit_UnitRelationBL");
            if (unitAsBLH) { var unitAsBLInx = ListView.GetHeaderByDBName(lvw, "AssistUnit_UnitRelationBL").i; }
            var idInx = ListView.GetHeaderByDBName(lvw, "id").i;
            var initnum = lvw.rows[rowindex][initInx];
            if (unitAsBLInx) { var unitBl = lvw.rows[rowindex][unitAsBLInx]; }
            var xlh = ListView.GetHeaderByDBName(lvw, "xlh").i;//获取序列号所在列index
            if (parseFloat(app.FormatNumber(initnum, "numberbox")) == parseFloat(app.FormatNumber(num1, "numberbox"))) return;
            //录入数量大于当前行初始数量
            if (parseFloat(num1) >= parseFloat(initnum)) {
                if ($("#CkPageType_0").val() == '1' && parseFloat(num1) > parseFloat(initnum)) {
                    var upnum = parseFloat(num1) - parseFloat(initnum);
                    var jlvw = window['lvw_JsonData_Scanflist'];
                    app.ajax.regEvent("UpScankuinlist");
                    app.ajax.addParam("ScanID", jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "ScanID").i]);
                    app.ajax.addParam("Num1", upnum);
                    app.ajax.addParam("assistNum", lvw.rows[rowindex][asNumInx]);
                    app.ajax.addParam("assistUnit", lvw.rows[rowindex][asUnitInx]);
                    var r = app.ajax.send();
                }
                ListView._DCBack($($ID("@" + lvw.id + "_num1_" + (parseInt(rowindex)) + "_" + cellindex + "_0"))[0], 'ZBServices.view.SYSN.mdl.sales.UnitsHelper.ChangeAssistUnit', 1, 0, '')
                return;
            }
            lvw.rows[rowindex][initInx] = num1;
            if (asNumInx) { lvw.rows[rowindex][asNumInx] = app.FormatNumber(num1 * unitBl, "numberbox"); }
            //拆出新行的
            var newrow = app.CloneObject(lvw.rows[rowindex]);
            newrow[idInx] = 0;
            newrow[cellindex] = parseFloat(initnum) - parseFloat(num1);
            if (asNumInx) { newrow[asNumInx] = app.FormatNumber(newrow[cellindex] * unitBl, "numberbox"); }
            newrow[initInx] = parseFloat(initnum) - parseFloat(num1);
            //-------拆行时序列号处理-------------------
            var xlhObj = app.CloneObject(lvw.rows[rowindex][xlh]);
            if (xlhObj && xlhObj.Num) {
                if (parseInt(num1) !== parseInt(xlhObj.Num)) {//不相等时说明序列号有变动
                    var serialNumbersArr = xlhObj.SerialNumbers.split(",");
                    serialNumbersArr.forEach(function(t, i){ serialNumbersArr[i] = xlhObj.IDs.split(",")[i] + "!@#9527#@!" + t })
                    //数量改小以后，序列号取降序排列前【num1】个。num1取整不四舍五入
                    var idsArr = xlhObj.IDs.split(",").map(Number).sort(function (a, b) { b - a });
                    serialNumbersArr = serialNumbersArr.sort(function (a, b) { parseInt(b.split("!@#9527#@!")[0]) - parseInt(a.split("!@#9527#@!")[0]) })
                    if (idsArr.slice(0, parseInt(num1)).toString()) {
                        var idsNew = idsArr.slice(0, parseInt(num1))
                        lvw.rows[rowindex][xlh].IDs = idsNew.toString()
                        lvw.rows[rowindex][xlh].Num = parseInt(num1)
                        var serialNumbers = serialNumbersArr.filter(function(item, i) { return $.inArray(parseInt(item.split("!@#9527#@!")[0]), idsNew) != -1 })
                        serialNumbers.forEach(function(t, i){ serialNumbers[i] = t.split("!@#9527#@!")[1] })
                        lvw.rows[rowindex][xlh].SerialNumbers = serialNumbers.toString()
                    }
                    if (idsArr.slice(parseInt(num1)).toString()) {
                        var idsNew = idsArr.slice(parseInt(num1))
                        newrow[xlh].IDs = idsNew.toString()
                        newrow[xlh].Num = newrow[initInx]
                        var serialNumbers = serialNumbersArr.filter(function(item, i) { return $.inArray(parseInt(item.split("!@#9527#@!")[0]), idsNew) != -1 })
                        serialNumbers.forEach(function(t, i) { serialNumbers[i] = t.split("!@#9527#@!")[1] })
                        newrow[xlh].SerialNumbers = serialNumbers.toString()
                    }
                }
            }
            //--------------------------------------------
            lvw.rows.splice(rowindex + 1, 0, newrow);
            window.ListView.ReCreateVRows(false, lvw, null);
            var updateCols = window.ListView.GetNeedReChangeCols(lvw, cellindex);
            window.ListView.ApplyCellSumsData(lvw, updateCols);
            ___RefreshListViewByJson(lvw);
            $($ID("@" + lvw.id + "_num1_" + (parseInt(rowindex) + 1) + "_" + cellindex + "_0")).keyup();
            $($ID("@" + lvw.id + "_num1_" + (parseInt(rowindex) + 1) + "_" + cellindex + "_0")).change();
            break;
        case "AssistNum":
        case "AssistUnit":
            var asNumH = ListView.GetHeaderByDBName(lvw, "AssistNum");
            if (asNumH) { var asNumInx = ListView.GetHeaderByDBName(lvw, "AssistNum").i; }
            var asUnitH = ListView.GetHeaderByDBName(lvw, "AssistUnit");
            if (asUnitH) { var asUnitInx = ListView.GetHeaderByDBName(lvw, "AssistUnit").i; }
            app.ajax.regEvent("UpScanAssInfo");
            var jlvw = window['lvw_JsonData_Scanflist'];
            if (jlvw.rows.length > 0) {
                app.ajax.addParam("ScanID", jlvw.rows[rowindex][ListView.GetHeaderByDBName(jlvw, "ScanID").i]);
                app.ajax.addParam("assistNum", lvw.rows[rowindex][asNumInx]);
                app.ajax.addParam("assistUnit", lvw.rows[rowindex][asUnitInx].fieldvalue);
                var r = app.ajax.send();
            }
            break;
    }
}



/*
window.KuinNumberCellChange = function (box) {
    var defnum = 0, num = 0;
    if (!box) { return; }
    if (!(box.defaultValue == "" || box.defaultValue == null)) {
        defnum = parseFloat(box.defaultValue);
    }
    num = parseFloat(box.value);
    if (defnum == num) { return; }
    if (num == 0) { return; }
    var td = $(box).parents('td[dbcolindex]:eq(0)')[0];
    var tr = td.parentNode;
    var rowindex = parseInt(tr.getAttribute('pos'));
    var tb = tr.parentNode.parentNode;
    var lvw = window[tb.id.replace('lvw_dbtable_', 'lvw_JsonData_')];
    var cellindex = parseInt(td.getAttribute('dbcolindex'));
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    switch (dbname) {
        case "num1":
            var num1 = parseFloat(box.value);
            var initnum = lvw.rows[rowindex][ListView.GetHeaderByDBName(lvw, "initnum").i];
            //录入数量大于当前行初始数量
            if (parseFloat(num1) > parseFloat(initnum)) return;
            //拆出新行的
            var newrow = app.CloneObject(lvw.rows[rowindex]);
            newrow[cellindex] = parseFloat(initnum) - parseFloat(num1);
            lvw.rows.splice(rowindex + 1, 0, newrow);
            window.ListView.ReCreateVRows(false, lvw, null);
            var updateCols = window.ListView.GetNeedReChangeCols(lvw, cellindex);
            window.ListView.ApplyCellSumsData(lvw, updateCols);
            break;
    }
    //Bill.ListViewAddRows(lvw.id, jsv, "", "num1", rowindex);
}
*/
//选择仓库考虑库位问题
window.OnFieldAutoCompleteCallBackHank = function (obj, inputs) {
    var ispllr = inputs[0].getAttribute("ispllr");
    if (!ispllr) {
        try {
            var hdb = (inputs[0].getAttribute("id") || "").split("_");
            var td = $(inputs[0]).parents('td[dbcolindex]:eq(0)')[0];
            var tr = td.parentNode;
            var rowindex = parseInt(tr.getAttribute('pos'));
            var lvw_id = hdb[0].replace("@", "");
            var jlvw = window["lvw_JsonData_" + lvw_id];
            var kuInx = ListView.GetHeaderByDBName(jlvw, "Ku").i;
            var kwInx = ListView.GetHeaderByDBName(jlvw, "kw").i;
            var cknameInx = ListView.GetHeaderByDBName(jlvw, "CkName").i;
            if (rowindex == -1) {
                var plid = inputs[0].getAttribute("id");
                var vrows = jlvw.VRows.join(",");
                for (var n = 0 ; n < jlvw.rows.length ; n++) {
                    var kw = jlvw.rows[n][kwInx];
                    var isupdatejsonv = kw.length == 0 || (kw.length > 0 && ("," + kw + ",").indexOf("," + obj.value + ",") > -1);
                    var isshowrow = ("," + vrows + ",").indexOf("," + n + ",") >= 0;
                    if (isupdatejsonv && isshowrow) {//只修改显示出来的row的json值
                        __lvw_je_setcelldatav(jlvw, n, kuInx, obj.value, 0);
                        __lvw_je_setcelldatav(jlvw, n, cknameInx, { fieldvalue: obj.value, links: [{ title: obj.text }] }, 0);
                    }
                }
                ___RefreshListViewByJson(jlvw);
            } else {
                var kw = jlvw.rows[rowindex][kwInx];
                if (kw.length > 0) {
                    if (("," + kw + ",").indexOf("," + obj.value + ",") < 0) return;
                }
                __lvw_je_setcelldatav(jlvw, rowindex, kuInx, obj.value, 0);
                __lvw_je_setcelldatav(jlvw, rowindex, cknameInx, { fieldvalue: obj.value, links: [{ title: obj.text }] }, 0);
            }

        } catch (e) {

        }
    }
    inputs[0].value = (obj.texts ? obj.texts.join(",") : obj.text.split(" ").join(","));
    inputs[0].setAttribute("values", obj.value);
    try {
        inputs[1].value = (obj.texts ? obj.texts.join(",") : obj.text.split(" ").join(","));
        inputs[1].setAttribute("values", obj.value);
    } catch (e) {

    }
    return true;
}

function cenldisplaynoe(obj) {
    $("tr").each(function () {
        if ($(this).attr('dbname') == 'kuinlists' || $(this).attr('dbname') == 'scanlist') {
            if (obj.value == 2) {
                if($(this).css('display')=="none") $(this).attr("oldDisplay" , "none");
                $(this).css('display', 'none');
            }
            else {
                if ($(this).attr('oldDisplay') == "none") {
                    $(this).css('display', 'none');
                } else {
                    $(this).css('display', '');
                }
            }

        }
    });

}

window.onRecTime = function (timeLogoDisplay) {
    if (window.event&&window.event.srcElement.tagName != "BODY") { return; }
    var htm = "";
    if (timeLogoDisplay) {
        var htm = "<div class='store_cont_operatearea load'>"
            + "<div class='ot_bg '></div>"
            + "<div class='ot_cont'>" + "正在识别" + "</div>"
        + "</div>";
    }
    $("#ScanfResult").html(htm);
}


window.Batchassignment = function (lvw, rowi, rowindex, cellindex, _v) {
    if (lvw.headers[cellindex].dbname == "ph") {
        var event = document.createEvent("HTMLEvents");
        event.initEvent("change", true, true);
        document.querySelector("#PHfreshEventbox_0").dispatchEvent(event);
    }
}
//选择序列号不刷新数量
window.NoNeedRefreshNum = true;
//通过公式获取仓库中的Id给ku字段赋值
function getKuId(obj) {
    return obj && obj.v ? obj.v.fieldvalue:"";
}

