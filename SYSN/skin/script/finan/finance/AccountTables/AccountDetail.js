var ShowBatchDialog = function() {
    var win = app.createWindow("BatchDialog", "批量操作", { closeButton: true, height: 380, width: 620, bgShadow: 30, canMove: 1 });
    win.innerHTML = "<iframe frameborder='0' scrolling=0 src='" + window.SysConfig.VirPath + "SYSN/view/finan/finance/AccountTables/AccountDetail_Batch.ashx' width=\"600\" height=\"360\"> ";
    win.style.overflow = "hidden";
}