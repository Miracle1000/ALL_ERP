
$(function(){
		//footer
		$(".footer ul li").bind('click',function(e){
			e.stopPropagation();
			var index = $(this).index();
			var src = $(this).attr("data-src");
			if(index==1){
				//点击进入分类页面 清除页面参数
				window.localStorage.removeItem("oldSortIndex");
				window.localStorage.removeItem("scrollTopHeight");
				window.localStorage.removeItem("scrollGoodsTopHeight");	
			}
			window.location.href = src;
		})
})
function search(){
	//搜索显隐
	 $("#showSearch").blur(function(){
	 	$("#searchDiv").hide();
	 }).focus(function(){
	 	$("#searchDiv").show();
	 	$("#search-input").blur(function(){
	 		var searTxt = $("#search-input").val().replace(/\s+/g,"");
			if(searTxt != ""){
				$(".right-btn").find("img").attr({"src":"img/searc.png","id":"search"});
				$("#search").click(function(){
					window.location = "html/goodList.html?result="+encodeURIComponent(searTxt);
				})
			}else{
				$(".right-btn").find("img").attr({"src":"img/brush.png","id":"sweep"});
			}
		}).focus(function(){
			console.log("000");
			$(".right-btn").find("img").attr({"src":"img/searc.png","id":"search"});
		})
	 })
}

//搜索
function search(data){
	 $(".speak").click(function(){
	 	window.location ="searList.html?data="+data;
	 })
}

