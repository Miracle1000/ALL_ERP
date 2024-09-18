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
			 }
		});
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
			 }
		});
	}
}