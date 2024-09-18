
function obselete(obj) {
    if (window.confirm('您确定要作废吗？')) {
        var ord = obj;
        app.ajax.regEvent("StopPriceRateCallback");
        app.ajax.addParam("ord", ord);
        app.ajax.send(function (data) {
            if (data == 1) {
                window.location.reload(); //刷新父窗口中的网页
                //window.close();
            } else {
                alert("作废失败！");
            }

        });
    } else {
        return false;
    }

}

function reload(obj) {
    if (window.confirm('您确定要取消作废吗？')) {
        var ord = obj;
        app.ajax.regEvent("OpenPriceRateCallback");
        app.ajax.addParam("ord", ord);
        app.ajax.send(function (data) {
            if (data == 1) {
                window.location.reload(); //刷新父窗口中的网页
                //window.close();
            } else if(data==-1){
                alert("工价编码存在重复，不允许取消作废！");
            } else {
                alert("取消作废失败！");
            }

        });
    } else {
        return false;
    }

}