﻿
$(document).ready(function(){
//列表的批量删除
$("#Del_Batch").click(function(){
   if($(".Del_Item_List").attr("checked")){$(".Del_Item_List").removeAttr("checked"); }
   else{$(".Del_Item_List").attr("checked",'true');}
	});
$("#Del_List").click(function(){
if(confirm('确认删除所选？')){
		var list="";
		var check=$('input[type="checkbox"][class="Del_Item_List"]:checked');
		check.each(function()
		{
			if(list=="")
			{
				list=$(this).val();
				}
			else
			{
				list=list+","+$(this).val();
				}
		});
		if (list=="")
		{
			alert("没有选择任何流程,请选择后再删除!");
			return;
		}
		window.location.href="HfConfig.asp?action=dellist&OrdList="+list+"&CurrPage="+$("#pageid").val();
}
});
});