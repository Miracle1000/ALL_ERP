function wapel()
{ 
    window.open('" + this.VirPath + "SYSN/view/produceV2/WorkAssign/WorkAssignDetail.ashx?ord=" + WAID + @"&view=details','','height=800,width=1150,scrollbars=yes,status =yes')
}
function showWPNames() {
    $("p[dbname = 'WPNames']").trigger('click');
}

window.ShowwTimeHtml = function (Wtime, UnitTime) {
    var result = '';
    switch (UnitTime) {
        case '0':
            result = '秒';
            break;
        case '1':
            result = '分钟';
            break;
        case '2':
            result = '小时';
            break;
        default:
            break;
    }
    return Wtime + '' + result;
}

function ReportScanfAutoSave() {
    var isSave = false;
    setTimeout(function () {
        var btn = $('.zb-button');
        for (var i = 0; i < btn.length; i++) {
            if (btn[i].innerHTML == '保存') {
                if (isSave == false) {
                    btn[i].click();
                    isSave = true;
                }
            }
        }
    }, 1000);
}