

function selectList(paybackID)
{
	$.ajax({
		url:"paybacklist.asp?paybackID="+paybackID,
		success:function(r){
			$('#w').html(r).window({
				title:'产品明细',
				width:670,
				height:420,
				closeable:true,
				collapsible:false,
				minimizable:false,
				maximizable:false
			}).window('open');
		}
	});
}

function select_paylist_yfk(paybackID)
{
	$.ajax({
		url:"paybacklist_yfk.asp?payback="+paybackID,
		success:function(r){
			$('#w1').html(r);
			$('#w1').window({
				title:'预收款使用明细',
				width:670,
				height:420,
				closeable:true,
				collapsible:false,
				minimizable:false,
				maximizable:false
			}).window('open');
		}
	});
}

function resetPlan(ord){
	if(confirm('确认重置？')){
		window.open('reset_plan.asp?contract='+ord,'contract_addfq','width=900,height=500,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=200');
	}
}
