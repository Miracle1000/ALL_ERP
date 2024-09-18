var imgObj = null;
var xlhObj = null;
var rowIndex = 0, cellIndex = -1;
var CellNum = 0;
function SetAllXlhSQ(obj) {
    var lvw = parent.window["lvw_JsonData_kuinlist"];
    var ID = obj.parentNode.parentNode.getAttribute("id");
    rowIndex = ID.split("_")[ID.split("_").length - 3];
    if (lvw.rows[rowIndex][0] == ListView.NewRowSignKey) { return;}

    var hd = lvw.headers;
    var rows = lvw.rows;
    var h_title = -1;
    var h_order1 = -1;
    var h_type1 = -1;
    var h_num1 = -1;
    var h_xlh = -1
    for (var i = 0; i < hd.length; i++) {
        if (hd[i].dbname == "title") { h_title = i; }
        if (hd[i].dbname == "order1") { h_order1 = i; }
        if (hd[i].dbname == "type1") { h_type1 = i; }
        if (hd[i].dbname == "num1") { h_num1 = i; }
        if (hd[i].dbname == "xlh") { h_xlh = i; }
    }

    var title = lvw.rows[rowIndex][h_title]; //产品名称
    var order1 = lvw.rows[rowIndex][h_order1];    //产品编号
    var type1 = lvw.rows[rowIndex][h_type1];   //产品型号
    var num = lvw.rows[rowIndex][h_num1];        //入库数量
    if (num.length == 0) { num = 0; }
    num = app.FormatNumber(num, "numberbox"); 

    var AllTitle = title.length==0 ? "" : "  【产品名称：" + title + (order1.length > 0 ? "	产品编号：" + order1 : "") + (type1.length > 0 ? "   产品型号：" + type1 : "") + "】";

    var setObjSQ = document.getElementById(ID.replace("_div", "_0"));//序列号编辑文本框

    var xlh = setObjSQ.value;
    var xlhs = xlh.split("\1");//序列号个数
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
    html += " 入库申请数量：<span class='gray'>" + num + "</span> ";
    html += " 当前序列号数量：<span id='xlhnum' class='gray'>" + xlhnum + "</span>&nbsp;&nbsp;<input type='button' onclick='deleteallxlh()' class='page' value='清空'>";
    html += "</div>";
    html += "</td></tr></table>";
    var win = app.createWindow("kuinlistXlh", "序列号管理" + AllTitle, { canMove: true, closeButton: true, height: 400, width: 624, bgShadow: 30 });
    win.innerHTML = html;

    cellIndex = h_xlh;
    imgObj = obj;
    xlhObj = setObjSQ;
    CellNum = num;
}

app.OnCloseWindow = function (id) {
    if (id == "sdksysautokeylistdiv") { return;}
    if (xlhObj == null) return;
    var x1 = new Array();
    var i = 0;
    $("#target").find("li").each(function () {
        x1[i] = $(this).text();
        i++;
    });
    if (i > 0) {
        xlhObj.value = x1.join("\1");
        var imgid = "00";
        if (CellNum.length == 0) { CellNum = 0; }
        if (i >= parseInt(CellNum)) { imgid = "100"; }
        else if (parseInt(CellNum) != 0) {
            imgid = (parseInt(i / CellNum * 10) > 0 ? parseInt(i / CellNum * 10) + "0" : "10");
        }
        imgObj.src = window.SysConfig.VirPath + "/SYSN/skin/default/img/percent" + imgid + ".png";
    } else if (xlhObj!=null) {
        xlhObj.value = "";
        imgObj.src = window.SysConfig.VirPath + "/SYSN/skin/default/img/percent100.png";
    }
    var lvw = parent.window["lvw_JsonData_kuinlist"];
    lvw.rows[rowIndex][cellIndex] = xlhObj.value;
    //parent.__lvw_je_updateCellValue(lvw.id, rowIndex, cellIndex, xlhObj.value);
    //parent.app.closeWindow('kuinlistXlh');
}

