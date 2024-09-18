$(function(){
	var ly = getRequest("ly");	
	if(ly==""){
		$('.addp_title').append("<span class='addpt_arrow'><img src='../img/addpt_arrow.png'></span>");	
		if(hdata.clstxt1!=""){
			$('.addp_title').append("<a href='../html/index.html'>"+
				"<span class='addpt_one' id='addptt_one'>"+ hdata.clstxt1 +"</span></a>");
		}
		if(hdata.clstxt2!=""){
			$('.addp_title').append("<span class='addpt_arrow'><img src='../img/addpt_arrow.png'></span>"+
				"<a id='addpt_twoo' href='../html/help_colum.html?sort2="+ hdata.cls2 +"'>"+
				"<span class='addpt_one' id='addptt_two'>"+ hdata.clstxt2 +"</span></a>")
		}
		if(hdata.tit!=""){
			$('.addp_title').append("<span class='addpt_arrow'><img src='../img/addpt_arrow.png'></span>"+
				"<span class='addpt_two'>"+ hdata.tit +"</span>");
		}
		if(hdata.ord1+""!="" && hdata.ord1+""!="0"){
			$('.right_nav').append("<li><a id='last_page' href='../html/help_usefunction.html?ord="+ hdata.ord1 +"'>上页</a></li>");
		}
		if(hdata.ord2+""!="" && hdata.ord2+""!="0"){
			$('.right_nav').append("<li><a id='next_page' href='../html/help_usefunction.html?ord="+ hdata.ord2 +"'>下页</a></li>");
		}
		if(hdata.cls2+""!="" && hdata.cls2+""!="0"){
			$('.right_nav').append("<li><a id='return_page' href='../html/help_colum.html?sort2="+ hdata.cls2 +"'>栏目首页</a></li>");
		}		

	}else{
		$('.addp_title').append("<span class='addpt_arrow'><img src='../img/addpt_arrow.png'></span>");
		if(hdata.clstxt1!=""){
			$('.addp_title').append("<span class='addpt_one' id='addptt_one'>"+ hdata.clstxt1 +"</span>");
		}
		var wcintro = $("#main_cont").html();
		if(wcintro.indexOf("href=\"help_usefunction.html?ord=")>-1){
			$("#main_cont div").find("a").each(function(){
				var href = $(this).attr("href");
				if(href.indexOf("help_usefunction.html?ord=")>-1 && href.indexOf("&ly=")==-1){
					$(this).attr("href",href+"&ly="+ly);
				}
			})
		}
	}
})
