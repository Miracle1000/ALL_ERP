window.__ShowImgBigToSmall=true;
function doHandle(cmd ,ord , pword , canAddNotice , noticeType){
	switch (cmd){
	case "通知":
		var url ='../notice/add.asp?datatype=-31&fromid='+ord
		if (noticeType==15001)
		{
			url = "../../SYSN/view/market/notice/notice.ashx?datatype="+ noticeType +"&fromid="+ord
		}
		window.open(url,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
		break;
	case "修改":
		window.open('add.asp?act=content&ord='+ord,'updatedesign','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
		break;
	case "变更":
		window.open('add.asp?act=change&ord='+ord,'updatedesign','width=' + 1100 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
		break;
	case "指派" :
		window.open('order.asp?selectid='+ord,'orderdesign','width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
		break;
	case "共享":
		window.open('share.asp?act=content&selectid='+ord,'sharedesign','width=' + 1000 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
		break;
	case "审批":
		window.open('../inc/CommSPSet.asp?ord='+ord+'&sort1=5029&lvw=mlistvw','setsp','width=' + 900 + ',height=' + 500 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
		break;
	case "导出":
		break;
	case "放弃" :
		app.easyui.CAjaxWindow("setAbandon",function(){
			ajax.addParam2("ord",ord);
		});
		break;
	default :
		if (cmd=="作废" || cmd=="删除" || cmd=="取消作废"){
			if(!confirm("确定"+cmd+"吗?")){return false;}
		}
		ajax.regEvent("doHandle")
		ajax.addParam("command", cmd);
		ajax.addParam("value", ord);
		var r = ajax.send();
		if (cmd=="删除" || cmd=="作废"|| cmd=="取消作废"){
			if(canAddNotice==1){
				window.open('../notice/add.asp?datatype=-31&fromid='+pword,'newwinAddNotice','width=' + 1200 + ',height=' + 600 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
			}
		}
		if (cmd=="删除"){
			try{window.opener.DoRefresh();}catch(e){}
			window.open('', '_self');
			window.close()
		}else{
			RefreshWindow();
		}
	}
}

function doReply(pwid,pwsortreply){
	window.open("reply.asp?action=content&ord="+pwid+"&sortreply="+pwsortreply,"plancor50","width=" + 990 + ",height=" + 500 + ",fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150");
}

spclient.onProcComplete =function(ord, spid ,spuser , obj){
	ajax.regEvent("doSpHandle")
	ajax.addParam("id", ord);
	ajax.addParam("@__sp_level_id", spid);
	ajax.addParam("@__sp_cateid", spuser);
	ajax.exec();
	RefreshWindow();
}

function setSpProc(ord , sptype , designer , isback){
	spclient.GetNextSP('Design',ord,0,sptype,designer,isback ,document.body);
}
//详情修改刷新
function RefreshWindow(){
	window.location.reload();
	try{window.opener.DoRefresh();}catch(e){}
}

function saveAbandon(ord){
	var reson = $("#reson").val();
	ajax.regEvent("doHandle")
	ajax.addParam("command", "放弃");
	ajax.addParam("value", ord);
	ajax.addParam("reson", reson);
	ajax.exec();
	app.easyui.closeWindow("setAbandon");
	RefreshWindow();
}

//编辑明细保存  刷新详情明细数据
window.RefreshMxList = function(LvRows ,dataType ,id){
	var data = "";
	for (var i=0;i<LvRows.length;i++){
		var p = LvRows[i];
		data +=  (data.length>0 ? "\2" : "") + p[0] + "\1" + p[1] ;
	}
	ajax.regEvent("saveMxList")
	ajax.addParam("dataType", dataType);
	ajax.addParam("id", id);
	ajax.addParam("data", data);
	ajax.exec();
	RefreshWindow();
}

window.__ShowImgBigToSmall= true;