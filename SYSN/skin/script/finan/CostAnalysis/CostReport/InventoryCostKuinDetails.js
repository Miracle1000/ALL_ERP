$(function () {
    $('#PriceMode_0').bind('change', function () {
        var seleVal = $('#PriceMode_0  option:selected').val();
        if (seleVal == 2) {
            Report.Data.searchs[0].uiskin = 'datemonth';
        } else {
            Report.Data.searchs[0].uiskin = 'date';
        }
        $("td.rpt_sf_fd[dbname='date1']").html(Bill.CRangeField(Report.Data.searchs[0]));
        $("td.rpt_sf_fd[dbname='date1']")[0].setAttribute("uitype", Report.Data.searchs[0].uitype);
        $("td.rpt_sf_fd[dbname='date1']")[0].setAttribute("uiskin", Report.Data.searchs[0].uiskin);
    })
    $("td.rpt_sf_fd").eq(0).on("click", function () {
        var input = window.event.target ? window.event.target : "";
        if (input && input.tagName == "INPUT") {
            input.select();
        }
    })
})

Report.SetSearchData = function (stype) {
    Report.CurrSearchModel = stype;
    var sdiv = (stype == 0 ? $ID("commfieldsBox") : $ID("adfieldsBox"));
    var ndiv = (stype == 0 ? $ID("adfieldsBox") : $ID("commfieldsBox"));
    var cells = $(sdiv).find("td[searchitemcell=1]");
    Report.CurrSearchDatas = [];
    Report.searchCon = [];//存储所有的检索条件的值，用来显示顶部的检索条件
    //检测单据日期是否都为清空状态,都为清空状态给默认值当月
    var date1_0 = document.getElementsByName("date1")[0].value;
    var date1_1 = document.getElementsByName("date1")[1].value;
    var date = new Date(), y = date.getFullYear(), m = date.getMonth(), d = date.getDate();
    var firstDay = new Date(y, m, 1);
    var lastDay = new Date(y, m + 1, 0);
    if (date1_0 == "") {
        //var strFirstDay = formatDate(firstDay, "yyyy-MM-dd");
        //document.getElementsByName("date1")[0].value = strFirstDay;
        //document.getElementsByName("date1")[1].value = strLastDay;
    }
    if (date1_1 == "") {
        var seleVal = $('#PriceMode_0  option:selected').val();
        var format = "yyyy-MM-dd";
        if (seleVal == 2) { format = "yyyy-MM"; }
        var strLastDay = formatDate(lastDay, format);
        document.getElementsByName("date1")[1].value = strLastDay;
    }
    var searCells = $("#fieldsBox").find("td[dbname]");
    for (var i = 0, len = searCells.length; i < len; i++) {
        Bill.getBillDataItem(searCells[i], function (dbname, value, obj) {
            Report.searchCon.push(value)
        });
    }
    var adSearCells = $("#adfieldsBox").find("td[dbname]");
    for (var i = 0, len2 = adSearCells.length; i < len2; i++) {
        Bill.getBillDataItem(adSearCells[i], function (dbname, value, obj) {
            Report.searchCon.push(value)
        });
    }
    for (var i = 0; i < cells.length; i++) {
        Bill.getBillDataItem(cells[i], aaa);
        function aaa(dbname, value, obj) {
            var dbtype = obj ? (obj.drfomat || obj) : "";  //linkbox返回值 obj是对象，一般是空或者是drformat值
            var uiskin = cells[i].getAttribute("uiskin") || "";
            Report.CurrSearchDatas.push({ "n": dbname, "v": value, "t": dbtype, "data": aaa.data, uitype: cells[i].getAttribute("uitype"), "obj": obj, "uiskin": uiskin });
        }
    }
    cells = $(ndiv).find("td[searchitemcell=1]");
    for (var i = 0; i < cells.length; i++) {
        Bill.getBillDataItem(cells[i], bbb);
        function bbb(dbname, value, obj) {
            var dbtype = obj ? (obj.drfomat || obj) : "";
            for (var ii = 0; ii < Report.CurrSearchDatas.length; ii++) {
                if (Report.CurrSearchDatas[ii].n == dbname) { return; }
            }
            if (cells[i].outerHTML.indexOf("nul=\"1\"") > 0) {
                Report.CurrSearchDatas.push({ "n": dbname, "v": value, "t": dbtype, "data": bbb.data, uitype: cells[i].getAttribute("uitype"), "obj": obj });
            } else {
                Report.CurrSearchDatas.push({ "n": dbname, "v": "", "t": dbtype, "data": bbb.data, uitype: cells[i].getAttribute("uitype"), "obj": obj });
            }
        }
    }
    window.realAlert = window.alert;
    window.alert = function () { };
    if (app.DataVerification(document.body, null, 1) == true)  //单据数据校验
    {
        Report.showTopSearchCondition(stype);
        if ($ID("SearchItemsPlayer") && $ID("SearchItemsPlayer").getElementsByTagName("a").length == 0) {
            $ID("SearchItemsPlayer").style.display = "none"
        }
    }
    window.alert = window.realAlert;
}

function formatDate(date, format) {
    var o = {
        "M+": date.getMonth() + 1, // month
        "d+": date.getDate(), // day
        "h+": date.getHours(), // hour
        "m+": date.getMinutes(), // minute
        "s+": date.getSeconds(), // second
        "q+": Math.floor((date.getMonth() + 3) / 3), // quarter
        "S": date.getMilliseconds()
    }
    if (/(y+)/.test(format)) {
        format = format.replace(RegExp.$1, (date.getFullYear() + "")
            .substr(4 - RegExp.$1.length));
    }
    for (var k in o) {
        if (new RegExp("(" + k + ")").test(format)) {
            format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k]
                : ("00" + o[k]).substr(("" + o[k]).length));
        }
    }
    return format;
}