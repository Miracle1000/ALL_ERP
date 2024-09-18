
$(document).ready(function(){
//列表的批量删除
$("#Del_Batch").click(function(){
   if($(".Del_Item_List").attr("checked")){$(".Del_Item_List").removeAttr("checked"); }
   else{$(".Del_Item_List").attr("checked",'true');}
	});

$("#GetVale").click(function(){
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
		window.opener.GetTemplateVal(""+list+"");
		winClose();
});
});
function winClose()
{
	try
	{
		window.opener=null;
		window.open('','_self');
		window.close();
	}catch(e)
	{}
}
