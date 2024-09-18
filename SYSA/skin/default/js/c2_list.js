window.onReportExtraHandle = function(btnText , values , pword , canAddNotice){
	switch(btnText){
		case "批量打印" :
			if (values.length>50){
				app.Alert("选择的单据数量不要超过50个！");
				return;
			}
			var ids = ""
			for (var i =0; i <values.length ; i++ ){
				ids = ids + "|" + values[i].split(",")[0];
			}
			ids = ids.replace("|","");
			window.open('../../SYSN/view/comm/TemplatePreview.ashx?sort=11&ord='+ids ,'newwin77','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0');
			break;
		default :
			if (window.confirm("您确定要" + btnText + "吗？")==false) { return; }
			ajax.regEvent("__doBatHandle")
			ajax.addParam("command", btnText);
			ajax.addParam("checkvalues", values.join(","));
			ajax.exec();
			if (btnText=="删除" && canAddNotice==1){
				window.open('../notice/add.asp?datatype=-31&fromid='+pword,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
			}	
	}
}