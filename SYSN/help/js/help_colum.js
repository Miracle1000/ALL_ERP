window.onload=function(){
	var sort1 = 0;
	var sort1Text = "";
	var sort2Text = "";
	if(listIntro.sort1){sort1=listIntro.sort1;}
	if(listIntro.sort1Text){sort1Text=listIntro.sort1Text;}
	if(listIntro.sort2Text){sort2Text=listIntro.sort2Text;}
	if(sort1Text!=""){
	$('.addp_title').append("<span class='addpt_arrow'><img src='../img/addpt_arrow.png'></span>"+
		"<a href='../html/index.html'><span class='addpt_one'>"+ sort1Text +"</span></a>");
	}
	if(sort2Text!=""){
	$('.addp_title').append("<span class='addpt_arrow'><img src='../img/addpt_arrow.png'></span>"+
		"<span class='addpt_two'>"+ sort2Text +"</span>");
	}
	
	var list_len=listdata.length;
	
	for (var i=0;i<list_len;i++) {
		$('.r_content').append("<div class='addp_proma'><div class='addpp_title'>"+ listdata[i].text.replace('.','') +"</div><div class='addpp_line'></div><ul class='addpp_ull'></ul></div>");
		if(list_child=listdata[i].children!=0){
			var child_len=list_child=listdata[i].children.length;
			for(var j=0;j<child_len;j++){
				if(j%2==0){
					$('.r_content').children('.addp_proma').eq(i).find('.addpp_ull').append("<li class='ul_r'><a href='../html/help_usefunction.html?ord="+ listdata[i].children[j].id +"'>"+ listdata[i].children[j].text +"</a></li>");
				}else{
					$('.r_content').children('.addp_proma').eq(i).find('.addpp_ull').append("<li class='ul_l'><a href='../html/help_usefunction.html?ord="+ listdata[i].children[j].id +"'>"+ listdata[i].children[j].text +"</a></li>");
				}
			}
		}
		if(i==(list_len-1)){
			var offset_Top=$('.r_content').children('.addp_proma').eq(i).offset().top;
			var self_Height=$('.r_content').children('.addp_proma').eq(i).height();
			var offset_Height=parseInt(offset_Top+self_Height+400);
			$('.colum').css('height',offset_Height)
		}
	}
	//常用栏目
	window. _sum = listdata[0].children.length;
	window._len = 0;
	if(_sum>=6){for(var i=0;i<6;i++){
			$('.addpu_list').append("<li><a href='../html/help_usefunction.html?ord="+ listdata[0].children[i].id +"'>"+listdata[0].children[i].text+"</a></li>");
		}
	}else{
		for(var i=0;i<_sum;i++){
			$('.addpu_list').append("<li><a href='../html/help_usefunction.html?ord="+ listdata[0].children[i].id +"'>"+listdata[0].children[i].text+"</a></li>");
		}
		AddUseLi(1);
		if(_sum < 6){
			AddUseLi(2);
			if(_sum < 6){
				AddUseLi(3);
				if(_sum < 6){
					AddUseLi(4);
					if(_sum < 6){
						AddUseLi(5);
					}
				}
			}
		}
	}
	//遍历填充
	function AddUseLi(index){
		if(listdata[index]){
			if(listdata[index].children.length >= 6-_sum){
				_len = 6-_sum;
			}else{
				_len = listdata[index].children.length;
			}
			for(var i=0;i<_len;i++){
				$('.addpu_list').append("<li><a href='../html/help_usefunction.html?ord="+ listdata[index].children[i].id +"'>"+listdata[index].children[i].text+"</a></li>");
			}
			_sum+=listdata[index].children.length;
		}
	}
}
