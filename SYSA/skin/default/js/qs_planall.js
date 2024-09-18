function selectall(obj)
{
	$(".lvcbox").attr("checked",obj.checked);
}
function OperateDelete(ord)
{
	if (confirm("确认删除？"))
	{
		ajax.regEvent("doDel")
        ajax.addParam('id', ord);
        ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			}
		});
	}
}


function OperateDeleteAll(qx_sort1) {
		var ordlist="";
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
			app.Alert("您没有选择任何资质,请选择后再删除！");
			return ;
		}
		if(confirm('确认删除？')){
			ajax.regEvent("doDelAll")
			ajax.addParam('ordlist', ordlist);
			ajax.addParam('qx_sort1', qx_sort1);
			ajax.send(function(r){
				 if (r == "1") {
					lvw_refresh('mlistvw');
				 }
				 else
				 {
					if (r=="0")
					{		
						app.Alert("没有选择可删除的资质,请重新选择后再删除！");
					}
				 }
			});
		}
    }



function cancelAlt(id,sort){
	if (id!=""){
		if(confirm("确认取消提醒？")){
			ajax.regEvent("","setalt.asp")
			ajax.addParam('ord', id);
			ajax.addParam('sort', sort);
			ajax.send(function(r){
				 if (r == "1") {
					lvw_refresh('mlistvw');
				 }
			});
		}
	}
}
