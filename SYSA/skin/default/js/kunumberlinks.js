function CLinkNumber(pagetype , productid, unit , ck)
{
	var d1 = $ID("date1_v_0").value;
	var d2 = $ID("date1_v_1").value;
	var win = window.open("kunumberlinks.asp?pagetype=" + pagetype + "&p=" + productid + "&u=" + unit + "&c=" + ck + "&d1=" + d1 + "&d2=" + d2, "", "width=1000,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100")
}
//初始加载帮助图片
$(function () {

    var pageurl = window.location.pathname;
    if (pageurl.indexOf("kunumberlinks.asp")>-1) {
        var meghtml = "<div id='bill_help_expaln_text1'  style='display:none;color:#2F496E;background-color: #b2dbfd;width: 600px;position: absolute;    left: 260px;padding: 15px;line-height: 29px;z-index: 1;margin-top:-18px;font-weight: normal;'><p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>报表说明：</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>1.检索时间指的是入库确认时间和出库确认时间</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>2.</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>期初变动前、本期变动为：数量默认为0</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>期初变动后为：检索开始时间前剩余库存数量</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>本期变动前为：上一笔本期变动的变动后数量</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>本期本次变动为：检索时间范围内所有确认出库单数量</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>本期变动后为：检索结束时间时库存剩余数量</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>本期变动后=期初变动后+本期入库-本期出库</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>3.</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>查看成本请参考产品成本核算表</p>";
        meghtml += "<a title='关闭' href='javascript:;'   onclick='closediv(2)' class='bill_help_expaln_close1'";
        meghtml += "style='position:absolute;top:-2px;right:5px;font-size:14'>×</a></div>";
    } else {

        var meghtml = "<div id='bill_help_expaln_text1'  style='display:none;color:#2F496E;background-color: #b2dbfd;width: 600px;position: absolute;    left: 240px;padding: 15px;line-height: 29px;z-index: 1;margin-top:-18px;font-weight: normal;'><p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>报表说明：</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>1.检索时间指的是入库确认时间和出库确认时间</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>2.产品系列检索的是此分类下所有产品的库存变动情况</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>3.</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>期初数据为：检索开始时间前库存剩余数量</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>本期入库为：检索时间范围内所有确认入库单数量</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'>本期出库为：检索时间范围内所有确认出库单数量</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;margin-left:15px;'> 期末数据为：检索结束时间时库存剩余数量 期末数据=期初数据+本期入库-本期出库</p>";
        meghtml += "<p style='font-size: 12px;font-family: 宋体;color: #2F496E;font-weight: normal;'>4.查看成本请参考产品成本核算表";

        meghtml += "<a title='关闭' href='javascript:;'   onclick='closediv(2)' class='bill_help_expaln_close1'";
        meghtml += "style='position:absolute;top:-2px;right:5px;font-size:14'>×</a></div>";

    }




    meghtml += "<div style=\"float:right;margin-top: 12px;margin-right: 48px;\"><span class='help_explan_ico' onclick=\"showHelpExplan(this)\"> ";
    meghtml += "</span></div>";
    $('#comm_itembarText').append(meghtml);

})
//显示内容
function showHelpExplan(type) {
    window.event.cancelBubble = true
    if (type == 1) {
        document.getElementById("bill_help_expaln_text").style.display = "block";
    } else { document.getElementById("bill_help_expaln_text1").style.display = "block"; }
}
//关闭提示框
function closediv(type) {

    window.event.cancelBubble = true
    if (type == 1) {
        document.getElementById("bill_help_expaln_text").style.display = "none";
    } else { document.getElementById("bill_help_expaln_text1").style.display = "none"; }

}

function opentourl(v)
{
    var ret = $("#date1_v_0").val();
    var ret2 = $("#date1_v_1").val();
    window.open("hzkc3_hz2.asp?cls=" + v + "&ret=" + ret + "&ret2=" + ret2 + "", "width=1000,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100")
}