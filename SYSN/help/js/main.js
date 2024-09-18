$(function(){
	//首页内容
	var list_len = 0;
	if(listdata.length){list_len=listdata.length;}
	for(var i=0;i<list_len;i++){
		$('.con_view').children('.con_viewcont').eq(i).find('dt a').attr("href","../html/help_content.html?one="+ i);
		$('.con_view').children('.con_viewcont').eq(i).find('.con_view_title').html("<a href='../html/help_content.html?one="+ i +"' title='"+ listdata[i].text +"'>"+ listdata[i].text +"</a>")
	}
})
