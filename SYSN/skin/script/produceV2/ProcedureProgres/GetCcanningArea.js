//-1-获得扫描区域焦点
//-2-设置实时回调得值
//-3-实时值变化制定值跟着变化
//-4-根据扫码标识判断指定字段
//jQuery(function ($) {
//    $("body").click(function (e) {
//        //扫码取值    
//        var BarCode = document.getElementById("BarCode_0");
//        var obj = document.activeElement;
//        if (!obj) return false;
//        //判断文本框获取焦点
//        if (obj.tagName != 'INPUT' && obj.tagName != 'SELECT' && obj.tagName != 'TEXTAREA' && obj.tagName != 'IFRAME' && obj.className != 'zb-button') {
//            BarCode.focus();
//        }
//    });

//});
//$(document).keypress(function (e) {
//    // 回车键事件  
//    if (e.which == 13) {
//        jQuery(".confirmButton").click();
//        show();
//    }
//});
//function show() {
//    var BarCode = document.getElementById("BarCode_0");
//    if (BarCode.value != "") {
//        //根据扫码规则类型选取对应字段赋值
//        //生产人员
//        if (BarCode.value.indexOf("scry") != -1) {
//            document.getElementById("cateid_tit").value = "";
//            document.getElementById("cateid_tit").value = BarCode.value;
//            BarCode.value = "";
//        }
//            //汇报数量
//        else if (BarCode.value.indexOf("hbsl") != -1) {
//            document.getElementById("num1_0").value = "";
//            document.getElementById("num1_0").value = BarCode.value;
//            BarCode.value = "";
//        }
//            //加工工时
//        else if (BarCode.value.indexOf("jggs") != -1) {
//            document.getElementById("wtime_0").value = "";
//            document.getElementById("wtime_0").value = BarCode.value;
//            BarCode.value = "";
//        }
//            //质检结果扫描合格自动保存
//        else if (BarCode.value.indexOf("ZJJG：1") != -1) {
//            document.getElementById("result_0check").value = "1";
//            var bt = document.getElementById("bill.dosave_btn");
//            bt.click();
//        }
//            //质检结果-返工
//        else if (BarCode.value.indexOf("ZJJG：2") != -1) {
//            document.getElementById("result_1check").value = "2";
//        }
//            //质检结果-作废
//        else if (BarCode.value.indexOf("ZJJG：3") != -1) {
//            document.getElementById("result_2check").value = "3";
//        }
//            //***********扫描派工ID****根据单据类型作为标识***************
//        else if (BarCode.value.indexOf("54002") != -1 || BarCode.value.indexOf("54005") != -1) {
//            document.getElementById("WAID_0").value = BarCode.value;
//            var WAID = document.getElementById("WAID_0").value;
//            app.ajax.regEvent("WABHCallback");
//            app.ajax.addParam("WAID", WAID);
//            app.ajax.send(function (data) {
//                var str = (data + "|||||").split("|");
//                var f = Bill.GetField("WABH2");
//                f.value = str[0];
//                $ID("WABH2_0").parentNode.parentNode.innerHTML = Bill.GetFieldHtml(f);
//                f = Bill.GetField("wcenter");
//                f.value = str[1];
//                $ID("wcenter_0").parentNode.parentNode.innerHTML = Bill.GetFieldHtml(f);
//                f = Bill.GetField("mdname");
//                f.value = str[2];
//                $ID("mdname_0").parentNode.parentNode.innerHTML = Bill.GetFieldHtml(f);


//            });
//        }
//            //扫描工序ID****根据单据类型作为标识***************
//        else if (BarCode.value.indexOf("51002") != -1) {
//            //alert(document.getElementById("WAID_0").value);
//            Bill._DCBack(BarCode, "AddSingleReportCallback", 1);
//            var WPID = BarCode.value;
//            var WAID = document.getElementById("WAID_0").value;
//            app.ajax.regEvent("SingleReportCallback");
//            app.ajax.addParam("WPID", WPID);
//            app.ajax.addParam("WAID", WAID);
//            app.ajax.send(function (data) {
//                var str = (data + "|||||").split("|");
//                var f = Bill.GetField("WFPAID");
//                f.value = str[0];
//                $ID("WFPAID_0").parentNode.parentNode.innerHTML = Bill.GetFieldHtml(f);
//                f = Bill.GetField("Procedure");
//                f.value = str[1];
//                $ID("Procedure_0").parentNode.parentNode.innerHTML = Bill.GetFieldHtml(f);
                
//            }); 

//        }
//        else {//序列号
//            document.getElementById("codeProduct_0").value = "";
//            document.getElementById("codeProduct_0").value = BarCode.value;
//            BarCode.value = "";
//        }
//        BarCode.value = "";
//    }

//}


function aa() {
    // BarCode.focus();
}

function computWindowSize() {
    var w=document.documentElement.clientWidth||document.body.clientWidth;
    if(w<1075){
        $("html").width(1075)
    }else{
        $("html").width("auto")
    }
    var topDiv = $("#gxhb_add");
    topDiv.parent().height(topDiv.height())
    //document.getElementById("BlockCustomFields").style.display = "none";
}

$(function () {
    computWindowSize()
})
window.onresize=function () {
    computWindowSize()
}