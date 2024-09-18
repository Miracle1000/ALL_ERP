function selectall(obj)
{
	$(".lvcbox").attr("checked",obj.checked);
}

function OperateDelete(ord ,typ) {
	var ordlist="";
	var isall = 0 ;
	if (ord==0 && typ==1 )
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
		isall = 1 ;
	}
	else 
	{
		ordlist = ord;
	}
	if(confirm('确认删除？')){
		ajax.regEvent("doDel")
		ajax.addParam('typ', typ);
		ajax.addParam('isall', isall);
		ajax.addParam('ordlist', ordlist);
		ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可彻底删除的凭证,请重新选择后再删除！");
				}
			 }
		});
	}
}

function OperateClick(ord)
{
	var isall = 0 ;
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
			app.Alert("您没有选择任何凭证,请选择后再恢复！");
			return ;
		}
		isall = 1 ;
	}
	else 
	{
		ordlist = ord;
	}

	if(confirm('确认恢复？')){
		ajax.regEvent("doSet")
		ajax.addParam('isall', isall);
		ajax.addParam('ordlist', ordlist);
		ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可恢复的凭证,请重新选择后再恢复！");
				}
			 }
		});
	}
}