$(function(){
	//全选功能
	$("#selectAll").live("click",function(){
		var $box = $("input:checkbox[name=sys_lvw_ckbox]");
		$box.attr("checked",this.checked);
		$box.click(function(){
			$("#selectAll").attr("checked",$box.length == $("input[name='sys_lvw_ckbox']:checked").length ? true : false);	
		});
	});	
	
	//单个删除
	$(".singelDel-btn").live("click",function(event){
		if(!confirm('确认要删除该维修单吗？')){
			event.preventDefault();
			return false;
		};
		var rID = $(this).attr("repID");
		$.post("RepairOrderDel.asp",{ID:rID},function(){
			lvw_refresh("mlistvw");
		});			
		
	});
	
	
	//批量删除
	$("#batchDel").live("click",function(event){
		var $box = $("input:checkbox[name='sys_lvw_ckbox']:checked");
		if($box.size() == 0){
			app.Alert('您没有选择任何维修单，请选择后再删除!')
			event.preventDefault();
			return false;
		}
		
		if(!confirm('确认要删除该维修单吗？')){
			event.preventDefault();
			return false;
		};
		var boxArray = new Array();
		$box.each(function(index,ele) {
            var val = $(ele).val();			
			boxArray.push(val);
        });
		
		if(boxArray.length > 0){
			$.post("RepairOrderDel.asp",{ID:boxArray.join(",")},function(){
				lvw_refresh("mlistvw");
			});			
		}
	})
	
	//显示可处理节点层
	$("input[name=dealBtn]").live("click",function(){
		var h = $(this).siblings(".box").height();				//弹出层高度
		var y = $(this).offset().top;							//处理按钮的纵坐标
		$("body>.box").remove();								//移除body中的克隆对话框
		var x = $(this).siblings(".box").clone();				//克隆对话框对象
		$("body").append(x);									//将克隆对话框追加到body
		x.css({"top":y}).show();								//显示对话框
	});
	
	//关闭处理节点层
	$(".box .boxClose").live("click",function(){
		$(this).parents(".box").remove();						//移除对话框
	});
	
});