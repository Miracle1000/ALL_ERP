var object = new Object;
var MenuInx = 1;

////初始化日期
//var formatDateTime = function (date) {  
//    var y = date.getFullYear();  
//    var m = date.getMonth() + 1;  
//    m = m < 10 ? ('0' + m) : m;  
//    var d = date.getDate();  
//    d = d < 10 ? ('0' + d) : d;  
//    var h = date.getHours();  
//    var minute = date.getMinutes();  
//    minute = minute < 10 ? ('0' + minute) : minute;  
//    return y + '年' + m + '月' + d+'日 '+h+':'+minute;  
//}; 

//车间实际看板
function CBodyHtml() {
    var html = new Array();
    var myDate = new Date();
    var h = document.documentElement.clientHeight || document.body.clientHeight;
    html.push("<div id='Body_div' style='width:100%;height:"+h+"px'>")
    html.push("<div id='Content_div'>");
    html.push("<div id='Top_DateArea_div'>");
    if ((MenuInx == 1) || (MenuInx == 2 && object.Data[1].datadt.rows.length > 0))
    {
        html.push("<div id='Top_DateArea' style='font-size:13px;color:white;font-weight:bold'>" + object.Data[0] + "</div>");
    }
    html.push("</div>")
    html.push("<table id ='Main_tb' style='width:100%;line-height:48px;'><tbody>");
    if ((MenuInx == 1) || (MenuInx == 2 && object.Data[1].datadt.rows.length > 0))
    {
        html.push("<tr>");
        for (var i = 0; i < (MenuInx == 1 ? object.Data[1].headers.length : object.Data[1].datadt.headers.length); i++) {
            if (MenuInx==1 && i == 9 || (MenuInx == 2 && i == 5)){
            }
            else {
                html.push("<th style='font-size:13px;color:#00ff8e;'>" + (MenuInx == 1 ? object.Data[1].headers[i].name : object.Data[1].datadt.headers[i].name) + "</th>");
            }
        }
        html.push("</tr>");
    }
    for (var i = 0; i < (MenuInx == 1 ? object.Data[1].rows.length : object.Data[1].datadt.rows.length) ; i++) {
        html.push("<tr id='Main_tr'>");
        for (var j = 0; j < (MenuInx == 1 ? object.Data[1].rows[i].length : object.Data[1].datadt.rows[i].length) ; j++) {
            if (MenuInx == 1) {
                if (j == 9) { }
                else {
                    html.push("<td id='Main_td'><a style='font-size:13px;color:#00ff8e;font-weight:bold' href='javascript:;' onclick='javascript:app.OpenUrl(\"ActualMDBoard02.ashx?WCid=" + object.Data[1].rows[i][9] + "\")'>" + object.Data[1].rows[i][j] + "</a></td>");
                }
            }
            else {
                if (j == 5) { }
                else {
                    html.push("<td id='Main_td'><a style='font-size:13px;color:#00ff8e;font-weight:bold' href='javascript:;' onclick='javascript:app.OpenUrl(\"ActualMDBoard03.ashx?WFPAid=" + object.Data[1].datadt.rows[i][5] + "\")'>" + object.Data[1].datadt.rows[i][j] + "</a></td>");
                }
            }
        }
        html.push("</tr>");
    }
    html.push("</tbody></table>");
    html.push("</div>");
    document.write(html.join(""));    

    if (MenuInx == 2) {
        $(function () {
            var tb = $('#Main_tb');
            var wid = tb[0].width;
            var div = "<div id='WCInfo_tb'><span class='span_cla' style='border-left:none'>产线编号：" + object.Data[1].wcdata.wcbh + "</span>";
            div += "<span class='span_cla'>产线：" + object.Data[1].wcdata.wcname + "</span></div>";
            $(div).insertBefore(tb);
        })
    }
    
}

function ExtraBodyHtml()
{
    var html = new Array();
    var myDate = new Date();
    var h = screen.height;
    html.push("<div id='Body_div' style='width:100%;height:px'>");
    html.push("<div id='content_div_3'>");

    html.push("<div id='Top_DateArea_div'>");
    html.push("<div id='Top_DateArea' style='font-size:13px;color:white;font-weight:bold'>" + object.Data.nowtime + "</div>");
    html.push("</div>");
    html.push("<div class='content' style='border-bottom:none;border-right:none;text-overflow:ellipsis;overflow:hidden;word-break:break-all;white-space:nowrap;'><span style='color:white;margin-left:10px'>派工编号：</span>" + object.Data.wabh + "</div><div class='content' style='border-left:none;border-bottom:none'><span style='color:white;margin-left:10px'>数量：</span>" + object.Data.number + "</div>");
    html.push("<div class='content' style='border-right:none'><span style='color:white;margin-left:10px'>产品编号：</span>" + object.Data.probh + "</div><div class='content' style='border-left:none'><span style='color:white;margin-left:10px'>型号：</span>" + object.Data.prosn + "</div>");
    html.push("<div class='div_ss'><span class='border_span'>目标产出</span><span class='data_span'>" + object.Data.ordernum + "</span></div>");
    html.push("<div class='div_ss'><span class='border_span'>当前产出</span><span class='data_span'>" + object.Data.nownum + "</span></div>");
    html.push("<div class='div_ss'><span class='border_span'>达成率</span><span class='data_span'>" + object.Data.percent + "</span></div>");
    html.push("<div id='WC_div'><div style='color:#00ff8e;text-align:right;overflow:hidden;word-break:break-all;white-space:nowrap;text-overflow:ellipsis;padding:0 3px'><span style='color:white'>产线：</span>" + object.Data.wcname + "</div></div>");
    html.push("</div>");
    html.push("</div>");
    document.write(html.join(""));

    $(function () {
        var div = $('#content_div_3');
        var wid = div.height();
        div.css("margin-top", -wid / 2);
        
    })
}

function abc() {
    window.location.reload();
   // $('#gettime').text(getNowFormatDate());
}

$(function () {
    window.onload = function () {
    var h = document.body.scrollHeight;
    var div = $("#Body_div");
    var hei = div.height();
    if (hei <= h) {
        div.height(h)
    } else {
        div.height("auto")
    }
    }
    
})
window.createPage = function () {
    object.Data = window.PageInitParams[0];
    if (MenuInx != 3) {
        //加载内容 
        CBodyHtml();
        setInterval("abc()", 1000*300);
    }
    else {
        ExtraBodyHtml();
    }
}

