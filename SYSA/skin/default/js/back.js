function selectall(obj)
{
	$(".lvcbox").attr("checked",obj.checked);
}
//typ = 0 批量操作 
//typ = 1 单个操作 nord = 单据ord
//typ = 2 全部
function deleteall(typ,nord){
	var ordlist="";
	if (typ == 0 )
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
			app.Alert("您没有选择任何单据,请选择后再删除！");
			return ;
		}
	}
	else 
	{
		ordlist = nord;
	}
	if(confirm('确认删除？')){
		ajax.regEvent("doDelete")
		ajax.addParam('typ',typ)
		ajax.addParam('ordlist', ordlist);
		ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可删除的单据,请重新选择后再删除！");
				}
			 }
		});
	}
}

function resetall(typ,nord){
	var ordlist="";
	if (typ == 0 )
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
			app.Alert("您没有选择任何单据,请选择后再恢复！");
			return ;
		}
	}
	else 
	{
		ordlist = nord;
	}
	if(confirm('确认恢复？')){
		ajax.regEvent("reSet")
		ajax.addParam('typ',typ)
		ajax.addParam('ordlist', ordlist);
		ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			 }
			 else
			 {
				if (r=="0")
				{		
					app.Alert("没有选择可恢复的单据,请重新选择后再恢复！");
				}
			 }
		});
	}
}