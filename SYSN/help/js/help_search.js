$(function(){
	var len=listdata.length;
	var sum=0;
	for(var i=0;i<len;i++){
		sum+=listdata[i].children.length;
		for(var j=0;j<listdata[i].children.length;j++){
			$('.return_search').append("<li><a href='../html/help_usefunction.html?ly=search&ord="+ listdata[i].children[j].id +"'>"+ listdata[i].children[j].text +"</a></li>");
		}
	}
	if(sum<50){
		$('.search_notice').html("<a href='index.html'><返回首页</a>当前为您检索到"+ sum +"条信息");
	}else{
		$('.search_notice').html("<a href='index.html'><返回首页</a>由于为您检索出的信息条数过多 当前仅显示前50条数据");
	}
})
