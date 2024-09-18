
//取消洽谈进展提醒功能
$(function(){
	$("a[name=cancelAlt]").each(function(index, element) {
        $(this).click(function(){			
			if(confirm("提示：您确定要取消提醒吗？")){
				var rid = $(this).attr("rid");	
				$.post("/work/all.asp",{cancelAlt:1,rid:rid},function(data){
					if(data == 1){
						$(element).remove();
					}
				});
			};
		});
    });
	
	
	$(".zb-swith-btn").on("click",function(){
		$(this).hide();
		$("#quickSearch").hide();
		$("#advanced").show();
		$("#advanced").load("genjin_tj.asp");
	});
	
	$("#advanced").on("click", "#closeAD", function () {
		$(".zb-swith-btn").show();
		$("#quickSearch").show();
		$("#advanced").hide();
	});
	
});


	function checkAll2(str){
		var a=document.getElementById("u"+str).getElementsByTagName("input");
		var b=document.getElementById("e"+str);
		for(var i=0;i<a.length;i++){
			a[i].checked=b.checked;
		}
	}


