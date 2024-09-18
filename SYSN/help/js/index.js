$(function(){
	//顶部选项
	$('.search_select').on('click',function(){
		if($('.select_option').css("display")=="none"){ 
			$('.select_option').slideDown("fast"); 
		}else{ 
			$('.select_option').slideUp("fast"); 
		} 
	})
	$('.select_option li').click(function(){ 
		var txt = $(this).text();
		$('.search_select span').html(txt);
	})
	
	//顶部搜索框
	$('.search_input input').focus(function () {
	    $(this).attr("fcs", "1");
		if($(this).val()=='请输入问题关键词'){
			$(this).val('');
		}
	})
	$('.search_input input').blur(function () {
	    $(this).attr("fcs", "0");
		if($('.search_input input').val()==''){
			$('.search_input input').val('请输入问题关键词');
		}
	})
	
	$('.search_btn').click(function(){
		var sectype = 0;
		if($('.search_select span').html()=="标题"){
			sectype = 1;
		}else{
			sectype = 2;
		}
		var seckey = "";
		if($('.search_input input').val()!=''&& $('.search_input input').val()!='请输入问题关键词'){
			seckey = escape($('.search_input input').val());
			window.location.href = ("../html/help_search.html?sectype="+ sectype +"&seckey="+ seckey);
		}else{
			alert("请输入搜索内容");
		}
	})

	function HandlePageKeyDownEvent(event) {
	    var target=event.target;
	    if (event.keyCode == 13) {
	        var isFocus = $('.search_input input').attr("fcs");
	        if (isFocus == "1") {
	            var sectype = 0;
	            if ($('.search_select span').html() == "标题") {
	                sectype = 1;
	            } else {
	                sectype = 2;
	            }
	            var seckey = "";
	            if ($('.search_input input').val() != '' && $('.search_input input').val() != '请输入问题关键词') {
	                seckey = escape($('.search_input input').val());
	                window.location.href = ("../html/help_search.html?sectype=" + sectype + "&seckey=" + seckey);
	            } else {
	                alert("请输入搜索内容");
	            }
	        }
	    }
	}
	$(document).unbind("keydown", HandlePageKeyDownEvent).bind("keydown", HandlePageKeyDownEvent);

	//我要留言
	$('.top_leavemes').on('mousemove',function(){
		$('.mess_logo').css('background-position','bottom center');
		$('.mess_title').css('color','#377cc9');
	})
	$('.top_leavemes').on('mouseout',function(){
		$('.mess_logo').css('background-position','top center');
		$('.mess_title').css('color','#8b8888');
    })
    //服务中心
    $('.top_service').on('mousemove', function () {
        $('.serv_logo').css('background-position', 'bottom center');
        $('.serv_title').css('color', '#377cc9');
    })
    $('.top_service').on('mouseout', function () {
        $('.serv_logo').css('background-position', 'top center');
        $('.serv_title').css('color', '#8b8888');
    })
    $('.top_service').click(function () {
        window.open("http://service.zbintel.com", "newwindow","height=800, width=1250, top=50, left=50,resizable=yes");
    })
	//兼容字段的显示
	var win_width=$(window).width();
	var maxwidth=0;
	if(win_width>900&&win_width<1000){
		maxwidth=16;
	}else if(win_width>1000&&win_width<1500){
		maxwidth=18;
	}else{
		maxwidth=20;
	}
	$(".con_view_cont a").each(function(){
		if($(this).text().length>maxwidth){
			$(this).text($(this).text().substring(0,maxwidth));
			$(this).html($(this).html()+"…");
		}
	});
	
	//返回顶部
	$(window).scroll(function(){
		var win_scroll = $(window).scrollTop();
		if(win_scroll>$(window).height()){
			$('.turn_top').show();
		}else{
			$('.turn_top').hide();
		}
	})
	$('.turn_top').click(function(){
		$('html,body').scrollTop(0);
	})
	
	//左侧导航
	var tree_len=treedata.length;
	for(var i=0;i<tree_len;i++){
		if(treedata[i].text.indexOf("移动")==-1 && treedata[i].text.indexOf("引导")==-1 && treedata[i].text.indexOf("工具")==-1 && treedata[i].text.indexOf("导航")==-1 ){
			$('.nav_list').append("<li><span></span>"+ treedata[i].text +"<ul class='nav_list_wrap' style='top:"+((i+1)*50+1)+"px;'></ul></li>");
			if(treedata[i].children.length!=0){
				var chil_len=treedata[i].children.length;
				for(var j=0;j<chil_len;j++){
					$('.nav_list').children('li').eq(i).find('.nav_list_wrap').append("<li><a href='../html/help_colum.html?sort2="+treedata[i].children[j].id+"'>"+ treedata[i].children[j].text +"</a></li>");
				}
			}
		}
	}
	$('.nav_list').append("<li id='syset'><span></span>系统信息</li>");
	$('#syset').click(function(){
		window.open("../../../SYSA/china2/help.system.asp");
	})
	//导航
	$('.nav_list li').on('mousemove',function(){
		$(this).children('span').eq(0).css('background-position','bottom center ');
	})
	$('.nav_list li').on('mouseout',function(){
		$(this).children('span').eq(0).css('background-position','top center ');
	})
	for(var i=0;i<tree_len;i++){
		$('.nav_list').children('li').eq(i).hover(function(){
			$(this).find('.nav_list_wrap').offsetHeight;
			$(this).find('.nav_list_wrap').css('display','block');
		},function(){
			$(this).find('.nav_list_wrap').css('display','none');
		})
	}
	
});
