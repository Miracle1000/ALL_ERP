function ScanfByContractNo()
{
    var v = $("#Scanf_0").val();
    var x = v.indexOf(":");//合同详情生成的一维码格式为HTID:HT_xxxxxxx
    $("#serchkey_0").find("option[value='HTid']").attr("selected", true);
    $("#serchkeyTxt_0").val(v.substring(parseInt(x)+1, v.length))
    $("#serchkey_0").next("div").text("合同编号")
    Report.SetSearchData(0);
    Report.ReportSubmit();
}
function mydel(box) {
    var cellinfo = ListView.GetListViewCellInfoDomObj(box);
    var msginx = ListView.GetHeaderByDBName(window['lvw_JsonData_' + cellinfo.lvwid], "msg").i;
    var msg = window['lvw_JsonData_' + cellinfo.lvwid].rows[cellinfo.rowindex][msginx]
    if (confirm(msg)) {
        ___flagConfirm(box, 0, cellinfo.lvwid, cellinfo.rowindex);
    }
}
//临时去掉高级检索，支持了删除此代码
//$(function () {
    
//    $("#reportasearchlink").css("display", "none");
//})