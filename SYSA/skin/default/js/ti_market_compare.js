//时间日期再次检查
window.__Report_Date_Check = function(d1 ,d2 ,stype){
	if (window.__Report_Fields_OK == true)
	{
		if (d1 ==undefined || d2 ==undefined )
		{
			app.Alert("温馨提示：\n\n请选择【起始日期】和【截止日期】。\n");
			window.__Report_Fields_OK = false;
		}else if (d1.getFullYear() != d2.getFullYear())
		{
			app.Alert("温馨提示：\n\n【起始日期】和【截止日期】必须在同一个自然年内。\n" );
			window.__Report_Fields_OK = false;
		}	
	}
}

function __rpt_showAreaDeepPanel() {
	app.easyui.CAjaxWindow("showAreaDeepSetting",function(){});
}

function __Report_area_Save(){
	ajax.regEvent("save_AreaDeep");
	var boxs = $ID("areasetting").getElementsByTagName("input");
	var showIds = ""; 
	var names = "";
	for(var i = 0 ; i < boxs.length; i++) {
		var box = boxs[i];
		showIds = showIds + (box.type=="checkbox" && box.checked ? ","+ box.value : "");
		names = names + (box.type=="text" ? "\1"+ box.value : "");
	}
	if (showIds.length==0)
	{
		app.Alert("请选择区域级别");
		return;
	}
	ajax.addParam("showIds",showIds);
	ajax.addParam("names",names);
	var r = ajax.send();
	if (r=="ok"){app.Alert("保存成功");}else{
		app.Alert(r.replace("err:"));
		return;
	}
	app.easyui.closeWindow("showAreaDeepSetting");
	window.location.reload();
}

function __Report_SetShowData(style){
	window.location.href = "market_compare.asp?isall="+style;
}

window.ReportServerLinkData = function(r , dbname ,keyord){
	switch (dbname)
	{
	case "sumkh":
		window.open('../work/telhy.asp?H=1011','work','width=' + 1100 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
		break;
	}
}