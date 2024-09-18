
$(function(){
	$("#sharecontact").click(function(){
		if(!confirm('确定共享客户所有联系人?')){
			$("#sharecontact").attr("checked",false);
			$("#sharecontact1").attr("checked",true);
		}
	});
	
	$("#replyShare").click(function(){
		if(!confirm('确定共享客户所有洽谈进展?')){
			$("#replyShare").attr("checked",false);
			$("#replyShare1").attr("checked",true);
		}
	});
	
	$("#chanceShare").click(function(){
		if(!confirm('确定共享客户所有项目?')){
			$("#chanceShare").attr("checked",false);
			$("#chanceShare1").attr("checked",true);
		}
	});
	
	$("#contractShare").click(function(){
		if(!confirm('确定共享客户所有合同?')){
			$("#contractShare").attr("checked",false);
			$("#contractShare1").attr("checked",true);
		}
	});
	
});
