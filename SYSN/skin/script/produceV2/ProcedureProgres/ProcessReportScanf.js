var onScanfTypeChange = function (_this) {
    var _val = $(":radio[name='ScanfType']:checked").val();
    var _txt = "请扫【周转码】开始生产";
    if (_val == "0")
        _txt = "请扫【周转码】开始汇报";

    $("[dbname='ScanfProcessHtml'] p").eq(1).html(_txt);
}

var triggerScanfTypeTopClick = function (_val, _date) {
    $(':radio[name=\'ScanfType\'][value=\'' + _val + '\']').click();
    var p1 = $("[dbname='ScanfProcessHtml'] p").eq(0);
    p1.show();
    p1.html("已于" + _date + "开始");
    $("[dbname='ScanfProcessHtml'] p").eq(1).html("请扫【周转码】开始汇报");
}