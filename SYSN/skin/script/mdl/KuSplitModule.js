function CKuSplitHeaderHtml(lvw, rowindex, cellindex) {
    if (lvw.rows.length == rowindex + 1) {
        if (lvw.rows[rowindex][0] == window.ListView.NewRowSignKey) {
            return "";
        }
    }
    try {
        var json = eval("(" + lvw.rows[rowindex][cellindex] + ")");
    } catch (ex) { return "";}
    var html = [];
	if(json.length==0) {return "<div style='line-height:16px;text-align:left'>没有库存</div>"; }
    html.push("<div style='line-height:16px;text-align:left'>");
	var sunnum = 0;
    for (var i = 0; i < json.length; i++) {
        var obj = json[i];
        if (obj.kuunit == obj.unit) {
			sunnum = sunnum + obj.kunum*1;
            html.push("<div><span>" + obj.ckname + "</span>  <span style='color:red'>" + obj.unitname + "  " + app.FormatNumber(obj.kunum,"numberbox") + "</span></div>");
        } else {
			sunnum = sunnum + obj.kunum * obj.unitbl;
            html.push("<div><span>" + obj.ckname + "  " + obj.kuunitname + "  ")
            html.push(app.FormatNumber(obj.kunum, "numberbox") + " = " + obj.unitname + "  " + app.FormatNumber(obj.kunum * obj.unitbl, "numberbox") + "</span>")
            html.push(" <span><img src='" + window.SysConfig.VirPath + "SYSA/images/jiantou.gif'>");
            html.push("<a href='javascript:void(0)' onclick='showKuSplitDlg(" + obj.ord + "," + obj.unit + "," + obj.ck + ",\"" + lvw.id + "\"," + rowindex + "," + cellindex + ")'>拆分</a></span>")
            html.push("</div>");
        }
    }
	if(json.length>1) {
		 html.push("<div><span>合计：</span> <span>" + obj.unitname + "  " + app.FormatNumber(sunnum,"numberbox") + "</span></div>");
	}
    html.push("</div>");
    return html.join("");
}


//显示库存拆分列表
function showKuSplitDlg(productid, unitid, ck, lvwid, rowindex, cellindex)
{
    window.currKuSplitListPos = {lvwID: lvwid, rid: rowindex, cid: cellindex, product:productid, unit: unitid};
    var div = app.createWindow("asdas_kusplit", "产品拆分", {
        width: 780,
        height: 460,
        closeButton: true,
        maxButton: true,
        minButton: true,
        canMove: true,
        sizeable: true,
        bgShadow: 30
    });
	div.innerHTML = "<iframe id='unit_cf' style='width:100%;height:99%' frameborder=0></iframe>"
    //IE6不兼容问题.
	document.getElementById("unit_cf").src = window.SysConfig.VirPath + "SYSA/store/ku_unit2.asp?ord=" + productid + "&unit=" + unitid + "&ck=0&ck2=" + ck + "&ridx=" + rowindex;
	div.style.padding = "0px";
}

window.OnKuSplitComplete = function (rowindex) {
    app.closeWindow("asdas_kusplit");
	var pos = window.currKuSplitListPos;
    var lvw = window["lvw_JsonData_" + pos.lvwID];
    app.ajax.regStaticSub("ZBServices.view.SYSN.mdl.store.KuSplitModule.GetKuInfoMessage");
	app.ajax.addParam("product", pos.product);
	app.ajax.addParam("unit", pos.unit);
	lvw.rows[pos.rid][pos.cid] = app.ajax.send();
	___RefreshListViewByJson(lvw);
}