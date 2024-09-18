var imgObj = null;
var xlhObj = null;
var rowIndex = 0, cellIndex = -1;
var CellNum = 0;

function SetAllXlhSQ(obj, autoComplete) {
    var lvw = parent.window["lvw_JsonData_NotDoProcedure"];
    var ID = obj.parentNode.parentNode.getAttribute("id");
    rowIndex = ID.split("_")[ID.split("_").length - 3];
    if (lvw.rows[rowIndex][0] == ListView.NewRowSignKey) { return; }

    var hd = lvw.headers;
    var rows = lvw.rows;
    var h_num1 = -1;
    var h_xlh = -1
    for (var i = 0; i < hd.length; i++) {
        if (hd[i].dbname == "num1") { h_num1 = i; }
        if (hd[i].dbname == "codeProduct") { h_xlh = i; }
    }

    var num = lvw.rows[rowIndex][h_num1];        //汇报数量
    if (num.length == 0) { num = 0; }
    var setObjSQ = document.getElementById(ID.replace("_div", "_0"));//序列号编辑文本框
    if (!autoComplete) {
        var xlh = setObjSQ.value;
        var xlhs = xlh.split(",");//序列号个数
        var html = "<table style='width:100%;height:100%;'><tr><td style='width:23%;'>"
        html += "<div style='height:308px;margin:2px;'><textarea id='lrxlh' style='height:99%;border:1px solid #ccc;overflow:auto;cursor:default'></textarea></div>";
        html += "<div style='width:100%;text-align:right;margin-right:2px;margin-top:3px;'>";
        html += " <input type='button' onclick='addxlh()' class='page' value='加入'>";
        html += " <input type='button' onclick='deleteaddxlh()' class='page' value='重置'>";
        html += "</div>"
        html += "</td><td style='width:77%;'>";
        html += "<div id='target' class='div_li' style='height:308px;margin:3px;margin-left:0px;border:1px solid #ccc;overflow:auto;cursor:default;padding-bottom:3px;' >"
        var xlh_lis = new Array();
        var xlhnum = 0
        if (xlh.length > 0) {
            for (var i = 0; i < xlhs.length ; i++) {
                xlh_lis[i] = "<li style='width:100px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img title='删除' style='width:10px;display:none;right:1px;top:1px;color:red;position:absolute' onclick='deleteli(this)' src='" + window.SysConfig.VirPath + "/SYSN/skin/default/img/delete.jpg'/>" + xlhs[i] + "</li>";
            }
            xlhnum = xlhs.length;
        }
        html += xlh_lis.join("");
        html += "</div>";
        html += "<div style='width:100%;text-align:right;margin-right:10px;margin-top:5px;'>";
        html += " 汇报数量：<span class='gray'>" + app.FormatNumber(num, 'numberbox') + "</span> ";
        html += " 当前序列号数量：<span id='xlhnum' class='gray'>" + xlhnum + "</span>&nbsp;&nbsp;<input type='button' onclick='deleteallxlh()' class='page' value='清空'>";
        html += "</div>";
        html += "</td></tr></table>";
        var win = app.createWindow("kuinlistXlh", "序列号管理", { canMove: true, closeButton: true, height: 400, width: 624, bgShadow: 30 });
        win.innerHTML = html;
    }
    cellIndex = h_xlh;
    imgObj = obj;
    xlhObj = setObjSQ;
    CellNum = num;
}

function addxlh() {
    var v = $("#lrxlh").val();
    if (v.length > 0) {
        var arrli = v.split(/\n/g)
        for (var i = 0; i < arrli.length ; i++) {
            var v1 = arrli[i].replace(/(^\s*)|(\s*$)/g, '');
            if (v1.length > 0) {
                $("<li style='width:100px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img style='width:10px;right:1px;top:1px;color:red;display:none;position:absolute' onclick='deleteli(this)' title='删除' src='" + window.SysConfig.VirPath + "/SYSN/skin/default/img/delete.jpg'/>" + v1 + "</li>").appendTo($("#target"));
            }
        }
        $("#lrxlh").val("");
        $("#xlhnum").text($("#target").children().size());
    }

    changeImg();
}

function changeImg(obj) {
    if (xlhObj == null) return;
    var x1 = new Array();
    var i = 0;
    if (obj) {
        var ID = obj.parentNode.parentNode.getAttribute("id");
        var setObjSQ = document.getElementById(ID.replace("_div", "_0"));//序列号编辑文本框
        var xlhs = setObjSQ.value.split(",");//序列号个数
        for (var i = 0; i < xlhs.length; i++) {
            x1[i] = xlhs[i];
            i++;
        }
    }
    else {
        $("#target").find("li").each(function () {
            x1[i] = $(this).text();
            i++;
        });
    }

    if (i == 0) {
        xlhObj.value = "";
        imgObj.src = window.SysConfig.VirPath + "/SYSN/skin/default/img/percent00.png";
    }
    else if (i == 1) {
        xlhObj.value = x1.join(",");
        imgObj.src = window.SysConfig.VirPath + "/SYSN/skin/default/img/percent100.png";
    }
    else if (i >= CellNum) {
        xlhObj.value = x1.join(",");
        imgObj.src = window.SysConfig.VirPath + "/SYSN/skin/default/img/percent100.png";
    }
    else if (i > 1) {
        xlhObj.value = x1.join(",");
        var imgid = "00";
        if (CellNum.length == 0) { CellNum = 0; }
        if (i >= parseInt(CellNum)) { imgid = "100"; }
        else if (parseInt(CellNum) != 0) {
            imgid = (parseInt(i / CellNum * 10) > 0 ? parseInt(i / CellNum * 10) + "0" : "10");
        }
        imgObj.src = window.SysConfig.VirPath + "/SYSN/skin/default/img/percent" + imgid + ".png";
    } else if (xlhObj != null) {
        xlhObj.value = "";
        imgObj.src = window.SysConfig.VirPath + "/SYSN/skin/default/img/percent100.png";
    }
    var lvw = parent.window["lvw_JsonData_NotDoProcedure"];
    __lvw_je_setcelldatav(lvw, rowIndex, cellIndex, xlhObj.value)
    if (!obj) { $("#lrxlh")[0].focus(); }
}

function showdel(obj) {
    var $close = $(obj).find("img");
    $close.css({ display: "block" });
}
function deleteaddxlh() {
    $("#lrxlh").val("");
    $("#lrxlh")[0].focus();
    changeImg();
}

function deleteallxlh() {
    if (confirm("确认清空？")) {
        $("#target li").remove();
        $("#xlhnum").text($("#target").children().size());
    }
    $("#lrxlh")[0].focus();
    changeImg();
}

function hiddendel(obj) {
    var $close = $(obj).find("img");
    $close.css({ display: "none" });
}

function deleteli(obj) {
    $(obj).parent().remove();
    $("#xlhnum").text($("#target").children().size());
    changeImg();
}