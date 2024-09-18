window.CurrOBJ  = {};
window.__w = function (strtxt) { document.write(strtxt); }

function LinkCollection(maxspan, existsArrow) {
	var obj = new Object();
	obj.links = [];
	obj.maxspan = maxspan;
	obj.existsjt = existsArrow;
	obj.Add = function (title, count, url, remark) {
		if (count == -1) { return; }  //count==-1, 表示无签名
		obj.links.push({ 'title': title, 'count': count, 'url': url, 'remark': remark });
	}
	obj.CHtml = function () {
		var allw = 92;  //92%
		var intw = parseInt(allw / maxspan);
		var len = obj.links.length;
		for (var i = 0; i < len; i++) {
			var n = obj.links[i];
			var counthtml = "";
			var linkhtml = "";
			if (n.url) { linkhtml = " onclick='COpenUrl(\"" + window.SysConfig.VirPath + n.url + "\")' "; }
			if (n.count > 0) { counthtml = "<span class='linkcount'>( " + app.NumberFormat(n.count) + " )</span>"; }
			__w("<div style='width:" + intw + "%'  class='linkitem'>");
			__w("<div class='linktitle" + ((obj.existsjt && i < (len - 1)) ? " jt" : "") + "'>");
			if (linkhtml) {
				__w("<a href='javascript:void(0)'  " + linkhtml + ">" + n.title + counthtml+"</a> "  );
			} else {
				__w( n.title  + counthtml );
			}
			__w("</div><div class=linkremark>" + n.remark + "</div>");
			__w("</div>");
		}
	}
 	return obj;
}

window.createPage = function () {
	window.CurrOBJ =  window.PageInitParams[0];
	__w("<div id='mypage'>")
	__w("<div id='maintitle'>系统启用及配置引导</div>");
	__w("<div id='titleremark'>为了能让贵公司更快速、更高效的启用本软件，请按照如下步骤进行操作</div>");
	__w("<div class='hsplit' style='height:38px'>&nbsp;</div>");

	//1.组织架构
	CLinkGroup(1, "组织架构", "#4E7EDD", function () {
		var links = new LinkCollection(4, 1);
		links.Add("组织架构", CurrOBJ.OrgsCount, "SYSN/view/magr/OrganizList.ashx", "请设置公司组织架构");
		links.Add("岗位设置", CurrOBJ.JobCount, "SYSA/sort3/edit.asp?ord=1080", "请设置公司所有岗位名称");
		links.Add("账号及权限设置", CurrOBJ.UserCount, "SYSN/view/magr/Accountlist.ashx", "请添加账号和分配权限");
		links.Add("档案管理", CurrOBJ.HrPersonCount, "SYSN/view/hrm/list.ashx", "请添加或者导入员工档案");
		links.CHtml();
	});
	//2.系统参数设置
	CLinkGroup(2, "系统参数设置", "#3CAFE3", function () {
		var links = new LinkCollection(2, 0);
		links.Add("系统参数", 0, "SYSA/setjm/set_jm3.asp", "系统级参数影响整套系统，保证数据规则统一");
		links.Add("<span style='color:red;font-size:15px'>●</span>&nbsp; 必设参数", 0, "SYSN/view/init/guide/ImportantSetting.ashx", "避免系统使用过程中出现误差，提高系统使用效率");
		links.CHtml();
	});
	//3.业务流及栏目参数设置
	CLinkGroup(3, "业务流及栏目参数设置", "#14B5BB", function () {
		var links = new LinkCollection(2, 0);
		links.Add("按业务流程设置", 0, "SYSN/view/init/guide/flowguide.ashx", "保证业务流启用的流畅性");
		links.Add("<a href='javascript:void(0)' onclick='window.gotoGroupSetting();"+ (window.SysConfig.SystemType==3?"window.close();window.top.app.closeWindow?window.top.app.closeWindow(\"guiddlg\"):\"\"":"") +"'>按栏目设置</a>", 0, "", "设置各栏目参数，保证使用通畅无比");
		links.CHtml();
	});
	//4.基础数据导入
	CLinkGroup(4, "基础数据导入", "#877CE5", function () {
		var links = new LinkCollection(4, 0);
		links.Add("客户导入", CurrOBJ.CustomCount, "SYSA/load/newload/kfdr.asp", "快速导入已有客户数据");
		links.Add("供应商导入", CurrOBJ.SupplierCount, "SYSN/view/import/gysImport.ashx", "快速导入已有供应商数据");
		links.Add("产品导入", CurrOBJ.ProductCount, "SYSN/view/sales/product/ProductImport.ashx", "快速导入已有产品数据");
		links.Add("库存导入", CurrOBJ.StoreKuCount, "SYSN/view/store/kuin/KuinImport.ashx?importType=2", "快速导入已有库存数据");
		links.Add("设备导入", CurrOBJ.MachineCount, "SYSN/view/produceV2/Machine/MachineImport.ashx", "快速导入已有设备数据");
		links.Add("工序导入", CurrOBJ.WPCount, "SYSN/view/produceV2/workflow/WorkingProceduresImport.ashx", "快速导入已有工序数据");
		links.Add("工艺流程导入", CurrOBJ.WFCount, "SYSN/view/produceV2/workflow/WorkingFlowImport.ashx", "快速导入已有工艺流程数据");
		links.Add("物料清单导入", CurrOBJ.BomCount, "SYSN/view/produceV2/BOM/BOMImport.ashx?bomType=1", "快速导入已有物料清单");
		links.CHtml();
	});
	//
	CLinkGroup(5, "数据备份", "#42BD81", function () {
		var links = new LinkCollection(1, 0);
		var html = "";
		if (!CurrOBJ.LastBackupTime) {
			html = "<span style='color:red'>还未进行备份，请备份 </span>  → <a href='javascript:void(0)' onclick='COpenUrl(\"" + window.SysConfig.VirPath + "SYSN/view/system/DBBakList.ashx?showbakdlg=1\")'>备份</a>";
		} else {
			html = "<span style='color:red'>最近备份时间： " + CurrOBJ.LastBackupTime + " &nbsp;  &nbsp;继续备份</span>"
			+ " &nbsp; &nbsp; &nbsp; &nbsp; →  &nbsp; &nbsp; &nbsp; &nbsp; "
			+ "<a href='javascript:void(0)' onclick='COpenUrl(\"" + window.SysConfig.VirPath + "SYSN/view/system/DBBakList.ashx?showbakdlg=1\")'>备份</a>"
			+ "  &nbsp; &nbsp; &nbsp; &nbsp;<a id='baklistlink'   href='javascript:void(0)' onclick='COpenUrl(\"" + window.SysConfig.VirPath + "SYSN/view/system/DBBakList.ashx\")'>查看更多备份&gt;&gt;</a>"
		}
		links.Add(html, 0, "", "如果基础数据已设置完毕，为了保证基础数据完整性，请进行数据库备份；为保证数据安全，请对数据库设置自动备份维护计划。");
		links.CHtml();
	});
	__w("</div>");
	__w("<div style='height:100px;clear:both'>&nbsp;</div>");
}

