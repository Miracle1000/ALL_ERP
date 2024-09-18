$(function () {
    $("#lvwbtmtooldiv_ku DIV").eq(2).before("<div class='lvw_btmtoolbtn'><input type='button' onclick='bathzd(1)' class='zb-button'  value='批量指定'></div><div class='lvw_btmtoolbtn'><input type='button' onclick='bathzd(2)' class='zb-button'  value='全部指定'></div>");
})
function bathzd(TYPE)
{
    if(TYPE==2){
        Kuout__lvw_je_proSelectBox("ku", 1);
    }
    var num1 = $("#num2_0").val().replace(",", "");;//未指定数量
    //var num1 = $("#num1_0").val().replace(",", "");;//应指定数量
    var jlvw = window['lvw_JsonData_ku'];
    var CKcellindex = ListView.GetHeaderByDBName(jlvw, "num1").i;
    var Num2cellindex = ListView.GetHeaderByDBName(jlvw, "num2").i;
    var sumnum = 0;
    var Isnode = 0
    var ct = 0;
    var sumzdnum = 0;
    if (num1 == 0) { return;}
    for (var i = 0; i < jlvw.rows.length; i++) {
        if (jlvw.rows[i][CKcellindex] == 0 || jlvw.rows[i][CKcellindex] == undefined || jlvw.rows[i][CKcellindex] == "") {
            if (jlvw.rows[i][1] == 1 || TYPE == 2) {
                ct++;
                var num = jlvw.rows[i][Num2cellindex];
                sumnum += num
                if (sumnum > num1) {

                    if (Isnode == 1) {
                        jlvw.rows[i][CKcellindex] = 0;
                    }
                    else {
                        jlvw.rows[i][1] = 1;
                        var cellnum = num - (sumnum - num1);
                        if (ct == jlvw.rows.length && parseFloat(app.FormatNumber(cellnum, "numberbox")) > parseFloat(app.FormatNumber(num1, "numberbox"))) {
                            jlvw.rows[i][CKcellindex] = parseFloat(num1) - parseFloat(sumzdnum)
                        } else {
                            jlvw.rows[i][CKcellindex] = cellnum > 0 ? cellnum : 0;
                        }

                        Isnode = 1
                    }
                }
                else {
                    jlvw.rows[i][CKcellindex] = jlvw.rows[i][Num2cellindex];

                }
            }
        }
        else if (jlvw.rows[i][1] == 1)
        {
            ct++;
            sumzdnum += parseFloat(app.FormatNumber(jlvw.rows[i][CKcellindex], "numberbox"));
        }
        //else { jlvw.rows[i][CKcellindex] = 0; }
        __lvw_je_redrawCell(jlvw, jlvw.headers[CKcellindex], i, jlvw.headers[CKcellindex].showindex);
        $($ID("@ku_num1_" + i + "_" + CKcellindex + "_0")).change();
    }
    if (ct == 0) {alert("未选中需要操作的行")}
    ___ReSumListViewByJsonData(jlvw)
    ___RefreshListViewByJson(jlvw);
    ___RefreshListViewselPos(jlvw);
    Bill.MainFieldsFormulaHandleProc();

}



//处理全选反选框
function Kuout__lvw_je_proSelectBox(id, type) {
    var lvw = window["lvw_JsonData_" + id];
    var rows = lvw.rows;
    var _sindex = lvw.selectallIndex || __lvw_je_show_inputIndex(lvw);
    var topSelect = document.getElementById('lvw_1_jec_qx' + id);
    var allSelect = document.getElementById('lvw_je_selectAll_' + id);
    var allchoose = true;
    if (type == 1) {//全选
        if (allSelect) {
                allchoose = true;
                if (topSelect) { topSelect.checked = true; }
                __lvw_setCheckedRows(id, 1);
        }
        $ID("lvw_je_exselectAll_" + id).checked = false;//点击全选时，取消反选的选中状态
    } 
    ___RefreshListViewByJson(lvw);
    for (var i = 0; i < rows.length; i++) {
        if (lvw.rows[i][0] == window.ListView.NewRowSignKey) { break; }
        if (ListView.IsVisibleRow(lvw, i) == false) { continue; }
        if (lvw.rows[i][_sindex] == 0) {
            allchoose = false;
            break;
        }
    }
    if (allchoose) {
        if (topSelect) { topSelect.checked = true; }
        if (allSelect) { allSelect.checked = true; }
    } else {
        if (topSelect) { topSelect.checked = false; }
        if (allSelect) { allSelect.checked = false; }
    }
}

