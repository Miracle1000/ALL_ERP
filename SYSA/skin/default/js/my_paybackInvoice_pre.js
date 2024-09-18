window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}

window.onReportExtraHandle = function (text, arrValue) {
    var ids = arrValue.join(",");
    switch (text) {
        case "批量生成开票计划":
            var selectid = "";
            $("input[name='sys_lvw_ckbox']:checked").each(function () {
                var id = $(this).val();
                selectid += (selectid == "" ? "" : ",") + id;
            });
            app.OpenUrl('SYSN/view/finan/InvoiceManage/InvoicePlan/InvoicePlansBatchAdd.ashx?ids=' + selectid, 'newwin', null, 'ids');
            break;
    }
}