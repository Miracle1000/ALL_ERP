function xmldata1(ord, act, fromType) {
    if (typeof (act) == "undefined") { act = ""; }
    if (typeof (fromType) == "undefined") { fromType = 0; }
    var left = parseInt(event.clientX) - 30;
    var top = event.clientY + 2; //鼠标的y坐标
    var htmlleft = document.body.offsetWidth; //所打开当前网页，办公区域的高度，网页的高度
    if (htmlleft - event.clientX < 924) {
        left = htmlleft - 924;
    }
    var htmlheight = document.body.offsetHeight; //所打开当前网页，办公区域的高度，网页的高度
    var scrollheight = window.screen.availHeight;//整个windows窗体的高度
    if (htmlheight - event.clientY < 200) {
        top = top - 20 * (4 - parseInt((htmlheight - event.clientY) / 100));
    }
    try{app.closeWindow('sys_comm_open_dlg',true);}catch(e){}
    var url = window.SysConfig.VirPath + "SYSA/caigou/content_qcmx.asp?ord=" + escape(ord) + "&act=" + act + "&fromType=" + fromType + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    app.OpenDlg(url, "top:" + top + ",left:" + left + ",width:900,closeButton:1,canMove:1");
}