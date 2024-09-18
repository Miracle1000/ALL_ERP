
    function getCshild() {
		var act = jQuery(".invoice_sorce_open_close:checked").val();
		var tp = act=="1"?"开启":"关闭";
        var $infobox = jQuery("#MyMessageInfo");
		var $btn = jQuery('.addnew_btn');
		var iframe = parent.leftFrame;

		if(confirm('您将'+tp+' 票据来源 功能,您确认'+tp+'吗?')){
			jQuery.ajax({
				url:"PJLYOpenOrColse.asp?ord37="+act,
				cache:false,
				success:function(r){
						$infobox.html("刷新中请稍候...");
						
						if(typeof(parent.leftFrame) != "undefined"){							
							parent.leftFrame.location.reload();	
						}
						window.setTimeout(function(){
							$infobox.html('票据来源 功能,已成功'+tp+'!');
							act=="1"?$btn.show(200):$btn.hide(200);
						},2000);
				},
				error:function(){
					$infobox.html("<font color = 'red'>保存失败,您的操作已取消!</font>");
				}
			});
		}
	}
