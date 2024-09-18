
function AjaxSend() {
    if ($('#userid').val() == 0) {
        alert('删除失败,关联竞争对手参数错误!');
        window.opener.location.reload();
        window.close();
        return false;
    } else {
        $.post('?', {
            __msgId: 'doDel',
            id: $('#userid').val()
        },
        function(data) {
            var msg = parseInt(data);
            if (msg == 1) {
                window.opener.location.reload();
                window.close();
            } else {
                alert('删除失败,关联竞争对手参数错误!');
                window.opener.location.reload();
                window.close();
            }
        })
    }
}

	$(function () {
		try{
			var defWidth = 200;	
			var defHeight = 150;
			$(".ewebeditorImg img,.ewebeditorImg_plan img").each(function (index, element) {
				var parentsVal = $(this).closest(".ewebeditorImg_plan").html();		//判断是否为日程列表 不是则返回 null
				var w  = $(this).width();	//实际宽度
				var h  = $(this).height(); //实际高度
				//缩放后的高度 =（默认宽度*实际高度）/ 实际宽度
				if(w > defWidth){
					var thumbH = (defWidth * h) / w;
					$(this).attr({ width: '200', height: thumbH });				
				}
				//缩放后的宽度 =（默认高度*实际宽度）/ 实际高度
				else if(h > defHeight){
					var thumbW = (defHeight * w) / h;	
					$(this).attr({ width: thumbW, height: '150' });	
				}
				//判断日程列表不显示弹出框
				if(parentsVal == null){
					//缩放后的图片可点击，弹出窗口显示原图
					if(w > defWidth || h > defHeight){
						$(this).css({ margin: '5px', cursor: 'pointer' });	
						var url = $(this).attr("src");						
						$(this).click(function () {
							window.open('../inc/img.asp?url='+url)
						});
					}
				}
				
			});
		
		}catch(e){
			
		}
    })