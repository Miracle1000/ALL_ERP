/*处理数据库传回的字符串格式，将汇率显示在页面上*/
function getHlFormat(hlText, date) {
    var day = GetNumberOfDays("2000/1/1", date)
    if (hlText == null || hlText == '')
        return "未设置<img src='" + window.SysConfig.VirPath +"SYSN/skin/default/img/jiantou.gif'>"
            + "<span style='cursor: pointer' href='javascript:void(0);'"
            + "onclick = \"window.OpenUrlCC(window.location.href+'/../HlDetail.ashx?&ord=" + day + "','_blank',{left:0})\">添加汇率</span> "
    var tableHTML = "<table class='reportTable'>"
    var table = hlText.split(';')
    for (var i = 0; i < table.length; i++) {
        if (table[i] == null || table[i] == '') {
            break
        }
        tableHTML += "<tr>"
        var tableTd = table[i].split(",");
        for (var j = 0; j < tableTd.length; j++) {
            var tdName = j == 0 ? "<td class='report_td td_right'>" : "<td report_td class='td_left'>&nbsp;&nbsp;"
            tableHTML += tdName + tableTd[j] + "</td>"
        }
        tableHTML += "</tr>"
    }
    tableHTML += "</table>"
    return tableHTML
}

function GetNumberOfDays(date1, date2) {//获得天数
    //date1：开始日期，date2结束日期
    var a1 = Date.parse(new Date(date1));
    var a2 = Date.parse(new Date(date2));
    var day = parseInt((a2 - a1) / (1000 * 60 * 60 * 24));//核心：时间戳相减，然后除以天数
    return day
}

window.OpenUrlCC = function (url) {
    app.OpenUrl(url, "syswin",  "width=1070, height=640, top=110, left=220");
}