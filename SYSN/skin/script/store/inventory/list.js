function showHtml(complete1, id, date1,canHandle) {
    var htmlStr = "";
    htmlStr += "<button onclick=\"javascript:window.open('content.ashx?ord=" + app.pwurl(id) + "&date1="+date1+"','newwin','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')\">详情</button>"; 
    if (complete1 == "1") { 
        var canVisible ="";
        if(canHandle=="0"){canVisible = " disabled ";}
        htmlStr += "<button class='zb-button' "+ canVisible +" onclick=\"reSetInventory(" + id + ")\">取消核算</button>"; 
    }else{
        if (canHandle == "2") { 
            htmlStr += "<button onclick=\"costCurrData(" + id + ",'" + date1 + "')\">确定核算</button>";
        }
    }
    return htmlStr;
}

function reSetInventory(id) {
    if (confirm("确认取消吗？")) {
        app.ajax.regEvent("reSetCost");
        app.ajax.addParam("ID", id);
        var r = app.ajax.send();
        if (r.length > 0) {
            alert("" + r + "");
        } else {
            alert("已成功取消存货核算结果!");
        }
        Report.Refresh();
    }
}

function costCurrData(id,date1) {
    if (confirm("存货核算可能需要较长的时间，请耐心等待，确认存货核算吗？")) {
        app.ajax.regEvent("costCurrData");
        app.ajax.addParam("ID", id);
        app.ajax.addParam("date1", date1);
        var r = app.ajax.send();
        if (r.length > 0) {
            alert("" + r + "");
        } else {
            alert("恭喜您,存货核算已完成!");
        }
        Report.Refresh();
    }
}

function costOldData(stype) {
    var div = app.createWindow("costOldData", "历史存货核算", { height: 200, bgShadow:50,closeButton: true });
    var htm = "<div id='costmessage' style='margin:30px 50px 20px 50px'>存货核算依次按月进行，请点击“确定”核算历史数据！</div>" +
            "<div style='margin-left:50px'>&nbsp;</div>" +
            "<div style='margin-top:10px' align='center'><button class='zb-button' id='cost_btn' onclick=\"costOldDataProc()\">确定</button>"+
            "&nbsp;<button class='zb-button' id='close_btn' onclick=\"app.closeWindow('costOldData')\">取消</button></div>";
    div.innerHTML = htm;
}

$(function () {
    if ($("#costOld_btn").size() > 0) {
        costOldData(0);
    }
});

var isCost = false;
function costOldDataProc() {
    if (isCost == true) { app.closeWindow("costOldData"); return;}
    $("#cost_btn").attr("disabled", "disabled");
    $("#close_btn").attr("disabled", "disabled");
    $("#costmessage").html("<div>核算可能需要较长时间，请耐心等待...(<span style='color:red'>请不要关闭窗口</span>)</div>");
    setTimeout(function () {
        app.ajax.regEvent("costOldData");
        var r = app.ajax.send();
        try {
            if (r.length > 0) {
                $("#close_btn").removeAttr("disabled");
                $("#costmessage").html("<div style='color:red'>" + r + "</div>");
            } else {
                isCost = true;
                $("#costmessage").html("<div style='color:green'>恭喜您,历史存货核算已完成!</div>");
                $("#costOld_btn").hide();
                $("#cost_btn").removeAttr("disabled");
            }
        } catch (e) { }
        Report.Refresh();
    }, 100);
}