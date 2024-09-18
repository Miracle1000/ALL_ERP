
$.extend($.messager.defaults,{   
    ok:"确定",   
    cancel:"取消"  
}); 
function assignValue(Id){
	$.ajax({
		url:"AssignAdd.asp?fromId="+Id+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			if(msg.length==0){
				alert("请先下达上级目标");
			}else{
				$("#targetAssign").html(msg);
				$.parser.parse($('#targetAssign'));
				$('#win').window({
					collapsible:false,
					minimizable:false,
					maximizable:true,
					modal:true
				});
				$('#win').window('open');
			}
		}
   });
}
function confirmTarget(Id,cStr){
	$.ajax({
		url:"targetConfirm.asp?Id="+Id+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			$("#"+cStr).html(msg);
		}
   });
}
$(function(){
	$("#tt").select();
});
