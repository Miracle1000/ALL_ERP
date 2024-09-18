
function StopBtn(obj) {
    if (window.confirm('工序委外终止后不可以继续生成付款、收票、物料登记、质检后续单据，已生成的单据不受影响，您确定终止吗？')) {
        var ord = obj;
        app.ajax.regEvent("OutProcedureCallback");
        app.ajax.addParam("ord", ord);
        app.ajax.send(function (data) {
            if (data == 1) {
                alert("终止成功！");
                window.location.reload();
            } else {
                alert("终止失败！");
            }

        });
    } else {
        return false;
    }
   
}

function QXStopBtn(obj) {
    if (window.confirm('您确定要取消终止吗？')) {
        var ord = obj;
        app.ajax.regEvent("QXOutProcedureCallback");
        app.ajax.addParam("ord", ord);
        app.ajax.send(function (data) {
            if (data == 1) {
                alert("取消终止成功！");
                window.location.reload();
            } else {
                alert("取消终止失败！");
            }

        });
    } else {
        return false;
    }

}