window.CLinkGroup = function (i,  title,  bgcolor,  func) {
		__w("<div class='linkareabar'>");
		__w("<div class='linkareabartitle t" + i + "' style='background-color:" + bgcolor + "'>");
		__w("<img src='" + window.SysConfig.VirPath + "SYSN/skin/default/img/guide/m" + i + ".png'>" + title);
		__w("</div>");
		__w("<div class='linkareabody'>");  func();
		__w("</div>")
		__w("</div>")
}

window.watchOpenHwnds = [];

window.COpenUrl = function (url) {
	var win = app.OpenUrl(url);
	setTimeout(function(){
		window.watchOpenHwnds.push(win);
	},2000);
}

window.setInterval(function () {
	for (var i = 0; i < window.watchOpenHwnds.length; i++)
	{
		var ohwnd = window.watchOpenHwnds[i];
		try {
			var a = ohwnd.document.documentElement.offsetHeight;
			if (a == 0) {
				window.location.reload();
			}
		} catch (ex) {
			window.location.reload();
		}
		
	}
}, 500);


window.gotoGroupSetting = function () {
    if (opener) {
        if (window.SysConfig.SystemType == 3) {
            var mainIframe = opener.parent.document.getElementById("mainFrame"), bodyIframe;
            if (!mainIframe) {
                bodyIframe = opener.top.document.getElementsByTagName("iframe")[0];
                mainIframe = bodyIframe.contentWindow.document.getElementById("mainFrame");
            }
            mainIframe.src = "../../SYSN/view/comm/syssettings.ashx"
            return;
        }
        app.OpenUrl("../../../SYSN/view/comm/syssettings.ashx");
    }else{
        if (window.SysConfig.SystemType == 3) {
            var bodyIframe = window.top.document.getElementsByTagName("iframe")[0];
            var mainIframe = bodyIframe.contentWindow.document.getElementById("mainFrame");
            if (!mainIframe) { return;}
            mainIframe.src = "../../SYSN/view/comm/syssettings.ashx";
            return;
        }
        app.OpenUrl("../../../SYSN/view/comm/syssettings.ashx");
    }
}