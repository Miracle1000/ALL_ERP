function showDetailHtml(ord, canDetail, title, billType) {
    var htmlStr = (title + "").replace(/\</g,"&lt;");
    if (title.indexOf("已彻底删除")>0) {
        htmlStr = "<span style=color:red>" + title + "</span>";
        canDetail = "0";
    } else if(title.indexOf("(已删除)") >= 0){
        htmlStr = "<span>" + title.replace("(已删除)", "") + "</span>" + "<span style=color:red>(已删除)</span>";
        title = htmlStr;
    }
    if (canDetail == "_url" || canDetail == "1") {
        var typeName = "";
        switch (billType) {
            case "-1": typeName = "product"; break;//产品详情
            case "1":
                htmlStr = OnClickLinkUrl("SYSN/view/sales/contract/ContractDetails.ashx?ord="+ app.pwurl(ord)+"&view=details", billType, title);
                break;//合同详情
            case "2": //收款计划
            case "3": //实际收款
                htmlStr = OnClickLinkUrl("SYSN/view/finan/payback/PayBackSureDetail.ashx?ord=" + app.pwurl(ord) , billType , title);
                break;
            case "4": typeName = "contractth"; break;//合同退货详情
            case "5"://退货退款详情
                htmlStr =OnClickLinkUrl("sysa/money3/payback.asp?ord=" + app.pwurl(ord) , billType , title);
                break;
            case "6": //客户预收款详情
                htmlStr =  OnClickLinkUrl("sysa/money/contentyfk.asp?ord=" + app.pwurl(ord) + "", billType , title);
                break;
            case "7": //客户退预收款详情
                htmlStr =  OnClickLinkUrl("sysa/money/contentbackyfk.asp?ord=" + app.pwurl(ord) + "", billType , title);
                break;
        	case "caigouth":
            case "8"://采购退货
                htmlStr = OnClickLinkUrl("sysn/view/store/caigouth/PurchaseReturn.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break; 
            case "12":
            case "13":
                htmlStr = OnClickLinkUrl("sysa/manufacture/inc/Readbill.asp?orderid=" + billType + "&ID=" + ord + "&SplogId=0", billType, title);
                break;
			case "repair"://维修单
                htmlStr =  OnClickLinkUrl("sysa/repair/RepairOrderContent.asp?id=" + ord + "", billType , title);
				break;
            case "wwfk":
                htmlStr =  OnClickLinkUrl("sysa/manufacture/inc/Readbill.asp?orderid=25&ID=" + ord + "&SplogId=0", billType , title);
                break;
            case "kuin":
                htmlStr = OnClickLinkUrl("SYSN/view/store/kuin/kuin.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "kuout":
                htmlStr = OnClickLinkUrl("SYSN/view/store/kuout/kuoutDetails.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "scll": //生产领料
                htmlStr =  OnClickLinkUrl("sysn/view/producev2/material/ordersadd.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType , title);
                break;
            case "sctl": //生产退料
                htmlStr =  OnClickLinkUrl("sysn/view/producev2/returnmaterial/returnmaterialadd.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType , title);
                break;
            case "scfl": //生产废料
                htmlStr =  OnClickLinkUrl("sysn/view/producev2/Waste/WasteAdd.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType , title);
                break;
            case "manuplan": //生产计划
                htmlStr =  OnClickLinkUrl("sysn/view/producev2/ManuPlans/ManuPlansAdd.ashx?ord=" + app.pwurl(ord) + "&view=details", billType , title);
                break;
            case "planrecycle": //生产计划回收站
                htmlStr =  OnClickLinkUrl("sysn/view/producev2/ManuPlans/ManuPlansAdd.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType , title);
                break;
            case "manuplanpre": //生产预计划
                htmlStr =  OnClickLinkUrl("sysn/view/producev2/ManuPlansPre/ManuPlansPreAdd.ashx?ord=" + app.pwurl(ord) + "&view=details", billType , title);
                break;
            case "planprerecycle": //生产预计划回收站
                htmlStr = OnClickLinkUrl("sysn/view/producev2/ManuPlansPre/ManuPlansPreAdd.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1" , billType , title);
                break;
			case "workflowrecycle": //工艺流程回收站
				htmlStr = OnClickLinkUrl("sysn/view/producev2/workflow/AddWorkingFlow.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1" , billType , title);
				break;
            case "workflow": //工艺流程详情
                htmlStr = OnClickLinkUrl("sysn/view/producev2/workflow/AddWorkingFlow.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "macdetail"://设备详情
                htmlStr = OnClickLinkUrl("sysn/view/producev2/Machine/MachineAdd.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "WCurl":
                htmlStr = OnClickLinkUrl("sysn/view/producev2/workcenter/AddWorkingCenter.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "workcenterrecycle":  //产线回收站
                htmlStr = OnClickLinkUrl("sysn/view/producev2/workcenter/AddWorkingCenter.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType, title);
                break;
            case "workassignsrecycle"://生产派工回收站
                htmlStr = OnClickLinkUrl("sysn/view/producev2/WorkAssign/WorkAssignDetail.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType, title);
                break;
            case "manuOrder"://生产订单
                htmlStr = OnClickLinkUrl("sysn/view/produceV2/ManuOrders/ManuOrdersAdd.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "workassigns"://生产派工
                htmlStr = OnClickLinkUrl("sysn/view/producev2/WorkAssign/WorkAssignDetail.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "rework"://生产返工
                htmlStr = OnClickLinkUrl("sysn/view/producev2/Rework/ReworkDetail.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "reworkrecycle"://生产返工回收站
                htmlStr = OnClickLinkUrl("sysn/view/producev2/Rework/ReworkDetail.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType, title);
                break;
            case "outprocedures"://工序委外
            case "gxww":
                htmlStr = OnClickLinkUrl("sysn/view/producev2/OutProcedure/AddOutProcedure.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "zdww"://整单委外
                htmlStr = OnClickLinkUrl("sysn/view/producev2/ProductionOutsource/ProOutsourceAdd.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "chukumingxi"://产品详情
                htmlStr = OnClickLinkUrl("SYSA/product/content.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "chukumingxizhuti"://出库明细主题
                htmlStr = OnClickLinkUrl("SYSA/store/contentck.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "chukuzhuti"://出库单主题
                htmlStr = OnClickLinkUrl("SYSA/store/contentck.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "kuinTitle"://入库主题
                htmlStr = OnClickLinkUrl("SYSA/store/contentrk.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "CostChangeRedBlue"://入库主题_红蓝调整单
                htmlStr = OnClickLinkUrl("SYSN/view/finan/CostAnalysis/CostChange/CostChangeRedBlue.ashx?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "dangan"://档案列表
                htmlStr = OnClickLinkUrl("SYSA/hrm/personContent.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "lianxiren"://联系人
                htmlStr = OnClickLinkUrl("SYSA/person/content.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "guanliantel_1"://客户
                htmlStr = OnClickLinkUrl("SYSA/work/content.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "guanliantel_2"://供应商
                htmlStr = OnClickLinkUrl("SYSA/work2/content.asp?ord=" + app.pwurl(ord) + "", billType, title);
                break;
            case "Inquiries_1"://预购
                htmlStr = OnClickLinkUrl("../../SYSN/view/store/yugou/YuGou.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "Inquiries_2"://报价
                htmlStr = OnClickLinkUrl("SYSN/view/sales/price/price.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "bankin":
                htmlStr = OnClickLinkUrl("sysn/view/finan/CashBank/DirectInOrOut/DirectCreditDetail.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType, title);
                break;
            case "SupplierStateMent1":
                var i = 0
                var ret = '';
                var ret1 = '';
                var gys = 0;
                var bz = 0;
                bz = $("#billBz_0").val();
                $("input[name='billDate']").each(function () {
                    if (i == 0) { ret = $(this).val() }
                    if (i > 0) { ret1 = $(this).val() }
                    i++;
                })
                htmlStr = OnClickLinkUrl("sysn/view/finan/payout/SupplierStateMent1.ashx?ret=" + ret + "&ret1=" + ret1 + "&gys=" + app.pwurl(ord) + "&bz=" + bz + "", billType, title);
                break;
            case "bankout":
                htmlStr = OnClickLinkUrl("SYSN/view/finan/CashBank/DirectInOrOut/DirectCreditOutDetail.ashx?ord=" + app.pwurl(ord) + "&view=details&recycle=1", billType, title);
                break;
            case "gxsj":
                htmlStr = OnClickLinkUrl("SYSN/view/produceV2/QualityControl/Procedure/AddQCTask.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "pgsj":
                htmlStr = OnClickLinkUrl("/SYSN/view/produceV2/QualityControl/WorkOrder/OneSelfQualityTestingTaskDetail.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "gxhb":
                htmlStr = OnClickLinkUrl("/SYSN/view/produceV2/ProcedureProgres/AddProcedureProgres.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "gxzj":
                htmlStr = OnClickLinkUrl("/SYSN/view/produceV2/QualityControl/Procedure/AddQC.ashx?ord=" + app.pwurl(ord) + "&view=details", billType, title);
                break;
            case "pgzj":
                htmlStr = OnClickLinkUrl("/SYSN/view/produceV2/QualityControl/WorkOrder/QualityWorkOrderDetail.ashx?view=details&ord=" + app.pwurl(ord) + "&index=0", billType, title);
                break;
            case "caigou":
                htmlStr = OnClickLinkUrl("/SYSN/view/store/caigou/CaigouDetails.ashx?view=details&ord=" + app.pwurl(ord) + "", billType, title);
                break;
            default: typeName = billType; break;
        }
        if (typeName.length > 0) {
            htmlStr =  OnClickLinkUrl("sysa/" + typeName + "/content.asp?ord=" + app.pwurl(ord) + "" , billType , title);
        }
    }
    return htmlStr;
}

function productKuoutContrast(topord, v, company, sdate, kuoutmoney, thmoney) {
    var number = '';
    $('input:checkbox[dbname=cpclass]:checked').each(function (k) {
        if (k == 0) {
            number = $(this).val();
        } else {
            number += ',' + $(this).val();
        }
    })
    return OnClickLinkUrl("SYSN/view/statistics/sale/customer/ProductSalesDetails.ashx?company=" + company + "&topORD=" + topord + "&date5=" + sdate + "&kuoutmoney=" + kuoutmoney + "&thmoney=" + thmoney + "" + (number != '' ? "&sort1="+ number : ""), topord, v);
}

function OnClickLinkUrl(url, billType, title) {
    var htmlStr = "<a href='javascript:void(0);' onclick=\"javascript:app.OpenUrl('";
    htmlStr += window.SysConfig.VirPath;
    htmlStr += url;
    htmlStr += "','salesDetails',null,'company,topORD,date5,kuoutmoney,thmoney,sort1')\">" + title + "</a>";
    return htmlStr
}

window.onload = function () {//高级检索树结构展开固定表头重新定位
    $("td.rpt_af_fd[uitype='checktree']").click(function () {
        Report.ResetCloneDivStartPos();
    })
}