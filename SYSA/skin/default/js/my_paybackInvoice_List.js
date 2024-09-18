window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}

function selectall(obj)
{
	$(".lvcbox").attr("checked",obj.checked);
}

function OperateInvoiceAll()
{
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
		app.Alert("您没有选择任何开票计划,请选择后再开票！");
		return ;
	}
	//window.location.href="invoice_hb.asp?selectid="+ordlist;
	app.OpenUrl('SYSN/view/finan/InvoiceManage/MakeOutInvoice/InvoiceApply.ashx?ids=' + ordlist, 'newwinApply', null, 'ids');
}

function OperateHandleAll()
{
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
		app.Alert("您没有选择任何开票计划,请选择后再指派！");
		return ;
	}
	window.location.href="orderallhy_invoice.asp?selectid="+ordlist;
}
function OperateAbolish(ord)
{
	if (confirm("发票废止后无法恢复，您确认废止该单据？"))
	{
		ajax.regEvent("doAbolish")
        ajax.addParam('id', ord);
        ajax.send(function(r){
			 if (r == "1") {
				lvw_refresh('mlistvw');
			}
		});
	}
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

function OperateDeleteAll() {
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
			app.Alert("您没有选择任何开票计划,请选择后再删除！");
			return ;
		}
		if(confirm('确认删除？')){
			ajax.regEvent("doDelAll")
			ajax.addParam('ordlist', ordlist);
			ajax.send(function(r){
				 if (r == "1") {
					lvw_refresh('mlistvw');
				 }
				 else
				 {
					if (r=="0")
					{		
						app.Alert("没有选择可删除的开票计划,请重新选择后再删除！");
					}
				 }
			});
		}
    }