function lvwnum1zd(num1,inx)
{
    window.opener.updatelvwcellzd(num1, inx);
}
function updatenum2()
{

    var num2 = $("#num2_0").val();
    if (parseFloat(num2) < 0)
    {
        try {
            $("#num2_0").prev("span.billfieldreadonlymodecont").text( app.FormatNumber(0, "numberbox"));
        }
        catch (ex) {
          
        }
    }

}
function Batchassignment(a, b, c, d, e) {
    var lvw = window['lvw_JsonData_ku'];
    if (lvw.headers[d].dbname.toLowerCase() == "assistnum") { return; }
    var num2 = $("#num2_0").val();
    var rows = lvw.rows;
    try {
            if (b == -1) {
                var v = 0;
                v = parseFloat(c.length) * parseFloat(e) > parseFloat($("#num1_0").val()) ? 0 : parseFloat($("#num1_0").val()) - (parseFloat(c.length) * parseFloat(e)) < 0 ? 0 : parseFloat($("#num1_0").val()) - (parseFloat(c.length) * parseFloat(e))
                $("#num2_0").prev("span.billfieldreadonlymodecont").text(app.FormatNumber(v, "numberbox"));

            } else {

                if (parseFloat(num2) < 0) {
                    $("#num2_0").prev("span.billfieldreadonlymodecont").text(app.FormatNumber(0, "numberbox"));
                }
            }
    } catch (ex)
    {

    }
}

