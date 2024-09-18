//--弹出浏览人数和浏览次数窗口
function __WinOpen(code){
	var mType = code.T;
	var u = code.code;
	var mTitle = "";
	switch (mType)
	{
		case "R":
			mTitle = "浏览人数";
			break;
		case "C":
			mTitle = "浏览次数";
			break;
	}
	if (!document.getElementById("__BrwWin"))
	{
		var div = document.createElement("div");
		div.setAttribute("id","__BrwWin");
		document.body.appendChild(div);
		$('#__BrwWin').window({
			width:450,
			height:360,
			modal:true,
			resizable:false,	//--禁止重定义大小
			collapsible:false,	//--禁止折叠按钮
			maximizable:false,
			minimizable:false
		});
	}
	$('#__BrwWin').window({
		title:mTitle
	});
	$('#__BrwWin').window('open');
	__GetBrwInfo(u+"&Y="+mType,"1","");
}

//--异步调用，获取浏览人员信息
//--u:页面参数；
//--pNum：当前页码
//--keyWord：查询条件
function __GetBrwInfo(u,pNum,keyWord){
	ajax.url = "../inc/BrowseRDS_Ajax.asp?" + u;
	ajax.regEvent("GetBrwPerson");
	ajax.addParam("pNum",pNum);
	ajax.addParam("keyWord",keyWord)
	var v = ajax.send();
	//alert(v);
	document.getElementById("__BrwWin").innerHTML = v;
}

//--页码跳转
function __BrwGoto(pNum){
	var u = document.getElementById("BrwUrl").value;
	var keyWord = document.getElementById("BrwKeyword").value;
	__GetBrwInfo(u,pNum,keyWord);
}

//--查询
function __BrwSearch(){
	var u = document.getElementById("BrwUrl").value;
	var keyWord = document.getElementById("BrwKeyword").value;
	var SQL_injdata = "'| and |exec |insert |select |delete |update |count(|chr(|mid(|truncate |char(|declare ";
	var SQL_inj = SQL_injdata.split("|");
	for (var i = 0; i < SQL_inj.length; i++)
	{
		if (keyWord.toLowerCase().indexOf(SQL_inj[i]) >= 0)
		{
			alert("请不要使用非法字符(B)");
			return false;
		}
	}
	__GetBrwInfo(u,"1",keyWord);
}

//--回车自动查询
function __BrwAutoSearch(event){
	if (event.keyCode == 13) {
		__BrwSearch();
	}
}