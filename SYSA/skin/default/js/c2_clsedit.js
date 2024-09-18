function myOpenUrl(url) {
	window.open(url,'adds2x','width=900,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150')
}

function delcls(id) {
	if (window.confirm("您确定要删除该分类吗？"))
	{
		ajax.regEvent("delcls");
		ajax.addParam("ord", id);
		ajax.exec();
		if($ID("lvw_tablebg_mlistvw")) {
			lvw_refresh("mlistvw");
		}
		else{
			window.location.reload();
		}
	}
}