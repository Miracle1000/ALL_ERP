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
			app.Alert("您没有选择任何凭证,请选择后再删除！");
			return ;
		}
	}
	else 
	{
		ordlist = ord;
	}
	if(confirm('确认删除？')){
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
					app.Alert("没有选择可删除的凭证,请重新选择后再删除！");
				}
			 }
		});
	}
}

function OperatePrint(){
	var ordlist="";
	$(".lvcbox").each(
		function(){
			if($(this).attr("checked")==true)
			{
				if (ordlist.length!="")
				{
					ordlist = ordlist + "|";
				}
				ordlist = ordlist + $(this).val();
			}
		}
	)
	if (ordlist.length=="")
	{
		app.Alert("您没有选择任何凭证,请选择后再打印！");
		return ;
	}
	var idsArr = ordlist.split("|");
	if (idsArr.length > 50){alert("选择的单据数量不要超过50个！");return false;}
	window.OpenNoUrl('../../../SYSN/view/comm/TemplatePreview.ashx?sort=150&ord='+ordlist,'newwin33','width=' + 850 + ',height=' + (screen.availHeight-80) + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=' + (screen.availWidth-850)/2  + ',top=0')

}

function OperateClick(typ,ord)
{
	var status = "审核";
	if (typ == 2)
	{
		status = "反审核"
	}
	else if (typ == 3)
	{
		status = "记账"
	}
	else if (typ == 4)
	{
		status = "反记账"
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
			app.Alert("您没有选择任何凭证,请选择后再"+status+"！");
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
		ajax.addParam('typ', typ);
		ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可"+status+"的凭证,请重新选择后再"+status+"！");
				}
			 }
		});
	}
}