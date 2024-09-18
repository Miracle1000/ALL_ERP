window.__ShowImgBigToSmall= true;

function doHandle(cmd ,ord , pword , canAddNotice){
	switch (cmd){
	case "通知":
		window.open('../notice/add.asp?datatype=-11&fromid='+ord,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
		break;
	case "修改":
		window.open('add.asp?act=content&ord='+ord,'updatedesign','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
		break;
	case "变更":
		window.open('add.asp?act=change&ord='+ord,'updatedesign','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
		break;
	case "导出":
		break;
	default :
		if (cmd=="删除"){
			if(!confirm("确定"+cmd+"吗?")){return false;}
		}
		ajax.regEvent("doHandle")
		ajax.addParam("command", cmd);
		ajax.addParam("value", ord);
		ajax.exec();
		if (cmd=="删除"){
			if(canAddNotice==1){
				window.open('../notice/add.asp?datatype=-11&fromid='+pword,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
			}
			try{window.opener.DoRefresh();}catch(e){}
			window.open('', '_self');
			window.close()
		}else{
			RefreshWindow();
		}
	}
}

//详情修改刷新
function RefreshWindow(){
	window.location.reload();
	try{window.opener.DoRefresh();}catch(e){}
}