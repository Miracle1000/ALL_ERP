$(function(){
	var one_index=idFrom.indexOf("one=");
	var one_id=idFrom.substring(one_index+4);
	var list_len=listdata.length;
	$('.addpt_one').html(listdata[one_id].text);
	for(var i=0;i<listdata[one_id].children.length;i++){
		if(i==0){
			$('.addp_intro').append("<span class='intro_1'>"+ listdata[one_id].children[i].text +"</span>");
		}else{
			$('.addp_intro').append("<span class='intro_2'>"+ listdata[one_id].children[i].text +"</span>");
		}
	}
	
	var iframesrc=listdata[one_id].children[0].id;
	$('#iframe_src').attr("src","../html/help_iframecont.html?ord="+iframesrc);
	//常用页面选项卡
	for(var i=0;i<listdata[one_id].children.length;i++){
		(function(i){
			$('.addp_intro span').eq(i).click(function(){
				$('#iframe_src').css("height",0);
				var iframe_src=listdata[one_id].children[i].id;
				$('#iframe_src').attr("src","../html/help_iframecont.html?ord="+iframe_src);
				$(this).css('border-bottom','5px solid #377CC9');
				$(this).siblings().css('border-bottom','none');
			})
		})(i)
	}
})
