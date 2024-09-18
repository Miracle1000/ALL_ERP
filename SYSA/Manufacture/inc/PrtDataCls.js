var PrtData = {};

//--显示导出的弹窗
//--参数：json形式，{billID:@billID,Title:@Title,PrtType:@PrtType}
//--@billID模板ID,@Title模板标题,@PrtType模板类型名称
PrtData.ShowOut = function(json){
	if (!document.getElementById("lvw_xls_proc_bar"))
	{
		var div = document.createElement("div");
		div.innerHTML = PrtData.OutTable;
		document.body.appendChild(div);
	}
	if (!document.getElementById("PrtData_frm"))
	{
		div.innerHTML = div.innerHTML + PrtData.Iframe;
	}
	var a = document.getElementById("lxls_by_fLink");
	a.innerText = json.PrtType + "打印模板——" + json.Title + ".Dat";
	a.href = "PrtDataOut.asp?ord=" + json.billID;
	jQuery('#lvw_xls_proc_bar').show();
}

//--导出页面的弹窗信息
PrtData.OutTable = '<div style="Z-INDEX: 10000; POSITION: fixed; WIDTH: 460px; TOP: 26%; LEFT: 28%; _position: absolute" id="lvw_xls_proc_bar">'
				+  '<table style="WIDTH: 460px" class="sys_dbgtab8" cellspacing="0" cellpadding="0" align="center">'
				+  '<tbody>'
				+  '<tr>'
				+  '<td style="HEIGHT: 20px" class="sys_dbtl"></td>'
				+  '<td class="sys_dbtc"></td>'
				+  '<td class="sys_dbtr"></td>'
				+  '</tr> '
				+  '<tr>'
				+  '<td style="PADDING-BOTTOM: 22px; PADDING-TOP: 22px" class="sys_dbcl"></td>'
				+  '<td style="BORDER-BOTTOM: #c0ccdd 1px solid; BORDER-LEFT: #c0ccdd 1px solid; PADDING-BOTTOM: 22px; BACKGROUND-COLOR: #fff; PADDING-LEFT: 22px; PADDING-RIGHT: 22px; COLOR: #2f496e; BORDER-TOP: #c0ccdd 1px solid; BORDER-RIGHT: #c0ccdd 1px solid; PADDING-TOP: 22px" id="lxls_by" valign="top">'
				+  '<div style="PADDING-BOTTOM: 0px; LINE-HEIGHT: 22px; BACKGROUND-COLOR: #fff; PADDING-TOP: 5px" id="lxls_by_flist">'
				+  '<b style="COLOR: green">生成Dat文档成功。</b>'
				+  '<br />'
				+  '<span style="COLOR: #5b7cae">文件下载链接：</span>'
				+  '<br />'
				+  '<a style="TEXT-DECORATION: underline" target="PrtDatafrm" class="lxls_by_flink" href="" id="lxls_by_fLink">二维码列表_李洪涛-1.xls</a>'
				+  '<div style="TEXT-ALIGN: center">'
				+  '<a style="COLOR: red" onclick="jQuery(\'#lvw_xls_proc_bar\').hide()" href="javascript:void(0)">关闭对话框</a>'
				+  '</div>'
				+  '</div></td>'
				+  '<td class="sys_dbcr"></td>'
				+  '</tr>'
				+  '<tr>'
				+  '<td class="sys_dbbl"></td>'
				+  '<td class="sys_dbbc"></td>'
				+  '<td class="sys_dbbr"></td>'
				+  '</tr>'
				+  '</tbody>'
				+  '</table>'
				+  '</div>'
//--导出的执行IFRAME
PrtData.Iframe = '<iframe name="PrtDatafrm" id="PrtData_frm" frameBorder="1" style="width: 100px; height: 100px;"></iframe>';
//--显示导入界面弹窗
PrtData.ShowIn = function(sort) {
	var t = 200;
	try { t = t * 1 + document.body.scrollTop }
	catch (e) { }
	var div = window.DivOpen("lvw_drExcel", "导入打印模板", 640, 330, t, 'a', true, 20, true)
	var url = location.href;
	if (url.indexOf("?") > 0) { url = url.split("?")[0]; }
	if (url.indexOf("#") > 0) { url = url.split("#")[0]; }
	url = escape(url);
	div.innerHTML = "<iframe frameborder=0 scrolling=0 src='about:blank' style='width:100%;height:100%'></iframe><input id='lvw_drHidden' type='hidden' value='0'/>"
	div.children[0].src = "../../load/newload/PrtDataIn.asp?sort=" + sort;
}

document.body.onscroll = function () {
	try {
		document.getElementById("divdlg_lvw_drExcel").style.top = (document.body.scrollTop + 200) + "px";
	}
	catch (e) { }
}

//--包装弹窗关闭事件，出发页面跳转
PrtData.divdlgclick = divdlgclick
divdlgclick = function(obj,num){
	PrtData.divdlgclick(obj,num);
	var input = document.getElementById("lvw_drHidden");
	if (input)
	{
		var prtID = input.value;
		if (isNaN(prtID))
		{
			prtID = 0
		}
		if (prtID > 0)
		{
			window.location.href = "?id=" + prtID;
		}
	}
}