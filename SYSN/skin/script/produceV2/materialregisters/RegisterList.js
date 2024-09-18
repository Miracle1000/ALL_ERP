function UpdateKuinMR(RequestPageType, Route) {
    var EventType = (RequestPageType == undefined ? "SysReportCallBack" : RequestPageType);
    var AnalysisList = window.lvw_JsonData_AnalysisList;
    LoadDataHandleProc(EventType, "App_UpdateKuinMR", "入库登记匹配");
}
//BUG24108 Sword 2018-06-11 lrp、mrp分析页面，将数量改大，点击分析返回结果处理有误
var isFinish = false;

function LoadDataHandleProc(EventType , handleType, PName, attrs) {
    var div = CreateDiv(handleType, PName);
    if (EventType == "SysBillCallBack") {
        Bill.CallBackParams("入库登记匹配", handleType, false, handleType);
    } else {
        app.ajax.regEvent(EventType); 
        app.ajax.addParam("actionname", handleType);
        app.ajax.addParam("__cmdtag", handleType);
    }

    window.tmp9527 = null;
    var coutMonth = 1;
    var currInx = 1;
    var month = "";
    app.ajax.send(
        function (okmsg) {
            if (okmsg.indexOf("Status: err ") == 0) {
                var intro = okmsg.replace("Status: err ", "")
                showProcMessage(div, 300, intro, 100,"");
            } else {
                var hasCallback = okmsg.indexOf("Status: ALLOK") == 0;
                var intro = okmsg.replace("Status: ok ", "").replace("Status: ALLOK", "");
                showProcMessage(div, 300, hasCallback ? "恭喜您，" + PName + "完成！" : PName + "完毕", 100, hasCallback ? "" : intro);
                if (hasCallback) {
                    window.BillSysCallBackObj = window.tmp9527;
                    Bill.HandleCallbackPrco();
                    app.closeWindow("Do" + handleType, true);
                }
            }
            isFinish = true;
        },
        function (procmsg) {
            isFinish = false;
            if (procmsg.indexOf("Status: ") >= 0) {
                var msg = procmsg.split("Status: ")[1].replace(/\s/g, "").split(".");
                var ext = 0;       
                var pv = parseInt(msg[0]);
                var pmsg = msg[1];
                var intro = pv + ". " + pmsg;
                var persent = 0;
                if (pv < 10) {
                    pv = (ext + parseInt(pv * 7 / coutMonth))* 3;
                    persent = ext + parseInt(pv /3 / coutMonth);
                    pmsg = month +"正在进行" +  PName + "，时间可能较长，请稍后 ......"
                } else {
                    pv = ext*3 + 290 / coutMonth;
                    persent = ext + parseInt(pv / 3 / coutMonth);
                    pmsg = month + "正在进行" + PName + "，时间可能较长，请稍后 ......"
                }
                setTimeout(function(){showProcMessage(div, pv, pmsg, persent, intro);},50)
                
            }
            else { }
        },
        function (failmsg) {
            alert(failmsg);
        }
    );
}


function CreateDiv(handleType, PName) {
    var div = app.createWindow("Do" + handleType, PName, { width: 400, height: 140, bgShadow: 15, toolbar: true, closeButton: true,canMove:true, bgcolor: "#f3f3f3" });
    if(app.IeVer!=7)div.style.paddingTop = "20px";
    div.style.textAlign = "center";
    return div;
}


function showProcMessage(div, pv, pmsg, persent, intro) {
    if (isFinish) return;
    div.innerHTML = "<div style='float:left;margin:0 auto;margin-left:20px;width:300px;height:16px;padding-top:0px;border:1px solid #aaa;"+ (app.IeVer==7?"margin-top:20px;":"") +"background-color:white'>"
                        + "<div style='background-color:#2d8dd9;height:100%;overflow:hidden;width:" + pv + "px'>&nbsp;</div>"
                        + "</div>"
                        + "<div style='float:left;padding-left:5px;"+ (app.IeVer==7?"margin-top:20px;":"") +"padding-top:2px;'>(" + persent + "%)</div>"
                        + "<div style='clear:both;margin:0 auto;width:300px;text-align:left;padding-top:6px'>" + pmsg + "</div>"
                        + "<div style='clear:both;margin:0 auto;width:300px;text-align:left;padding-top:6px'>" + intro + "</div>";
}

Bill.CallBackParams = function (title, dbname, verfi, cmdtag, dismsgid) {
    if (verfi == 1) {
        //获取文本框字段数据
        if (Bill.DataVerification(document.body) == false)  //单据数据校验
        {
            return false; //校验失败
        }
    }
    if(dismsgid!=true) { app.ajax.regEvent("SysBillCallBack"); } 
    app.ajax.addParam("__sys_msgid", window.RuntimeInfo.SystemMessageKey);
    app.ajax.addParam("actionname", dbname);
    app.ajax.addParam("__cmdtag", cmdtag);
};