var imgObj = null;
var xlhObj = null;
var rowIndex = 0, cellIndex = -1;
var CellNum = 0;
function SetAllXlhSQ(obj) {
    var bd = Bill.Data.groups[0].fields;
    var show = false;
    var ProductAttr1T = "";
    var ProductAttr2T = "";
    var ProductAttr1V = "";
    var ProductAttr2V = "";
    for (var i = 0; i < bd.length; i++) {
        if (bd[i].dbname === "ProductAttr1") {
            show = true;
            ProductAttr1T = bd[i].title
            ProductAttr1V = bd[i].defvalue
        }
        if (bd[i].dbname === "ProductAttr2") {
            ProductAttr2T = bd[i].title
            ProductAttr2V = bd[i].defvalue
        }
    }
    var ProductAttrStr1 = "";
    var ProductAttrStr2 = "";
    if (show) {
        ProductAttrStr1 = "<span style='width:42%;overflow: hidden;text-overflow:ellipsis;white-space: nowrap;'>" + ProductAttr1T + "：" + ProductAttr1V + "</span>";
        ProductAttrStr2 = "<span style='width:27%;overflow: hidden;text-overflow:ellipsis;white-space: nowrap;'>" + ProductAttr2T + "：" + ProductAttr2V + "</span>";
    }
    var mainData = Bill.Data.groups[0].fields;
    var title = mainData[0].links[0].title; //产品名称
    var order1 = mainData[1].defvalue;    //产品编号
    var type1 = mainData[2].defvalue;   //产品型号
    var unit = mainData[3].defvalue;   //单位
    var num = mainData[show ? 6 : 4].defvalue;        //出库确认数量
    var html = "<table style='width:100%;height:100%;'><tr style='width:100%;'>";
    html += "<td colspan='2'><div style='width:783px;padding-left:3px;margin:5px 4px;height:65px;background-color:#E0F2FF;border:1px solid #ccc;color:#4A7098;font-weight:bold;display: flex;justify-content: space-between;flex-wrap:wrap;align-items:center'>";
    html += "<div style='width:42%;overflow: hidden;text-overflow:ellipsis;white-space: nowrap;'>产品名称：" + title + "</div>";
    html += "<div style='width:27%;overflow: hidden;text-overflow:ellipsis;white-space: nowrap;'>编号：" + order1 + "</div>";
    html += "<div style='width:27%;overflow: hidden;text-overflow:ellipsis;white-space: nowrap;'>型号：" + type1 + "</div>" + ProductAttrStr1 + ProductAttrStr2;
    html += "<div style='width:27%;overflow: hidden;text-overflow:ellipsis;white-space: nowrap;'>单位：" + unit + "</div></div></td></tr>"
    html += "<tr style='margin-top:-8px'><td style='width:23%;height:16%'><div style='height:308px;margin:2px;'><textarea id='lrxlh' style='width:98%;height:98%;border:1px solid #ccc;overflow:auto;cursor:default'></textarea></div>";
    html += "<div style='width:100%;margin-top:3px;display: flex;justify-content: space-between;'>";
    html += " <input type='button' class='zb-button' onclick='deduplication()' class='page' value='去重'>";
    html += " <input type='button' class='zb-button' onclick='addxlh()' class='page' value='加入'>";
    html += " <input type='button' class='zb-button' onclick='deleteaddxlh()' class='page' value='重置'>";
    html += "</div>"
    html += "</td><td style='width:77%;height:74%'>";
    html += "<div id='target' class='div_li' style='height:308px;margin:3px;margin-left:0px;border:1px solid #ccc;overflow:auto;cursor:default;padding-bottom:3px;' >"
    html += "</div>";
    html += "<div style='width:100%;text-align:right;margin-right:10px;margin-top:5px;'>";
    html += " 出库确认数量：<span class='gray'>" + num + "</span> ";
    html += " 当前序列号数量：<span id='xlhnum' class='gray'>0</span>&nbsp;&nbsp;<input type='button' class='zb-button' onclick='deleteabnormalxlh()' class='page' value='异常清空'>&nbsp;&nbsp;<input type='button' class='zb-button' onclick='deleteallxlh()' class='page' value='全部清空'>";
    html += "</div>";
    html += "</td></tr><tr style='width:100%;height:10%'><td colspan='2'><div style='display:flex;'><div id='tips' style='color:red;width:45%;visibility: hidden'>序列号标红说明此序列号不存在，需要手动删除。</div><div style='width:55%'><input type='button' class='zb-button' value='确定' onclick='saveXLH()'/></div></div></td></tr></table>";
    var win = app.createWindow("kuinlistXlh", "批量指定序列号", { canMove: true, closeButton: true, height: 530, width: 820, bgShadow: 30 });
    win.innerHTML = html;

    //cellIndex = h_xlh;
    imgObj = obj;
    //xlhObj = setObjSQ;
    //CellNum = num;
}
function addxlh() {
    var v = $("#lrxlh").val();
    if (v.length > 0) {
        var arrli = v.split(/\n|,/g)
        for (var i = 0; i < arrli.length ; i++) {
            var v1 = arrli[i].replace(/(^\s*)|(\s*$)/g, '');
            if (v1.length > 0) {
                $("<li title=\"" + v1.replace(/\'/g, "\'") + "\" style='width:105px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img style='width:10px;right:1px;top:1px;color:red;display:none;position:absolute' onclick='deleteli(this)' title='删除' src='" + window.SysConfig.VirPath + "/SYSN/skin/default/img/delete.jpg'/>" + v1 + "</li>").appendTo($("#target"));
            }
        }
        $("#lrxlh").val("");
        $("#xlhnum").text($("#target").children().size());
    }
    $("#lrxlh")[0].focus();
}
function getRepeatItem(arr) {
    const map = new Map();
    var needDel = [];
    for (let i = 0; i < arr.length; i++) {
        var boolM=false;
        map.forEach(function (key) {
            if (key === arr[i]) { boolM= true; }
        })
        if (boolM) {
            needDel.push(i);
        } else {
            map.set("val"+i, arr[i]);
        }
    }
    var j = 0;
    for (var i = 0; i < needDel.length; i++) {
        arr.splice(needDel[i] - j, 1);
        j++;
    }
}
function deduplication() {
    var v = $("#lrxlh").val();
    if (v.length > 0) {
        var arrli = v.split(/\n|,/g)
        for (var i = 0; i < arrli.length ; i++) {
            var v1 = arrli[i].replace(/(^\s*)|(\s*$)/g, '');
        }
        getRepeatItem(arrli)
        $("#lrxlh").val(arrli.join("\n"));
    }
    $("#lrxlh")[0].focus();
}

function showdel(obj) {
    var $close = $(obj).find("img");
    $close.css({ display: "block" });
}
function deleteaddxlh() {
    $("#lrxlh").val("");
    $("#lrxlh")[0].focus();
}

function deleteallxlh() {
    if (confirm("确认清空？")) {
        $("#target li").remove();
        $("#xlhnum").text($("#target").children().size());
    }
    $("#lrxlh")[0].focus();
}
function deleteabnormalxlh() {
    if (confirm("确认清空？")) {
        $("#target li[del='1']").remove();
        $("#xlhnum").text($("#target").children().size());
    }
    $("#lrxlh")[0].focus();
}
function hiddendel(obj) {
    var $close = $(obj).find("img");
    $close.css({ display: "none" });
}

function deleteli(obj) {
    $(obj).parent().remove();
    $("#xlhnum").text($("#target").children().size());
}
function saveXLH() {
    var lvw = lvw_JsonData_ku.rows;
    $("div#target li").each(function () {
        var IsMatch = false;
        if (lvw) {
            for (var i = 0; i < lvw.length;i++){
                if (lvw[i][18].toString().replace(/(^\s*)|(\s*$)/g, '') === $(this).attr("title").toString()) {
                    IsMatch = true;
                }
            }
        }
        if (!IsMatch) {
            $(this).css({ "border": "1px solid red", "box-shadow": "0 0 3px 1px red" }).attr("del", "1");
        }
    })
    var mainContainer = $('div#target');
    if (mainContainer.find('li[del="1"]').length>0) {
        scrollToContainer = mainContainer.find('li[del="1"]');//滚动到<div id="target">中第一个异常li的位置
        //动画效果
        mainContainer.animate({
            scrollTop: scrollToContainer.offset().top - mainContainer.offset().top + mainContainer.scrollTop()
        }, 500);//2秒滑动到指定位置
        $("#tips").css("visibility", "visible")
    }
    else {
        $("div#target li").each(function () {
            var IsMatch = false;
            if (lvw_JsonData_ku.rows) {
                for (var i = 0; i < lvw_JsonData_ku.rows.length; i++) {
                    if (lvw_JsonData_ku.rows[i][18].toString() === $(this).attr("title").toString()) {
                        lvw_JsonData_ku.rows[i][14] = lvw_JsonData_ku.rows[i][13];//让指定数量等于库存数量，防止老数据有数量不等于1但有序列号的情况
                        __lvw_je_updateCellValue('ku', i, 14, (lvw_JsonData_ku.rows[i][13]), true, undefined, true);
                    }
                }
            }
        })
        ___RefreshListViewByJson(lvw_JsonData_ku);
        app.closeWindow('kuinlistXlh', true);
    }
}