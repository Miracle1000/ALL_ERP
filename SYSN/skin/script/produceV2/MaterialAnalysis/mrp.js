
//BUG24108 Sword 2018-06-11 lrp、mrp分析页面，将数量改大，点击分析返回结果处理有误
var isFinish = false;

function MaterialAnalysis(RequestPageType, Route) {
    isFinish = false;
    var EventType = (RequestPageType == undefined ? "SysReportCallBack" : RequestPageType);
    var CelueID = $("input[name='CelueID']:checked").val();
  
    if (CelueID == undefined || CelueID == 0) {
        Bill.DataVerification($ID("CelueID_div").parentNode.parentNode.parentNode)
        return;
    }
    var Calculation = "test";
    var AnalysisList = window.lvw_JsonData_AnalysisList;
    LoadDataHandleProc(EventType, "App_MaterialAnalysis", "分析", { CelueID: CelueID, Route: Route, Calculation:Calculation, AnalysisList: AnalysisList });
}
function MaterialEdit()
{  
  Bill.CallBackParams("编辑可用库存","APP_EditCanUseKuNum",false,"APP_EditCanUseKuNum");
   app.ajax.addParam("visible", 1);
   app.ajax.send(
     function(){

	  var lvw= window['lvw_JsonData_AnalysisResultList'];
	  var col=-1;
	  var tcol=-1;
                 for (var i = 0; i < lvw.headers.length; i++) {
                        if (lvw.headers[i].dbname == 'CurrEnableKuNum') {
									col=i;
                            }
					    if(lvw.headers[i].dbname == 'title')
						  {
								tcol=i;
						  }
						}

	  for(var row=0;row<lvw.VRows.length;row++){
			lvw_je_Expnode1(row,tcol);			
		}
		window.oldFormateHtml= lvw_JsonData_AnalysisResultList.headers[col].formathtml;
		lvw_JsonData_AnalysisResultList.headers[col].formathtml="";
	    lvw_JsonData_AnalysisResultList.headers[col].uitype="numberbox";
		___RefreshListViewByJson(lvw_JsonData_AnalysisResultList)
	 }
   );
}
function CancleMaterialEdit()
{  
  Bill.CallBackParams("取消可用库存编辑","APP_CancleEditCanUseKuNum",false,"APP_CancleEditCanUseKuNum");
   app.ajax.addParam("visible", 1);
  var CelueID = $("input[name='CelueID']:checked").val();
  app.ajax.addParam("CelueID",CelueID)
   app.ajax.send(
	  function(){
	  var lvw= window['lvw_JsonData_AnalysisResultList'];
	   var col=-1;
                 for (var i = 0; i < lvw.headers.length; i++) {
                        if (lvw.headers[i].dbname == 'CurrEnableKuNum') {
									col=i;
                            }
							
						}
	    lvw_JsonData_AnalysisResultList.headers[col].formathtml=window.oldFormateHtml;
	    lvw_JsonData_AnalysisResultList.headers[col].uitype="none";
		___RefreshListViewByJson(lvw_JsonData_AnalysisResultList)
	 }
   );
}
function ChangeAnalysis()
{  
  Bill.CallBackParams("变动分析","APP_ChangeAnalysisM",false,"APP_ChangeAnalysisM");
  app.ajax.addParam("visible", 1);
   app.ajax.send(
 
   );
}
 

