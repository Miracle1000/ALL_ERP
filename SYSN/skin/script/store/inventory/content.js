document.write("<style>#reportsearchbar button.zb-button{display:none}</style>");

function costDataByMonth(date1, typ) {
    switch (typ) {
        case 0:
            window.open("costAccount.ashx?date1=" + date1, "newwinCostAccount", "width=1100,height=600 ,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=200");
            break;
        case 1:
            costCurrData(date1);
            break;
        case 2 :
            window.open("costAccountBillList.ashx?date1=" + date1, "newwinCostAccountBillList", "width=1200,height=600 ,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=200");
            break;
    }
}

function showContentInfo(dataRow , v, dataType, id) {
    var htmlStr = v;
    var url = "";
    var h = "500";
    if (dataRow.date1 == "{@@SubTalRow@@}") { dataType = "10";}
    switch (dataType) { 
        case "1":
            //入库
            if (id != "0" && parseFloat(v) != 0) {
                url = "../../../../sysa/tongji/hzkc2.asp?kuid=" + app.pwurl(id) + "&datemonth=" + dataRow.date1;
            }
            break;
        case "2":
            //出库
            if (id != "0" && parseFloat(v) != 0) {
                url = "../../../../sysa/tongji/hzkc3.asp?kuid=" + app.pwurl(id) + "&datemonth=" + dataRow.date1;
            }
            break;
        case "3":
            if (id != "0" && parseFloat(v) != 0) {
                url = "costAccountPrice.ashx?ord=" + app.pwurl(id) + "&datemonth=" + dataRow.date1;
                h = "600";
            }
            break;
     }
    if (url.length > 0) {
        htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:window.open('" + url + "','newwin" + dataType + "','width=' + 960 + ',height=' + "+ h +" + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150')\">" + v + "</a>";
    }else if(id == "0" || parseFloat(v) == 0){
        htmlStr = "<span style='color:#ccc'>"+ v +"</span>";
    }
    return htmlStr;
}

function costCurrData(date1) {
    if (confirm("存货核算可能需要较长的时间，请耐心等待，确认存货核算吗？")) {
        app.ajax.regEvent("costCurrData");
        app.ajax.addParam("date1", date1);
        var r = app.ajax.send();
        if (r.length > 0) {
            alert("" + r + "");
        } else {
            alert("恭喜您,存货核算已完成!");
        }
        window.location.reload();
        //Report.Refresh();
    }
}

function resetCostDataByMonth(id) {
    if (confirm("确认取消吗？")) {
        app.ajax.regEvent("reSetCost");
        app.ajax.addParam("ID", id);
        var r = app.ajax.send();
        if (r.length > 0) {
            alert("" + r + "");
        } else {
            alert("已成功取消存货核算结果!");
        }
        window.location.reload();
        //Report.Refresh();
    }
}