
    function clistdr(rd, ty) {
        var t = 200;
        try { t = t * 1 + document.documentElement.scrollTop }
        catch (e) { }
        var div = window.DivOpen("lvw_drExcel", "导入采购明细", 640, 330, t, 'a', true, 20, true)
        var url = location.href;
        if (url.indexOf("?") > 0) { url = url.split("?")[0]; }
        if (url.indexOf("#") > 0) { url = url.split("#")[0]; }
        var fkplan = 1;
        var isDetails = 1;
        if(url.indexOf("caigou/add3.asp") > 0){
            isDetails = 0;
            try{fkplan = document.getElementById("fkplan").value;}catch(e){}
        }
        url = escape(url);
        div.innerHTML = "<iframe frameborder=0 scrolling=0 src='about:blank' style='width:100%;height:100%'></iframe>"
        div.children[0].src = "../load/newload/cgmxdr.asp?ord=" + rd + "&ty=" + ty +(isDetails==0?"&fkplan="+fkplan : "");
    }
    document.body.onscroll = function () {
        try {
            document.getElementById("divdlg_lvw_drExcel").style.top = (document.documentElement.scrollTop + 200) + "px";
        }
        catch (e) { }
    }