function LoadDataHandleProc(EventType , handleType, PName, attrs) {
    var div = CreateDiv(handleType, PName);
    if (EventType == "SysBillCallBack") {
        Bill.CallBackParams("物料分析", handleType, false, handleType);
    } else {
        app.ajax.regEvent(EventType); 
        app.ajax.addParam("actionname", handleType);
        app.ajax.addParam("__cmdtag", handleType);
    }
    if (attrs) {
        for (var k in attrs) {
            app.ajax.addParam(k, attrs[k]);
        }
    }
    showProcMessage(div, 0, "正在准备数据，时间可能较长，请稍后 ......", 100, "");
    window.tmp9527 = null;
    var coutMonth = 1;
    var currInx = 1;
    var month = "";
    var ext = 0;
    app.ajax.send(
        function (okmsg) {
            if (okmsg.indexOf("Status:ok") >= 0) {

                showProcMessage(div, 300, "恭喜您，" + PName + "完成！", 100, "");
                isFinish = true;
              
                window.BillSysCallBackObj = window.tmp9527;
                Bill.HandleCallbackPrco();
                app.closeWindow("Do" + handleType, true);

            } else if (okmsg.indexOf("Status:proc") >= 0) {

                var msg = okmsg.replace("Status:proc", "").split("|");
                var procIndex = parseInt(msg[0]);//当前进度
                var procCount = parseInt(msg[1]);//总进度
                var procMessage = msg[2];//当前进度信息
                var pv = (procIndex / procCount) * 100;
                var pmsg = procMessage;
                var intro = procIndex + ". " + procMessage;
                pv = (ext + parseInt(pv * 1 / coutMonth)) * 3;
                persent = ext + parseInt(pv / 3 / coutMonth);
                pmsg = month + "正在进行" + PName + "，时间可能较长，请稍后 ......"
                setTimeout(function () { showProcMessage(div, pv, pmsg, persent, intro); }, 1)
            } else {

                showProcMessage(div, 300, okmsg, 100, "");
            }
        },
        function (procmsg) {
            if (procmsg.indexOf("Status:proc") >= 0) {
                var msg = procmsg.replace("Status:proc", "").split("|");
                var procIndex = parseInt(msg[0]);//当前进度
                var procCount = parseInt(msg[1]);//总进度
                var procMessage = msg[2];//当前进度信息
                var pv = (procIndex / procCount) * 100;
                var pmsg = procMessage;
                var intro = procIndex + ". " + procMessage;
                pv = (ext + parseInt(pv * 1 / coutMonth)) * 3;
                persent = ext + parseInt(pv / 3 / coutMonth);
                pmsg = month + "正在进行" + PName + "，时间可能较长，请稍后 ......"
                setTimeout(function () { showProcMessage(div, pv, pmsg, persent, intro); }, 1)
                
            }
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

function showErrorProductInfo(jsontext) {
    var e = e || window.event;
    app.showServerPopo(e, "ChangeLogDialogx", eval("(" + jsontext + ")"), 1, 420);
}


var ObjeckShow = function (obj, id, type) {
    app.ajax.regEvent("ChangeLogDialogData");
    app.ajax.addParam("id", id);
    app.ajax.addParam("type", type);
	 var CelueID = $("input[name='CelueID']:checked").val();
	app.ajax.addParam("CelueID",CelueID)
    var result = app.ajax.send();
    if (result == undefined || result == "") return;
    var e = e || window.event;
    app.showServerPopo(e, "ChangeLogDialog", eval("(" + result + ")"), 1, 350);
    $("#ChangeLogDialog").show();
}

window.CCelueDlg = function (ov) {
	$ID("CelueIDV_0").value = ov;
	$($ID("CelueIDV_0")).change();
};
$(function () {
    if (window.SysConfig.SystemType==3) {$("a.policieViewing").css("color", "#2F79fe") }   
})
function lvw_je_Expnode1(rowindex, cellindex, disRefresh) {
	var lvw= window['lvw_JsonData_AnalysisResultList'];
   var node = lvw.rows[rowindex][cellindex];
    var nl = node.deepData.length;
    var childeep = nl + 1;
    var rowlen = lvw.rows.length;
    if (node.cot == 0) { return false; }
    node.expand = 1;//Ps:展开折叠的状态切换  0:+收缩  1:-展开
    if(node.ico == 'jia'){ // [BUG:63896] 【集成】生产-物料分析：展开“+”按钮功能异常
        node.ico = '';
        node.ico2 = '';
    }
    var visibleMap = []; visibleMap[nl] = node.expand;  //折叠显示层级 {0,1,0,1}
    var visiblelist = [];
    var hidelist = [];
    for (var i = rowindex + 1; i < rowlen ; i++)
    {
    	if (i == (rowlen - 1) && lvw.rows[i][0] == ListView.NewRowSignKey) { visiblelist.push(i); break; }  //lvw_je_RowVisible(lvw, i, 1, true); 
    	nd = lvw.rows[i][cellindex];
    	var cndeep =(nd && nd.deepData != undefined) ? nd.deepData.length : 0; //当前节点深度
    	if (cndeep <= nl) { break; }
    	visibleMap[cndeep] = nd.expand;
    	var visible = 1;
    	for (var ii = cndeep-1; ii > nl - 1; ii--)
    	{
    		if (visibleMap[ii] == 0) { 	visible = 0; break; }
    	}
    	(visible? visiblelist : hidelist).push(i);  	//lvw_je_RowVisible(lvw, i, visible, true);
    }
    lvw_je_RowVisibleBatch(lvw, visiblelist, hidelist);  //批量设置显示和隐藏
    if (disRefresh != 1) {
    	lvw.VRows.sort(function (a, b) { return a > b ? 1 : -1 });
    	___RefreshListViewByJson(lvw);
    }
}