function addxlh() {
    var v = $("#lrxlh").val();
    if (v.length > 0) {
        var arrli = v.split(/\n/g)
        for (var i = 0; i < arrli.length ; i++) {
            var v1 = arrli[i].replace(/(^\s*)|(\s*$)/g, '');
            if (v1.length > 0) {
                $("<li style='width:100px;position:relative' onmouseover='showdel(this)' onmouseout='hiddendel(this)'><img style='width:10px;right:1px;top:1px;color:red;display:none;position:absolute' onclick='deleteli(this)' title='删除' src='"+ window.SysConfig.VirPath + "/SYSN/skin/default/img/delete.jpg'/>" + v1 + "</li>").appendTo($("#target"));
            }
        }
        $("#lrxlh").val("");
        $("#xlhnum").text($("#target").children().size());
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

function hiddendel(obj) {
    var $close = $(obj).find("img");
    $close.css({ display: "none" });
}

function deleteli(obj) {
    $(obj).parent().remove();
    $("#xlhnum").text($("#target").children().size());
}

window.onlvwUpdateCellValue = function (lvw, rowindex, cellindex, v, isztlr, isEof, disrefresh, oldvalue) {
    if (window.___Refreshinglvw == true || isztlr==0) { return; }
    var header = lvw.headers[cellindex];
    var dbname = header.dbname;
    if (dbname == "num1") {
        CurrFormulaInfoHandle(lvw, rowindex, cellindex, "commUnitAttr", v , true);
    }
}
//通过公式获取仓库中的Id给ku字段赋值
function getKuId(obj) {
    return obj && obj.v ? obj.v.fieldvalue : "";
}
//查看二维码
function OpenCode(str)
{
    window.open(window.SysConfig.VirPath + "SYSA/inc/img.asp?url=" + escape(str) + "");
}

//主题链接
function showDetailByColumn(v, ord, canDetail, type,ptype,potype, fromBillType) {
    var htmlStr = v;
    if (canDetail === "1" && v != "" && ord != "0") {
        var domain = "";
        var column = "";
        var page = "";
        var condition = "";
        switch (type) {
            case "1":
                domain = "SYSN";
                column = "view/store/caigou";
                page = "caigoudetails.ashx";
                condition = "ord=" + app.pwurl(ord) + "&view=details";
                break;
            case "2":
                domain = "SYSA";
                column = "contractth";
                page = "content.asp";
                condition = "&view=details&ord=" + app.pwurl(ord) + "";
                break;
            case "6":
                domain = "SYSA";
                column = "store";
                page = "contenthh.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "7":
                domain = "SYSA";
                column = "store";
                page = "contentdb.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "8":
                domain = "SYSA";
                column = "store";
                page = "contentpd2.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "9":
                domain = "SYSA";
                column = "store";
                page = "contentzz.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "10":
                domain = "SYSA";
                column = "store";
                page = "contentck.asp";
                condition = "ord=" + app.pwurl(ord) + "";
                break;
            case "3"://退料入库
                domain = "SYSN";
                column = "view/produceV2/ReturnMaterial";
                page = "ReturnMaterialAdd.ashx";
                condition = "ord=" + app.pwurl(ord) + "&view=details";
                break;
            case "16"://废料入库
                domain = "SYSN";
                column = "view/produceV2/Waste";
                page = "WasteAdd.ashx";
                condition = "ord=" + app.pwurl(ord) + "&view=details";
                break;
        }
        if (ptype == "0" || fromBillType == "54002") {
            //派工入库
            domain = "SYSN";
            column = "view/produceV2/WorkAssign";
            page = "WorkAssignDetail.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        }
        if (ptype == "1" || fromBillType == "54005") {
            //返工入库
            domain = "SYSN";
            column = "view/produceV2/Rework";
            page = "ReworkDetail.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        }
        if (potype == "3" || potype == "4" || fromBillType == "54004") {
            //派工质检入库
            domain = "SYSN";
            column = "view/produceV2/QualityControl/WorkOrder";
            page = "QualityWorkOrderDetail.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        }
        if (potype == "1" || fromBillType == "54009") {
            //委外质检入库
            domain = "SYSN";
            column = "view/produceV2/QualityControl/OutSource";
            page = "QualityOutSourceDetail.ashx";
            condition = "ord=" + app.pwurl(ord) + "&view=details";
        }
        if (domain != "" && column != "" && page != "" && condition != "") {
            htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + window.SysConfig.VirPath + "" + domain + "/" + column + "/" + page + "?" + condition + "','newwin','width=' + 960 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
        }
    }
    return htmlStr;
}

window.SerialNumberBoxHtml = function (field, datas, numbers) {
    var htm = [];
    htm.push("<span dbname='" + field.dbname + "' uitype='" + field.uitype + "' name='" + field.dbname + "' id='" + field.dbname + "' value='" + datas.SerialNumbers + "'>" + numbers[0]);
    field.typejson = field.typejson.replace("editable", "readonly");
    htm.push("<img name='serial' src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/percent100.png' onclick='Bill.openSerialNumberPage(" + field.typejson + ",$(this)," + datas.CreateType + ",\"" + encodeURIComponent(field.dbname) + "\"," + datas.SerialNumbers.split(',').length + "," + JSON.stringify(datas) + ")' alt='点击显示更多' style='margin-left:5px;width:12px;height:18px;cursor:pointer;' >");
    htm.push("</span>");
    return htm.join("");
}