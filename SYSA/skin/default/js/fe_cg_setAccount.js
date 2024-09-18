function selectall(obj)
{
	$(".lvcbox").attr("checked",obj.checked);
}

function OperateDelete(ord) {
	var ordlist="";
	if (ord==0)
	{
		$(".lvcbox").each(
			function(){
				if($(this).attr("checked")==true)
				{
					if (ordlist.length!="")
					{
						ordlist = ordlist + ",";
					}
					ordlist = ordlist + $(this).val();
				}
			}
		)
		if (ordlist.length=="")
		{
			app.Alert("您没有选择任何账套,请选择后再删除！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}
	if(confirm('确认删除？')){
		checkPassWord(ordlist);
	}
}

function doDel(ordlist)
{
	ajax.regEvent("doDel")
	ajax.addParam('ordlist', ordlist);
	ajax.send(function(r){
		 if (r == "1") {
			lvw_refresh('mlistvw');
		 }
		 else
		 {
			if (r=="0")
			{		
				app.Alert("没有选择可删除的账套,请重新选择后再删除！");
			}
			else
			{
				app.Alert("有人在登录使用所选择的账套，不允许删除！");
			}
		 }
	});
}

function checkPassWord(ordlist){
	var win = bill.easyui.createWindow("checkPassWord", "确认密码", {width:300, height:131} );
	var strHtml
	strHtml = "<table id='content'>";
	strHtml = strHtml + "<tr height='30'><td align='right' style='background:#ffffff;width:30%'>密码：</td><td  style='background:#ffffff;'><input type='password' id='password' size='20' value=''>&nbsp;<span id='showspan' class='red'></span></td></tr>";
	strHtml = strHtml + "<tr height='30'><td align='center' colspan='2'><input type='button' class='oldbutton' value='确认' onclick=\"checkPassWordNext('"+ ordlist +"')\">&nbsp;&nbsp;<input type='button' class='oldbutton' value='取消' onclick=\"bill.easyui.closeWindow('checkPassWord');\"></td></tr>" ; 
	strHtml = strHtml + "</table>" ; 
	win.innerHTML =strHtml;
}

function checkPassWordNext(ordlist){
	var PassWord = $("#password").val();
	if ($("#password").val().length==0)
	{
		$("#showspan").html("请输入密码");
		return false ;
	}
	ajax.regEvent("checkPassWord");
	ajax.addParam('password', PassWord);
	var r = ajax.send();
	if (r=="1")
	{
		bill.easyui.closeWindow('checkPassWord');
		doDel(ordlist);
	}
	else
	{
		$("#showspan").html("密码错误");
	}
}

function OperateStopOpen(typ,ord)
{
	var status = "停用";
	if (typ == 0)
	{
		status = "启用"
	}
	var ordlist="";
	if (ord==0)
	{
		$(".lvcbox").each(
			function(){
				if($(this).attr("checked")==true)
				{
					if (ordlist.length!="")
					{
						ordlist = ordlist + ",";
					}
					ordlist = ordlist + $(this).val();
				}
			}
		)
		if (ordlist.length=="")
		{
			app.Alert("您没有选择任何账套,请选择后再"+status+"！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}

	if(confirm('确认'+status+'？')){
		ajax.regEvent("doSet")
		ajax.addParam('ordlist', ordlist);
		ajax.addParam('status', typ);
		ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可"+status+"的账套,请重新选择后再"+status+"！");
				}
				else if (r == "2")
				{
					app.Alert("启用账套后,启用账套个数将超过系统限制！");
				}
				else if (r == "3")
				{
					app.Alert("有人在登录使用所选择的账套，不允许停用！");
				}

			 }
		});
	}
}

function OperateShowHidden(typ,ord)
{
	var status = "显示";
	if (typ == 0)
	{
		status = "隐藏"
	}
	var ordlist="";
	if (ord==0)
	{
		$(".lvcbox").each(
			function(){
				if($(this).attr("checked")==true)
				{
					if (ordlist.length!="")
					{
						ordlist = ordlist + ",";
					}
					ordlist = ordlist + $(this).val();
				}
			}
		)
		if (ordlist.length=="")
		{
			app.Alert("您没有选择任何账套,请选择后再"+status+"！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}

	if(confirm('确认'+status+'？')){
		ajax.regEvent("doShow")
		ajax.addParam('ordlist', ordlist);
		ajax.addParam('status', typ);
		ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可"+status+"的账套,请重新选择后再"+status+"！");
				}
			 }
		});
	}
}

window.onReportRefresh = function() {
	$("#mlistvw_ckv_1").attr("disabled",true) ;
	$("#mlistvw_ckv_1").css("display","none") ;
	$("#mlistvw_ckv_1").remove();
}

window.onReportListRefresh = function() {
	window.onReportRefresh()
}
